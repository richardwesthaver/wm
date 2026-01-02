;; hostname.lisp

;; Put %h in your modeline format string to show your hostname
(in-package #:wm/modeline)

(defun fmt-hostname (ml)
  "Return hostname"
  (declare (ignore ml))
  (format nil "~a" (list (machine-instance) (machine-type) (lisp-implementation-type))))

;; Install formatter
(add-screen-mode-line-formatter #\h #'fmt-hostname)
