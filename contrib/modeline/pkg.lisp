;;; pkg.lisp --- StumpWM Modeline Packages

;; 

;;; Code:
(defpackage #:swm/cpu
  (:use #:cl :stumpwm)
  (:export #:*cpu-modeline-fmt*
           #:*acpi-thermal-zone*))

(defpackage #:swm/battery
  (:use :cl :stumpwm :cl-ppcre)
  (:export #:*refresh-time* #:*prefer-sysfs*))

(defpackage #:swm/net
  (:use #:cl #:stumpwm #:cl-ppcre #:net #:cli/tools/net)
  (:export #:*net-device*))

(defpackage #:swm/tray
  (:use #:cl #:std)
  (:export 
   :*tray-viwin-background*
   :*tray-hiwin-background*
   :*tray-placeholder-pixels-per-space*
   :*tray-icon-spacing*
   :add-mode-line-hooks
   :remove-mode-line-hooks))

(defpackage :swm/disk
  (:use :cl :stumpwm :disk)
  (:export :*disk-modeline-fmt*
           :*disk-usage-paths*))

(pkg:defpkg :swm/modeline
  (:use #:cl #:stumpwm)
  (:use-reexport #:swm/cpu #:swm/battery #:swm/net #:swm/tray #:swm/disk))
