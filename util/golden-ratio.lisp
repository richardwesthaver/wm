(in-package #:wm/golden-ratio)

(defvar *golden-ratio* 0.6180)
(defparameter *golden-ratio-on* nil)

(defun target-px (size-px)
  (floor (*  size-px *golden-ratio*)))

(defun resize-px (target current-px)
  (- target current-px))

(defun resize-to-golden-ratio (to-frame from-frame)
  (declare (ignore from-frame))
  (when (and *golden-ratio-on* (not (wm::single-frame-p)))
    (let* ((target-x (target-px (wm::head-width (current-head))))
           (target-y (target-px (wm::head-height (current-head)))))
      (setq *golden-ratio-on* nil)
      (wm::balance-frames)
      (wm::resize (resize-px target-x
                             (wm::frame-width to-frame))
                  (resize-px target-y
                             (wm::frame-height to-frame)))
      (setq *golden-ratio-on* t))))

(defcommand toggle-golden-ratio ()
  "Toggle golden ratio"
  (setf *golden-ratio-on* (null *golden-ratio-on*)))

;; (add-wm-hook *focus-frame-hook* 'resize-to-golden-ratio)
