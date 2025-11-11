(in-package #:wm/clipboard-history)

(defmacro push-max-stack (stack val max-depth)
  `(setq ,stack
         (cons ,val
               (if (<= ,max-depth (length ,stack))
                   (subseq ,stack 0 (1- ,max-depth))
                   ,stack))))

(defun string-maxlen (s maxlen)
  (let ((s1 (subseq s 0 (min maxlen (length s)))))
    (if (string-equal s1 s)
        s1
        (wm:concat s1 " ..."))))

(defun poll-selection (&optional (selection :primary))
  (xlib:convert-selection selection
                          :utf8_string
                          (wm::screen-input-window
                            (wm:current-screen))
                          :wm-selection))

;; (poll-selection)
(defun poll-clipboard-selection ()
  (poll-selection :clipboard))

(defun basic-get-x-selection (&optional (selection :clipboard))
  (getf wm:*x-selection* selection))

;; (basic-get-x-selection)
(defvar *clipboard-history* nil)
(defparameter *clipboard-history-max-length* 32)

(defun save-clipboard-history (sel)
  (when (and (stringp sel)
             (not (zerop (length sel)))
             (not (member sel *clipboard-history* :test 'string-equal)))
    (push-max-stack *clipboard-history* sel *clipboard-history-max-length*)))

(wm:add-wm-hook wm:*selection-notify-hook* 'wm/clipboard-history::save-clipboard-history)

(wm:defcommand show-clipboard-history () ()
  "Select from previously saved selections"
  (if (null *clipboard-history*)
      (wm::message "No selection history")
      (let ((sel (second
                  (wm:select-from-menu
                   (wm:current-screen)
                   (mapcar (lambda (s)
                             (list (wm::escape-caret (string-maxlen s 32)) s))
                           *clipboard-history*)
                   nil))))
        (when sel
          (wm:set-x-selection sel :clipboard)))))

(defvar *clipboard-timer* nil)

(defun stop-clipboard-manager ()
  (when (wm:timer-p *clipboard-timer*)
    (wm:cancel-timer *clipboard-timer*)
    (setq *clipboard-timer* nil)))

;; (stop-clipboard-manager)
(defvar *clipboard-poll-timeout* 5)

(defun start-clipboard-manager ()
  (stop-clipboard-manager)
  (setf *clipboard-timer*
        (wm:run-with-timer (- *clipboard-poll-timeout*
                                   (mod (get-decoded-time) *clipboard-poll-timeout*))
                                *clipboard-poll-timeout*
                                'poll-clipboard-selection)))

;; (start-clipboard-manager)
(wm:defcommand clear-clipboard-history () ()
  "Clear saved selections"
  (setf *clipboard-history* nil))
