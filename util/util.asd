;;; ~/comp/ext/stumpwm/contrib/util/util.asd --- Util Sytem Definitions
(defsystem :util
  :depends-on (:std :swank :wm :dat :xlib :xlib/truetype :ppcre)
  :components ((:file "pkg")
               (:file "golden-ratio")
               (:file "beckon")
               (:file "clipboard")
               (:file "history")
               (:file "screenshot")
               (:file "gaps")
               (:file "ttf-fonts")
               (:file "windows")
               (:file "winner")))
