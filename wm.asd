;;; -*- Mode: Lisp -*-
(defsystem :wm
  :name "WM"
  :author "Shawn Betts <sabetts@vcn.bc.ca>"
  :version "24.11"
  :maintainer "Richard Westhaver <richard.westhaver@gmail.com>"
  :license "GNU General Public License"
  :description "A tiling, keyboard driven window manager"
  :serial t
  :depends-on (#:core #:xlib)
  :components ((:file "pkg")
               (:file "debug")
               (:file "prim")
               (:file "wrappers")
               (:file "font-rendering")
               (:file "keysyms")
               (:file "keytrans")
               (:file "kmap")
               (:file "input")
               (:file "core")
               (:file "command")
               (:file "menu-declarations")
               (:file "menu-definitions")
               (:file "screen")
               (:file "head")
               (:file "group")
               (:file "bindings")
               (:file "events")
               (:file "window")
               (:file "floating-group")
               (:file "tile-window")
               (:file "tile-group")
               (:file "window-placement")
               (:file "message-window")
               (:file "selection")
               (:file "module")
               (:file "ioloop")
               (:file "timers")
               (:file "wm")
               (:file "user")
               (:file "interactive-keymap")
               (:file "iresize")
               (:file "help")
               (:file "fdump")
               (:file "time")
               (:file "mode-line")
               (:file "mode-line-formatters")
               (:file "color")
               (:file "wse")
               (:file "dynamic-window")
               (:file "dynamic-group")
               (:file "remap-keys")
               (:file "minor-modes")
               (:file "replace-class"))
  :in-order-to ((test-op (test-op "wm/tests"))))

(defsystem "wm/tests"
  :name "WM tests"
  :serial t
  :depends-on ("wm" "rt")
  :components ((:file "tests"))
  :perform (test-op (o c)
             (uiop/package:symbol-call "RT" "DO-TESTS" :wm)))
