;;; tracktor-api.el --- trakt.tv api wrapper for the tracktor plugin -*- lexical-binding: t -*-


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
            (lambda (&key error-thrown &allow-other-keys)
              (message "Tracktor: trakt authentication failed: %s" error-thrown)))))

(cl-defun tracktor--trakt-write-tokens (access-token refresh-token expires-in)
  (with-temp-file tracktor--trakt-app-tokens-file
    (insert
     (json-encode
      `((access_token . ,access-token)
        (refresh_token . ,refresh-token)
        (expires_at . ,(+ (float-time) expires-in)))))))


(cl-defun tracktor--trakt-read-tokens ()
  (if (file-exists-p tracktor--trakt-app-tokens-file)
    (with-temp-file tracktor--trakt-app-tokens-file
      (insert-file-contents tracktor--trakt-app-tokens-file)
      (json-parse-buffer :object-type 'alist))
    (tracktor--trakt-auth)))

(message "%s" (tracktor--trakt-read-tokens))

(provide 'tracktor-api)
;;; tracktor-api.el ends here
