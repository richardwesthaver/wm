;;; bindings.lisp --- standard key bindings

;; Copyright (C) 2003-2008 Shawn Betts

;;; Commentary:

;; define standard key bindings

;; Code:
(in-package #:wm)

(defvar *escape-key* (kbd "C-t")
  "The escape key. Any keymap that wants to hang off the escape key
should use this specific key struct instead of creating their own
C-t.")

(defvar *help-keys* (list (kbd "?") (kbd "C-h"))
  "The list of keys used to invoke the help command.")

(defvar *escape-fake-key* (kbd "t")
  "The binding that sends the fake escape key to the current window.")

(defvar *groups-map* (sparse-keymap)
  "The keymap that group related key bindings sit on. It is bound to 'C-t g' by default.")

(defvar *exchange-window-map* (sparse-keymap)
  "The keymap that exchange-window key bindings sit on. It is bound to 'C-t x' by default.")

(defvar *help-map* (sparse-keymap)
  "Help related bindings hang from this keymap")

(defvar *group-top-maps* '((tile-group *tile-group-top-map*)
                           (group *group-top-map*))
  "An alist of the top level maps for each group type. For a given
group, all maps whose type matches the given group are active. So for
a tile-group, both the group map and tile-group map are active.

Order is important. Each map is seached in the order they appear in
the list (inactive maps being skipped). In general the order should go
from most specific groups to most general groups.")

(defvar *group-top-map* (sparse-keymap))
(defvar *group-root-map* (sparse-keymap)
  "Commands specific to a group context hang from this keymap.
It is available as part of the @dnf{prefix map}.")
(defvar *tile-group-top-map* (sparse-keymap))
(defvar *tile-group-root-map* (sparse-keymap)
  "Commands specific to a tile-group context hang from this keymap.
It is available as part of the @dnf{prefix map} when the active group
is a tile group.")

;; Do it this way so its easier to wipe the map and get a clean one.
;; (defmacro fill-keymap (map &rest bindings)
;;   `(unless (not (sequence:emptyp ,map))
;;      (setf ,map
;;            (let ((m (sparse-keymap)))
;;              ,@(loop for i = bindings then (cddr i)
;;                      while i
;;                      collect `(define-key m ,(first i) ,(second i)))
;;              m))))

