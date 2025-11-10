;;; ~/comp/ext/stumpwm/contrib/util/util.asd --- Util Sytem Definitions
(defsystem :util
  :depends-on (:std :swank :stumpwm :dat :clx :clx/truetype :cl-ppcre)
  :components ((:file "pkg")
               (:module "golden-ratio"
                :components ((:file "golden-ratio")))
               (:module "beckon"
                :components ((:file "beckon")))
               (:module "clipboard-history"
                :components ((:file "clipboard-history")))
               (:module "command-history"
                :components ((:file "command-history")))
               (:module "globalwindows"
                :components ((:file "globalwindows")))
               (:module "kbd-layouts"
                :components ((:file "kbd-layouts")))
               (:module "perwindowlayout"
                :components ((:file "perwindowlayout")))
               (:module "screenshot"
                :components ((:file "screenshot")))
               (:module "shell-command-history"
                :components ((:file "shell-command-history")))
               (:module "spatial-groups"
                :components ((:file "spatial-groups")))
               (:module "gaps"
                :components ((:file "gaps")))
               (:module "ttf-fonts"
                :components ((:file "ttf-fonts")))
               (:module "windowtags"
                :components ((:file "windowtags")))
               (:module "urgentwindows"
                :components ((:file "urgentwindows")))
               (:module "winner-mode"
                :components ((:file "variables")
                             (:file "macros")
                             (:file "dumper")
                             (:file "winner-mode")))))
