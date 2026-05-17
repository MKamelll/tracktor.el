;;; tracktor-api-auth.el --- trakt.tv api auth -*- lexical-binding: t -*-

;;; Code:
(add-to-list 'load-path "~/playground/tracktor")
(require 'tracktor-secrets)
(require 'cl-lib)

(defvar tracktor--trakt-auth-code nil)

(cl-defun tracktor--trakt-start-callback-server (port)
  (when (get-process "tracktor-trakt-callback")
    (delete-process "tracktor-trakt-callback"))
  (make-network-process
   :name "tracktor-trakt-callback"
   :server t
   :host "localhost"
   :service port
   :family 'ipv4
   :filter (lambda (proc data)
             (when (string-match "code=\\([^& \n]+\\)" data)
               (setq tracktor--trakt-auth-code (match-string 1 data))
               (process-send-string proc "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n
                 <html><body><h1>Done! You can close this tab.</h1></body></html>")
               (delete-process proc)))))


(cl-defun tracktor--trakt-auth ()
  (tracktor--trakt-start-callback-server tracktor--trakt-app-redirect-url-port)
  (browse-url
   (format "https://trakt.tv/oauth/authorize?response_type=code&client_id=%s&redirect_uri=%s"
           tracktor--trakt-app-client-id
           tracktor--trakt-app-redirect-url))
  (while (null tracktor--trakt-auth-code)
    (accept-process-output nil 0.1))
  (let ((code tracktor--trakt-auth-code))
    (setq tracktor--trakt-auth-code nil)
    (tracktor--trakt-exchange-code code)))

(cl-defun tracktor--trakt-exchange-code (code)
  (request "https://api.trakt.tv/oauth/token"
    :type "POST"
    :headers '(("accept" . "application/json")
               ("Content-Type" . "application/json"))
    :data (json-encode
           `(("code" . ,code)
             ("client_id" . ,tracktor--trakt-app-client-id)
             ("client_secret" . ,tracktor--trakt-app-client-secret)
             ("redirect_uri" . ,tracktor--trakt-app-redirect-url)
             ("grant_type" . "authorization_code")))
    :parser 'json-read
    :success (cl-function
              (lambda (&key data &allow-other-keys)
                (let ((token (alist-get 'access_token data))
                      (refresh_token (alist-get 'refresh_token data))
                      (expires_in (alist-get 'expires_in data)))
                  (tracktor--trakt-write-tokens token refresh_token expires_in)
                  (message "Tracktor: trakt authentication successful"))))
    :error (cl-function
            (lambda (&key response &allow-other-keys)
              (message "Tracktor: trakt authentication failed: %s"
                       (request-response-data response))))))

(cl-defun tracktor--trakt-write-tokens (access-token refresh-token expires-in)
  (with-temp-file tracktor--trakt-app-tokens-file
    (insert
     (json-encode
      `((access_token . ,access-token)
        (refresh_token . ,refresh-token)
        (expires_at . ,(+ (float-time) expires-in)))))))


(cl-defun tracktor--trakt-read-tokens ()
  "Read the tokens file and tries to run auth if it fails"
  (if (file-exists-p tracktor--trakt-app-tokens-file)
    (with-temp-buffer
      (insert-file-contents tracktor--trakt-app-tokens-file)
      (json-parse-buffer :object-type 'alist))
    (tracktor--trakt-auth)))

(cl-defun tracktor--trakt-is-token-valid (tokens)
  "Checks if the token has expired"
  (let ((expires_at (alist-get 'expires_at tokens)))
    (< (float-time) expires_at)))

(cl-defun tracktor--trakt-refresh-access-token (tokens &key callback)
  "Refresh token"
  (request "https://api.trakt.tv/oauth/token"
    :type "POST"
    :headers '(("accept" . "application/json")
               ("Content-Type" . "application/json"))
    :data (json-encode
           `(("refresh_token" . ,(alist-get 'refresh_token tokens))
             ("client_id" . ,tracktor--trakt-app-client-id)
             ("client_secret" . ,tracktor--trakt-app-client-secret)
             ("redirect_uri" . ,tracktor--trakt-app-redirect-url)
             ("grant_type" . "refresh_token")))
    :parser 'json-read
    :success (cl-function
              (lambda (&key data &allow-other-keys)
                (let ((token (alist-get 'access_token data))
                      (refresh_token (alist-get 'refresh_token data))
                      (expires_in (alist-get 'expires_in data)))
                  (tracktor--trakt-write-tokens token refresh_token expires_in)
                  (message "Tracktor: trakt refreshed token successfully")
                  (when callback
                    (funcall callback token)))))
    :error (cl-function
            (lambda (&key response &allow-other-keys)
              (message "Tracktor: trakt refreshing token failed: %s"
                       (request-response-data response))))))

(cl-defun tracktor--trakt-get-access-token ()
  "Get the access token or if it expired, refreshes it"
  (let ((tokens (tracktor--trakt-read-tokens)))
    (if (and tokens (tracktor--trakt-is-token-valid tokens))
        (alist-get 'access_token tokens)
      (tracktor--trakt-refresh-access-token tokens
                                            :callback
                                            (lambda (token) token)))))

(cl-defun tracktor--trakt-request (endpoint &key auth? (method "GET") params data callback)
  "General handler for requests"
  (let* ((base-url "https://api.trakt.tv")
         (full-url (format "%s%s" base-url endpoint))
         (headers `(("accept" . "application/json")
                    ("Content-Type" . "application/json")
                    ("trakt-api-version" . "2")
                    ("trakt-api-key" . ,tracktor--trakt-app-client-id)))
         (headers (if auth?
                      (let ((token (tracktor--trakt-get-access-token)))
                        (if token
                            (cons `("Authorization" . ,(format "Bearer %s" token)) headers)
                          (error "Tracktor: no valid token available")))
                    headers)))
    (unless
        (or (null method)
            (member method '("GET" "POST" "DELETE" "PUT" "PATCH")))
      (error
       (format "Tracktor: invalid method: %s" method)))

    (request full-url
      :type method
      :headers headers
      :params (cl-remove-if
               (lambda (pair) (null (cdr pair)))
               params)
      :parser 'json-read
      :data (when data (json-encode data))
      :success (cl-function
                (lambda (&key data &allow-other-keys)
                  (when callback
                    (funcall callback data))))
      :error (cl-function
              (lambda (&key response &allow-other-keys)
                (message "Tracktor: request failed: (%d) %s"
                         (request-response-status-code response)
                         (request-response-data response)))))))

(provide 'tracktor-api-auth)
;;; tracktor-api-auth.el ends here
