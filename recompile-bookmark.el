;;; recompile-bookmark.el --- Bookmark compile commands for recompilation -*- lexical-binding: t -*-

;; Copyright (C) 2021 Akira Komamura

;; Author: Akira Komamura <akira.komamura@gmail.com>
;; Version: 0.1
;; Package-Requires: ((emacs "26.1"))
;; Keywords: processes convenience
;; URL: https://github.com/akirak/recompile-bookmark.el

;; This file is not part of GNU Emacs.

;;; License:

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; This library provides `recompile-bookmark-store' command, which stores the
;; current compilation command to your bookmarks. The bookmark can be used to
;; rerun the command.

;;; Code:

(require 'compile)

;;;###autoload
(defun recompile-bookmark-handler (bookmark)
  "Restart a compile command from BOOKMARK."
  (let ((command (cdr (assoc 'command bookmark)))
        (comint (cdr (assoc 'comint bookmark)))
        (default-directory (cdr (assoc 'directory bookmark))))
    (save-some-buffers (not compilation-ask-about-save)
                       compilation-save-buffers-predicate)
    (compile command comint)))

(defun recompile-bookmark-make-record ()
  "Build a bookmark record for the current compilation buffer."
  `(,(format "%s: %s" compilation-directory compile-command)
    (filename . ,compilation-directory)
    (command . ,compile-command)
    (directory . ,compilation-directory)
    (comint . ,compilation-shell-minor-mode)
    (handler . recompile-bookmark-handler)))

;;;###autoload
(defun recompile-bookmark-store ()
  "Bookmark the current compile command."
  (interactive)
  (pcase-let ((`(,name . ,alist) (with-current-buffer
                                     (or (get-buffer "*compilation*")
                                         (user-error "Compilation buffer is not found"))
                                   (recompile-bookmark-make-record))))
    (bookmark-store (read-string "Bookmark name: " name)
                    alist nil)))

(provide 'recompile-bookmark)
;;; recompile-bookmark.el ends here
