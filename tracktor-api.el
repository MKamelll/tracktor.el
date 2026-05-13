;;; tracktor-api.el --- trakt.tv api wrapper for the tracktor plugin -*- lexical-binding: t -*-


;;; Code:
(add-to-list 'load-path "~/playground/tracktor")
(require 'cl-lib)
(require 'tracktor-api-auth)

;; (tracktor--trakt-get "/search/show"
;;                      :params '(("query" . "breaking bad"))
;;                      :callback (lambda (res)
;;                                  (message "%s" res)))

;; https://api.trakt.tv/shows/id/comments/sort
(tracktor--trakt-get (format "/shows/%s/comments/%s" "breaking-bad" "likes")
                     :auth? t
                     :callback (lambda (res)
                                 (message "%s" res)))

(provide 'tracktor-api)
;;; tracktor-api.el ends here
