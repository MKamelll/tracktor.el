;;; tracktor-api.el --- trakt.tv api wrapper for the tracktor plugin -*- lexical-binding: t -*-


;;; Code:
(add-to-list 'load-path "~/playground/tracktor")
(require 'cl-lib)
(require 'tracktor-api-auth)

(cl-defun tracktor-tv-show-search (show-name &key callback)
  "Search the api for show-name"
  (tracktor--trakt-get "/search/show"
                       :params `(("query" . ,show-name))
                       :callback callback))

(cl-defun tracktor-tv-show-get-trending (&key callback)
  "Get the most trending shows"
  (tracktor--trakt-get "/shows/trending"
                       :callback callback))

(cl-defun tracktor-tv-show-get-popular (&key callback)
  "Get the most popular shows"
  (tracktor--trakt-get "/shows/popular"
                       :callback callback))

(cl-defun tracktor-tv-show-get-most-favourited (period &key callback)
  "Get the most favourited shows by period"
  (cl-check-type period (member weekly monthly daily all))
  (tracktor--trakt-get (format "/shows/favorited/%s" period)
                       :callback callback))


(cl-defun tracktor-tv-show-get-most-played (period &key callback)
  "Get the most played shows by period"
  (cl-check-type period (member weekly monthly daily all))
  (tracktor--trakt-get (format "/shows/played/%s" period)
                       :callback callback))

(cl-defun tracktor-tv-show-get-most-watched (period &key callback)
  "Get the most watched shows by period"
  (cl-check-type period (member weekly monthly daily all))
  (tracktor--trakt-get (format "/shows/watched/%s" period)
                       :callback callback))

(cl-defun tracktor-tv-show-get-most-collected (period &key callback)
  "Get the most collected shows by period"
  (cl-check-type period (member weekly monthly daily all))
  (tracktor--trakt-get (format "/shows/collected/%s" period)
                       :callback callback))

(cl-defun tracktor-tv-show-get-most-anticipated (&key callback)
  "Get the most anticipated shows by period"
  (tracktor--trakt-get "/shows/anticipated"
                       :callback callback))


(cl-defun tracktor-tv-show-get-details (show-name &key extended callback)
  "Get a show details, if extended it returns the full details"
  (tracktor--trakt-get (format "/shows/%s" (replace-regexp-in-string " " "-" show-name))
                       :params (when (eq extended 'full)
                                 '(("extended" . "full")))
                       :callback callback))

(tracktor-tv-show-get-details "breaking bad"
                              :extended 'full
                              :callback (lambda (res)
                                          (message "%s" res)))
(provide 'tracktor-api)
;;; tracktor-api.el ends here
