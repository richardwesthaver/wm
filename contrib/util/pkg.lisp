;;; pkg.lisp --- StumpWM Util Packages

;; 

;;; Code:
(defpackage #:swm/golden-ratio
  (:use #:cl #:stumpwm)
  (:export :*golden-ratio* :*golden-ratio-on* :toggle-golden-ratio))

(defpackage #:swm/beckon
  (:use #:cl)
  (:import-from 
   #:stumpwm 
   #:defcommand 
   #:window-frame 
   #:ratwarp #:current-window #:frame-x #:frame-y 
   #:frame-height #:frame-width)
  (:export #:beckon #:*window-height-fraction* #:*window-width-fraction*))

(defpackage #:swm/clipboard-history
  (:use #:cl)
  (:export 
   #:start-clipboard-manager
   #:stop-clipboard-manager
   #:show-clipboard-history
   #:*clipboard-history-max-length*))

(defpackage #:swm/command-history
  (:use :cl :stumpwm)
  (:export
   :*command-history-file*
   :*start-hook*
   :*quit-hook*))

(defpackage #:swm/globalwindows
  (:use #:cl :stumpwm)
  (:import-from 
   :stumpwm
   :*window-format*
   :completing-read
   :current-group
   :current-screen
   :current-window
   :focus-all
   :frame-raise-window
   :group-windows
   :move-window-to-group
   :pull-window
   :select-window-from-menu
   :show-frame-indicator
   :sort-groups
   :sort1
   :tile-group-current-frame
   :window-frame
   :window-group
   :window-name))

(defpackage #:swm/kbd-layouts
  (:use #:cl #:stumpwm #:io/kbd)
  (:export 
   #:*caps-lock-behavior*
   #:*custom-setxkb-options*
   #:*run-xmodmap*
   #:keyboard-layout-list))

(defpackage #:swm/perwindowlayout
  (:use #:cl :stumpwm)
  (:export 
   #:*emacs-toggle-input-method-key*
   #:switch-window-layout
   #:enable-per-window-layout
   #:disable-per-window-layout))

(defpackage #:swm/screenshot
  (:use #:cl :stumpwm :dat/png))

(defpackage #:swm/shell-command-history
  (:use :cl :stumpwm)
  (:export
   :*shell-command-history-file*
   :*start-hook*
   :*quit-hook*))

(defpackage #:swm/spatial-groups
  (:use #:cl #:stumpwm)
  (:export 
   :*spatial-banish-on-move*
   :spatial-gselect
   :install-default-keybinds))

(defpackage #:swm/gaps
  (:use #:cl :stumpwm)
  (:export 
   :*inner-gaps-size* :*outer-gaps-size* 
   :*head-gaps-size* :*gaps-on* 
   :toggle-gaps :toggle-gaps-on :toggle-gaps-off))

(defpackage #:swm/ttf-fonts
  (:shadowing-import-from :stumpwm :version :message)
  (:use #:cl #:stumpwm #:ttf)
  (:import-from :stumpwm
   :font-exists-p :open-font 
   :close-font :font-ascent :font-descent :text-line-width
   :draw-image-glyphs :font-height)
  (:export 
   :font-exists-p 
   :open-font
   :close-font
   :font-ascent
   :font-descent
   :text-line-width
   :draw-image-glyphs))

(defpackage #:swm/windowtags
  (:use #:cl #:stumpwm)
  (:import-from #:stumpwm
                ;; string wrappers for tag data storage
                #:utf8-to-string
                ;; groups
                #:find-group
                ;; switching windows
                #:really-raise-window)
  (:export :window-tags :clear-tags))

(defpackage #:swm/urgentwindows
  (:use #:cl :stumpwm)
  (:import-from :stumpwm
   :*urgent-window-hook* :gselect
   :message-no-timeout :really-raise-window
   :window-group :window-title)
  (:export :raise-urgent :*urgent-window-message*))

(defpackage #:swm/winner-mode
  (:use :cl)
  (:export :winner-undo :winner-redo :*tmp-folder* :dump-group-to-file :*default-commands*))