(define-keymap *top-map* ()
  *escape-key* '*root-map*)
;; TODO: define-smart-keymap (shadow mod keys)
(define-keymap *root-map* ()
  (kbd "c")   "exec xterm"
  (kbd "C-c") "exec xterm"
  (kbd "e")   "emacs"
  (kbd "C-e") "emacs"
  (kbd "b")   "banish"
  (kbd "C-b") "banish"
  (kbd "a")   "time"
  (kbd "C-a") "time"
  (kbd "!")   "exec"
  (kbd "C-g") "abort"
  *escape-fake-key* "send-escape"
  (kbd ";")   "colon"
  (kbd ":")   "eval"
  (kbd "v")   "version"
  (kbd "m")   "lastmsg"
  (kbd "C-m") "lastmsg"
  (kbd "G")   "vgroups"
  (kbd "g")   '*groups-map*
  (kbd "x")   '*exchange-window-map*
  (kbd "F1")  "gselect 1"
  (kbd "F2")  "gselect 2"
  (kbd "F3")  "gselect 3"
  (kbd "F4")  "gselect 4"
  (kbd "F5")  "gselect 5"
  (kbd "F6")  "gselect 6"
  (kbd "F7")  "gselect 7"
  (kbd "F8")  "gselect 8"
  (kbd "F9")  "gselect 9"
  (kbd "F10") "gselect 10"
  (kbd "h")   '*help-map*)
(define-keymap *group-top-map* ()
  *escape-key* '*group-root-map*)
(define-keymap *group-root-map* ()
  (kbd "C-u") "next-urgent"
  (kbd "M-n")     "next"
  (kbd "M-p")     "prev"
  (kbd "o")       "other"
  (kbd "RET")     "expose"
  (kbd "C-RET")   "expose"
  (kbd "w")   "windows"
  (kbd "C-w") "windows"
  (kbd "DEL") "repack-window-numbers"
  (kbd "k")   "delete"
  (kbd "C-k") "delete"
  (kbd "K")   "kill"
  (kbd "'")   "select"
  (kbd "\"")  "windowlist"
  (kbd "0")   "select-window-by-number 0"
  (kbd "1")   "select-window-by-number 1"
  (kbd "2")   "select-window-by-number 2"
  (kbd "3")   "select-window-by-number 3"
  (kbd "4")   "select-window-by-number 4"
  (kbd "5")   "select-window-by-number 5"
  (kbd "6")   "select-window-by-number 6"
  (kbd "7")   "select-window-by-number 7"
  (kbd "8")   "select-window-by-number 8"
  (kbd "9")   "select-window-by-number 9"
  (kbd "C-N") "number"
  (kbd "#")   "mark"
  (kbd "F11") "fullscreen"
  (kbd "A")   "title"
  (kbd "i")   "info"
  (kbd "I")   "show-window-properties")
(define-keymap *tile-group-top-map* ()
  *escape-key* '*tile-group-root-map*)
(define-keymap *tile-group-root-map* ()
  (kbd "n")       "pull-hidden-next"
  (kbd "C-n")     "pull-hidden-next"
  (kbd "C-M-n")   "next-in-frame"
  (kbd "SPC")     "pull-hidden-next"
  (kbd "C-SPC")   "pull-hidden-next"
  (kbd "p")       "pull-hidden-previous"
  (kbd "C-p")     "pull-hidden-previous"
  (kbd "C-M-p")   "prev-in-frame"
  (kbd "P")       "place-current-window"
  (kbd "W")       "place-existing-windows"
  *escape-key*     "pull-hidden-other"
  (kbd "M-t")     "other-in-frame"
  (kbd "C-0")     "pull 0"
  (kbd "C-1")     "pull 1"
  (kbd "C-2")     "pull 2"
  (kbd "C-3")     "pull 3"
  (kbd "C-4")     "pull 4"
  (kbd "C-5")     "pull 5"
  (kbd "C-6")     "pull 6"
  (kbd "C-7")     "pull 7"
  (kbd "C-8")     "pull 8"
  (kbd "C-9")     "pull 9"
  (kbd "R")       "remove"
  (kbd "s")       "vsplit"
  (kbd "S")       "hsplit"
  (kbd "r")       "iresize"
  (kbd "o")       "fnext"
  (kbd "TAB")     "fnext"
  (kbd "M-TAB")   "fother"
  (kbd "f")       "fselect"
  (kbd "F")       "curframe"
  (kbd "-")       "fclear"
  (kbd "Q")       "only"
  (kbd "X")       "remove-split"
  (kbd "q")       "quit-confirm"
  (kbd "Up")      "move-focus up"
  (kbd "Down")    "move-focus down"
  (kbd "Left")    "move-focus left"
  (kbd "Right")   "move-focus right"
  (kbd "M-Up")    "move-window up"
  (kbd "M-Down")  "move-window down"
  (kbd "M-Left")  "move-window left"
  (kbd "M-Right") "move-window right"
  (kbd "+")       "balance-frames"
  (kbd "l")       "redisplay"
  (kbd "C-l")     "redisplay")
(define-keymap *groups-map* ()
  (kbd "g")     "groups"
  (kbd "c")     "gnew"
  (kbd "n")     "gnext"
  (kbd "C-n")   "gnext"
  (kbd "SPC")   "gnext"
  (kbd "C-SPC") "gnext"
  (kbd "N")     "gnext-with-window"
  (kbd "p")     "gprev"
  (kbd "C-p")   "gprev"
  (kbd "P")     "gprev-with-window"
  (kbd "o")     "gother"
  (kbd "'")     "gselect"
  (kbd "\"")    "grouplist"
  (kbd "m")     "gmove"
  (kbd "M")     "gmove-marked"
  (kbd "k")     "gkill"
  (kbd "A")     "grename"
  (kbd "r")     "grename"
  (kbd "1")     "gselect 1"
  (kbd "2")     "gselect 2"
  (kbd "3")     "gselect 3"
  (kbd "4")     "gselect 4"
  (kbd "5")     "gselect 5"
  (kbd "6")     "gselect 6"
  (kbd "7")     "gselect 7"
  (kbd "8")     "gselect 8"
  (kbd "9")     "gselect 9"
  (kbd "0")     "gselect 10")
(define-keymap *exchange-window-map* ()
  (kbd "Up")    "exchange-direction up"   
  (kbd "Down")  "exchange-direction down" 
  (kbd "Left")  "exchange-direction left" 
  (kbd "Right") "exchange-direction right"
  (kbd "p")     "exchange-direction up"   
  (kbd "n")     "exchange-direction down" 
  (kbd "b")     "exchange-direction left" 
  (kbd "f")     "exchange-direction right"
  (kbd "k")     "exchange-direction up"   
  (kbd "j")     "exchange-direction down" 
  (kbd "h")     "exchange-direction left" 
  (kbd "l")     "exchange-direction right")    
(define-keymap *help-map* ()
  (kbd "v") "describe-variable"
  (kbd "f") "describe-function"
  (kbd "k") "describe-key"
  (kbd "c") "describe-command"
  (kbd "w") "where-is")
