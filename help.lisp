;;; help.lisp --- WM Help and Introspection

;; Copyright (C) 2008 Shawn Betts

;;; Commentary:

;; Help and introspection commands

;;; Code:
(in-package #:wm)

(setq cmd:*command-names-p* nil)

(defvar *which-key-format* (concat *key-seq-color* "*~5a^n ~a")
  "The format string that decides how keybindings will show up in the
which-key window. Two arguments will be passed to this formatter:

- the keybind itself
- the associated command")

(defun columnize (list columns &key col-aligns (pad 1) (char #\Space) (align :left))
  ;; only somewhat nasty
  (let* ((rows (ceiling (length list) columns))
         (data (loop for i from 0 below (length list) by (max rows 1)
                     collect (subseq list i (min (+ i rows) (length list)))))
         (max (mapcar (lambda (col)
                        (reduce 'max col :key 'length :initial-value 0))
                      data))
         (padstr (make-string pad :initial-element char))
         (cols ;; normalize width
           (loop
             for i in data
             for j in max
             for c from 0
             collect (loop
                       for k from 0 below rows
                       for s = (or (nth k i) "")
                       for len = (make-string (- j (length s))
                                              :initial-element char)
                       collect (ecase (or (nth c col-aligns) align)
                                 (:left (format nil "~a~a~a" (if (= c 0) "" padstr) s len))
                                 (:right (format nil "~a~a~a" (if (= c 0) "" padstr) len s)))))))
    (apply 'mapcar 'concat (or cols '(nil)))))

(defun display-bindings-for-keymaps (key-seq &rest keymaps)
  (let* ((screen (current-screen))
         (data (mapcan (lambda (map)
                         (mapcar (lambda (b)
                                   (let ((bound-to (keybind-cmd b)))
                                     (format nil *which-key-format*
                                             (print-key (keybind-key b))
                                             (cond ((or (symbolp bound-to)
                                                        (stringp bound-to))
                                                    bound-to)
                                                   ((keymap-p bound-to)
                                                    "Anonymous Keymap")
                                                   (t "Unknown")))))
                                 map))
                       keymaps))
         (cols (ceiling (1+ (length data))
                        (truncate (- (head-height (current-head)) (* 2 (screen-msg-border-width screen)))
                                  (font-height (screen-font screen))))))
    (message-no-timeout "Prefix: ~a~%~{~a~^~%~}"
                        (print-key-seq key-seq)
                        (or (columnize data cols) '("(EMPTY MAP)")))))

(defcommand commands ()
  "List all available commands."
  (let* ((screen (current-screen))
         (data (wm-commands))
         (cols (ceiling (length data)
                        (truncate (- (head-height (current-head)) (* 2 (screen-msg-border-width screen)))
                                  (font-height (screen-font screen))))))
    (message-no-timeout "~{~a~^~%~}"
                        (columnize data cols))))

(defun final-key-p (keys class)
  "Determine if the key is a memeber of a class"
  (member (lastcar keys) (mapcar #'parse-key class) :test #'equalp))

(defun help-key-p (keys)
  "If the key is for the help command."
  (final-key-p keys *help-keys*))

(defun cancel-key-p (keys)
  "If a key is the cancelling key binding."
  (final-key-p keys '("C-g")))

(defcommand describe-key (keys)
  "Either interactively type the key sequence or supply it as text. This
  command prints the command bound to the specified key sequence."
  (declare (interactive (key-seq "Describe key:")))
  (let ((printed-key (mapcar 'print-key keys)))
    (if-let ((cmd (loop for map in (top-maps)
                        for cmd = (lookup-key-sequence map keys)
                        when cmd return cmd)))
            (let ((cmd-without-args (read-arg cmd)))
              (message-no-timeout "~{~A~^ ~} is bound to \"~A\".~%~A"
                                  printed-key cmd
                                  (describe-object cmd-without-args nil)))
            (cond ((and (help-key-p keys)
                        (cdr printed-key))
                   (wm-message "~{~A~^ ~} shows the bindings for the prefix map under ~{~A~^ ~}."
                               printed-key (butlast printed-key)))
                  ((cancel-key-p keys)
                   (wm-message "Any command ending in ~A is meant to cancel any command in progress \"ABORT\".~%"
                               (lastcar printed-key)))
                  (t (wm-message "~{~A~^ ~} is not bound." printed-key))))))

(defun describe-variable-to-stream (var stream)
  "Write the help for the variable to the stream."
  (format stream "variable:^5 ~a^n~%~a~%Its value is:~%~a."
          var
          (or (documentation var 'variable) "")
          (let* ((value (format nil "~a" (symbol-value var)))
                 (split (split-string value (format nil "~%"))))
            (if (> (1+ *print-lines*)
                   (length split))
                value
                (format nil "~a.."
                        (word-wrap (format nil "~{~a~^~%~}"
                                      (take* *print-lines* split))))))))

(defcommand describe-variable (var)
  "Print the online help associated with the specified variable."
  (declare (interactive (variable "Describe variable: ")))
  (message-no-timeout "~a"
                      (with-output-to-string (s)
                        (describe-variable-to-stream var s))))

(defun describe-function-to-stream (fn stream)
  "Write the help for the function to the stream."
  (format stream "function:^5 ~a^n~%" (string-downcase (symbol-name fn)))
  (when-let ((lambda-list (sb-introspect:function-lambda-list
                           (symbol-function fn))))
            (format stream "(^5~a ^B~{~a~^ ~}^b^n)~&~%" (string-downcase (symbol-name fn)) lambda-list))
  (format stream "~&~a"(or (documentation fn 'function) "")))

(defcommand describe-function (fn)
  "Print the online help associated with the specified function."
  (declare (interactive (function "Describe function: ")))
  (message-no-timeout "~a"
                      (with-output-to-string (s)
                        (describe-function-to-stream fn s))))

(defun find-binding-in-kmap (command keymap &key match-partial-string
                                                 match-with-arguments)
  "Walk through KEYMAP recursively looking for bindings that match COMMAND.
Return a list of keybindings where each keybinding is of the form:

(command \"binding-1 binding-2 ... binding-n\" *map1* *map2* ... *mapn*) 

For every space-separated binding there is a corresponding keymap that it is
bound in. In the above list, binding-1 is bound in *map1*, binding-2 in *map2*,
and binding-n in *mapn*. 

COMMAND must be a string, a symbol, or a kmap structure. 

KEYMAP must be a symbol or a kmap structure, though it should be a symbol if readable return values are desired. 

MATCH-PARTIAL-STRING is a true/false value. If true, any binding structure whose
command slot contains the string COMMAND is treated as a match. 

In the list returned, command refers to the value of (keybind-cmd binding)
where binding is the keybinding that matches COMMAND. 

Example: 
=> (find-binding-in-kmap \"grename\" '*root-map*)
((\"grename\" \"g A\" *ROOT-MAP* *GROUPS-MAP*)
 (\"grename\" \"g r\" *ROOT-MAP* *GROUPS-MAP*))
"
  (labels ((str-from-key (key)
             ;; Inverse of (kbd ...) 
             (concatenate 'string
                          (when (key-control key) "C-")
                          (when (key-meta key)    "M-")
                          (when (key-super key)   "s-")
                          (when (key-hyper key)   "H-")
                          (when (key-alt key)     "A-")
                          (when (key-shift key)   "S-")
                          (keysym-code-name (key-sym key))))
           (command-equal (cmd)
             (cond ((and (stringp cmd) (stringp command))
                    (cond (match-partial-string
                           (ppcre:scan command cmd))
                          (match-with-arguments
                           (let ((els (ppcre:split " " cmd)))
                             (member command els :test #'string-equal)))
                          (t (string-equal cmd command))))
                   ((or (and (symbolp cmd) (symbolp command))
                        (and (keymap-p cmd) (keymap-p command)))
                    (eql cmd command))))
           (walk-keymap (keymap &optional binding-acc keymap-acc)
             (loop for binding in (car (deref-keymaps
                                        (list keymap)))
                   if (command-equal (keybind-cmd binding))
                   collect (list* (keybind-cmd binding)
                                  (format nil "~{~A~^ ~}"
                                          (reverse (cons (str-from-key
                                                          (keybind-key binding))
                                                         binding-acc)))
                                  (reverse keymap-acc))
                   else
                   if (keymap-or-keymap-symbol-p (keybind-cmd binding))
                   append (walk-keymap (keybind-cmd binding)
                                       (cons (str-from-key (keybind-key binding))
                                             binding-acc)
                                       (cons
                                        (if (keymap-p (keybind-cmd binding))
                                            'anonymous-keymap
                                            (keybind-cmd binding))
                                        keymap-acc)))))
    (let ((keys (walk-keymap keymap nil (list keymap))))
      keys)))

(defun find-binding (command &key match-partial-string (match-with-arguments t)
                                  (top-level-maps
                                   (cons '*top-map*
                                         (mapcar #'cadr *group-top-maps*))))
  "Return a list of all keybindings matching COMMAND as specified by
FIND-BINDING-IN-KMAP."
  (loop for map in top-level-maps
        append (find-binding-in-kmap command map
                                     :match-partial-string match-partial-string
                                     :match-with-arguments match-with-arguments)))

(defcommand describe-command (com)
  "Print the online help associated with the specified command."
  (declare (interactive (command "Describe command: ")))
  (message-no-timeout "~a" (describe-object com nil)))

;; TODO 2026-01-28: 
(defun where-is-to-stream (cmd stream)
  (labels ((keys (cmd)
             (loop for map in (top-maps) append (search-keymap cmd map)))
           (sym (comm)
             (typecase comm
               (command (name comm))
               (string (intern (string-upcase comm)))
               (symbol comm))))
    (let ((cmd (string-downcase cmd)))
      (if-let ((bindings (keys cmd)))
              (format stream "\"~a\" is on ~{~a~^, ~}." cmd
                      (mapcar 'print-key-seq bindings))
              (format stream "Command \"~a\" is not currently bound." cmd))
      (let ((reverse-hash (make-hash-table :size (hash-table-size *commands*)
                                           :test 'eq)))
        (loop for k being each hash-key of *commands* using (hash-value v)
              do (setf #1=(gethash (sym v) reverse-hash)
                       (let ((sym (sym v)))
                         (when (not (eql sym (sym v)))
                           (cons sym #1#)))))
        (when-let ((aliases (gethash (intern (string-upcase cmd)) reverse-hash)))
                  (format stream "~%\"~a\" is aliased to ~{\"~a\"~^, ~}."
                          cmd (mapcar #'string-downcase aliases))
                  (loop for a in aliases
                        for k = #2=(keys (string-downcase (symbol-name a))) then #2#
                        when k do (format stream "~%\"~a\" is on ~{~a~^, ~}." (string-downcase a) (mapcar 'print-key-seq k))))))))

(defcommand where-is (cmd)
  "Print the key sequences bound to the specified command."
  (declare (interactive (command "Where is command: ")))
  (let ((stream (make-string-output-stream)))
    (where-is-to-stream cmd stream)
    (message-no-timeout "~A" (get-output-stream-string stream))))

(defun get-kmaps-at-key (kmaps key)
  (deref-keymaps
   (reduce
    (lambda (result map)
      (let* ((binding (handler-case (find key map
                                          :key 'keybind-key :test 'equalp)
                        (type-error () nil)))
             (command (when binding (keybind-cmd binding))))
        (if command
            (setf result (cons command result))
            result)))
    kmaps
    :initial-value ())))

(defun get-kmaps-at-key-seq (kmaps key-seq)
  "get a list of kmaps that are activated when pressing KEY-SEQ when
KMAPS are enabled"
  (if (= 1 (length key-seq))
      (get-kmaps-at-key kmaps (first key-seq))
      (get-kmaps-at-key-seq (get-kmaps-at-key kmaps (first key-seq))
                            (rest key-seq))))

(defun which-key-mode-key-press-hook (key key-seq cmd)
  "*key-press-hook* for which-key-mode"
  (declare (ignore key cmd))
  (when (not (eq *top-map* *resize-map*))
    (let* ((oriented-key-seq (reverse key-seq))
           (maps (get-kmaps-at-key-seq (deref-keymaps (top-maps)) oriented-key-seq)))
      (when-let ((only-maps (remove-if-not 'keymap-p maps)))
                (apply 'display-bindings-for-keymaps oriented-key-seq only-maps)))))

(defcommand which-key-mode ()
  "Toggle which-key-mode"
  (if (find 'which-key-mode-key-press-hook *key-press-hook*)
      (remove-wm-hook *key-press-hook* 'which-key-mode-key-press-hook)
      (add-wm-hook *key-press-hook* 'which-key-mode-key-press-hook)))

(defcommand modifiers ()
  "List the modifiers WM recognizes and what MOD-X it thinks they're on."
  (wm-message "~@{~5@a: ~{~(~a~)~^ ~}~%~}"
              "Meta" (modifiers-meta *modifiers*)
              "Alt" (modifiers-alt *modifiers*)
              "Super" (modifiers-super *modifiers*)
              "Hyper" (modifiers-hyper *modifiers*)
              "AltGr" (modifiers-altgr *modifiers*)))

(setq cmd:*command-names-p* t)
