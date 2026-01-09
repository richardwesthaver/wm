;;; module.lisp --- WM Modules

;; Copyright (C) 2008 Julian Stecklina, Shawn Betts, Ivy Foster
;; Copyright (C) 2014 David Bjergaard

;;; Commentary:

;; Use `set-module-dir' to set the location WM searches for modules.

;;; Code:
(in-package #:wm)

(defvar *module-dir*
  (directory-path (merge-homedir-pathnames ".config/wm/lisp"))
  "The location of the contrib modules on your system. Defaults to ~/.config/wm/lisp.")

(defun build-load-path (path)
  "Maps subdirectories of path, returning a list of all subdirs in the
  path which contain any files ending in .asd"
  (let ((ret))
    (walk-directory path (constantly t) (constantly t)
                    (lambda (d) 
                      (mapc (lambda (f) 
                              (when (equal "asd" (pathname-type f))
                                (push
                                 (directory-namestring f)
                                 ret)))
                            (directory-files d))))
    (nreverse ret)))

(defvar *load-path* nil
  "A list of paths in which modules can be found, by default it is
  populated by any asdf systems found in `*module-dir*' set from the
  configure script when WM was built, or later by the user using
  `add-to-load-path'")

(define-wm-type :module (input prompt)
  (or (argument-pop-rest input)
      (completing-read (current-screen) prompt (list-modules) :require-match t)))

(defun find-asd-file (path)
  "Returns the first file ending with asd in `PATH', nil else."
  (first (remove-if-not (lambda (file)
                          (uiop:string-suffix-p (file-namestring file) ".asd"))
                        (directory-files path))))

(defun list-modules ()
  "Return a list of the available modules."
  (flet ((list-module (dir)
           (when-let ((f (find-asd-file dir)))
             (pathname-name
              (pathname f)))))
    (flatten (mapcar #'list-module *load-path*))))

(defun ensure-pathname (path)
  (if (stringp path) (first (directory path))
      path))
(defcommand set-contrib-dir () (:rest)
  "Deprecated, use `add-to-load-path' instead"
  (wm-message "Use add-to-load-path instead."))
(defcommand add-to-load-path (path) ((:string "Directory: "))
  "If `PATH' is not in `*LOAD-PATH*' add it, check if `PATH' contains
an asdf system, and if so add it to the central registry"
  (let* ((pathspec (find (ensure-pathname path)  *load-path*))
         (in-central-registry (find pathspec asdf:*central-registry*))
         (is-asdf-path (find-asd-file path)))
    (cond ((and pathspec in-central-registry is-asdf-path) *load-path*)
          ((and pathspec is-asdf-path (not in-central-registry))
           (push pathspec asdf:*central-registry*))
          ((and is-asdf-path (not pathspec))
           (push (ensure-pathname path) asdf:*central-registry*)
           (push (ensure-pathname path) *load-path*))
          (T *load-path*))))

(defcommand init-load-path (path) ((:string "Directory: "))
  "Recursively builds a list of paths that contain modules, then
add them to the load path. This is called each time WM starts
with the argument `*module-dir*'"
  (mapcar #'add-to-load-path (build-load-path path))
  *load-path*)

(defun set-module-dir (dir)
  "Sets the location of the for WM to find modules"
  (when (stringp dir)
    (setf dir (pathname (concat dir "/"))))
  (setf *module-dir* dir)
  (init-load-path dir))

(defcommand load-wm-module (name) ((:module "Load module: "))
  "Loads the contributed module with the given NAME."
  (let ((module (find name (list-modules) :test #'string-equal)))
    (if module
        (asdf:operate 'asdf:load-op module)
        (error "Could not load or find module: ~s" name))))
