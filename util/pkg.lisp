;;; pkg.lisp --- WM Util Packages

;; 

;;; Code:
(defpackage #:wm/golden-ratio
  (:use #:std-lisp #:wm #:cmd)
  (:export :*golden-ratio* :*golden-ratio-on*))

(defpackage #:wm/clipboard
  (:use #:std-lisp #:wm #:cmd)
  (:export 
   #:start-clipboard-manager
   #:stop-clipboard-manager
   #:*clipboard-history-max-length*))

(defpackage #:wm/history
  (:use :std-lisp :wm)
  (:export
   :*command-history-file*))

(defpackage #:wm/windows
  (:use #:std-lisp :wm #:cmd)
  (:import-from 
   :wm
   :*window-format*
   :completing-read-screen
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
   :window-name
   :*urgent-window-hook* :gselect
   :message-no-timeout :really-raise-window
   :window-title
   ;; string wrappers for tag data storage
   #:utf8-to-string
   ;; groups
   #:find-group
   #:defcommand 
   #:ratwarp 
   #:frame-x #:frame-y 
   #:frame-height #:frame-width)
  ;; global
  (:export
   :goto-window :with-global-windowlist
   :global-windowlist :global-pull-windowlist)
  ;; urgent
  (:export :raise-urgent :*urgent-window-message*)
  ;; tags
  (:export :window-tags :clear-tags)
  ;; beckon
  (:export #:beckon #:*window-height-fraction* #:*window-width-fraction*))

(defpackage #:wm/screenshot
  (:use #:std-lisp :wm :dat/png #:cmd))

(defpackage #:wm/gaps
  (:use #:std-lisp :wm #:cmd)
  (:export 
   :*inner-gaps-size* :*outer-gaps-size* 
   :*head-gaps-size* :*gaps-on*))

(defpackage #:wm/ttf-fonts
  (:shadowing-import-from :wm :version :message)
  (:use #:std-lisp #:wm #:ttf)
  (:import-from :wm
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
