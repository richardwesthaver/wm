;;; modeline.asd --- Modeline Sytem Definitions
(defsystem :modeline
  :depends-on (:std :net :clx :stumpwm)
  :components ((:file "pkg")
               (:module "battery"
                :components ((:file "battery")))
               (:module "cpu"
                :components ((:file "cpu")))
               (:module "mem"
                :components ((:file "mem")))
               (:module "net"
                :components ((:file "net")))
               (:module "hostname"
                :components ((:file "hostname")))
               (:module "hidden"
                :components ((:file "hidden")))
               (:module "maildir"
                :components ((:file "maildir")))
               (:module "tray"
                :components ((:file "tray")))
               (:file "disk")))



