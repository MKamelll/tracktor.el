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

(cl-defun tracktor-tv-show-get-most-favourited (&key period callback)
  "Get the most favourited shows by period"
  (cl-check-type period (member weekly monthly daily all))
  (tracktor--trakt-get (format "/shows/favorited/%s" period)
                       :callback callback))


(cl-defun tracktor-tv-show-get-most-played (&key period callback)
  "Get the most played shows by period"
  (cl-check-type period (member weekly monthly daily all))
  (tracktor--trakt-get (format "/shows/played/%s" period)
                       :callback callback))

(cl-defun tracktor-tv-show-get-most-watched (&key period callback)
  "Get the most watched shows by period"
  (cl-check-type period (member weekly monthly daily all))
  (tracktor--trakt-get (format "/shows/watched/%s" period)
                       :callback callback))

(cl-defun tracktor-tv-show-get-most-collected (&key period callback)
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

(cl-defun tracktor-tv-show-get-comments (show-name &key sort callback)
  "Get all the comments for a show with a sort"
  (cl-check-type sort (member likes likes_30 replies replies_30 watched plays rating added))
  (tracktor--trakt-get
   (format "/shows/%s/comments/%s"
           (replace-regexp-in-string " " "-" show-name)
           sort)
   :callback callback)
  )

(cl-defun tracktor-tv-show-get-lists-containing (show-name &key type sort)
  "Get all the lists containing a show"
  (cl-check-type sort (member popular likes comments items added updated))
  (cl-check-type type (member all personal official watchlists favorites))
  (tracktor--trakt-get
   (format "/shows/%s/lists/%s/%s"
           (replace-regexp-in-string " " "-" show-name)
           type
           sort)
   :callback callback)
  )

(cl-defun tracktor-tv-show-get-collection-progress
    (show-name &key hidden? specials? count-specials? callback)
  "Get the collected progress of a show for the user, for physical media or bought online"
  (tracktor--trakt-get
   (format "/shows/%s/progress/collection"
           (replace-regexp-in-string " " "-" show-name))
   :auth? t
   :params `(("hidden" . ,(if hidden?
                              "true"
                            "false"))
             ("specials" . ,(if specials?
                                "true"
                              "false"))
             ("count_specials" . ,(if count-specials?
                                      "true"
                                    "false")))
   :callback callback)
  )

(cl-defun tracktor-tv-show-get-watched-progress
    (show-name &key hidden? specials? count-specials? callback)
  "Get the progress watched of a show for the user"
  (tracktor--trakt-get
   (format "/shows/%s/progress/watched"
           (replace-regexp-in-string " " "-" show-name))
   :auth? t
   :params `(("hidden" . ,(if hidden?
                              "true"
                            "false"))
             ("specials" . ,(if specials?
                                "true"
                              "false"))
             ("count_specials" . ,(if count-specials?
                                      "true"
                                    "false")))
   :callback callback)
  )


(cl-defun tracktor-tv-show-get-people (show-name &key callback)
  "Get the cast and crew for a show"
  (tracktor--trakt-get
   (format "/shows/%s/people"
           (replace-regexp-in-string " " "-" show-name))
   :callback callback)
  )

(cl-defun tracktor-tv-show-get-rating (show-name &key callback)
  "Get ratings for a show"
  (tracktor--trakt-get
   (format "/shows/%s/ratings"
           (replace-regexp-in-string " " "-" show-name))
   :callback callback)
  )

(cl-defun tracktor-tv-show-get-related (show-name &key callback)
  "Get related shows for a show"
  (tracktor--trakt-get
   (format "/shows/%s/related"
           (replace-regexp-in-string " " "-" show-name))
   :callback callback)
  )


(cl-defun tracktor-tv-show-get-seasons (show-name &key callback)
  "Get seasons for a show"
  (tracktor--trakt-get
   (format "/shows/%s/seasons"
           (replace-regexp-in-string " " "-" show-name))
   :callback callback)
  )

(cl-defun tracktor-tv-show-get-season (show-name season-number &key callback)
  "Get a single season for a show"
  (tracktor--trakt-get
   (format "/shows/%s/seasons/%d/info"
           (replace-regexp-in-string " " "-" show-name)
           season-number)
   :callback callback)
  )

(cl-defun tracktor-tv-show-get-season-episodes (show-name season-number &key callback)
  "Get a single season episodes for a show"
  (tracktor--trakt-get
   (format "/shows/%s/seasons/%d"
           (replace-regexp-in-string " " "-" show-name)
           season-number)
   :callback callback)
  )

(cl-defun tracktor-tv-show-get-season-comments (show-name season-number &key sort callback)
  "Get a single season comments for a show"
  (cl-check-type sort (member likes likes_30 replies replies_30 watched plays rating added))
  (tracktor--trakt-get
   (format "/shows/%s/seasons/%d/comments/%s"
           (replace-regexp-in-string " " "-" show-name)
           season-number
           sort)
   :callback callback)
  )

(cl-defun tracktor-tv-show-get-season-ratings (show-name season-number &key callback)
  "Get a single season ratings for a show"
  (tracktor--trakt-get
   (format "/shows/%s/seasons/%d/ratings"
           (replace-regexp-in-string " " "-" show-name)
           season-number)
   :callback callback)
  )

(cl-defun tracktor-tv-show-get-episode (show-name season-number episode-number &key callback)
  "Get a single episode for a show"
  (tracktor--trakt-get
   (format "/shows/%s/seasons/%d/episodes/%d"
           (replace-regexp-in-string " " "-" show-name)
           season-number
           episode-number)
   :callback callback)
  )

(cl-defun tracktor-tv-show-get-episode-comments
    (show-name season-number episode-number &key sort callback)
  "Get a single episode comments for a show"
  (cl-check-type sort (member likes likes_30 replies replies_30 plays rating added))
  (tracktor--trakt-get
   (format "/shows/%s/seasons/%d/episodes/%d/comments/%s"
           (replace-regexp-in-string " " "-" show-name)
           season-number
           episode-number
           sort)
   :auth? t
   :callback callback)
  )

(cl-defun tracktor-tv-show-get-episode-people
    (show-name season-number episode-number &key callback)
  "Get a single episode people for a show"
  (tracktor--trakt-get
   (format "/shows/%s/seasons/%d/episodes/%d/people"
           (replace-regexp-in-string " " "-" show-name)
           season-number
           episode-number)
   :callback callback)
  )

(cl-defun tracktor-tv-show-get-episode-ratings
    (show-name season-number episode-number &key callback)
  "Get a single episode ratings for a show"
  (tracktor--trakt-get
   (format "/shows/%s/seasons/%d/episodes/%d/ratings"
           (replace-regexp-in-string " " "-" show-name)
           season-number
           episode-number)
   :callback callback)
  )

(tracktor-tv-show-get-episode-ratings "breaking bad" 1 1
                                     :callback (lambda (res)
                                                 (message "%s" res)))
(provide 'tracktor-api)
;;; tracktor-api.el ends here
