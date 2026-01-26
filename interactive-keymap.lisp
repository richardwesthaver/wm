;;; interactive-keymap.lisp --- Interactive Commands

;; Copyright (C) 2016, 2017 Caio Oliveira

;;; Commentary:

;; Macro for defining interactive command. Just pushes and pops new keymaps.

;;; Code:
(in-package #:wm)

(defun enter-interactive-keymap (kmap name)
  "Enter interactive mode"
  (wm-message "~S started." name)
  (push-top-map kmap))

(defun exit-interactive-keymap (name)
  "Exits interactive mode"
  (wm-message "~S finished." name)
  (pop-top-map))

(defcommand call-and-exit-kmap (command exit-command)
  "This command effectively calls two other commands in succession, via run-commands.
it is designed for use in the define-interactive-keymap macro, to implement exiting
the keymap on keypress. "
  (declare (interactive (command "command to run: ") (command "exit command: ")))
  (run-commands command exit-command))

(defmacro define-interactive-keymap (name (&key on-enter on-exit 
                                                abort-if 
                                                (exit-on '((kbd "RET")
                                                           (kbd "ESC")
                                                           (kbd "C-g"))))
                                     &body key-bindings)
  "Declare an interactive keymap mode. This can be used for developing
interactive modes or command trees, such as IRESIZE.

The NAME argument follows the same convention as in DEFCOMMAND.

ON-ENTER and ON-EXIT are optional functions to run before and after the
interactive keymap mode, respectively. If ABORT-IF is defined, the interactive
keymap will only be activated if calling ABORT-IF returns true.

KEY-BINDINGS is a list of the following form: ((KEY COMMAND) (KEY COMMAND) ...)
If one appends t to the end of a binding like so: ((kbd \"n\") \"cmd\" t) then
the keymap is immediately exited after running the command. 

Each element in KEY-BINDINGS declares a command inside the interactive keymap.
Be aware that these commands won't require a prefix to run."
  (let* ((command (if (listp name) (car name) name))
         (exit-command (format nil "EXIT-~A" command))
         (keymap (gensym "m")))
    (multiple-value-bind (key-bindings decls docstring)
        (parse-body key-bindings :documentation t)
      `(let ((,keymap (sparse-keymap)))
         ,@(loop for keyb in key-bindings
                 collect `(define-key ,keymap ,(first keyb)
                            ,(if (third keyb)
                                 (concatenate 'string "call-and-exit-kmap \""
                                              (second keyb) "\" " exit-command)
                                 (second keyb))))
         ,@(loop for keyb in exit-on
                 collect `(define-key ,keymap ,keyb ,exit-command))
         (defcommand ,name ()
           ,@decls
           (block ,command
             ,(or docstring
                  (format nil "Starts interactive command \"~A\"" command))
             ,@(when abort-if `((when (funcall ,abort-if)
                                  (return-from ,command))))

             ,@(when on-enter `((funcall ,on-enter)))
             (enter-interactive-keymap ,keymap (quote ,command))))
         (defcommand ,(intern exit-command) ()
           ,@(when on-exit `((funcall ,on-exit)))
           (exit-interactive-keymap (quote ,command)))))))
