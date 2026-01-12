;;; pkg.lisp --- WM Modeline Packages

;; 

;;; Code:
(defpackage #:wm/cpu
  (:use #:std-lisp :wm)
  (:export #:*cpu-modeline-fmt*
           #:*acpi-thermal-zone*))

(defpackage #:wm/battery
  (:use :std-lisp :wm :ppcre)
  (:export #:*refresh-time* #:*prefer-sysfs*))

(defpackage #:wm/net
  (:use #:std-lisp #:wm #:ppcre #:net #:cli/tools/net #:time)
  (:export #:*net-device*))

(defpackage #:wm/tray
  (:use #:std-lisp)
  (:export 
   :*tray-viwin-background*
   :*tray-hiwin-background*
   :*tray-placeholder-pixels-per-space*
   :*tray-icon-spacing*
   :add-mode-line-hooks
   :remove-mode-line-hooks))

(defpackage #:wm/disk
  (:use :std-lisp :wm :disk)
  (:export :*disk-modeline-fmt*
           :*disk-usage-paths*))

(pkg:defpkg :wm/modeline
  (:use #:std-lisp #:wm)
  (:use-reexport #:wm/cpu #:wm/battery #:wm/net #:wm/tray #:wm/disk))
