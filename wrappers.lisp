;;; wrappers.lisp --- WM Portability Wrappers

;; Copyright (C) 2003-2008 Shawn Betts

;;; Commentary:

;; TODO 2026-01-06: delete this file - this ain't Kansas anymore

;; portability wrappers. Any code that must run different code for different
;; lisps should be wrapped up in a function and put here.

;;; Code:
(in-package #:wm)

(defun screen-display-string (screen &optional (assign t))
  (format nil
          (if assign "DISPLAY=~a:~d.~d" "~a:~d.~d")
          (screen-host screen)
          (xlib:display-display *display*)
          (screen-id screen)))

(defun run-prog (prog &rest opts &key args output (wait t) &allow-other-keys)
  "Common interface to shell. Does not return anything useful."
  (remf opts :args)
  (remf opts :output)
  (remf opts :wait)
  (let ((env (sb-ext:posix-environ)))
    (when (current-screen)
      (setf env (cons (screen-display-string (current-screen) t)
                      (remove-if (lambda (str)
                                   (string= "DISPLAY=" str
                                            :end2 (min 8 (length str))))
                                 env))))
    (apply #'sb-ext:run-program prog args :output (if output output t)
           :error t :wait wait :environment env opts)))

(defun run-prog-collect-output (prog &rest args)
  "run a command and read its output."
  (with-output-to-string (s)
    (run-prog prog :args args :output s :wait t)))

(defun utf8-to-string (octets)
  "Convert the list of octets to a string."
  (let ((octets (coerce octets '(vector (unsigned-byte 8)))))
    (handler-bind
        ((sb-impl::octet-decoding-error #'(lambda (c)
                                            (declare (ignore c))
                                            (invoke-restart 'use-value (string #\replacement_character)))))
      (sb-ext:octets-to-string octets :external-format :utf-8))))

;;; On GNU/Linux some contribs use sysfs to figure out useful info for
;;; the user. SBCL upto at least 1.0.16 (but probably much later) has
;;; a problem handling files in sysfs caused by SBCL's slightly
;;; unusual handling of files in general and Linux' sysfs violating
;;; POSIX. When this situation is resolved, this function may be removed.
(defun read-line-from-sysfs (stream &optional (blocksize 80))
  "READ-LINE, but with a workaround for a known SBCL/Linux bug
regarding files in sysfs. Data is read in chunks of BLOCKSIZE bytes."
  (let ((buf (make-array blocksize
                         :element-type '(unsigned-byte 8)
                         :initial-element 0))
        (fd (sb-sys:fd-stream-fd stream))
        (string-filled 0)
        (string (make-string blocksize))
        bytes-read
        pos
        (stringlen blocksize))
    (loop
       ;; Read in the raw bytes
       (setf bytes-read
             (sb-unix:unix-read fd (sb-sys:vector-sap buf) blocksize))
       ;; Why does SBCL return NIL when an error occurs?
       (when (or (null bytes-read)
                 (< bytes-read 0))
         (error "UNIX-READ failed."))
       ;; This is # bytes both read and in the correct line.
       (setf pos (or (position (char-code #\Newline) buf) bytes-read))
       ;; Resize the string if necessary.
       (when (> (+ pos string-filled) stringlen)
         (setf stringlen (max (+ pos string-filled)
                              (* 2 stringlen)))
   (let ((new (make-string stringlen)))
     (replace new string)
     (setq string new)))
       ;; Translate read bytes to string
       (setf (subseq string string-filled)
             (sb-ext:octets-to-string (subseq buf 0 pos)))
       (incf string-filled pos)
       (if (< pos blocksize)
         (return (subseq string 0 string-filled))))))
