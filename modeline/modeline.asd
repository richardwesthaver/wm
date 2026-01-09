;;; modeline.asd --- Modeline Sytem Definitions
(defsystem :modeline
  :depends-on (:std :net :xlib :wm :obj)
  :components ((:file "pkg")
               (:file "battery")
               (:file "cpu")
               (:file "mem")
               (:file "net")
               (:file "hostname")
               (:file "hidden")
               (:file "maildir")
               (:file "tray")
               (:file "disk")))



