;;; iresize.lisp --- Interactive Resize Command

;; Copyright (C) 2003-2008 Shawn Betts

;;; Commentary:

;; A resize minor mode. Something a bit better should probably be written. But
;; it's an interesting way of doing it.

;;; Code:
(in-package #:wm)

(defvar *resize-increment* 10
  "Number of pixels to increment by when interactively resizing frames.")

(defun set-resize-increment (val)
  (setf *resize-increment* val))

(defun single-frame-p ()
  "Checks if there's only one frame."
  (let ((frame (tile-group-current-frame (current-group))))
    (atom (tile-group-frame-head (current-group)
                                 (frame-head (current-group)
                                             frame)))))

(defun abort-resize-p ()
  "Resize is only available if there's more than one frame."
  (when (single-frame-p)
    (wm-message "There's only 1 frame!")
    t))

(defun setup-iresize ()
  "Start the interactive resize mode."
  (when *resize-hides-windows*
    (dolist (f (head-frames (current-group) (current-head)))
      (clear-frame f (current-group))))
  (draw-frame-outlines (current-group) (current-head)))

(defcommand (:wm resize-direction) (d)
  "Resize frame to direction D"
  (declare (interactive (direction "Direction: ")))
  (case (princ d)
    ((:up) (resize 0 (- *resize-increment*)))
    ((:down) (resize 0 *resize-increment*))
    ((:left) (resize (- *resize-increment*) 0))
    ((:right) (resize *resize-increment* 0))))

(defun resize-unhide ()
  (clear-frame-outlines (current-group))
  (when *resize-hides-windows*
    (let ((group (current-group))
          (head (current-head)))
      (dolist (f (head-frames group head))
        (sync-frame-windows group f))
      (dolist (w (reverse (head-windows group head)))
        (setf (frame-window (window-frame w)) w)
        (raise-window w))
      (when (current-window)
        (focus-window (current-window))))))

(setq *command-class* 'wm-tile-command)

(define-interactive-keymap (:wm iresize) (:on-enter #'setup-iresize
                                          :on-exit #'resize-unhide
                                          :abort-if #'abort-resize-p)

  ((kbd "Up") "resize-direction up")
  ((kbd "C-p") "resize-direction up")
  ((kbd "p") "resize-direction up")
  ((kbd "k") "resize-direction up")

  ((kbd "Down") "resize-direction down")
  ((kbd "C-n") "resize-direction down")
  ((kbd "n") "resize-direction down")
  ((kbd "j") "resize-direction down")

  ((kbd "Left") "resize-direction left")
  ((kbd "C-b") "resize-direction left")
  ((kbd "b") "resize-direction left")
  ((kbd "h") "resize-direction left")

  ((kbd "Right") "resize-direction right")
  ((kbd "C-f") "resize-direction right")
  ((kbd "f") "resize-direction right")
  ((kbd "l") "resize-direction right"))

(setq *command-class* 'wm-command)
