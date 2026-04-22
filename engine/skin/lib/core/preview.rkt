#lang racket/base

(require racket/hash
         racket/list
         racket/string
         json)

(provide preview-spec-from-files)

(define preview-logical-width 375)

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
             (exact->inexact (/ numerator denominator)))]
       [else (string->number value)])]
    [else #f]))

(define (preview-size page)
  (define keyboard-height
    (parse-numberish (page-ref page 'keyboardHeight #f)))
  (and keyboard-height
       (positive? keyboard-height)
       (hash 'width preview-logical-width
             'height keyboard-height)))

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

(define (preview-spec-from-files preview-files)
  (with-handlers ([exn:fail? (lambda (_) #f)])
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
                [size (and (hash? page) (preview-size page))]
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
                      'size size
                      'rows rows))))))
