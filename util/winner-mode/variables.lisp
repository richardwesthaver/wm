(in-package #:wm/winner-mode)

(defvar *current-ids* (make-hash-table))
(defvar *max-ids* (make-hash-table))
(defvar *tmp-folder* #p"/tmp/")
(defvar *default-commands*
  '(wm:only
    wm:pull-from-windowlist
    wm:pull-hidden-next
    wm:pull-hidden-other
    wm:pull-hidden-previous
    wm:pull-marked
    wm:pull-window-by-number
    wm:next-window
    wm:next-in-frame
    wm:next-urgent
    wm:prev-window
    wm:prev-in-frame
    wm:select-window
    wm:select-from-menu
    wm:select-window-by-name
    wm:select-window-by-number
    wm::pull
    wm::remove
    wm:iresize
    wm:vsplit
    wm:hsplit
    wm:move-window
    wm:move-windows-to-group
    wm:move-window-to-group
    wm:balance-frames
    wm::delete
    wm::kill
    wm:fullscreen))
