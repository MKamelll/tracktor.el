;;; tracktor.el --- trakt.tv plugin to track your tv/movies progress -*- lexical-binding: t -*-

;; Author: Mina Kamel <minallkamel@gmail.com>
;; Version: 0.1.0
;; Package-Requires: ((emacs "29.1") (magit-section "3.0") (request "0.3.3"))
;; Keywords: multimedia
;; URL: https://github.com/mkamelll/tracktor

;;; Commentary:
;; A trakt.tv plugin.

;;; Code:
(add-to-list 'load-path "~/playground/tracktor")
(require 'tracktor-api)

(provide 'tracktor)
;;; tracktor.el ends here
