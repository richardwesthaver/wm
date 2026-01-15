;;; net.lisp

;; Network activity formatter for the mode-line

;; Copyright 2009 Vitaly Mayatskikh

;;; Code:
(in-package #:wm/net)

;; Install formatters.
(add-screen-mode-line-formatter #\l 'net-modeline)

(defvar *net-device* nil) ; nil means auto. or specify explicitly, i.e. "wlan0"
(defvar *net-ipv4* nil)
(defvar *net-ipv6* nil)
(defvar *last-route-rescan-time* (real-time))
(defvar *last-route-device* nil)

(defun net-device ()
  "Returns statically assigned device name or tries to find it be default gw.
For the second case rescans route table every minute."
  (if *net-device*
      *net-device*
      (if (and *last-route-device*
	       (< (- (real-time) *last-route-rescan-time*) 60))
	  *last-route-device*
	  (let ((new-device (or (default-network-device) "lo")))
	    (when (string/= new-device *last-route-device*)
              (setf *net-ipv4*
                    (string-trim '(#\Newline)
                     (run-shell-command
                      (format nil
                       "/sbin/ip -o -4 addr list ~A | awk '{print $4}' | cut -d/ -f1" new-device)
                     t)))
              (setf *net-ipv6*
                    (string-trim '(#\Newline)
                     (run-shell-command
                      (format nil
                       "/sbin/ip -o -6 addr list ~A | awk '{print $4}' | cut -d/ -f1" new-device)
                     t)))
	      (setq *net-last-tx* 0
		    *net-last-rx* 0
		    *net-last-time* nil
		    *net-rx* nil
		    *net-tx* nil
		    *net-time* nil))
	    (setq *last-route-rescan-time* (real-time)
		  *last-route-device* new-device)))))

(defun net-sys-stat-read* (device stat-file)
  (or (net-sys-stat-read device stat-file)
      (progn (setq *net-device* nil
		   *last-route-device* nil)
	     0)))

(defun fmt-ipv4 ()
  (or *net-ipv4* "noip"))

(defun fmt-ipv6 ()
  (or *net-ipv6* "noip"))

(defun fmt-net-usage ()
  "Returns a string representing the current network activity."
  (multiple-value-bind (rx tx) (net-usage)
    (let (dn up)
      (flet ((kbmb (x y)
               (if (>= (/ x 1e6) y)
                   (list (/ x 1e6) "m")
                   (list (/ x 1e3) "k"))))
        (setq dn (kbmb rx 0.1)
              up (kbmb tx 0.1))
        (format nil "~5,2F~A/~5,2F~A"
                (car dn) (cadr dn) (car up) (cadr up))))))

(defvar *net-formatters-alist*
  '((#\d  net-device)
    (#\u  fmt-net-usage)
    (#\i  fmt-ipv4)
    (#\I  fmt-ipv6)))

(defvar *net-modeline-fmt* "%d:%u"
  "The default value for displaying net information on the modeline.
- %% :: A literal '%'
- %d :: network device name
- %u :: network usage
- %i :: ipv4
- %I :: ipv6")

(defun net-modeline (ml)
  (declare (ignore ml))
  (format-expand *net-formatters-alist*
                 *net-modeline-fmt*))
