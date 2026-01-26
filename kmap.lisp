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

(defstruct key
  keysym shift control meta alt hyper super altgr)

(defstruct kmap
  bindings)

(defstruct binding
  key command)

(defun make-sparse-keymap ()
  "Create an empty keymap. If you want to create a new list of bindings
in the key binding tree, this is where you start. To hang frame
related bindings off 'C-t C-f' one might use the following code:

Example:

(defvar *my-frame-bindings*
  (let ((m (wm:make-sparse-keymap)))
    (wm:define-key m (wm:kbd \"f\") \"curframe\")
    (wm:define-key m (wm:kbd \"M-b\") \"move-focus left\")
    m ; NOTE: this is important
  ))

(wm:define-key wm:*root-map* (wm:kbd \"C-f\") '*my-frame-bindings*)"
  (make-kmap))

(defun lookup-command (keymap command)
  "Return a list of keys that are bound to command"
  (loop for i in (kmap-bindings keymap)
     when (equal command (binding-command i))
     collect (binding-key i)))

(defun lookup-key (keymap key &optional accept-default)
  (labels ((retcmd (key)
             (when key (binding-command key))))
    (or (retcmd (find key (kmap-bindings keymap) :key 'binding-key :test 'equalp))
        (and accept-default
             (retcmd (find t (kmap-bindings keymap) :key 'binding-key))))))

(defun key-mods-p (key)
  (or (key-shift key)
      (key-control key)
      (key-meta key)
      (key-alt key)
      (key-hyper key)
      (key-super key)))

(defun x11-mods (key &optional with-numlock with-capslock)
  "Return the modifiers for key in a format that xlib understands. if
WITH-NUMLOCK is non-nil then include the numlock modifier. if WITH-CAPSLOCK is
non-nil then include the capslock modifier. Most of the time these just gets
in the way."
  (let (mods)
    (when (key-shift key) (push :shift mods))
    (when (key-control key) (push :control mods))
    (when (key-meta key) (setf mods (append (modifiers-meta *modifiers*) mods)))
    (when (key-alt key) (setf mods (append (modifiers-alt *modifiers*) mods)))
    (when (key-hyper key) (setf mods (append (modifiers-hyper *modifiers*) mods)))
    (when (key-super key) (setf mods (append (modifiers-super *modifiers*) mods)))
    (when with-numlock (setf mods (append (modifiers-numlock *modifiers*) mods)))
    (when with-capslock (push :lock mods))
    (apply 'xlib:make-state-mask mods)))

(defun report-kbd-parse-error (c stream)
  (format stream "Failed to parse key string: ~s" (slot-value c 'string))
  (when-let ((reason (kbd-parse-error-reason c)))
    (format stream "~%Reason: ~A" reason)))

(define-condition kbd-parse-error (wm-error)
  ((string :initarg :string)
   (reason :initarg :reason :reader kbd-parse-error-reason
	   :initform nil))
  (:report report-kbd-parse-error)
  (:documentation "Raised when a kbd string failed to parse."))

(defun parse-mods (mods end)
  "MODS is a sequence of <MOD CHAR> #\- pairs. Return a list suitable
for passing as the last argument to (apply #'make-key ...)"
  (unless (evenp end)
    (error 'kbd-parse-error :string mods
           :reason "Did you forget to separate modifier characters with '-'?"))
  (loop for i from 0 below end by 2
        when (char/= (char mods (1+ i)) #\-)
          do (error 'kbd-parse-error :string mods)
        nconc (case (char mods i)
                (#\M (list :meta t))
                (#\A (list :alt t))
                (#\C (list :control t))
                (#\H (list :hyper t))
                (#\s (list :super t))
                (#\S (list :shift t))
                (t (error 'kbd-parse-error :string mods
                          :reason (format nil "Unknown modifer character ~A" (char mods i)))))))

(defvar *altgr-offset* 2
  "The offset of altgr keysyms. Often 2 or 4, but always an even number.")

(defun keysym-requires-altgr (keysym)
  (when *display*
    (unless (and (xlib:keysym->keycodes *display* keysym) t)
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

(defun parse-key (string)
  "Parse STRING and return a key structure. Raise an error of type
kbd-parse if the key failed to parse."
  (let* ((p (when (> (length string) 2)
              (position #\- string :from-end t :end (- (length string) 1))))
         (%mods (parse-mods string (if p (1+ p) 0)))
         (keysym (keysym-from-name (subseq string (if p (1+ p) 0))))
         (mods (if (keysym-requires-altgr keysym)
                   (append '(:altgr t) %mods)
                   %mods)))
    (if keysym
        (apply 'make-key :keysym keysym mods)
        (error 'kbd-parse-error :string string))))

(defun parse-key-seq (keys)
  "KEYS is a key sequence. Parse it and return the list of keys."
  (mapcar 'parse-key (split-string keys)))

(defun kbd (keys)
  "This compiles a key string into a key structure used by
`define-key', `set-prefix-key' and others."
  ;; XXX: define-key needs to be fixed to handle a list of keys
  (first (parse-key-seq keys)))

(defun copy-key-into (from to)
  "copy the contents of TO into FROM."
  (setf (key-keysym to) (key-keysym from)
        (key-shift to) (key-shift from)
        (key-control to) (key-control from)
        (key-meta to) (key-meta from)
        (key-alt to) (key-alt from)
        (key-hyper to) (key-hyper from)
        (key-super to) (key-super from)))

(defun print-mods (key)
  (concatenate 'string
               (when (key-control key) "C-")
               (when (key-meta key) "M-")
               (when (key-alt key) "A-")
               (when (key-shift key) "S-")
               (when (key-super key) "s-")
               (when (key-hyper key) "H-")))

(defun print-key (key)
  (format nil "~a~a"
          (print-mods key)
          (name-from-keysym (key-keysym key))))

(defun print-key-seq (seq)
  (format nil
          (concat *key-seq-color* "*~{~a~^ ~}^n")
          (mapcar 'print-key seq)))

(defun define-key (map key command)
  "Add a keybinding mapping for the key, KEY to the command,
COMMAND, in the specified keymap. If COMMAND is nil, remove an
existing binding. For example,

Example:

(wm:define-key wm:*root-map* (wm:kbd \"C-z\") \"echo Zzzzz...\")

Now when you type C-t C-z, you'll see the text ``Zzzzz...'' pop up."
  (declare (type kmap map) (type (or key (eql t)) key))
  (let ((binding (find key (kmap-bindings map) :key 'binding-key :test 'equalp)))
  (if command
      (setf (kmap-bindings map)
            (append (if binding
                        (delete binding (kmap-bindings map))
                        (kmap-bindings map))
                    (list (make-binding :key key :command command))))
      (setf (kmap-bindings map) (delete binding (kmap-bindings map))))
    ;; TODO 2026-01-25: replace with hook
    ;; We need to tell the X server when changing the top-map bindings.
    (when (eq map *top-map*)
      (sync-keys))))

(defun lookup-key-sequence (kmap key-seq)
  "Return the command bound to the key sequenc, KEY-SEQ, in keymap KMAP."
  (when (kmap-symbol-p kmap)
    (setf kmap (symbol-value kmap)))
  (check-type kmap kmap)
  (let* ((key (car key-seq))
         (cmd (lookup-key kmap key)))
    (cond ((null (cdr key-seq))
           cmd)
          (cmd
           (if (kmap-or-kmap-symbol-p cmd)
               (lookup-key-sequence cmd (cdr key-seq))
               cmd))
          (t nil))))

(defun kmap-symbol-p (x)
  (and (symbolp x)
       (boundp x)
       (kmap-p (symbol-value x))))

(defun kmap-or-kmap-symbol-p (x)
  (or (kmap-p x)
      (kmap-symbol-p x)))

(defun dereference-kmaps (kmaps)
  (mapcar (lambda (m)
            (if (kmap-symbol-p m)
                (symbol-value m)
                m))
          kmaps))

(defun search-kmap (command keymap &key (test 'equal))
  "Search the keymap for the specified binding. Return the key
sequences that run binding."
  (labels ((search-it (cmd kmap key-seq)
             (when (kmap-symbol-p kmap)
               (setf kmap (symbol-value kmap)))
             (check-type kmap kmap)
             (loop for i in (kmap-bindings kmap)
                if (funcall test (binding-command i) cmd)
                collect (cons (binding-key i) key-seq)
                else if (kmap-or-kmap-symbol-p (binding-command i))
                append (search-it cmd (binding-command i) (cons (binding-key i) key-seq)))))
    (mapcar 'reverse (search-it command keymap nil))))

;;; The Top Map
(defvar *top-map-list* nil)

(defun push-top-map (new-top)
  (push *top-map* *top-map-list*)
  (setf *top-map* new-top)
  (sync-keys))

(defun pop-top-map ()
  (when *top-map-list*
    (setf *top-map* (pop *top-map-list*))
    (sync-keys)
    t))
