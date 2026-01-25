;;; keytrans.lisp --- Key Translations

;; Copyright (C) 2006-2008 Matthew Kennedy

;;; Commentary:

;; Translate between wm key names and keysym names.

;;; Code:
(in-package #:wm)

(defvar *wm-keysym-name-table* (make-hash-table :test #'equal)
  "Hashtable mapping from wm key names to keysym names.")

(defun define-keysym-name (wm-name keysym-name)
  "Define a mapping from a WM-NAME to KEYSYM-NAME.
This function is used to translate Emacs-like names to keysym
names."
  (setf (gethash wm-name *wm-keysym-name-table*)
        keysym-name))

(defun wm-name-to-keysym-name (wm-name)
  (multiple-value-bind (value present-p)
      (gethash wm-name *wm-keysym-name-table*)
    (declare (ignore present-p))
    value))

(defun keysym-name-to-wm-name (keysym-name)
  (maphash (lambda (k v)
             (when (equal v keysym-name)
               (return-from keysym-name-to-wm-name k)))
           *wm-keysym-name-table*))

(defun wm-name-to-keysym (wm-name)
  "Return the keysym corresponding to WM-NAME.
If no mapping for WM-NAME exists, then fallback by calling
KEYSYM-NAME-CODE."
  (let ((keysym-name (wm-name-to-keysym-name wm-name)))
    (keysym-name-code (or keysym-name wm-name))))

(defun keysym-to-wm-name (keysym)
  "Return the wm key name corresponding to KEYSYM.
If no mapping for the wm key name exists, then fall back by
calling KEYSYM->KEYSYM-NAME."
  (let ((keysym-name (keysym-code-name keysym)))
    (or (keysym-name-to-wm-name keysym-name)
        keysym-name)))

(define-keysym-name "RET" "Return")
(define-keysym-name "ESC" "Escape")
(define-keysym-name "TAB" "Tab")
(define-keysym-name "DEL" "BackSpace")
(define-keysym-name "SPC" "space")
(define-keysym-name "!" "exclam")
(define-keysym-name "\"" "quotedbl")
(define-keysym-name "$" "dollar")
(define-keysym-name "£" "sterling")
(define-keysym-name "%" "percent")
(define-keysym-name "&" "ampersand")
(define-keysym-name "'" "apostrophe")
(define-keysym-name "`" "grave")
(define-keysym-name "&" "ampersand")
(define-keysym-name "(" "parenleft")
(define-keysym-name ")" "parenright")
(define-keysym-name "*" "asterisk")
(define-keysym-name "+" "plus")
(define-keysym-name "," "comma")
(define-keysym-name "-" "minus")
(define-keysym-name "." "period")
(define-keysym-name "/" "slash")
(define-keysym-name ":" "colon")
(define-keysym-name ";" "semicolon")
(define-keysym-name "<" "less")
(define-keysym-name "=" "equal")
(define-keysym-name ">" "greater")
(define-keysym-name "?" "question")
(define-keysym-name "@" "at")
(define-keysym-name "[" "bracketleft")
(define-keysym-name "\\" "backslash")
(define-keysym-name "]" "bracketright")
(define-keysym-name "^" "asciicircum")
(define-keysym-name "_" "underscore")
(define-keysym-name "#" "numbersign")
(define-keysym-name "{" "braceleft")
(define-keysym-name "|" "bar")
(define-keysym-name "}" "braceright")
(define-keysym-name "~" "asciitilde")
(define-keysym-name "«" "guillemotleft")
(define-keysym-name "»" "guillemotright")
(define-keysym-name "À" "Agrave")
(define-keysym-name "à" "agrave")
(define-keysym-name "Ç" "Ccedilla")
(define-keysym-name "ç" "ccedilla")
(define-keysym-name "É" "Eacute")
(define-keysym-name "é" "eacute")
(define-keysym-name "È" "Egrave")
(define-keysym-name "è" "egrave")
(define-keysym-name "Ê" "Ecircumflex")
(define-keysym-name "ê" "ecircumflex")
