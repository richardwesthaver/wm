;;; debug.lisp --- WM Debugging

;; Copyright (C) 2003-2008 Shawn Betts

;;; Commentary:

;; This file contains the code for debugging stumpwm.

;;; Code:
(in-package #:wm)

(defvar *debug-stream* (make-synonym-stream '*error-output*)
  "This is the stream debugging output is sent to. It defaults to
*error-output*. It may be more convenient for you to pipe debugging
output directly to a file.")

;; levels from stumpwm = 1-5,7[1],10
(defun dformat (ilevel fmt &rest args)
  (let ((lvls #.(1- (length *log-levels*)))
        (level (+ ilevel 2))) ;; always force the range to (:WARN[0] :INFO :DEBUG :TRACE)
    (log-message (svref *log-levels* (if (> level lvls) lvls level)) `(:wm ,ilevel)
                 (apply 'aformat nil fmt args))))

(defvar *redirect-stream* nil
  "This variable keeps track of the stream all output is sent to when
`redirect-all-output' is called so if it changes we can close it
before reopening.")

(defun redirect-all-output (file)
  "Elect to redirect all output to the specified file. For instance,
if you want everything to go to ~/.data/wm/debug-output.txt you would do:

(redirect-all-output (data-dir-file \"debug-output\" \"txt\"))"
  (when (typep *redirect-stream* 'file-stream)
    (close *redirect-stream*))
  (setf *redirect-stream* (open file :direction :output :if-exists :append :if-does-not-exist :create)
        *error-output*    *redirect-stream*
        *standard-output* *redirect-stream*
        *trace-output*    *redirect-stream*
        *debug-stream*    *redirect-stream*))
