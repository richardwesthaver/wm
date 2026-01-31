;;; command.lisp --- WM Commands

;; Copyright (C) 2003-2008 Shawn Betts

;;; Commentary:

;; implementation of commands

;;; Code:
(in-package #:wm)

(init :commands :name :wm :class 'wm-command :names t)

(defkernel wm-command (command) ())
(defmethod name ((self wm-command))
  "The name of a WM command, which is the keyword used to access it in
*COMMANDS*. NOTE: uses linear search."
  (maphash (lambda (k v) (when (equiv v self) (return-from name k))) *commands*))

;; instead of requiring a :class slot, we just subclass wm-command for our
;; groups (tiling, floating, and dynamic)
(defkernel wm-tile-command (wm-command) ())
(defmethod command-class ((self wm-tile-command)) 'tile-group)
(defkernel wm-float-command (wm-command) ())
(defmethod command-class ((self wm-float-command)) 'float-group)
(defkernel wm-dynamic-command (wm-tile-command) ())
(defmethod command-class ((self wm-dynamic-command)) 'dynamic-group)

(defvar *dynamic-command-blacklist* nil
  "A blacklist of commands for dynamic groups specifically.")

(defun command-active-p (command)
  (declare (special *dynamic-command-blacklist*))
  (let* ((group (current-group))
         (active (or (typep group (command-class command))
                     (some (lambda (f) (funcall f group command))
                           *custom-command-filters*))))
    (if (typep (current-group) 'dynamic-group)
        (unless (member command *dynamic-command-blacklist*)
          active)
        active)))

(defun get-command (command &optional (only-active t))
  "Return the command structure for COMMAND. COMMAND can be a string,
symbol, command, or command-alias. By default only search active
commands."
  (declare (type (or string symbol command) command))
  (when (or (stringp command) (symbolp command))
    (setf command (command command)))
  (when (and command
             (or (not only-active)
                 (command-active-p command)))
    command))

(defun wm-commands (&optional (only-active t))
  "Return a list of all interactive commands as strings. By default
only return active commands."
  (let (acc)
    (maphash (lambda (k v)
               ;; make sure its an active command
               (when (get-command v only-active)
                 (push (string-downcase k) acc)))
             *commands*)
    (sort acc 'string<)))

;;; Hooks
(defun wm-command-eval-result (result)
  ;; interactive commands update the modeline
  (update-all-mode-lines)
  (cond ((stringp result) (wm-message "~a" result))
        ((eq result :abort) (unless *suppress-abort-messages*
                              (wm-message "Abort.")))))

(add-hook cmd:*command-hook* #'wm-command-eval-result :name :eval)

;;; command args
(defun read-wm-arg (input prompt &optional completions)
  (or (read-arg input)
      (if completions
          (completing-read-screen (current-screen) prompt completions)
          (read-one-line (current-screen) prompt))
      (throw 'cmd :abort)))

(defun read-wm-args (input prompt &optional completions)
  (or (read-args input)
      (if completions
          (completing-read-screen (current-screen) prompt completions)
          (read-one-line (current-screen) prompt))
      (throw 'cmd :abort)))

(define-command-type :y-or-n (prompt)
  (let* ((positive-responses '("y" t))
         (s (or (read-arg *command-input*)
                (read-one-line (current-screen) (concat prompt "(y/n): ")))))
    (member s positive-responses :test #'equalp)))

(defun lookup-symbol (string)
  (let* ((ofs (split-string string ":"))
         (pkg (if (> (length ofs) 1)
                  (find-package (string-upcase (pop ofs)))
                  *package*))
         (var (string-upcase (pop ofs)))
         (ret (find-symbol var pkg)))
    (when (plusp (length ofs))
      (throw 'cmd "Too many :'s"))
    (if ret
        (values ret pkg var)
        (throw 'cmd (format nil "No such symbol: ~a::~a."
                              (package-name pkg) var)))))

(define-command-type :variable (prompt)
  (lookup-symbol (read-wm-arg *command-input* prompt)))

(define-command-type :function (prompt)
  (multiple-value-bind (sym pkg var)
      (lookup-symbol (read-wm-arg *command-input* prompt))
    (if (fboundp sym)
        sym
        (throw 'cmd (format nil "The symbol ~A::~A is not bound to any function."
                              (package-name pkg) var)))))

(define-command-type :command (prompt)
  (or (read-arg *command-input*)
      (completing-read-screen (current-screen)
                       prompt
                       (wm-commands))))

(define-command-type :key-seq (prompt)
  (labels ((update (seq)
             (wm-message "~a ~{~a ~}"
                      prompt
                      (mapcar 'print-key (reverse seq)))))
    (let ((rest (read-args *command-input*)))
      (or (and rest (parse-wm-key-seq rest))
          ;; read a key sequence from the user
          (with-focus (screen-key-window (current-screen))
            (wm-message "~a" prompt)
            (nreverse (nth-value 1 (read-from-keymap (top-maps) #'update))))))))

(define-command-type :window-number (prompt)
  (when-let ((n (or (read-arg *command-input*)
               (completing-read-screen (current-screen)
                                prompt
                                (mapcar 'window-map-number
                                        (group-windows (current-group)))))))
    (if-let ((win (find n (group-windows (current-group))
                     :test #'string=
                     :key #'window-map-number)))
      (window-number win)
      (throw 'cmd "No such window."))))

(define-command-type :number (prompt)
  (when-let ((n (or (read-arg *command-input*)
                    (read-one-line (current-screen) prompt))))
    (handler-case (parse-number n)
      (invalid-number (c)
        (declare (ignore c))
        (throw 'cmd "Number required.")))))

(define-command-type :string (prompt)
  (or (read-arg *command-input*)
      (read-one-line (current-screen) prompt)))

(define-command-type :password (prompt)
  (or (read-arg *command-input*)
      (read-one-line (current-screen) prompt :password t)))

(define-command-type :key (prompt)
  (when-let ((s (or (read-arg *command-input*)
               (read-one-line (current-screen) prompt))))
    (kbd s)))

(define-command-type :window-name (prompt)
  (or (read-arg *command-input*)
      (completing-read-screen (current-screen) prompt
                       (mapcar 'window-name
                               (group-windows (current-group))))))

(define-command-type :direction (prompt)
  (let* ((values '(("up" :up)
                   ("down" :down)
                   ("left" :left)
                   ("right" :right)))
         (string (read-wm-arg *command-input* prompt (mapcar 'first values)))
         (dir (second (assoc string values :test 'string-equal))))
    (or dir
        (throw 'cmd "No matching direction."))))

(define-command-type :gravity (prompt)
"Set the current window's gravity."
  (let* ((values '(("center" :center)
                   ("top" :top)
                   ("right" :right)
                   ("bottom" :bottom)
                   ("left" :left)
                   ("top-right" :top-right)
                   ("top-left" :top-left)
                   ("bottom-right" :bottom-right)
                   ("bottom-left" :bottom-left)))
         (string (read-wm-arg *command-input* prompt (mapcar 'first values)))
         (gravity (second (assoc string values :test 'string-equal))))
    (or gravity
        (throw 'cmd "No matching gravity."))))

(defun select-group (screen query)
  "Attempt to match string QUERY against group number or partial name."
  (labels ((match-num (grp)
             (string-equal (group-map-number grp) query))
           (match-whole (grp)
             (string-equal (group-name grp) query))
           (match-partial (grp)
             (let* ((end (min (length (group-name grp)) (length query))))
               (string-equal (group-name grp) query :end1 end :end2 end))))
    (when query
      (or (find-if #'match-num (screen-groups screen))
          (find-if #'match-whole (screen-groups screen))
          (find-if #'match-partial (screen-groups screen))))))

(define-command-type :group (prompt)
  (let ((match (select-group (current-screen)
                             (or (read-arg *command-input*)
                                 (completing-read-screen (current-screen) prompt
                                                  (mapcar 'group-name
                                                          (screen-groups (current-screen))))))))
    (or match
        (throw 'cmd "No such group."))))

(define-command-type :frame (prompt)
  (declare (ignore prompt))
  (if-let ((arg (read-arg *command-input*)))
    (or (find arg (group-frames (current-group))
              :key (lambda (f)
                     (string (get-frame-number-translation f)))
              :test 'string=)
        (throw 'cmd "Frame not found."))
    (or (choose-frame-by-number (current-group))
        (throw 'cmd :abort))))

(define-command-type :shell (prompt)
  (declare (ignore prompt))
  (let ((prompt (format nil "~A -c " *shell-program*))
        (*input-history* *input-shell-history*))
    (unwind-protect
         (or (read-args *command-input*)
             (completing-read-screen (current-screen) prompt 'complete-program))
      (setf *input-shell-history* *input-history*))))

(define-command-type :rest (prompt)
  (or (read-args *command-input*)
      (read-one-line (current-screen) prompt)))

(defcommand colon (&optional initial-input)
  "Read a command from the user with optional INITIAL-TEXT. When
supplied, the text will appear in the prompt.

String arguments with spaces may be passed to the command by delimiting them
with double quotes. A backslash can be used to escape double quotes or
backslashes inside the string. This does not apply to commands taking :REST or
:SHELL type arguments."
  (declare (interactive (rest "foo: ")))
  (let ((cmd (completing-read-screen (current-screen) ": " (wm-commands) :initial-input (or initial-input ""))))
    (unless cmd
      (throw 'cmd :abort))
    (when (plusp (length cmd))
      (eval-command cmd t))))
