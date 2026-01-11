;;; wm.lisp --- WM Top-level

;; Copyright (C) 2003-2008 Shawn Betts

;;; Code:
(in-package :wm)

(defvar *in-main-thread* nil
  "Dynamically bound to T during the execution of the main wm function.")

;;; Main
(defun load-rc-file (&optional (catch-errors t))
  "Load the user's wmrc file or the system wide one if that
doesn't exist. Returns a values list: whether the file loaded (t if no
rc files exist), the error if it didn't, and the rc file that was
loaded. When CATCH-ERRORS is nil, errors are left to be handled
further up."
  (let* ((user-rc (std:xdg-config-file :wm))
         (dir-rc
           (probe-file (std:xdg-config-dir :wm "init.lisp")))
         (conf-rc
           (probe-file (std:xdg-config-dir :wm "config/")))
         (etc-rc (probe-file #p"/etc/wmrc"))
         (rc (or user-rc dir-rc conf-rc etc-rc)))
    (if rc
        (if catch-errors
            (handler-case (load rc)
              (error (c) (values nil (format nil "~a" c) rc))
              (:no-error (&rest args) (declare (ignore args)) (values t nil rc)))
            (progn
              (load rc)
              (values t nil rc)))
        (values t nil nil))))

(defun error-handler (display error-key &rest key-vals &key asynchronous &allow-other-keys)
  "Handle X errors"
  (cond
    ;; ignore asynchronous window errors
    ((and asynchronous
          (find error-key '(xlib:window-error xlib:drawable-error xlib:match-error)))
     (dformat 4 "Ignoring error: ~s~%" error-key))
    ((eq error-key 'xlib:access-error)
     (write-line "Another window manager is running.")
     (throw :top-level :quit))
    ;; all other asynchronous errors are printed.
    (asynchronous
     (wm-message "Caught Asynchronous X Error: ~s ~s." error-key key-vals))
    (t
     (apply 'error error-key :display display :error-key error-key key-vals))))


(defgeneric handle-top-level-condition (c))

;; Do nothing by default; there's nothing wrong with signalling arbitrary
;; conditions
(defmethod handle-top-level-condition (c))

(defmethod handle-top-level-condition ((c warning)) (muffle-warning))

(defmethod handle-top-level-condition ((c serious-condition))
  (ecase *top-level-error-action*
    (:message
     (let ((s (format nil "~&Caught '~a' at the top level. Please report this." c)))
       (write-line s)
       (print-backtrace)
       (wm-message "^1*^B~a" s)))
    (:break (restart-case
                (invoke-debugger c)
              (:abort-debugging ()
               :report (lambda (stream) (format stream "abort debugging"))
                (throw :top-level (list c (backtrace-string))))))
    (:abort
     (throw :top-level (list c (backtrace-string))))))

(defclass request-channel ()
  ((in    :initarg :in
          :reader request-channel-in)
   (out   :initarg :out
          :reader request-channel-out)
   (queue :initform nil
          :accessor request-channel-queue)
   (lock  :initform (sb-thread:make-mutex)
          :reader request-channel-lock)))

(defvar *request-channel* nil)

(defmethod io-channel-ioport (io-loop (channel request-channel))
  (sb-sys:fd-stream-fd (request-channel-in channel)))

(defmethod io-channel-events ((channel request-channel))
  (list :read))

(defmethod io-channel-handle ((channel request-channel) (event (eql :read)) &key)
  ;; At this point, we know that there is at least one request written
  ;; on the pipe. We read all the data off the pipe and then evaluate
  ;; all the waiting jobs.
  (loop
    with in = (request-channel-in channel)
    do (read-byte in)
    while (listen in))
  (let ((events (sb-thread:with-mutex ((request-channel-lock channel))
                  (let ((queue-copy (request-channel-queue channel)))
                    (setf (request-channel-queue channel) nil)
                    queue-copy))))
    (dolist (event (reverse events))
      (funcall event))))

(defun in-main-thread-p ()
  *in-main-thread*)

(defun push-event (fn)
  (sb-thread:with-mutex ((request-channel-lock *request-channel*))
    (push fn (request-channel-queue *request-channel*)))
  (let ((out (request-channel-out *request-channel*)))
    ;; For now, just write a single byte since all we want is for the
    ;; main thread to process the queue. If we want to handle
    ;; different types of events, we'll have to change this so that
    ;; the message sent indicates the event type instead.
    (write-byte 0 out)
    (finish-output out)))

(defun call-in-main-thread (fn)
  (cond ((in-main-thread-p)
         (funcall fn))
        (t
         (push-event fn))))

(defclass display-channel ()
  ((display :initarg :display)))

(defmethod io-channel-ioport (io-loop (channel display-channel))
  (sb-sys:fd-stream-fd
   (xlib::display-input-stream (slot-value channel 'display))))

(defmethod io-channel-events ((channel display-channel))
  (list :read :loop))

(flet ((dispatch-all (display)
         (block handle
           (loop
             (xlib:display-finish-output display)
             (let ((nevents (xlib:event-listen display 0)))
               (unless nevents (return-from handle))
               (xlib:with-event-queue (display)
                 (run-hook *event-processing-hook*)
                 ;; Note: process-event appears to hang for an unknown
                 ;; reason. This is why it is passed a timeout in hopes that
                 ;; this will keep it from hanging.
                 (xlib:process-event display :handler #'handle-event :timeout 0)))))))
  (defmethod io-channel-handle ((channel display-channel) (event (eql :read)) &key)
    (dispatch-all (slot-value channel 'display)))
  (defmethod io-channel-handle ((channel display-channel) (event (eql :loop)) &key)
    (dispatch-all (slot-value channel 'display))))

(defun wm-internal-loop ()
  (loop
    (with-simple-restart (:new-io-loop "Recreate I/O loop")
      (let ((io (make-instance *default-io-loop*)))
        (io-loop-add io (make-instance 'wm-timer-channel))
        (io-loop-add io (make-instance 'display-channel :display *display*))
        ;; If we have no implementation for the current CL, then
        ;; don't register the channel.
        (multiple-value-bind (in out) (open-pipe)
          (let ((channel (make-instance 'request-channel :in in :out out)))
            (io-loop-add io channel)
            (setq *request-channel* channel)))
        (setf *toplevel-io* io)
        (loop
          (handler-bind
              ((t (lambda (c)
                    (handle-top-level-condition c))))
            (io-loop io :description "WM")))))))

(defun parse-display-string (display)
  "Parse an X11 DISPLAY string and return the host and display from it."
  (ppcre:register-groups-bind (protocol host ('parse-integer display screen))
      ("^(?:(.*?)/)?(.*?)?:(\\d+)(?:\\.(\\d+))?" display :sharedp t)
    (values
     ;; xlib doesn't like (vector character *)
     (coerce (or host "")
             '(simple-array character (*)))
     display screen
     (cond (protocol
            (intern1 protocol :keyword))
           ((or (string= host "")
                (string-equal host "unix"))
            :local)
           (t :internet)))))

(defun close-resources ()
  (xlib:close-display *display*)
  (close-log))

(defun wm-internal (display-str)
  (multiple-value-bind (host display screen protocol) (parse-display-string display-str)
    (declare (ignore screen))
    (setf *display* (xlib:open-display host :display display :protocol protocol)
          (xlib:display-error-handler *display*) 'error-handler)
    (with-simple-restart (quit-wm "Quit WM")
      ;; In the event of an error, we always need to close the display
      (unwind-protect
           (progn
             (let ((*initializing* t))
               ;; we need to do this first because init-screen grabs keys
               (update-modifier-map)
               ;; Initialize all the screens
               (setf *screen-list* (loop for i in (xlib:display-roots *display*)
                                         for n from 0
                                         collect (init-screen i n host)))
               (xlib:display-finish-output *display*)
               ;; Enable minor mode keymap lookup. This needs to be done after
               ;; screens are initialized.
               (push #'minor-mode-top-maps *minor-mode-maps*)
               ;; Load rc file
               (let ((*package* (find-package *default-wm-package*)))
                 (multiple-value-bind (success err rc) (load-rc-file)
                   (if success
                       (and *startup-message* (wm-message *startup-message* (print-key *escape-key*)))
                       (wm-message "^B^1*Error loading ^b~A^B: ^n~A." rc err))))
               (when *last-unhandled-error*
                 (message-no-timeout "^B^1*WM Crashed With An Unhandled Error!~%Copy the error to the clipboard with the 'copy-unhandled-error' command.~%^b~a^B^n~%~%~a."
                                     (first *last-unhandled-error*) (second *last-unhandled-error*)))
               (mapc 'process-existing-windows *screen-list*)
               ;; We need to setup each screen with its current window. Go
               ;; through them in reverse so the first screen's frame ends up
               ;; with focus.
               (dolist (s (reverse *screen-list*))
                 ;; map the current group's windows
                 (mapc 'unhide-window (reverse (group-windows (screen-current-group s))))
                 ;; update groups
                 (dolist (g (reverse (screen-groups s)))
                   (dformat 3 "Group windows: ~S~%" (group-windows g))
                   (group-startup g))
                 ;; switch to the (old) current group.
                 (let ((netwm-id (first (xlib:get-property (screen-root s) :_NET_CURRENT_DESKTOP))))
                   (when (and netwm-id (< netwm-id (length (screen-groups s))))
                     (switch-to-group (elt (sort-groups s) netwm-id))))
                 (redraw-current-message (current-screen))))
             (run-hook *pre-thread-hook*)
             ;; Start hashing the user's PATH so completion is quick
             ;; the first time they try to run a command.
             (sb-thread:make-thread #'rehash)
             ;; Let's manage.
             (let ((*package* (find-package *default-wm-package*)))
               (run-hook *start-hook*)
               (wm-internal-loop)))
        (close-resources))))
  :quit)
  
(defun force-wm-restart (&key (close-display t))
  (when close-display
    (xlib:close-display *display*))
  (apply 'execv (first sb-ext:*posix-argv*) sb-ext:*posix-argv*))

;; Usage: (start-wm)
(defun start-wm (&optional (display-str (or (sb-posix:getenv "DISPLAY") ":0")))
  "Start the stump window manager."
  (std:init :xdg)
  (setf *data-dir* (default-data-dir))  
  (ensure-data-dir)
  (init-load-path *module-dir*)
  (open-log)
  (set-signal-handler sb-posix:sighup
    (dformat 0 "SIGHUP received: forcing immediate restart of wm~%")
    (force-wm-restart))
  (let ((*in-main-thread* t))
    (dformat 10 "initialization complete~%")
    (loop
      (let ((ret (catch :top-level
                   (wm-internal display-str))))
        (setf *last-unhandled-error* nil)
        (cond ((and (consp ret)
                    (typep (first ret) 'condition))
               (format t "~&Caught '~a' at the top level. Please report this.~%~a"
                       (first ret) (second ret))
               (setf *last-unhandled-error* ret))
              ;; we need to jump out of the event loop in order to hup
              ;; the process because otherwise we get errors.
              ((eq ret :hup-process)
               (run-hook *restart-hook*)
               (force-wm-restart :close-display nil))
              ((eq ret :restart)
               (run-hook *restart-hook*))
              (t
               (run-hook *quit-hook*)
               (sb-ext:exit :code 0)))))))
