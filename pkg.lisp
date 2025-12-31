;;; package.lisp -- StumpWM Packages

;; Copyright (C) 2003-2008 Shawn Betts

;;  This file is part of stumpwm.

;; stumpwm is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; stumpwm is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this software; see the file COPYING.  If not, see
;; <http://www.gnu.org/licenses/>.

;;; Code:
(defpackage :wm
  (:use #:cl #:std #:obj/meta/mix)
  (:import-from #:sb-debug #:print-backtrace #:backtrace)
  (:shadow #:yes-or-no-p #:y-or-n-p)
  (:export 
   ;; primitives
   *suppress-abort-messages*
   *suppress-frame-indicator*
   *suppress-window-placement-indicator*
   *timeout-wait*
   *timeout-wait-multiline*
   *timeout-frame-indicator-wait*
   *frame-indicator-text*
   *frame-indicator-timer*
   *message-window-timer*
   *hooks-enabled-p*
   *command-mode-start-hook*
   *command-mode-end-hook*
   *urgent-window-hook*
   *new-window-hook*
   *new-head-hook*
   *destroy-window-hook*
   *focus-window-hook*
   *place-window-hook*
   *pre-thread-hook*
   *start-hook*
   *restart-hook*
   *quit-hook*
   *internal-loop-hook*
   *event-processing-hook*
   *focus-frame-hook*
   *new-frame-hook*
   *split-frame-hook*
   *remove-split-hook*
   *message-hook*
   *top-level-error-hook*
   *focus-group-hook*
   *key-press-hook*
   *root-click-hook*
   *new-mode-line-hook*
   *destroy-mode-line-hook*
   *mode-line-click-hook*
   *pre-command-hook*
   *post-command-hook*
   *selection-notify-hook*
   *menu-selection-hook*
   *display*
   *shell-program*
   *maxsize-border-width*
   *transient-border-width*
   *normal-border-width*
   *text-color*
   *window-events*
   *window-parent-events*
   *message-window-padding*
   *message-window-y-padding*
   *message-window-margin*
   *message-window-y-margin*
   *message-window-gravity*
   *message-window-real-gravity*
   *message-window-input-gravity*
   *editor-bindings*
   *input-window-gravity*
   *normal-gravity*
   *maxsize-gravity*
   *transient-gravity*
   *top-level-error-action*
   *window-name-source*
   *frame-number-map*
   *all-modifiers*
   *modifiers*
   *screen-list*
   *initializing*
   *processing-existing-windows*
   *executing-stumpwm-command*
   *debug-level*
   *debug-expose-events*
   *debug-stream*
   *window-formatters*
   *window-format*
   *group-formatters*
   *group-format*
   *list-hidden-groups*
   *x-selection*
   *last-command*
   *max-last-message-size*
   *record-last-msg-override*
   *suppress-echo-timeout*
   *run-or-raise-all-groups*
   *run-or-raise-all-screens*
   *deny-map-request*
   *deny-raise-request*
   *suppress-deny-messages*
   *honor-window-moves*
   *resize-hides-windows*
   *min-frame-width*
   *min-frame-height*
   *new-frame-action*
   *new-window-preferred-frame*
   *startup-message*
   *default-package*
   *window-placement-rules*
   *mouse-focus-policy*
   *root-click-focuses-frame*
   *banish-pointer-to*
   *xwin-to-window*
   *resize-map*
   *default-group-name*
   *window-border-style*
   *data-dir*
   add-wm-hook
   remove-wm-hook
   clear-window-placement-rules
   concat
   data-dir-file
   dformat
   define-frame-preference
   redirect-all-output
   remove-all-hooks
   run-hook
   run-hook-with-args
   command-mode-start-message
   command-mode-end-message
   split-string
   with-restarts-menu
   with-data-file
   move-to-head
   format-expand
   ;; Frame accessors
   frame-x
   frame-y
   frame-width
   frame-height
   ;; Screen accessors
   screen-heads
   screen-root
   screen-focus
   screen-float-focus-color
   screen-float-unfocus-color
   ;; Window states
   +withdrawn-state+
   +normal-state+
   +iconic-state+
   ;; Modifiers
   modifiers
   modifiers-p
   modifiers-alt
   modifiers-altgr
   modifiers-super
   modifiers-meta
   modifiers-hyper
   modifiers-numlock
   ;; Conditions
   stumpwm-condition
   stumpwm-error
   stumpwm-warning
   ;; Completion Options
   *maximum-completions*
   ;; Minor mode keymaps
   *minor-mode-maps*
   ;; wrappers.lisp
   read-line-from-sysfs
   ;; kmap.lisp
   *top-map*
   *root-map*
   *key-seq-color*
   *altgr-offset*
   define-key
   kbd
   lookup-command
   lookup-key
   make-sparse-keymap
   undefine-key
   ;; input.lisp
   *input-history-ignore-duplicates*
   *input-candidate-selected-hook*
   *input-refine-candidates-fn*
   *input-completion-style*
   *input-map*
   *numpad-map*
   register-altgr-as-modifier
   completing-read
   input-delete-region
   input-goto-char
   input-insert-char
   input-insert-string
   input-point
   input-refine-prefix
   input-refine-fuzzy
   input-refine-regexp
   input-substring
   input-validate-region
   read-one-char
   read-one-line
   ;; core.lisp
   grab-pointer ungrab-pointer
   ;; command.lisp
   argument-line-end-p
   argument-pop
   argument-pop-or-read
   argument-pop-rest
   define-stumpwm-command
   defcommand
   defcommand-alias
   define-stumpwm-type
   run-commands
   %interactivep%
   ;; menu-declarations.lisp
   *menu-map*
   *single-menu-map*
   *batch-menu-map*
   menu-entry
   menu-entry-display
   menu-entry-apply
   menu
   menu-abort
   menu-up
   menu-down
   menu-scroll-down
   menu-scroll-up
   menu-page-down
   menu-page-up
   menu-finish
   ;; menu-definitions.lisp
   menu-backspace
   entries-from-nested-list
   select-from-menu
   select-from-batch-menu
   command-menu
   ;; screen.lisp
   *default-bg-color*
   current-screen
   current-window
   screen-current-window
   screen-number
   screen-groups
   screen-windows
   screen-height
   screen-width
   set-fg-color
   set-bg-color
   set-border-color
   set-win-bg-color
   set-focus-color
   set-unfocus-color
   set-float-focus-color
   set-float-unfocus-color
   set-msg-border-width
   set-frame-outline-width
   set-font
   ;; head.lisp
   current-head
   ;; group.lisp
   current-group group-windows move-window-to-group add-group
   ;; Group accessors
   group group-screen group-windows group-number group-name
   ;; Group API
   group-startup group-add-window group-delete-window group-wake-up
   group-suspend group-current-window group-current-head
   group-resize-request group-move-request group-raise-request
   group-lost-focus group-indicate-focus group-focus-window
   group-button-press group-root-exposure group-add-head
   group-remove-head group-before-resize-head group-after-resize-head
   group-sync-all-heads group-sync-head
   ;; bindings.lisp
   *groups-map*
   *group-top-maps*
   *help-map*
   *help-keys*
   set-prefix-key
   *button-state*
   bind-key unbind-key
   ;; window.lisp
   *default-window-name*
   define-window-slot
   set-normal-gravity
   set-maxsize-gravity
   set-transient-gravity
   set-window-geometry
   find-wm-state
   add-wm-state
   remove-wm-state
   window window-xwin window-width window-height window-x window-y
   window-gravity window-group window-number window-parent window-title
   window-user-title window-class window-type window-res window-role
   window-unmap-ignores window-state window-normal-hints window-marked
   window-plist window-fullscreen window-screen
   ;; Window utilities
   update-configuration no-focus
   ;; Window management API
   update-decoration focus-window raise-window window-visible-p window-sync
   window-head really-raise-window
   ;; tile-window.lisp
   *ignore-wm-inc-hints*
   save-frame-excursion only-one-frame-p
   ;;; message-window.lisp
   echo-string
   swm-err
   wm-message
   gravity-coords
   with-message-queuing
   *queue-messages-p*
   ;; selection.lisp
   get-x-selection
   set-x-selection
   *default-selections*
   ;; module.lisp
   load-wm-module
   list-modules
   *load-path*
   *module-dir*
   init-load-path
   set-module-dir
   find-module
   add-to-load-path
   ;; ioloop.lisp
   io-channel-ioport io-channel-events io-channel-handle
   io-loop io-loop-add io-loop-remove io-loop-update
   *default-io-loop* *current-io-loop*
   cancel-timer
   timer-p
   idle-time
   run-with-timer
   *toplevel-io*
   stumpwm
   call-in-main-thread
   in-main-thread-p
   push-event
   close-resources
   defprogram-shortcut
   programs-in-path
   restarts-menu
   run-or-raise
   run-or-pull
   run-shell-command
   window-send-string
   define-interactive-keymap
   *resize-increment*
   iresize
   setup-iresize
   *help-max-height*
   *message-max-width*
   *which-key-format*
   ;; fdump.lisp
   ddump
   ddump-current
   ddump-screens
   dump-desktop-to-file
   dump-group-to-file
   dump-screen-to-file
   fdump
   fdump-current
   fdump-height
   fdump-number
   fdump-width
   fdump-windows
   fdump-x
   fdump-y
   gdump
   gdump-current
   gdump-name
   gdump-number
   gdump-tree
   place-existing-windows
   restore
   sdump
   sdump-current
   sdump-groups
   sdump-number
   ;; time.lisp
   *time-format-string-default*
   *time-modeline-string*
   time-format
   echo-date
   time
   refresh-time-zone
   ;; mode-line.lisp
   *mode-line-background-color*
   *mode-line-border-color*
   *mode-line-border-width*
   *mode-line-foreground-color*
   *mode-line-pad-x*
   *mode-line-pad-y*
   *mode-line-position*
   *mode-line-timeout*
   *screen-mode-line-format*
   *screen-mode-line-formatters*
   add-screen-mode-line-formatter
   register-ml-on-click-id
   enable-mode-line
   toggle-mode-line
   *hidden-window-color*
   *mode-line-highlight-template*
   bar
   bar-zone-color
   format-with-on-click-id
   ;; color.lisp
   *colors*
   update-color-map
   adjust-color
   update-screen-color-context
   lookup-color
   ;; wse.lisp
   move-windows-to-group act-on-matching-windows
   ;; dynamic-group.lisp
   set-dynamic-group-initial-values
   dynamic-group-p
   dynamic-group-master-layout
   dynamic-group-default-split-ratio
   dynamic-group-head-layout
   dynamic-group-head-split-ratio
   dynamic-group-overflow-policy
   dynamic-group-head-placement-policy
   *rotation-focus-policy*
   dyn-blacklist-command
   dyn-unblacklist-command
   define-remapped-keys *remapped-keys-enabled-p*
   ;; minor-modes.lisp
   minor-mode
   define-minor-mode
   add-minor-mode-scope
   define-minor-mode-scope
   define-descended-minor-mode-scope
   sync-all-minor-modes
   validate-superscope
   validate-scope
   *minor-mode*
   *minor-mode-enable-hook*
   *minor-mode-disable-hook*
   *unscoped-minor-modes*
   minor-mode-scope
   minor-mode-global-p
   enable-minor-mode
   disable-minor-mode
   autoenable-minor-mode
   autodisable-minor-mode
   minor-mode-keymap
   minor-mode-lighter
   list-modes
   list-minor-modes
   list-current-mode-objects
   list-mode-objects
   enabled-minor-modes
   current-minor-modes
   minor-mode-enabled-p
   find-minor-mode
   generate-keymap
   wm-quit))

(defpackage :wm-user
  (:shadowing-import-from :wm :completing-read)
  (:use #:std-lisp #:wm #:cli #:obj #:log #:net #:io))

