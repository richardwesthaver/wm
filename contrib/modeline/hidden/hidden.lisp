;;;; hidden.lisp

(in-package #:swm/modeline)
;;; "hidden" goes here. Hacks and glory await!

;;; Hidden window formatter for the mode-line
;;;
;;; Copyright 2021 Woodrow Douglass 
;;;
;;; Maintainer: Woodrow Douglass
;;;

;; Install formatters.
(add-screen-mode-line-formatter #\H 'hidden-modeline)

(defun hidden-modeline (ml)
  (declare (ignore ml))
  (handler-case
      (progn
	(if (typep (wm::current-group) 'wm::tile-group)
	(let ((x (list-length (wm::frame-windows (current-group) (wm::current-frame)))))
    	  (if (>= x 1)
    	      (format NIL "(~A Hidden)" (- x 1))
    	      "(0 Hidden)"))
            ""))
    (t (c) (format nil "ERROR: ~A" c))))
