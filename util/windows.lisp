;;; util/windows.lisp --- Window Utils

;;; Code:
(in-package #:wm/windows)

;;; Global Windows
(defun global-windows ()
  "Returns a list of the names of all the windows in the current screen."
  (let ((groups (sort-groups (current-screen)))
        (windows nil))
    (dolist (group groups)
      (dolist (window (group-windows group))
        ;; Don't include the current window in the list
        (when (not (eq window (current-window)))
          (push window windows))))
    windows))

(defun goto-window (window)
  "Raise the window win and select its frame.  For now, it does not
select the screen."
  (let* ((group (window-group window))
         (frame (window-frame window))
         (old-frame (tile-group-current-frame group)))
    (frame-raise-window group frame window)
    (focus-all window)
    (unless (eq frame old-frame)
      (show-frame-indicator group))))

(define-wm-type :global-window-names (input prompt)
  (labels
      ((global-window-names ()
         (mapcar (lambda (window) (window-name window)) (global-windows))))
    (or (argument-pop input)
        (completing-read (current-screen) prompt (global-window-names)))))

(defmacro with-global-windowlist (name docstring &rest args)
 `(defcommand ,name (&optional (fmt *window-format*)) (:rest)
   ,docstring
   (let ((global-windows-list (global-windows)))
     (labels
         ((sort-windows (windowlist)
            (sort1 windowlist 'string-lessp :key 'window-name)))
       (if (null global-windows-list)
           (wm-message "No other windows on screen ;)")
           (let ((window (select-window-from-menu (sort-windows global-windows-list) fmt)))
             (when window
               (progn ,@args))))))))

(with-global-windowlist global-windowlist "Like windowlist, but for all groups not just the current one."
  (goto-window window))

(with-global-windowlist global-pull-windowlist
  "Global windowlist for pulling windows to the current frame."
  (when (not (equalp (window-group window)
                     (current-group)))
    (move-window-to-group window (current-group)))
  (pull-window window))

;;; Urgent Windows
(defvar *urgent-windows-stack* nil
  "Stack of windows gone urgent. After activating a window from the stack,
 it goes off the stack")

(defvar *urgent-window-message* "~a needs your attention."
  "Message template to be displayed to grab user's attention")

(defun echo-urgent-window (target)
  (message-no-timeout *urgent-window-message* (window-title target))
  (push target *urgent-windows-stack*))

(add-wm-hook *urgent-window-hook* 'echo-urgent-window)

(defun raise-urgent-window ()
  (let ((last-urgent (pop *urgent-windows-stack*)))
    (when last-urgent
      (gselect (group-name (window-group last-urgent)))
      (really-raise-window last-urgent))))

(defcommand raise-urgent () ()
  "Raise urgent window"
  (raise-urgent-window))

;;; Window Tags
;; Copyright 2009 Michael Raskin
(defvar *tag-group-name* ".tag-store")

;; String parsing for commands
(defun string-split-by-spaces (x)
  (if (not x) nil 
      (if (listp x) (mapcar 'string-upcase x)
          (ppcre:split " " (string-upcase x)))))

;; Basic operations
(defcommand window-tags (&optional (argwin nil)) ()
  "Show window tags"
  (let* ((win (or argwin (current-window)))
         (tags (xlib:get-property (window-xwin win) :WM_TAGS))
         (tagstring (utf8-to-string tags))
         (taglist 
           (if tags (string-split-by-spaces tagstring) nil)))
    (if argwin taglist (wm-message "Tags: ~{~%~a~}" taglist))))

(defun (setf window-tags) (newtags &optional (argwin nil))
  "Set the window tag set for a window"
  (let* ((win (or argwin (current-window)))
         (tagstring (format nil "~{~A ~}" (mapcar 'string-upcase newtags))))
    (xlib:change-property 
     (window-xwin win)
     :WM_TAGS
     (sb-ext:string-to-octets
      tagstring
      :external-format :utf-8)
     :UTF8_STRING 8)))

(defun clear-tags-if (clearp &optional (argwin nil))
  "Remove tags matched by predicate"
  (let*
      ((win (or argwin (current-window)))
       (new-tags (remove-if clearp (window-tags win))))
    (setf (window-tags win) new-tags)))

;; Commands for basic operations
(defcommand clear-tags (&optional (argtags nil) (argwin nil)) (:rest :rest)
  "Remove specified or all tags"
  (let*
      ((tags (string-split-by-spaces argtags))
       (condition (if tags 
                      (lambda (x) (find x tags :test 'equalp)) 
                      (constantly t))))
    (clear-tags-if condition argwin)))

(defcommand clear-all-tags () ()
  "Remove all tags and start afresh"
  (mapcar (lambda (x) (clear-tags nil x)) (screen-windows (current-screen))))

(defcommand tag-window (argtag &optional (argwin nil)) ((:rest "Tag to set: ") :rest)
  "Add a tag to current window"
  (let*
      ((win (or argwin (current-window)))
       (tag (string-split-by-spaces argtag)))
    (setf (window-tags win) (union tag (window-tags win) :test 'equalp))))

(defcommand all-tags () ()
  "List all windows with their tags"
  (let ((*suppress-echo-timeout* t))
    (wm-message 
     "Window list: ~{~%~{[ ~a ] ( ~a | ~a | ~a ) ~% ->~{~a, ~}~}~}"
     (mapcar
      (lambda (x)
        (list
         (window-title x)
         (window-class x)
         (window-res x)
         (window-role x)
         (window-tags x)))
      (screen-windows (current-screen))))))

;; Selection of tags and windows by tags
(defun tags-from (argtags &optional (argwindow nil))
  "Check whether (current) window has one of the specified tags.
  Tag T is implicitly assigned to all windows."
  (let*
      ((tags (string-split-by-spaces argtags))
       (window (or argwindow (current-window)))
       (wtags (union (list "T") (window-tags window) :test 'equalp)))
    (intersection tags wtags :test 'equalp)))

(defun select-by-tags (argtags &optional (without nil))
  "Select windows with (without) one of the specified tags 
  (any of the specified tags) from current screen. Tag T
  is implicitly assigned to every window"
  (let*
      ((tags (string-split-by-spaces argtags))
       (condition (lambda (w) (tags-from tags w)))
       (windows (screen-windows (current-screen))))
    (if without 
        (remove-if condition windows)
        (remove-if-not condition windows))))

;; Window manipulations using tags

;; And convenient instances
(defcommand pull-tag (argtag) ((:rest "Tag(s) to pull: "))
  "Pull all windows with the tag (any of the tags) to current group"
  (move-windows-to-group (select-by-tags (string-split-by-spaces argtag))))

(defcommand push-without-tag (argtag) ((:rest "Tag(s) needed to stay in the group: "))
  "Push windows not having the tag (any of the tags) to *TAG-GROUP-NAME*"
  (move-windows-to-group (select-by-tags (string-split-by-spaces argtag) T) *tag-group-name*))

(defcommand push-tag (argtag) ((:rest "Tag(s) to push: "))
  "Push windows having the tag (any of the tags) to *TAG-GROUP-NAME*"
  (move-windows-to-group (select-by-tags (string-split-by-spaces argtag)) *tag-group-name*))

(defcommand pull+push (argtag) ((:rest "Tag(s) to select: "))
  "Pull all windows with the tag, push all without"
  (pull-tag argtag)
  (push-without-tag argtag))

(defcommand push-window () ()
  "Push window to tag store"
  (move-windows-to-group (list (current-window)) *tag-group-name*))

;; Manage window numbers by tags..
(defun window-number-from-tag (window)
  "Find a numeric tag, if any, and parse it"
  (let*
      ((tags (window-tags window))
       (numtag (find-if (lambda (x) (ppcre:scan "^[0-9]+$" x)) tags))
       (num (and numtag (parse-integer numtag))))
    num))

(defcommand number-by-tags () ()
  "Every window tagged <number> will have a chance to have that number. The
remaining windows will have packed numbers"
  ;; First, assign impossible numbers.
  (mapcar
   (lambda (x)
     (setf (window-number x) -1))
   (group-windows (current-group)))
  ;; Now try to assign numbers to windows holding corresponding tags.
  (mapcar
   (lambda (x) 
     (let* 
         ((num (window-number-from-tag x))
          (occupied (mapcar 'window-number (group-windows (current-group)))))
       (if (and num (not (find num occupied)))
           (setf (window-number x) num))))
   (group-windows (current-group)))
  ;; Give up and give smallest numbers possible
  (repack-window-numbers 
   (mapcar 'window-number
           (remove-if-not 
            (lambda (x) (equalp (window-number x) (window-number-from-tag x)))
            (group-windows (current-group))))))

(defcommand tag-visible (&optional (argtags nil)) (:rest)
  "IN-CURRENT-GROUP or another specified tag will be assigned to all windows
in current group and only to them"
  (let ((tags (if (or (equalp argtags "") (not argtags)) "IN-CURRENT-GROUP" argtags)))
    (mapcar (lambda (x) (clear-tags tags x)) (screen-windows (current-screen)))
    (mapcar (lambda (x) (tag-window tags x)) (group-windows (current-group)))))

(defcommand raise-tag (tag) ((:rest "Tag to pull: "))
  "Make window current by tag"
  (let*
      ((window (car (select-by-tags tag))))
    (if window
        (progn
          (if (groups)
              (progn
                (move-windows-to-group (list window))
                (really-raise-window window))
              (raise-window window))
          window)
        nil)))

(defcommand search-tag (tag-regex) ((:rest "Tag regex to select: "))
  (only)
  (fclear)
  (let* ((current (current-group (current-screen)))
         (tag-store (find-group (current-screen) *tag-group-name*)))
    (loop for w in (screen-windows (current-screen)) 
          do (if (find-if (lambda (s) (ppcre:scan (concatenate 'string "(?i)" tag-regex) s)) (window-tags w))
                 (move-window-to-group w current)
                 (move-window-to-group w tag-store)))))

(defcommand search-tag-pull (tag-regex) ((:rest "Tag regex to pull: "))
  (only)
  (fclear)
  (let ((current (current-group (current-screen))))
    (loop for w in (screen-windows (current-screen)) 
          do (if (find-if (lambda (s) (ppcre:scan (concatenate 'string "(?i)" tag-regex) s)) (window-tags w))
                 (move-window-to-group w current)))))

(defcommand select-by-title-regexp (regex) ((:rest "Title regex to select: "))
  (only)
  (fclear)
  (let* ((current (current-group (current-screen)))
         (tag-store (find-group (current-screen) *tag-group-name*)))
    (loop for w in (screen-windows (current-screen)) 
          do (if (ppcre:scan regex (window-title w))
                 (move-window-to-group w current)
                 (move-window-to-group w tag-store)))))

(defcommand pull-by-title-regexp (regex) ((:rest "Title regex to select: "))
  (only)
  (fclear)
  (let ((current (current-group (current-screen))))
    (loop for w in (screen-windows (current-screen)) 
          do (when (ppcre:scan regex (window-title w))
               (move-window-to-group w current)))))

;;; Beckon
(defvar *window-height-fraction* 0.5
  "height from the top of the frame")

(defvar *window-width-fraction* 0.5
  "width from the top of the frame")

(defcommand beckon () ()
  "Beckon the mouse to the current window"
  (with-accessors ((x frame-x)
                   (y frame-y)
                   (height frame-height)
                   (width frame-width))
      (window-frame (current-window))
    (ratwarp
     (round
      (+ x (* width *window-height-fraction*)))
     (round
      (+ y (* height *window-width-fraction*))))))
