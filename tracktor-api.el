;;; tracktor-api.el --- trakt.tv api wrapper for the tracktor plugin -*- lexical-binding: t -*-


;;; Code:
(add-to-list 'load-path "~/playground/tracktor")
(require 'cl-lib)
(require 'tracktor-api-auth)

(cl-defun tracktor--tv-show-search (show-name &key callback)
  "Search the api for show-name"
  (tracktor--trakt-request "/search/show"
                       :params `(("query" . ,show-name))
                       :callback callback))

(cl-defun tracktor--tv-show-trending-get (&key callback)
  "Get the most trending shows"
  (tracktor--trakt-request "/shows/trending"
                       :callback callback))

(cl-defun tracktor--tv-show-popular-get (&key callback)
  "Get the most popular shows"
  (tracktor--trakt-request "/shows/popular"
                       :callback callback))

(cl-defun tracktor--tv-show-most-favourited-get (&key period callback)
  "Get the most favourited shows by period"
  (cl-check-type period (member weekly monthly daily all))
  (tracktor--trakt-request (format "/shows/favorited/%s" period)
                       :callback callback))


(cl-defun tracktor--tv-show-most-played-get (&key period callback)
  "Get the most played shows by period"
  (cl-check-type period (member weekly monthly daily all))
  (tracktor--trakt-request (format "/shows/played/%s" period)
                       :callback callback))

(cl-defun tracktor--tv-show-most-watched-get (&key period callback)
  "Get the most watched shows by period"
  (cl-check-type period (member weekly monthly daily all))
  (tracktor--trakt-request (format "/shows/watched/%s" period)
                       :callback callback))

(cl-defun tracktor--tv-show-most-collected-get (&key period callback)
  "Get the most collected shows by period"
  (cl-check-type period (member weekly monthly daily all))
  (tracktor--trakt-request (format "/shows/collected/%s" period)
                       :callback callback))

(cl-defun tracktor--tv-show-most-anticipated-get (&key callback)
  "Get the most anticipated shows by period"
  (tracktor--trakt-request "/shows/anticipated"
                       :callback callback))


(cl-defun tracktor--tv-show-details-get (show-name &key extended callback)
  "Get a show details, if extended it returns the full details"
  (tracktor--trakt-request (format "/shows/%s" (replace-regexp-in-string " " "-" show-name))
                       :params (when (eq extended 'full)
                                 '(("extended" . "full")))
                       :callback callback))

(cl-defun tracktor--tv-show-comments-get (show-name &key sort callback)
  "Get all the comments for a show with a sort"
  (cl-check-type sort (member likes likes_30 replies replies_30 watched plays rating added))
  (tracktor--trakt-request
   (format "/shows/%s/comments/%s"
           (replace-regexp-in-string " " "-" show-name)
           sort)
   :callback callback)
  )

(cl-defun tracktor--tv-show-lists-containing-get (show-name &key type sort)
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

(cl-defun tracktor--tv-show-progress-collection-get
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

(cl-defun tracktor--tv-show-progress-watched-get
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


(cl-defun tracktor--tv-show-people-get (show-name &key callback)
  "Get the cast and crew for a show"
  (tracktor--trakt-request
   (format "/shows/%s/people"
           (replace-regexp-in-string " " "-" show-name))
   :callback callback)
  )

(cl-defun tracktor--tv-show-rating-get (show-name &key callback)
  "Get ratings for a show"
  (tracktor--trakt-request
   (format "/shows/%s/ratings"
           (replace-regexp-in-string " " "-" show-name))
   :callback callback)
  )

(cl-defun tracktor--tv-show-related-get (show-name &key callback)
  "Get related shows for a show"
  (tracktor--trakt-request
   (format "/shows/%s/related"
           (replace-regexp-in-string " " "-" show-name))
   :callback callback)
  )


(cl-defun tracktor--tv-show-seasons-get (show-name &key callback)
  "Get seasons for a show"
  (tracktor--trakt-request
   (format "/shows/%s/seasons"
           (replace-regexp-in-string " " "-" show-name))
   :callback callback)
  )

(cl-defun tracktor--tv-show-season-get (show-name season-number &key callback)
  "Get a single season for a show"
  (tracktor--trakt-request
   (format "/shows/%s/seasons/%d/info"
           (replace-regexp-in-string " " "-" show-name)
           season-number)
   :callback callback)
  )

(cl-defun tracktor--tv-show-season-episodes-get (show-name season-number &key callback)
  "Get a single season episodes for a show"
  (tracktor--trakt-request
   (format "/shows/%s/seasons/%d"
           (replace-regexp-in-string " " "-" show-name)
           season-number)
   :callback callback)
  )

(cl-defun tracktor--tv-show-season-comments-get (show-name season-number &key sort callback)
  "Get a single season comments for a show"
  (cl-check-type sort (member likes likes_30 replies replies_30 watched plays rating added))
  (tracktor--trakt-request
   (format "/shows/%s/seasons/%d/comments/%s"
           (replace-regexp-in-string " " "-" show-name)
           season-number
           sort)
   :callback callback)
  )

(cl-defun tracktor--tv-show-season-ratings-get (show-name season-number &key callback)
  "Get a single season ratings for a show"
  (tracktor--trakt-request
   (format "/shows/%s/seasons/%d/ratings"
           (replace-regexp-in-string " " "-" show-name)
           season-number)
   :callback callback)
  )

(cl-defun tracktor--tv-show-episode-get (show-name season-number episode-number &key callback)
  "Get a single episode for a show"
  (tracktor--trakt-request
   (format "/shows/%s/seasons/%d/episodes/%d"
           (replace-regexp-in-string " " "-" show-name)
           season-number
           episode-number)
   :callback callback)
  )

(cl-defun tracktor--tv-show-episode-comments-get
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

(cl-defun tracktor--tv-show-episode-people-get
    (show-name season-number episode-number &key callback)
  "Get a single episode people for a show"
  (tracktor--trakt-request
   (format "/shows/%s/seasons/%d/episodes/%d/people"
           (replace-regexp-in-string " " "-" show-name)
           season-number
           episode-number)
   :callback callback)
  )

(cl-defun tracktor--tv-show-episode-ratings-get
    (show-name season-number episode-number &key callback)
  "Get a single episode ratings for a show"
  (tracktor--trakt-request
   (format "/shows/%s/seasons/%d/episodes/%d/ratings"
           (replace-regexp-in-string " " "-" show-name)
           season-number
           episode-number)
   :callback callback)
  )

(cl-defun tracktor--tv-user-settings-get (&key callback)
  "Get the user settings"
  (tracktor--trakt-request "/users/settings"
                       :auth? t
                       :callback callback)
  )

(cl-defun tracktor--tv-user-pending-following-get (&key callback)
  "Get the user's pending following requests that they're waiting for the other user's to approve"
  (tracktor--trakt-request "/users/requests/following"
                       :auth? t
                       :callback callback)
  )

(cl-defun tracktor--tv-user-follow-requests-get (&key callback)
  "Get the user's pending follow requests so they can either approve or deny them"
  (tracktor--trakt-request "/users/requests"
                       :auth? t
                       :callback callback)
  )

(cl-defun tracktor--tv-user-request-approve (id &key callback)
  "Approve a follower using the id of the request"
  (tracktor--trakt-request
   (format "/users/requests/%d" id)
   :method "POST"
   :auth? t
   :callback callback)
  )

(cl-defun tracktor--tv-user-request-deny (id &key callback)
  "Deny a follower using the id of the request"
  (tracktor--trakt-request
   (format "/users/requests/%d" id)
   :method "DELETE"
   :auth? t
   :callback callback)
  )

(cl-defun tracktor--tv-user-hidden-items-get (section &key type callback)
  "Get hidden shows for the user"
  (cl-check-type section (member calendar progress_watched progress_watched_reset progress_collected recommendations comments dropped))
  (cl-check-type type (member show season user))
  (tracktor--trakt-request
   (format "/users/hidden/%s" section)
   :params `(("type" . ,type))
   :auth? t
   :callback callback)
  )

(cl-defun tracktor--tv-user-hidden-items-add (section &key shows seasons callback)
  "Add a hidden item into a section"
  (cl-check-type section (member calendar progress_watched progress_watched_reset progress_collected recommendations comments dropped))

  (tracktor--trakt-request
   (format "/users/hidden/%s" section)
   :auth? t
   :method "POST"
   :data `((shows . ,(or shows []))
           (seasons . ,(or seasons [])))
   :callback callback))


(cl-defun tracktor--tv-user-hidden-items-remove (section &key shows seasons callback)
  "Remove a hidden item from a section"
  (cl-check-type section (member calendar progress_watched progress_watched_reset progress_collected recommendations comments dropped))
  (tracktor--trakt-request
   (format "/users/hidden/%s/remove" section)
   :auth? t
   :method "POST"
   :data `((shows . ,(or shows []))
           (seasons . ,(or seasons [])))
   :callback callback))


(cl-defun tracktor--tv-user-profile-get (&key callback)
  "Get the user general profile info"
  (tracktor--trakt-request "/users/me"
                           :auth? t
                           :callback callback))

(cl-defun tracktor--tv-user-likes-get (type &key callback)
  "Get the user likes"
  (cl-check-type type (member comments lists))
  (tracktor--trakt-request
   (format "/users/me/likes/%s" type)
   :auth? t
   :callback callback))

(cl-defun tracktor--tv-user-collection-get (&key callback)
  "Get all collected items in a user's collection"
  (tracktor--trakt-request "/users/me/collection/shows"
                           :auth? t
                           :callback callback))


(cl-defun tracktor--tv-user-comments-get (type comment-type &key include-replies? callback)
  "Returns the most recently written comments for the user"
  (cl-check-type comment-type (member all reviews shouts))
  (cl-check-type type (member all shows seasons episodes lists))
  (tracktor--trakt-request
   (format "/users/me/comments/%s/%s" comment-type type)
   :auth? t
   :params `(("include_replies" . include-replies?))
   :callback callback))


(cl-defun tracktor--tv-user-lists-get (&key callback)
  "Returns all personal lists for a user"
  (tracktor--trakt-request "/users/me/lists"
   :auth? t
   :callback callback))


(cl-defun tracktor--tv-user-list-create
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


(cl-defun tracktor--tv-user-list-get (list-id &key callback)
  "Returns a single personal list for the user"
  (tracktor--trakt-request
   (format "/users/me/lists/%d" list-id)
   :auth? t
   :callback callback))


(cl-defun tracktor--tv-user-list-trakt-id-get (list-name &key callback)
  "Returns the trakt id for the lists matching the name"
  (tracktor--tv-user-get-lists
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

(cl-defun tracktor--tv-user-list-update
    (list-id &key name description
          (privacy 'private)
          (display-numbers? nil)
          (allow-comments? t)
          (sort-by 'rank)
          (sort-how 'asc)
          callback)
  "Update a personal list"
  (cl-check-type privacy (member private link friends public))
  (cl-check-type sort-by (member rank added title released runtime popularity random percentage imdb_rating tmdb_rating rt_tomatometer rt_audience metascore votes imdb_votes tmdb_votes my_rating watched collected))
  (cl-check-type sort-how (member asc desc))
  (tracktor--trakt-request
   (format "/users/me/lists/%d" list-id)
   :method "PUT"
   :auth? t
   :data `((name . ,name)
           (description . ,description)
           (privacy . ,privacy)
           (display_numbers . ,display-numbers?)
           (allow_comments . ,allow-comments?)
           (sort_by . ,sort-by)
           (sort_how . ,sort-how))
   :callback callback))


(cl-defun tracktor--tv-user-list-delete (list-id &key callback)
  "Delete a personal list"
  (tracktor--trakt-request
   (format "/users/me/lists/%d" list-id)
   :method "DELETE"
   :auth? t
   :callback callback))


(cl-defun tracktor--tv-user-list-likes-get (list-id &key callback)
  "Returns all users who liked a list"
  (tracktor--trakt-request
   (format "/users/me/lists/%d/likes" list-id)
   :auth? t
   :callback callback))

(cl-defun tracktor--tv-user-list-like (list-id &key callback)
  "Like a list"
  (tracktor--trakt-request
   (format "/users/me/lists/%d/like" list-id)
   :auth? t
   :method "POST"
   :callback callback))


(cl-defun tracktor--tv-user-list-unlike (list-id &key callback)
  "Unlike a list"
  (tracktor--trakt-request
   (format "/users/me/lists/%d/like" list-id)
   :auth? t
   :method "Delete"
   :callback callback))


(cl-defun tracktor--tv-user-list-items-get
    (list-id &key (type 'show) (sort-by 'rank) (sort-how 'asc) callback)
  "Returns a single personal list items for the user"
  (cl-check-type type (member show season episode person))
  (cl-check-type sort-by (member rank added title released runtime popularity random percentage imdb_rating tmdb_rating rt_tomatometer rt_audience metascore votes imdb_votes tmdb_votes my_rating watched collected))
  (cl-check-type sort-how (member asc desc))
  (tracktor--trakt-request
   (format "/users/me/lists/%d/items/%s/%s/%s" list-id type sort-by sort-how)
   :auth? t
   :callback callback))


(cl-defun tracktor--tv-user-list-items-add (list-id &key shows seasons episodes callback)
  "Add items to a user's list"
  (tracktor--trakt-request
   (format "/users/me/lists/%d/items" list-id)
   :auth? t
   :method "POST"
   :data `((shows . (or shows []))
           (seasons . (or seasons []))
           (episodes . (or episodes [])))
   :callback callback))


(cl-defun tracktor--tv-user-list-items-remove (list-id &key shows seasons episodes callback)
  "Remove items from a user's list"
  (tracktor--trakt-request
   (format "/users/me/lists/%d/items/remove" list-id)
   :auth? t
   :method "POST"
   :data `((shows . (or shows []))
           (seasons . (or seasons []))
           (episodes . (or episodes [])))
   :callback callback))


(cl-defun tracktor--tv-user-list-items-reorder (list-id new-ranks &key callback)
  "Reorder all items on a list by sending the updated rank of list item ids"
  (tracktor--trakt-request
   (format "/users/me/lists/%d/items/reorder" list-id)
   :auth? t
   :method "POST"
   :data `((rank . ,new-ranks))
   :callback callback))

(cl-defun tracktor--tv-user-list-comments-get (list-id &key (sort 'likes) callback)
  "Returns all top level comments for a list"
  (cl-check-type sort (member likes likes_30 replies replies_30 plays rating added))
  (tracktor--trakt-request
   (format "/users/me/lists/%d/comments/%s" list-id sort)
   :auth? t
   :callback callback))

(cl-defun tracktor--tv-user-follow (user-id &key callback)
  "Follow a user"
  (tracktor--trakt-request
   (format "/users/%s/follow" user-id)
   :auth? t
   :method "POST"
   :callback callback))

(cl-defun tracktor--tv-user-unfollow (user-id &key callback)
  "Unfollow a user"
  (tracktor--trakt-request
   (format "/users/%s/follow" user-id)
   :auth? t
   :method "DELETE"
   :callback callback))


(cl-defun tracktor--tv-user-blocked-get (&key callback)
  "Get blocked users list"
  (tracktor--trakt-request "/users/blocked"
   :auth? t
   :callback callback))

(cl-defun tracktor--tv-user-block (user-id &key callback)
  "Block a user"
  (tracktor--trakt-request
   (format "/users/%s/block" user-id)
   :auth? t
   :method "POST"
   :callback callback))

(cl-defun tracktor--tv-user-unblock (user-id &key callback)
  "Unblock a user"
  (tracktor--trakt-request
   (format "/users/%s/block" user-id)
   :auth? t
   :method "DELETE"
   :callback callback))

(cl-defun tracktor--tv-user-followers-get (&key callback)
  "Get the followers of a user"
  (tracktor--trakt-request "/users/me/followers"
   :auth? t
   :callback callback))


(cl-defun tracktor--tv-user-following-get (&key callback)
  "Get the following list of a user"
  (tracktor--trakt-request "/users/me/following"
   :auth? t
   :callback callback))


(cl-defun tracktor--tv-user-friends-get (&key callback)
  "Get friends of a user"
  (tracktor--trakt-request "/users/me/friends"
   :auth? t
   :callback callback))

(cl-defun tracktor--tv-user-watched-history
    (item-id &key start-at end-at (type 'shows) callback)
  "Get the user's watched history for an item (ie. shows, seasons, episodes)
you can specify a start-at and end-at period of this format '2016-07-01T23:59:59.000Z'"
  (cl-check-type type (member shows seasons episodes))
  (tracktor--trakt-request
   (format "/users/me/history/%s/%s" type item-id)
   :auth? t
   :params `((start_at . ,start-at)
             (end_at . ,end-at))
   :callback callback))

(cl-defun tracktor--tv-user-ratings-get (type &key rating callback)
  "Get a user's ratings filtered by type. You can optionally filter for a specific rating between 1 and 10. Send a comma separated string for rating if you need multiple ratings."
  (cl-check-type type (member shows seasons episodes))
  (tracktor--trakt-request
   (format "/users/me/ratings/%s/%s" type rating)
   :auth? t
   :callback callback))


(cl-defun tracktor--tv-user-watchlist-get (type &key (sort-by 'rank) (sort-how 'asc) callback)
  "Returns all items in a user's watchlist filtered by type."
  (cl-check-type type (member shows seasons episodes))
  (cl-check-type sort-by (member rank added title released runtime popularity random percentage imdb_rating tmdb_rating rt_tomatometer rt_audience metascore votes imdb_votes tmdb_votes my_rating watched collected))
  (cl-check-type sort-how (member asc desc))
  (tracktor--trakt-request
   (format "/users/me/watchlist/%s/%s/%s" type sort-by sort-how)
   :auth? t
   :callback callback))


(cl-defun tracktor--tv-user-watchlist-comments-get (sort &key callback)
  "Returns all top level comments for the watchlist. By default, the comments are sorted by most likes"
  (cl-check-type sort (member likes likes_30 replies replies_30 plays rating added))
  (tracktor--trakt-request
   (format "/users/me/watchlist/comments/%s" sort)
   :auth? t
   :callback callback))


(cl-defun tracktor--tv-user-favorites-get (type &key (sort-by 'rank) (sort-how 'asc) callback)
  "Returns the top 100 shows and movies a user has favorited."
  (cl-check-type type (member shows seasons episodes))
  (cl-check-type sort-by (member rank added title released runtime popularity random percentage imdb_rating tmdb_rating rt_tomatometer rt_audience metascore votes imdb_votes tmdb_votes my_rating watched collected))
  (cl-check-type sort-how (member asc desc))
  (tracktor--trakt-request
   (format "/users/me/favorites/%s/%s/%s" type sort-by sort-how)
   :auth? t
   :callback callback))

(cl-defun tracktor--tv-user-favorites-comments-get (sort &key callback)
  "Returns all top level comments for the favorites. By default, the comments are sorted by most likes"
  (cl-check-type sort (member likes likes_30 replies replies_30 plays rating added))
  (tracktor--trakt-request
   (format "/users/me/favorites/comments/%s" sort)
   :auth? t
   :callback callback))


(cl-defun tracktor--tv-user-watching-get (&key callback)
  "Returns a movie or episode if the user is currently watching something. If they are not, it returns no data and a 204 HTTP status code."
  (tracktor--trakt-request "/users/me/watching"
                           :auth? t
                           :callback callback))


(cl-defun tracktor--tv-user-watched-get (&key extended callback)
  "Returns all movies or shows a user has watched sorted by most recently watched.
If you add :extended \\='noseasons to the URL, it won't return season or episode info."
  (tracktor--trakt-request "/users/me/watched/shows"
                           :auth? t
                           :params `((extended . ,extended))
                           :callback callback))

(provide 'tracktor-api)
;;; tracktor-api.el ends here
