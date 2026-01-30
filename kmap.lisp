;;; kmap.lisp --- WM Keymaps

;; Copyright (C) 2003-2008 Shawn Betts

;; WM-specific keymaps

;;; Commentary:

;; This file handles keymaps for the WM, which encapsulates all
;; user-configurable keys.

;;; Code:
(in-package :wm)

(defvar *top-map* nil
  "The top level key map. This is where you'll find the binding for the
prefix map.")

(defvar *root-map* nil
  "This is the keymap by default bound to C-t (along with
 *group-root-map* and either *tile-group-root-map*, *float-group-root-map*,
 or *dynamic-group-map*). It is known as the prefix map.")

(defvar *key-seq-color* "^5"
  "Color of a keybinding when displayed in windows such as the prefix
keybinding in the which-key window.")

(defun x11-mods (key &optional with-capslock with-scroll-lock)
  "Return the modifiers for key in a format that xlib understands. If
WITH-CAPSLOCK is non-nil then include the capslock modifier. Most of the time
these just gets in the way."
  (let (mods)
    (when (key-shift key) (push :shift mods))
    (when (key-control key) (push :control mods))
    (when (or (key-meta key) (key-alt key)) (push :mod-1 mods))
    (when (key-altgr key) (push :mod-5 mods))
    (when (or (key-hyper key) (key-super key)) (push :mod-4 mods))
    (when (key-numlock key) (push :mod-2 mods))
    (when with-capslock (push :lock mods))
    (when with-scroll-lock (push :mod-3 mods))
    (apply 'xlib:make-state-mask mods)))

(defvar *altgr-offset* 2
  "The offset of altgr keysyms. Often 2 or 4, but always an even number.")

(defun keysym-requires-altgr (keysym)
  (when *display*
    (unless (and (xlib:keycodes-from-keysym *display* keysym) t)
      (let* ((min (xlib:display-min-keycode *display*))
             (max (xlib:display-max-keycode *display*))
             (map (xlib::display-keyboard-mapping *display*))
             (size (array-dimension map 1)))
        (when (> *altgr-offset* size)
          (error "AltGr offset is larger than the available offsets"))
        (do ((i min (1+ i)))
            ((> i max) nil)
          (when (or (= keysym (aref map i *altgr-offset*))
                    (= keysym (aref map i (1+ *altgr-offset*))))
            (return-from keysym-requires-altgr t)))))))

(defun parse-wm-key (string)
  (let ((key (parse-key string)))
    (if (keysym-requires-altgr (key-sym key))
        (altgr-key key)
        key)))

(defun parse-wm-key-seq (keys)
  "KEYS is a key sequence. Parse it and return the list of keys."
  (mapcar 'parse-wm-key (split-whitespace keys)))

(defun %sync-top-map (map)
  ;; TODO 2026-01-25: should probably be equiv?
  (when (eq map *top-map*)
    (sync-keys)))

;; We need to tell the X server when changing the top-map bindings.
(add-hook *keymap-hook* '%sync-top-map :name :define)

;;; The Top Map
;; TODO 2026-01-25: async-aware queue
(defvar *top-map-queue* nil)

(defun push-top-map (new-top)
  (push *top-map* *top-map-queue*)
  (setf *top-map* new-top)
  (sync-keys))

(defun pop-top-map ()
  (when *top-map-queue*
    (setf *top-map* (pop *top-map-queue*))
    (sync-keys)
    t))
