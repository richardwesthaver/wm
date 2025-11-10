(in-package #:swm/perwindowlayout)

(defparameter *emacs-toggle-input-method-key* "C-\\"
  "Emacs keybinding being used to toggle its internal keyboard layout (input method)")

(defun get-current-layout (display)
  (xlib/xkb:device-state-locked-group (xlib/xkb:get-state display)))

(defun window-focus-changed (window previous-window)
  (declare (ignore previous-window))
  (when window
    (let ((window-layout (getf (xlib:window-plist (window-xwin window)) :keyboard-layout)))
      (if window-layout
          (xlib/xkb:lock-group *display* :group window-layout)
          (xlib/xkb:lock-group *display* :group 0)))))

(defun group-focus-changed (group previous-group)
  (let ((previous-window (group-current-window previous-group))
        (window (group-current-window group)))
    (window-focus-changed window previous-window)))

(defcommand enable-per-window-layout () ()
  "Enable layout switching"
  (xlib::initialize-extensions *display*) ;; we need it because
  (xlib/xkb:enable-xkeyboard *display*) ;; stumpwm opens display before extension definition
  (add-hook *focus-group-hook* 'group-focus-changed)
  (add-hook *focus-window-hook* 'window-focus-changed))

(defcommand disable-per-window-layout () ()
  "Disable layout switching"
  (remove-hook *focus-window-hook* 'window-focus-changed)
  (remove-hook *focus-group-hook* 'group-focus-changed))

(defun toggle-window-layout ()
  (let ((cur-window (current-window)))
    (when cur-window
      (let ((current-window-class (window-class cur-window)))
        (if (string= current-window-class "Emacs")
            (meta (kbd *emacs-toggle-input-method-key*))
            (let* ((current-layout (get-current-layout *display*))
                   (toggled-layout (logxor 1 current-layout)))
              (xlib/xkb:lock-group *display* :group toggled-layout)
              (setf (getf (xlib:window-plist (window-xwin cur-window))
                          :keyboard-layout) toggled-layout)))))))

(defcommand switch-window-layout () ()
  "Switches keyboard layout for current window"
  (toggle-window-layout))
