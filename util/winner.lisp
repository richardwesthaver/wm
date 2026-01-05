;;; winner.lisp --- Window Dumper

;; Based on StumpWM winner-mode

;;; Code:
(in-package #:wm/winner-mode)

(defvar *current-ids* (make-hash-table))
(defvar *max-ids* (make-hash-table))
(defvar *tmp-folder* #p"/tmp/")
(defvar *default-commands*
  '(wm:only
    wm:pull-from-windowlist
    wm:pull-hidden-next
    wm:pull-hidden-other
    wm:pull-hidden-previous
    wm:pull-marked
    wm:pull-window-by-number
    wm:next-window
    wm:next-in-frame
    wm:next-urgent
    wm:prev-window
    wm:prev-in-frame
    wm:select-window
    wm:select-from-menu
    wm:select-window-by-name
    wm:select-window-by-number
    wm::pull
    wm::remove
    wm:iresize
    wm:vsplit
    wm:hsplit
    wm:move-window
    wm:move-windows-to-group
    wm:move-window-to-group
    wm:balance-frames
    wm::delete
    wm::kill
    wm:fullscreen))

(defmacro check-ids (group-number &body ids)
  `(progn
     ,@(loop for id in ids
          collect `(unless (gethash ,group-number ,id)
                     (setf (gethash ,group-number ,id) 0)))))

(defun current-group-number ()
  (slot-value (wm:current-group) 'number))

(defun dump-name (group-number id)
  (merge-pathnames
   (pathname (format nil "wm-winner-mode-~d-~10,'0d" group-number id))
   *tmp-folder*))

(defun dump-group-to-file (&rest args)
  (declare (ignore args))
  (let* ((group-number (current-group-number)))
    (check-ids group-number *current-ids* *max-ids*)
    (wm::dump-to-file (wm::dump-group (wm:current-group))
     (dump-name group-number (incf (gethash group-number *current-ids*))))
    (when (> (gethash group-number *current-ids*)
             (gethash group-number *max-ids*))
      (setf (gethash group-number *max-ids*)
            (gethash group-number *current-ids*)))))

(wm:defcommand winner-undo () ()
                    "Go back to the last frame setup"
                    (let* ((group-number (current-group-number)))
                      (check-ids group-number *current-ids*)
                      (if (> (gethash group-number *current-ids*) 1)
                          (wm:restore-from-file
                           (dump-name
                            group-number
                            (decf (gethash group-number *current-ids*))))
                          (error "No previous frame setup"))))

(wm:defcommand winner-redo () ()
                    "Go forward to the next frame setup"
                    (let* ((group-number (current-group-number)))
                      (check-ids group-number *current-ids* *max-ids*)
                      (if (= (gethash group-number *max-ids*) (gethash group-number *current-ids*))
                          (error "No next frame setup")
                          (wm:restore-from-file
                           (dump-name
                            group-number
                            (incf (gethash group-number *current-ids*)))))))

(wm:add-wm-hook wm:*quit-hook* (lambda ()
                                      (mapcar #'delete-file
                                              (directory (merge-pathnames
                                                          #p"wm-winner-mode-*"
                                                          *tmp-folder*)))))
