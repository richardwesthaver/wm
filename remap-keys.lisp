;;; remap-keys.lisp --- Simple WM Remapping

;; Copyright (C) 2018 Ram Krishnan

;;; Commentary:

;; Provides a simple way to remap keybindings in applications running under WM.

;;; Code:
(in-package #:wm)

(defvar *remap-keys-window-match-list* nil)

(defvar *remapped-keys-enabled-p* t
  "Bool to toggle remapped-keys on/off. Defaults to t ")

(defun find-remap-keys-by-window (window)
  (first
   (member-if (lambda (pattern)
                (cond
                  ((stringp pattern)
                   (string-match (window-class window) pattern))

                  ((or (symbolp pattern) (functionp pattern))
                   (funcall pattern window))))
              *remap-keys-window-match-list*
              :key 'car)))

(defun make-remap-keys (kmap)
  (labels ((as-list (x) (if (consp x) x (list x)))
           (validated-kbd (key)
             (or (kbd key)
                 (throw 'cmd
                   (format nil "Invalid keyspec: ~S" key)))))
    (mapcar (lambda (kspec)
              (let ((src-key (car kspec))
                    (target-keyseq (as-list (cdr kspec))))
                (cons src-key
                      (mapcar #'validated-kbd target-keyseq))))
            kmap)))

(defun remap-keys-grab-keys (win)
  (let* ((keymap (cdr (find-remap-keys-by-window win)))
         (src-keys (mapcar 'car keymap)))
    (dolist (key src-keys)
      (xwin-grab-key (window-xwin win) (kbd key)))))

(defun remap-keys-focus-window-hook (new-focus cur-focus)
  (declare (ignorable cur-focus))
  (when new-focus
    (remap-keys-grab-keys new-focus)))

(defun remap-keys-event-handler (code state)
  (let* ((raw-key (code-state->key code state))
         (window (current-window))
         (keymap (when window
                   (cdr (find-remap-keys-by-window window))))
         (keys (cdr (assoc (print-key raw-key) keymap :test 'equal))))
    (when keys
      (dolist (key keys)
        (send-fake-key window (if *remapped-keys-enabled-p*
                                  key
                                  raw-key)))
      t)))

(defun define-remapped-keys (specs)
  "Define the keys to be remapped and their mappings. The SPECS
argument needs to be of the following structure:

  (regexp-or-function . ((\"key-to-remap\" . <new-keycodes>) ...))

EXAMPLE:
  (define-remapped-keys
    '((\"Firefox\"
       (\"C-n\"   . \"Down\")
       (\"C-p\"   . \"Up\")
       (\"C-k\"   . (\"C-S-End\" \"C-x\")))))

  The above form remaps Ctrl-n to Down arrow, and Ctrl-p to Up arrow
  keys. The Ctrl-k key is remapped to the sequence of keys
  Ctrl-Shift-End followed by Ctrl-x."
  (setq *custom-key-event-handler* nil
        *remap-keys-window-match-list*
        (mapcar (lambda (spec)
                  (let ((pattern (car spec))
                        (kmap (cdr spec)))
                    (cons pattern (make-remap-keys kmap))))
                specs))
  (when *remap-keys-window-match-list*
    (add-wm-hook *focus-window-hook* 'remap-keys-focus-window-hook)
    (setq *custom-key-event-handler* 'remap-keys-event-handler)))

(defcommand send-raw-key () ()
  "Prompts for a key and forwards it to the CURRENT-WINDOW."
  (wm-message "Press a key to send: ")
  (let* ((screen (current-screen))
         (win (screen-current-window screen))
         (k (with-focus (screen-key-window screen)
              (read-key-no-modifiers)))
         (code (car k))
         (state (cdr k)))
    (unmap-message-window screen)
    (when win
      (let ((xwin (window-xwin win)))
        (dolist (event '(:key-press :key-release))
          (xlib:send-event xwin
                           event
                           (xlib:make-event-mask event)
                           :display *display*
                           :root (screen-root screen)
                           ;; Apparently we need these in here, though they
                           ;; make no sense for a key event.
                           :x 0 :y 0 :root-x 0 :root-y 0
                           :window xwin
                           :event-window xwin
                           :code code
                           :state state))))))
