;;;; kbd-layouts.lisp

(in-package #:swm/kbd-layouts)

;;; Variables
(defvar *available-keyboard-layouts* '#1=("us" . #1#))
(defvar *keyboard-layout* "us")

(declaim ((or boolean (member :ctrl :swapped)) *caps-lock-behavior*))
(defvar *caps-lock-behavior* nil)

;; Custom option string appended to setxkbmap
(defvar *custom-setxkb-options* nil)

;; Run xmodmap ~/.Xmodmap each time layouts are switched
(defvar *run-xmodmap* t)

;;; Helper functions
(defun current-keyboard-layout (ml)
  "Return current keyboard layout"
  (declare (ignore ml))
  (let ((cmd "setxkbmap -print | awk -F'+' '/xkb_symbols/ {print $2}'"))
    (string-trim '(#\Newline) (run-shell-command cmd t))))

;; Make the current keyboard layout accessible from the modeline via %L.
(add-screen-mode-line-formatter #\L #'current-keyboard-layout)

;;; Commands
(defcommand switch-keyboard-layout () ()
  "Perform the actual layout switching."
  (let* ((layout *keyboard-layout*)
         (caps (ecase *caps-lock-behavior*
                 (t "caps:capslock")
                 (:ctrl "ctrl:nocaps")
                 (:swapped "ctrl:swapcaps")
                 (nil nil)))
         (cmd (format nil "setxkbmap ~a~@[ -option ~a~]~@[ ~a~]" layout caps *custom-setxkb-options*)))
    (run-shell-command cmd nil)
    (when *run-xmodmap*
      (run-shell-command "xmodmap ~/.Xmodmap"))
    (swm-message (format nil "Keyboard layout switched to: ~a" layout))))
