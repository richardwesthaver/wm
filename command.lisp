;;; command.lisp --- WM Commands

;; Copyright (C) 2003-2008 Shawn Betts

;;; Commentary:

;; implementation of commands

;;; Code:
(in-package #:wm)

(defkernel wm-command (command) ())
;; instead of requiring a :class slot, we just subclass wm-command for our groups (tiling, floating, and dynamic)
(defkernel wm-tiling-command (wm-command) ())
(defkernel wm-floating-command (wm-command) ())
(defkernel wm-dynamic-command (wm-tiling-command) ())
(init :commands :name :wm :class 'wm-command)

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
  (declare (type (or string symbol command command-alias) command))
  (when (or (stringp command) (symbolp command))
    (setf command (command command)))
  (when (and command
             (or (not only-active)
                 (command-active-p command)))
    command))

(defun list-all-commands (&optional (only-active t))
  "Return a list of all interactive commands as strings. By default
only return active commands."
  (let (acc)
    (maphash (lambda (k v)
               ;; make sure its an active command
               (when (get-command v only-active)
                 (push (string-downcase k) acc)))
             *command-hash*)
    (sort acc 'string<)))

;;; command arguments
(defun argument-line-end-p (input)
  "Return T if we're outta arguments from the input line."
  (>= (argument-line-start input)
      (length (argument-line-string input))))

(defun argument-pop (input)
  "Pop the next argument off."
  (unless (argument-line-end-p input)
    (flet ((pop-word (input start)
             ;; Return the first word of INPUT starting from START and
             ;; its end position.
             (let* ((p1 (position #\space input :start start :test #'char/=))
                    (p2 (or (and p1 (position #\Space input :start p1))
                            (length input))))
               ;; we wanna return nil if they're the same
               (unless (= p1 p2)
                 (values (subseq input p1 p2)
                         (1+ p2)))))
           (pop-string (input start)
             ;; Return a delimited string from INPUT starting from
             ;; START (if there is one) and the end position of the
             ;; string.
             (let ((start
                     (loop for i from start below (length input)
                           for char = (char input i)
                           do (case char
                                (#\space)             ;Skip spaces
                                (#\" (return (1+ i))) ;Start position found
                                (otherwise (return-from pop-string nil))))))
               (let ((str (make-string-output-stream)))
                 (loop for i from start below (length input)
                       for char = (char input i)
                       do (case char
                            (#\\        ;Escape next char
                             (incf i)
                             (if (< i (length input))
                                 (write-char (char input i) str)
                                 (return nil)))
                            (#\"        ;End delimiter
                             (return (values (get-output-stream-string str)
                                             (1+ i))))
                            (otherwise
                             (write-char char str))))))))
      (multiple-value-bind (arg end)
          (nth-value-or 0
            (pop-string (argument-line-string input)
                        (argument-line-start input))
            (pop-word (argument-line-string input)
                      (argument-line-start input)))
        (setf (argument-line-start input) end)
        arg))))

(defun argument-pop-or-read (input prompt &optional completions)
  (or (argument-pop input)
      (if completions
          (completing-read (current-screen) prompt completions)
          (read-one-line (current-screen) prompt))
      (throw 'cmd :abort)))

(defun argument-pop-rest (input)
  "Return the remainder of the argument text."
  (unless (argument-line-end-p input)
    (prog1
        (subseq (argument-line-string input) (argument-line-start input))
      (setf (argument-line-start input) (length (argument-line-string input))))))

(defun argument-pop-rest-or-read (input prompt &optional completions)
  (or (argument-pop-rest input)
      (if completions
          (completing-read (current-screen) prompt completions)
          (read-one-line (current-screen) prompt))
      (throw 'cmd :abort)))

(define-command-type :y-or-n (input prompt)
  (let* ((positive-responses '("y" t))
         (s (or (argument-pop input)
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

(define-command-type :variable (input prompt)
  (lookup-symbol (argument-pop-or-read input prompt)))

(define-command-type :function (input prompt)
  (multiple-value-bind (sym pkg var)
      (lookup-symbol (argument-pop-or-read input prompt))
    (if (fboundp sym)
        sym
        (throw 'cmd (format nil "The symbol ~A::~A is not bound to any function."
                              (package-name pkg) var)))))

(define-command-type :command (input prompt)
  (or (argument-pop input)
      (completing-read (current-screen)
                       prompt
                       (list-all-commands))))

(define-command-type :key-seq (input prompt)
  (labels ((update (seq)
             (wm-message "~a ~{~a ~}"
                      prompt
                      (mapcar 'print-key (reverse seq)))))
    (let ((rest (argument-pop-rest input)))
      (or (and rest (parse-key-seq rest))
          ;; read a key sequence from the user
          (with-focus (screen-key-window (current-screen))
            (wm-message "~a" prompt)
            (nreverse (nth-value 1 (read-from-keymap (top-maps) #'update))))))))

(define-command-type :window-number (input prompt)
  (when-let ((n (or (argument-pop input)
               (completing-read (current-screen)
                                prompt
                                (mapcar 'window-map-number
                                        (group-windows (current-group)))))))
    (if-let ((win (find n (group-windows (current-group))
                     :test #'string=
                     :key #'window-map-number)))
      (window-number win)
      (throw 'cmd "No such window."))))

(define-command-type :number (input prompt)
  (when-let ((n (or (argument-pop input)
                    (read-one-line (current-screen) prompt))))
    (handler-case (parse-number n)
      (invalid-number (c)
        (declare (ignore c))
        (throw 'cmd "Number required.")))))

(define-command-type :string (input prompt)
  (or (argument-pop input)
      (read-one-line (current-screen) prompt)))

(define-command-type :password (input prompt)
  (or (argument-pop input)
      (read-one-line (current-screen) prompt :password t)))

(define-command-type :key (input prompt)
  (when-let ((s (or (argument-pop input)
               (read-one-line (current-screen) prompt))))
    (kbd s)))

(define-command-type :window-name (input prompt)
  (or (argument-pop input)
      (completing-read (current-screen) prompt
                       (mapcar 'window-name
                               (group-windows (current-group))))))

(define-command-type :direction (input prompt)
  (let* ((values '(("up" :up)
                   ("down" :down)
                   ("left" :left)
                   ("right" :right)))
         (string (argument-pop-or-read input prompt (mapcar 'first values)))
         (dir (second (assoc string values :test 'string-equal))))
    (or dir
        (throw 'cmd "No matching direction."))))

(define-command-type :gravity (input prompt)
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
         (string (argument-pop-or-read input prompt (mapcar 'first values)))
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

(define-command-type :group (input prompt)
  (let ((match (select-group (current-screen)
                             (or (argument-pop input)
                                 (completing-read (current-screen) prompt
                                                  (mapcar 'group-name
                                                          (screen-groups (current-screen))))))))
    (or match
        (throw 'cmd "No such group."))))

(define-command-type :frame (input prompt)
  (declare (ignore prompt))
  (if-let ((arg (argument-pop input)))
    (or (find arg (group-frames (current-group))
              :key (lambda (f)
                     (string (get-frame-number-translation f)))
              :test 'string=)
        (throw 'cmd "Frame not found."))
    (or (choose-frame-by-number (current-group))
        (throw 'cmd :abort))))

(define-command-type :shell (input prompt)
  (declare (ignore prompt))
  (let ((prompt (format nil "~A -c " *shell-program*))
        (*input-history* *input-shell-history*))
    (unwind-protect
         (or (argument-pop-rest input)
             (completing-read (current-screen) prompt 'complete-program))
      (setf *input-shell-history* *input-history*))))

(define-command-type :rest (input prompt)
  (or (argument-pop-rest input)
      (read-one-line (current-screen) prompt)))

(defun call-interactively (command &optional (input ""))
  "Parse the command's arguments from input given the command's
argument specifications then execute it. Returns a string or nil if user
aborted."
  (declare (type (or string symbol) command)
           (type (or string argument-line) input))
  ;; Catch parse errors
  (catch 'error
    (let* ((arg-line (if (stringp input)
                         (make-argument-line :string input
                                             :start 0)
                         input))
           (cmd-data (or (get-command command)
                         (throw 'cmd (format nil "Command '~a' not found." command))))
           (arg-specs (command-args cmd-data))
           (args (loop for spec in arg-specs
                    collect (let* ((type (if (listp spec)
                                             (first spec)
                                             spec))
                                   (prompt (when (listp spec)
                                             (second spec)))
                                   (fn (gethash type *command-type-hash*)))
                              (unless fn
                                (throw 'cmd (format nil "Bad argument type: ~s" type)))
                              ;; If the prompt is NIL then it's
                              ;; considered an optional argument and
                              ;; we shouldn't prompt for it if the
                              ;; arg line is empty.
                              (if (and (null prompt)
                                       (argument-line-end-p arg-line))
                                  (loop-finish)
                                  (funcall fn arg-line prompt))))))
      ;; Did the whole string get parsed?
      (unless (or (argument-line-end-p arg-line)
                  (position-if 'alphanumericp (argument-line-string arg-line) :start (argument-line-start arg-line)))
        (throw 'cmd (format nil "Trailing garbage: ~{~A~^ ~}" (subseq (argument-line-string arg-line)
                                                                        (argument-line-start arg-line)))))
      ;; Success
      (prog1
          (apply (command-name cmd-data) args)
        (setf *last-command* command)))))

(defun eval-command (cmd &optional interactive)
  "exec cmd and echo the result."
  (labels ((parse-and-run-command (input)
             (let* ((arg-line (make-argument-line :string input
                                                  :start 0))
                    (cmd (argument-pop arg-line)))
               (let ((*interactive* interactive))
                 (call-interactively cmd arg-line)))))
    (multiple-value-bind (result error-p)
        ;; this fancy footwork lets us grab the backtrace from where the
        ;; error actually happened.
        (restart-case
            (handler-bind
                ((error (lambda (c)
                          (invoke-restart 'eval-command-error
                                          (format nil "^B^1*Error In Command '^b~a^B': ^n~A~a"
                                                  cmd c (if *show-command-backtrace*
                                                            (get-backtrace) ""))))))
              (parse-and-run-command cmd))
          (eval-command-error (err-text)
            :interactive (lambda ()
                           (list (format nil "^B^1*Error In Command '^b~a^B'"
                                         cmd)))
            :report (lambda (s)
                      (format s "Exit command ~S" cmd))
            (values err-text t)))
      ;; interactive commands update the modeline
      (update-all-mode-lines)
      (cond ((stringp result)
             (if error-p
                 (message-no-timeout "~a" result)
                 (wm-message "~a" result)))
            ((eq result :abort)
             (unless *suppress-abort-messages*
               (wm-message "Abort.")))))))

(defcommand colon (&optional initial-input) (:rest)
  "Read a command from the user with optional INITIAL-TEXT. When
supplied, the text will appear in the prompt.

String arguments with spaces may be passed to the command by delimiting them
with double quotes. A backslash can be used to escape double quotes or
backslashes inside the string. This does not apply to commands taking :REST or
:SHELL type arguments."
  (let ((cmd (completing-read (current-screen) ": " (list-all-commands) :initial-input (or initial-input ""))))
    (unless cmd
      (throw 'cmd :abort))
    (when (plusp (length cmd))
      (eval-command cmd t))))
