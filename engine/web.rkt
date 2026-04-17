#lang racket/base

(require web-server/servlet
         web-server/servlet-env
         racket/file
         racket/hash
         racket/path
         racket/list
         racket/string
         json
         "build.rkt")

(provide precomputed-skin-items list-static-schemas)

;; ---- Helpers ---------------------------------------------------------------

(define (valid-id? s)
  (and (string? s) (regexp-match? #rx"^[a-zA-Z0-9_-]+$" s)))

(define (page-ref page key [default #f])
  (cond
    [(symbol? key) (hash-ref page key default)]
    [(string? key) (hash-ref page (string->symbol key) default)]
    [else default]))

(define (parse-numberish value)
  (cond
    [(number? value) value]
    [(string? value)
     (define parts (string-split value "/"))
     (cond
       [(= (length parts) 2)
        (define numerator (string->number (first parts)))
        (define denominator (string->number (second parts)))
        (and numerator denominator (not (zero? denominator))
             (/ numerator denominator))]
       [else (string->number value)])]
    [else #f]))

(define (style-color style)
  (or (page-ref style 'normalColor #f)
      (page-ref style 'highlightColor #f)))

(define (text-style-layer page style-name)
  (define style (page-ref page style-name #f))
  (and (hash? style)
       (equal? (page-ref style 'buttonStyleType #f) "text")
       (let ([center (page-ref style 'center (hash))]
             [text (page-ref style 'text "")])
         (hash 'text text
               'x (or (page-ref center 'x #f) 0.5)
               'y (or (page-ref center 'y #f) 0.5)
               'font-size (or (page-ref style 'fontSize #f) 14)
               'font-weight (or (page-ref style 'fontWeight #f) "")
               'color (or (style-color style) "#000000")))))

(define (normalize-style-refs value)
  (cond
    [(string? value) (list value)]
    [(vector? value) (filter string? (vector->list value))]
    [(list? value) (filter string? value)]
    [else '()]))

(define (button-kind button-id button)
  (define action (page-ref button 'action #f))
  (cond
    [(string? action) action]
    [(string-contains? button-id "space") "space"]
    [(string-contains? button-id "backspace") "backspace"]
    [(string-contains? button-id "shift") "shift"]
    [(string-contains? button-id "enter") "enter"]
    [(string-contains? button-id "numeric") "numeric"]
    [else "key"]))

(define (button-icon page style-name)
  (define style (page-ref page style-name #f))
  (and (hash? style)
       (equal? (page-ref style 'buttonStyleType #f) "systemImage")
       (or (page-ref style 'systemImageName #f)
           (page-ref style 'highlightSystemImageName #f))))

(define (extract-key-preview page button-id)
  (define button (page-ref page button-id #f))
  (and (hash? button)
       (let* ([foreground-refs (normalize-style-refs (page-ref button 'foregroundStyle '()))]
              [layers (filter values (map (lambda (ref) (text-style-layer page ref)) foreground-refs))]
              [sorted-layers
               (sort layers
                     (lambda (left right)
                       (> (hash-ref left 'font-size 0)
                          (hash-ref right 'font-size 0))))]
              [primary-layer
               (or (findf (lambda (layer)
                            (and (string? (hash-ref layer 'text ""))
                                 (not (string=? (hash-ref layer 'text "") ""))))
                          sorted-layers)
                   (and (pair? sorted-layers) (car sorted-layers)))]
              [background-style-name (page-ref button 'backgroundStyle #f)]
              [background-style (and (or (string? background-style-name)
                                         (symbol? background-style-name))
                                     (page-ref page background-style-name #f))]
              [size (page-ref button 'size (hash))]
              [bounds (page-ref button 'bounds (hash))]
              [icon
               (let loop ([refs foreground-refs])
                 (cond
                   [(null? refs) #f]
                   [else (or (button-icon page (car refs))
                             (loop (cdr refs)))]))])
         (hash 'id button-id
               'kind (button-kind button-id button)
               'label (or (and primary-layer (hash-ref primary-layer 'text "")) "")
               'icon (or icon "")
               'width (or (parse-numberish (page-ref size 'width #f)) 1)
               'align (or (page-ref bounds 'alignment #f) "center")
               'background (or (and (hash? background-style) (page-ref background-style 'normalColor #f))
                               "#ffffff")
               'highlight-background (or (and (hash? background-style) (page-ref background-style 'highlightColor #f))
                                         "#e6e6e6")
               'layers sorted-layers))))

(define (extract-row-preview page row-spec)
  (define hstack (page-ref row-spec 'HStack #f))
  (define subviews (and (hash? hstack) (page-ref hstack 'subviews '())))
  (for/list ([subview (in-list (if (vector? subviews) (vector->list subviews) subviews))]
             #:when (hash? subview))
    (extract-key-preview page (page-ref subview 'Cell ""))))

(define (preferred-preview-page-path preview-files)
  (define keys (hash-keys preview-files))
  (or (findf (lambda (key) (regexp-match? #rx"^light/pinyinPortrait\\.yaml$" key)) keys)
      (findf (lambda (key) (regexp-match? #rx"^light/.*Portrait\\.yaml$" key)) keys)
      (findf (lambda (key) (regexp-match? #rx"^light/.*\\.yaml$" key)) keys)
      (and (pair? keys) (car keys))))

(define (extract-preview-spec skin-rkt)
  (with-handlers ([exn:fail? (lambda (_) #f)])
    (define preview-files
      (dynamic-require `(file ,(path->string skin-rkt)) 'skin-preview-files))
    (define page-path (preferred-preview-page-path preview-files))
    (and page-path
         (let* ([page-json (hash-ref preview-files page-path #f)]
                [page (and page-json
                           (bytes->jsexpr (string->bytes/utf-8 page-json)))]
                [keyboard-layout (and (hash? page) (page-ref page 'keyboardLayout '()))]
                [keyboard-style (and (hash? page)
                                     (page-ref page (page-ref (page-ref page 'keyboardStyle (hash))
                                                              'backgroundStyle "")
                                               #f))]
                [rows
                 (and (list? keyboard-layout)
                      (filter values
                              (map (lambda (row)
                                     (let ([preview-row (extract-row-preview page row)])
                                       (and (pair? preview-row) preview-row)))
                                   keyboard-layout)))])
           (and (pair? rows)
                (hash 'page page-path
                      'background (or (and (hash? keyboard-style)
                                           (page-ref keyboard-style 'normalColor #f))
                                      "#ffffff03")
                      'rows rows))))))

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
                     (extract-preview-spec f)))))))
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
           (define preview (cadddr item))
           (hash 'id name
                 'name (if (string=? zh-name "") name zh-name)
                 'triggers (if (eq? triggers 'default) "default" triggers)
                 'preview preview))
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
