;;; tracktor-api.el --- trakt.tv api wrapper for the tracktor plugin -*- lexical-binding: t -*-


;;; Code:
(add-to-list 'load-path "~/playground/tracktor")
(require 'cl-lib)
(require 'tracktor-api-auth)

(cl-defun tracktor-tv-show-search (show-name &key callback)
  "Search the api for show-name"
  (tracktor--trakt-request "/search/show"
                       :params `(("query" . ,show-name))
                       :callback callback))

(cl-defun tracktor-tv-show-get-trending (&key callback)
  "Get the most trending shows"
  (tracktor--trakt-request "/shows/trending"
                       :callback callback))

(cl-defun tracktor-tv-show-get-popular (&key callback)
  "Get the most popular shows"
  (tracktor--trakt-request "/shows/popular"
                       :callback callback))

(cl-defun tracktor-tv-show-get-most-favourited (&key period callback)
  "Get the most favourited shows by period"
  (cl-check-type period (member weekly monthly daily all))
  (tracktor--trakt-request (format "/shows/favorited/%s" period)
                       :callback callback))


(cl-defun tracktor-tv-show-get-most-played (&key period callback)
  "Get the most played shows by period"
  (cl-check-type period (member weekly monthly daily all))
  (tracktor--trakt-request (format "/shows/played/%s" period)
                       :callback callback))

(cl-defun tracktor-tv-show-get-most-watched (&key period callback)
  "Get the most watched shows by period"
  (cl-check-type period (member weekly monthly daily all))
  (tracktor--trakt-request (format "/shows/watched/%s" period)
                       :callback callback))

(cl-defun tracktor-tv-show-get-most-collected (&key period callback)
  "Get the most collected shows by period"
  (cl-check-type period (member weekly monthly daily all))
  (tracktor--trakt-request (format "/shows/collected/%s" period)
                       :callback callback))

(cl-defun tracktor-tv-show-get-most-anticipated (&key callback)
  "Get the most anticipated shows by period"
  (tracktor--trakt-request "/shows/anticipated"
                       :callback callback))


(cl-defun tracktor-tv-show-get-details (show-name &key extended callback)
  "Get a show details, if extended it returns the full details"
  (tracktor--trakt-request (format "/shows/%s" (replace-regexp-in-string " " "-" show-name))
                       :params (when (eq extended 'full)
                                 '(("extended" . "full")))
                       :callback callback))

(cl-defun tracktor-tv-show-get-comments (show-name &key sort callback)
  "Get all the comments for a show with a sort"
  (cl-check-type sort (member likes likes_30 replies replies_30 watched plays rating added))
  (tracktor--trakt-request
   (format "/shows/%s/comments/%s"
           (replace-regexp-in-string " " "-" show-name)
           sort)
   :callback callback)
  )

(cl-defun tracktor-tv-show-get-lists-containing (show-name &key type sort)
  "Get all the lists containing a show"
  (cl-check-type sort (member popular likes comments items added updated))
  (cl-check-type type (member all personal official watchlists favorites))
  (tracktor--trakt-request
   (format "/shows/%s/lists/%s/%s"
           (replace-regexp-in-string " " "-" show-name)
           type
           sort)
   :callback callback)
  )

(cl-defun tracktor-tv-show-get-collection-progress
    (show-name &key hidden? specials? count-specials? callback)
  "Get the collected progress of a show for the user, for physical media or bought online"
  (tracktor--trakt-request
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
  (tracktor--trakt-request
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
  (tracktor--trakt-request
   (format "/shows/%s/people"
           (replace-regexp-in-string " " "-" show-name))
   :callback callback)
  )

(cl-defun tracktor-tv-show-get-rating (show-name &key callback)
  "Get ratings for a show"
  (tracktor--trakt-request
   (format "/shows/%s/ratings"
           (replace-regexp-in-string " " "-" show-name))
   :callback callback)
  )

(cl-defun tracktor-tv-show-get-related (show-name &key callback)
  "Get related shows for a show"
  (tracktor--trakt-request
   (format "/shows/%s/related"
           (replace-regexp-in-string " " "-" show-name))
   :callback callback)
  )


(cl-defun tracktor-tv-show-get-seasons (show-name &key callback)
  "Get seasons for a show"
  (tracktor--trakt-request
   (format "/shows/%s/seasons"
           (replace-regexp-in-string " " "-" show-name))
   :callback callback)
  )

(cl-defun tracktor-tv-show-get-season (show-name season-number &key callback)
  "Get a single season for a show"
  (tracktor--trakt-request
   (format "/shows/%s/seasons/%d/info"
           (replace-regexp-in-string " " "-" show-name)
           season-number)
   :callback callback)
  )

(cl-defun tracktor-tv-show-get-season-episodes (show-name season-number &key callback)
  "Get a single season episodes for a show"
  (tracktor--trakt-request
   (format "/shows/%s/seasons/%d"
           (replace-regexp-in-string " " "-" show-name)
           season-number)
   :callback callback)
  )

(cl-defun tracktor-tv-show-get-season-comments (show-name season-number &key sort callback)
  "Get a single season comments for a show"
  (cl-check-type sort (member likes likes_30 replies replies_30 watched plays rating added))
  (tracktor--trakt-request
   (format "/shows/%s/seasons/%d/comments/%s"
           (replace-regexp-in-string " " "-" show-name)
           season-number
           sort)
   :callback callback)
  )

(cl-defun tracktor-tv-show-get-season-ratings (show-name season-number &key callback)
  "Get a single season ratings for a show"
  (tracktor--trakt-request
   (format "/shows/%s/seasons/%d/ratings"
           (replace-regexp-in-string " " "-" show-name)
           season-number)
   :callback callback)
  )

(cl-defun tracktor-tv-show-get-episode (show-name season-number episode-number &key callback)
  "Get a single episode for a show"
  (tracktor--trakt-request
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
  (tracktor--trakt-request
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
  (tracktor--trakt-request
   (format "/shows/%s/seasons/%d/episodes/%d/people"
           (replace-regexp-in-string " " "-" show-name)
           season-number
           episode-number)
   :callback callback)
  )

(cl-defun tracktor-tv-show-get-episode-ratings
    (show-name season-number episode-number &key callback)
  "Get a single episode ratings for a show"
  (tracktor--trakt-request
   (format "/shows/%s/seasons/%d/episodes/%d/ratings"
           (replace-regexp-in-string " " "-" show-name)
           season-number
           episode-number)
   :callback callback)
  )

(cl-defun tracktor-tv-user-get-settings (&key callback)
  "Get the user settings"
  (tracktor--trakt-request "/users/settings"
                       :auth? t
                       :callback callback)
  )

(cl-defun tracktor-tv-user-get-pending-following (&key callback)
  "Get the user's pending following requests that they're waiting for the other user's to approve"
  (tracktor--trakt-request "/users/requests/following"
                       :auth? t
                       :callback callback)
  )

(cl-defun tracktor-tv-user-get-follow-requests (&key callback)
  "Get the user's pending follow requests so they can either approve or deny them"
  (tracktor--trakt-request "/users/requests"
                       :auth? t
                       :callback callback)
  )

(cl-defun tracktor-tv-user-approve-request (id &key callback)
  "Approve a follower using the id of the request"
  (tracktor--trakt-request
   (format "/users/requests/%d" id)
   :method "POST"
   :auth? t
   :callback callback)
  )

(cl-defun tracktor-tv-user-deny-request (id &key callback)
  "Deny a follower using the id of the request"
  (tracktor--trakt-request
   (format "/users/requests/%d" id)
   :method "DELETE"
   :auth? t
   :callback callback)
  )

(cl-defun tracktor-tv-user-get-hidden-items (section &key type callback)
  "Get hidden shows for the user"
  (cl-check-type section (member calendar progress_watched progress_watched_reset progress_collected recommendations comments dropped))
  (cl-check-type type (member show season user))
  (tracktor--trakt-request
   (format "/users/hidden/%s" section)
   :params `(("type" . ,type))
   :auth? t
   :callback callback)
  )

(cl-defun tracktor-tv-user-add-hidden-items (section &key shows seasons callback)
  "Add a hidden item into a section"
  (cl-check-type section (member calendar progress_watched progress_watched_reset progress_collected recommendations comments dropped))

  (tracktor--trakt-request
   (format "/users/hidden/%s" section)
   :auth? t
   :method "POST"
   :data `((shows . ,(or shows []))
           (seasons . ,(or seasons [])))
   :callback callback))


(cl-defun tracktor-tv-user-remove-hidden-items (section &key shows seasons callback)
  "Remove a hidden item from a section"
  (cl-check-type section (member calendar progress_watched progress_watched_reset progress_collected recommendations comments dropped))
  (tracktor--trakt-request
   (format "/users/hidden/%s/remove" section)
   :auth? t
   :method "POST"
   :data `((shows . ,(or shows []))
           (seasons . ,(or seasons [])))
   :callback callback))


(cl-defun tracktor-tv-user-get-profile (&key callback)
  "Get the user general profile info"
  (tracktor--trakt-request "/users/me"
                           :auth? t
                           :callback callback))

(cl-defun tracktor-tv-user-get-likes (type &key callback)
  "Get the user likes"
  (cl-check-type type (member comments lists))
  (tracktor--trakt-request
   (format "/users/me/likes/%s" type)
   :auth? t
   :callback callback))

(cl-defun tracktor-tv-user-get-collection (&key callback)
  "Get all collected items in a user's collection"
  (tracktor--trakt-request "/users/me/collection/shows"
                           :auth? t
                           :callback callback))


(cl-defun tracktor-tv-user-get-comments (type comment-type &key include-replies? callback)
  "Returns the most recently written comments for the user"
  (cl-check-type comment-type (member all reviews shouts))
  (cl-check-type type (member all shows seasons episodes lists))
  (tracktor--trakt-request
   (format "/users/me/comments/%s/%s" comment-type type)
   :auth? t
   :params `(("include_replies" . include-replies?))
   :callback callback))


(cl-defun tracktor-tv-user-get-lists (&key callback)
  "Returns all personal lists for a user"
  (tracktor--trakt-request "/users/me/lists"
   :auth? t
   :callback callback))


(cl-defun tracktor-tv-user-create-list
    (name &key description
          (privacy 'private)
          (display-numbers? nil)
          (allow-comments? t)
          (sort-by 'rank)
          (sort-how 'asc)
          callback)
  "Create a new personal list"
  (cl-check-type privacy (member private link friends public))
  (cl-check-type sort-by (member rank added title released runtime popularity random percentage imdb_rating tmdb_rating rt_tomatometer rt_audience metascore votes imdb_votes tmdb_votes my_rating watched collected))
  (cl-check-type sort-how (member asc desc))
  (tracktor--trakt-request "/users/me/lists"
                           :method "POST"
                           :auth? t
                           :data `((name . ,name)
                                   (description . ,description)
                                   (privacy . ,privacy)
                                   (display_numbers . ,display-numbers?)
                                   (allow_comments . ,allow-comments?)
                                   (sort_by . ,sort-by)
                                   (sort_how . ,sort-how))
                           :callback callback))


(cl-defun tracktor-tv-user-get-list (list-id &key callback)
  "Returns a single personal list for the user"
  (tracktor--trakt-request
   (format "/users/me/lists/%d" list-id)
   :auth? t
   :callback callback))


(cl-defun tracktor-tv-user-get-list-trakt-id (list-name &key callback)
  "Returns the trakt id for the lists matching the name"
  (tracktor-tv-user-get-lists
   :callback (lambda (lists)
               (let ((result
                      (mapcar
                       (lambda (list)
                         (when (equal (alist-get 'name list) list-name)
                           (let ((ids (alist-get 'ids list)))
                             (alist-get 'trakt ids))))
                       lists)))
                 (funcall callback
                          (cl-remove-if (lambda (item) (null item)) result))))))


(cl-defun tracktor-tv-user-get-list-items (list-id &key callback)
  "Returns a single personal list items for the user"
  (tracktor--trakt-request
   (format "/users/me/lists/%d/items" list-id)
   :auth? t
   :callback callback))

(provide 'tracktor-api)
;;; tracktor-api.el ends here
