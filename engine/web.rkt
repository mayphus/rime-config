#lang racket/base

(require web-server/servlet
         web-server/servlet-env
         racket/file
         racket/path
         racket/list
         racket/string
         json
         "build.rkt")

(provide precomputed-skin-items list-static-schemas)

;; ---- Helpers ---------------------------------------------------------------

(define (valid-id? s)
  (and (string? s) (regexp-match? #rx"^[a-zA-Z0-9_-]+$" s)))

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
             (list (path->string (path-replace-extension (file-name-from-path f) #""))
                   (cond [(eq? trigger 'default) "default"]
                         [(list? trigger)        trigger]
                         [else                   '()])
                   (or zh-name ""))))))
   (sort (directory-list skins-dir #:build? #t) path<?)))

;; ---- Handlers --------------------------------------------------------------

(define (json-error msg)
  (response/full
   400 #"Bad Request" (current-seconds) #"application/json" '()
   (list (jsexpr->bytes (hash 'error msg)))))

(define (handle-metadata req)
  (define all-schemas
    (remove-duplicates (append generated-config-ids (list-static-schemas))))

  (define schemas
    (for/list ([s all-schemas])
      (define mo? (schema-module-ref s 'mobile-only? #f))
      (define deps (read-schema-deps s))
      (define zh-name (schema-module-ref s 'chinese-name (read-schema-name-from-yaml s)))
      (hash 'id s
            'name (or zh-name s)
            'deps deps
            'mobile-only? mo?)))

  (define skins
    (map (lambda (item)
           (define name (car item))
           (define triggers (cadr item))
           (define zh-name (caddr item))
           (hash 'id name
                 'name (if (string=? zh-name "") name zh-name)
                 'triggers (if (eq? triggers 'default) "default" triggers)))
         precomputed-skin-items))

  (response/full
   200 #"OK" (current-seconds) #"application/json" '()
   (list (jsexpr->bytes (hash 'schemas schemas 'skins skins)))))

(define (handle-build req)
  (define body-bytes (request-post-data/raw req))
  (define data (if body-bytes (bytes->jsexpr body-bytes) (hash)))
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
   [("metadata") handle-metadata]
   [("build") #:method "post" handle-build]))

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
