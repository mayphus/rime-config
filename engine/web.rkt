#lang racket/base

(require web-server/servlet
         web-server/servlet-env
         web-server/http
         racket/file
         racket/format
         racket/path
         racket/list
         racket/runtime-path
         racket/string
         json
         "frontend.rkt"
         "build-lib.rkt")

(provide precomputed-skin-items list-static-schemas)

;; ---- Helpers ---------------------------------------------------------------

(define-runtime-path app-css-path "static/app.css")

(define (valid-id? s)
  (and (string? s) (regexp-match? #rx"^[a-zA-Z0-9_-]+$" s)))

(define (skin-demo-path skin-id)
  (build-path output-dir "compiled-skins" skin-id "demo.png"))

(define (skin-preview-spec skin-rkt)
  (with-handlers ([exn:fail? (lambda (_) #f)])
    (dynamic-require `(file ,(path->string skin-rkt)) 'skin-preview-spec)))

(define (skin-preview-svgs skin-rkt)
  (with-handlers ([exn:fail? (lambda (_) (hash))])
    (dynamic-require `(file ,(path->string skin-rkt)) 'skin-preview-svgs)))

(define (skin-preview-svg skin-id [theme 'light])
  (for/or ([item (in-list precomputed-skin-items)]
           #:when (equal? skin-id (car item)))
    (define preview-svgs (car (cddddr item)))
    (hash-ref preview-svgs theme #f)))

(define (list-static-schemas)
  (filter-map
   (lambda (f)
     (define name (path->string f))
     (and (regexp-match? #rx"\\.schema\\.yaml$" name)
          (regexp-replace #rx"\\.schema\\.yaml$" name "")))
   (directory-list data-dir)))

;; Read skin metadata by statically parsing the .rkt file — avoids executing
;; the full skin module (which renders PNG demos and is very slow).
(define (read-skin-metadata rkt-path)
  (call-with-input-file rkt-path
    (lambda (in)
      (read-line in) ; skip #lang line
      (let loop ([trigger #f] [zh-name #f])
        (define expr (with-handlers ([exn:fail? (lambda (_) eof)]) (read in)))
        (cond
          [(eof-object? expr) (values trigger zh-name)]
          ;; Case 1: (skin slug (triggers ...) (meta (name "Eng" "Zh") ...) ...)
          [(and (list? expr) (> (length expr) 2) (eq? (car expr) 'skin))
           (define clauses (cddr expr))
           (define t (for/or ([c clauses])
                       (and (list? c) (eq? (car c) 'triggers)
                            (let ([args (cdr c)])
                              (if (and (= (length args) 1) (eq? (car args) 'default))
                                  'default
                                  (map (lambda (x) (if (symbol? x) (symbol->string x) (~a x))) args))))))
           (define n (for/or ([c clauses])
                       (and (list? c) (eq? (car c) 'meta)
                            (let ([meta-clauses (cdr c)])
                              (for/or ([mc meta-clauses])
                                (and (list? mc) (eq? (car mc) 'name)
                                     (>= (length mc) 3)
                                     (caddr mc)))))))
           (loop (or trigger t) (or zh-name n))]
          ;; Case 2: (define trigger-schemas ...)
          [(and (list? expr) (= (length expr) 3)
                (eq? (car expr) 'define)
                (eq? (cadr expr) 'trigger-schemas))
           (define val (caddr expr))
           (define t (cond [(eq? val 'default)                      'default]
                           [(and (pair? val) (eq? (car val) 'quote)) (cadr val)]
                           [else #f]))
           (loop (or trigger t) zh-name)]
          ;; Case 3: (define chinese-name ...)
          [(and (list? expr) (= (length expr) 3)
                (eq? (car expr) 'define)
                (eq? (cadr expr) 'chinese-name))
           (loop trigger (or zh-name (caddr expr)))]
          [else (loop trigger zh-name)])))))

;; Precompute skin metadata once at startup
(define precomputed-skin-items
  (filter-map
   (lambda (f)
     (and
      (equal? (path-get-extension f) #".rkt")
      (let-values ([(trigger zh-name) (read-skin-metadata f)])
        (and trigger
             (let ([skin-id (path->string (path-replace-extension (file-name-from-path f) #""))])
               (list skin-id
                     (cond [(eq? trigger 'default) "default"]
                           [(list? trigger)        trigger]
                           [else                   '()])
                     (or zh-name "")
                     (skin-preview-spec f)
                     (skin-preview-svgs f)))))))
   (sort (directory-list skins-dir #:build? #t) path<?)))

(define precomputed-schema-items
  (for/list ([s (in-list (remove-duplicates (append generated-config-ids
                                                    (list-static-schemas))))])
    (define mo? (schema-module-ref s 'mobile-only? #f))
    (define deps (read-schema-deps s))
    (define zh-name (schema-module-ref s 'chinese-name (read-schema-name-from-yaml s)))
    (hash 'id s
          'name (or zh-name s)
          'deps deps
          'mobile-only? mo?)))

;; ---- Handlers --------------------------------------------------------------

(define (json-error msg)
  (response/full
   400 #"Bad Request" (current-seconds) #"application/json" '()
   (list (jsexpr->bytes (hash 'error msg)))))

(define (html-response html)
  (response/full
   200 #"OK" (current-seconds) #"text/html; charset=utf-8" '()
   (list (string->bytes/utf-8 html))))

(define (svg-response svg)
  (response/full
   200 #"OK" (current-seconds) #"image/svg+xml"
   (list (make-header #"Cache-Control" #"public, max-age=300"))
   (list (string->bytes/utf-8 svg))))

(define (handle-page req route)
  (html-response (render-page req precomputed-schema-items precomputed-skin-items #:route route)))

(define (handle-configurator req)
  (html-response (render-configurator req precomputed-schema-items precomputed-skin-items)))

(define (handle-app-css req)
  (if (file-exists? app-css-path)
      (response/full
       200 #"OK" (current-seconds) #"text/css; charset=utf-8"
       (list (make-header #"Cache-Control" #"public, max-age=300"))
       (list (file->bytes app-css-path)))
      (response/full
       404 #"Not Found" (current-seconds) #"text/plain; charset=utf-8" '()
       (list #"CSS not found"))))

(define (handle-metadata req)
  (define skins
    (map (lambda (item)
           (define name (car item))
           (define triggers (cadr item))
           (define zh-name (caddr item))
           (define preview (cadddr item))
           (define preview-svgs (car (cddddr item)))
           (define demo-path (skin-demo-path name))
           (hash 'id name
                 'name (if (string=? zh-name "") name zh-name)
                 'triggers (if (eq? triggers 'default) "default" triggers)
                 'preview preview
                 'preview-svg (hash-ref preview-svgs 'light #f)
                 'preview-dark-svg (hash-ref preview-svgs 'dark #f)
                 'preview-image-url (and (file-exists? demo-path)
                                         (string-append "/skins/" name "/demo.png"))))
         precomputed-skin-items))

  (response/full
   200 #"OK" (current-seconds) #"application/json" '()
   (list (jsexpr->bytes (hash 'schemas precomputed-schema-items 'skins skins)))))

(define (handle-skin-demo req skin-id)
  (cond
    [(not (valid-id? skin-id))
     (json-error "Invalid skin id")]
    [else
     (define demo-path (skin-demo-path skin-id))
     (if (file-exists? demo-path)
         (response/full
          200 #"OK" (current-seconds) #"image/png"
          (list (make-header #"Cache-Control" #"public, max-age=300"))
          (list (file->bytes demo-path)))
         (response/full
          404 #"Not Found" (current-seconds) #"text/plain; charset=utf-8" '()
         (list #"Preview image not found")))]))

(define (handle-skin-preview-svg req skin-id)
  (cond
    [(not (valid-id? skin-id))
     (json-error "Invalid skin id")]
    [else
     (define svg (skin-preview-svg skin-id))
     (if svg
         (svg-response svg)
         (response/full
          404 #"Not Found" (current-seconds) #"text/plain; charset=utf-8" '()
          (list #"Preview SVG not found")))]))

(define (handle-build req)
  (define body-bytes (request-post-data/raw req))
  (define data
    (cond
      [(form-request? req) (form-profile req)]
      [body-bytes (bytes->jsexpr body-bytes)]
      [else (hash)]))
  (define schemas     (hash-ref data 'schemas '()))
  (define extra-skins (hash-ref data 'extra-skins '()))
  (cond
    [(not (and (list? schemas) (andmap valid-id? schemas)))
     (json-error "Invalid schema id")]
    [(not (and (list? extra-skins) (andmap valid-id? extra-skins)))
     (json-error "Invalid skin id")]
    [else
     (define profile (hash 'schemas     schemas
                           'extra-skins extra-skins
                           'desktop?    (hash-ref data 'desktop? #t)))
     (define final-profile
       (if (hash-ref profile 'desktop?)
           (hash-set profile 'extra-src-files '("squirrel.custom.yaml"))
           profile))

     (define tmp-dir      (make-temporary-file "rime-web-~a" 'directory))
     (define profile-name "rime-config")
     (define profile-out  (build-path tmp-dir profile-name))
     (define zip-path     (build-path tmp-dir (string-append profile-name ".zip")))

     (dynamic-wind
      void
      (lambda ()
        (build-profile-from-hash! final-profile profile-name profile-out)
        (zip-profile-path! profile-name profile-out zip-path)
        (define zip-bytes (file->bytes zip-path))
        (response/full
         200 #"OK" (current-seconds) #"application/zip"
         (list (make-header #"Content-Disposition" #"attachment; filename=\"rime-config.zip\""))
         (list zip-bytes)))
      (lambda ()
        (delete-directory/files tmp-dir)))]))

;; ---- Routing ---------------------------------------------------------------

(define-values (dispatch url)
  (dispatch-rules
   [("") (lambda (req) (handle-page req 'home))]
   [("desktop") (lambda (req) (handle-page req 'desktop))]
   [("mobile") (lambda (req) (handle-page req 'mobile))]
   [("ui" "configurator") handle-configurator]
   [("app.css") handle-app-css]
   [("metadata") handle-metadata]
   [("skins" (string-arg) "preview.svg") handle-skin-preview-svg]
   [("skins" (string-arg) "demo.png") handle-skin-demo]
   [("build") #:method "post" handle-build]
   [("api" "rime-config" "metadata") handle-metadata]
   [("api" "rime-config" "skins" (string-arg) "preview.svg") handle-skin-preview-svg]
   [("api" "rime-config" "skins" (string-arg) "demo.png") handle-skin-demo]
   [("api" "rime-config" "build") #:method "post" handle-build]))

(define (start)
  (define port      (let ([p (getenv "PORT")])      (if p (string->number p) 5001)))
  (define listen-ip (let ([h (getenv "LISTEN_IP")]) (or h "127.0.0.1")))
  (printf "Rime API starting on ~a:~a...\n" listen-ip port)
  (serve/servlet
   dispatch
   #:servlet-path ""
   #:servlet-regexp #rx""
   #:port port
   #:launch-browser? #f
   #:listen-ip listen-ip))

(module+ main
  (start))
