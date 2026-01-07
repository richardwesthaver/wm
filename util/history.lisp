;;; history.lisp --- WM Command History
(in-package #:wm/history)

(defvar *command-history-file* "history")

(defun load-input-history ()
  "Load *input-history* to file."
  (with-open-file (in *command-history-file* :if-does-not-exist nil)
    (when in
      (with-standard-io-syntax
        (setf wm::*input-history* (std:read-lisp-file in))))))

(defun save-input-history ()
  "Save current *input-history* to file."
  (with-open-file (out (std:xdg-data-dir :wm *command-history-file*)
                       :direction :output
                       :if-does-not-exist :create
                       :if-exists :supersede)
    (with-standard-io-syntax
      (loop for c in #1=(remove-duplicates wm::*input-history* :test #'string= :from-end t)
            unless (null c)
            do (print c out)
            finally (return #1#)))))

(add-wm-hook wm:*start-hook* 'load-input-history)

(add-wm-hook wm:*quit-hook* 'save-input-history)
