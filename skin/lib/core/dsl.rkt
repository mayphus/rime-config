#lang racket/base

(require racket/format
         racket/hash
         racket/list
         racket/string)

(provide object
         skin-spec
         skin-spec?
         page-spec
         page-spec?
         button-spec
         button-spec?
         make-skin
         make-page
         make-button
         make-skin-files
         bundle
         bundle/strict
         array
         json-number
         json-file
         static-files
         theme-pages
         yaml-page
         render-json
         auto-ordered-page)

(define-syntax-rule (object [key value] ...)
  (list (cons key value) ...))

(define-syntax-rule (array value ...)
  (vector value ...))

(struct button-spec (name kind props) #:transparent)
(struct page-spec (name base-kind rows buttons variants overrides) #:transparent)
(struct skin-spec (config-data pages extras) #:transparent)

(define (make-button name kind props)
  (button-spec name kind props))

(define (make-page name
                   #:base-kind base-kind
                   #:rows [rows '()]
                   #:buttons [buttons '()]
                   #:variants [variants '()]
                   #:overrides [overrides (hash)])
  (page-spec name base-kind rows buttons variants overrides))

(define (make-skin
         #:config config-data
         #:pages [pages '()]
         #:extras [extras '()])
  (skin-spec config-data pages extras))

(struct json-number-val (lexeme) #:transparent)
(define json-number? json-number-val?)
(define json-number-lexeme json-number-val-lexeme)
(define (json-number lexeme)
  (unless (regexp-match? #rx"^-?[0-9]+(\\.[0-9]+(([eE][+-]?[0-9]+)?))?$" lexeme)
    (error 'json-number "invalid numeric lexeme: ~v" lexeme))
  (json-number-val lexeme))

(define (json-string value)
  (define escaped
    (regexp-replace*
     #px"[\u0000-\u001f\\\\\"]"
     value
     (lambda (match)
       (case (string-ref match 0)
         [(#\") "\\\""]
         [(#\\) "\\\\"]
         [(#\backspace) "\\b"]
         [(#\page) "\\f"]
         [(#\newline) "\\n"]
         [(#\return) "\\r"]
         [(#\tab) "\\t"]
         [else (format "\\u~4,'0x" (char->integer (string-ref match 0)))]))))
  (string-append "\"" escaped "\""))

(define (render-json value [level 0])
  (define indent (make-string (* level 3) #\space))
  (define child-indent (make-string (* (add1 level) 3) #\space))
  (cond
    [(vector? value)
     (if (zero? (vector-length value))
         "[ ]"
         (string-append
          "[\n"
          (string-join
           (for/list ([entry (in-vector value)])
             (string-append child-indent (render-json entry (add1 level))))
           ",\n")
          "\n"
          indent
          "]"))]
    [(list? value)
     (if (null? value)
         "{ }"
         (string-append
          "{\n"
          (string-join
           (for/list ([entry (in-list value)])
             (format "~a~a: ~a"
                     child-indent
                     (json-string (car entry))
                     (render-json (cdr entry) (add1 level))))
           ",\n")
          "\n"
          indent
          "}"))]
    [(eq? value 'null) "null"]
    [(json-number? value) (json-number-lexeme value)]
    [(string? value) (json-string value)]
    [(boolean? value) (if value "true" "false")]
    [(number? value) (~a value)]
    [else (error 'render-json "unsupported json value: ~v" value)]))

(define (bundle . file-groups)
  (for/fold ([acc (hash)]) ([group (in-list file-groups)])
    (hash-union acc group #:combine/key (lambda (_ left _right) left))))

(define (bundle/strict . file-groups)
  (for/fold ([acc (hash)]) ([group (in-list file-groups)])
    (hash-union acc group #:combine/key (lambda (key _left _right)
                                          (error 'bundle/strict "duplicate key: ~v" key)))))

(define (page-group->hash group)
  (cond
    [(hash? group) group]
    [(page-spec? group) (page-spec-overrides group)]
    [else
     (error 'make-skin-files "expected page hash or page-spec, got ~v" group)]))

(define (json-file path value)
  (hash path (string-append (render-json value) "\n")))

(define (yaml-page theme name)
  (string-append theme "/" name ".yaml"))

(define (theme-pages names)
  (append
   (for/list ([name (in-list names)])
     (yaml-page "light" name))
   (for/list ([name (in-list names)])
     (yaml-page "dark" name))))

(define (auto-ordered-page combined)
  (for/list ([key (in-list (sort (hash-keys combined) string<?))])
    (cons key (hash-ref combined key))))

(define (make-skin-files spec)
  (unless (skin-spec? spec)
    (error 'make-skin-files "expected skin-spec, got ~v" spec))
  (apply bundle
         (append
          (for/list ([group (in-list (skin-spec-pages spec))])
            (page-group->hash group))
          (for/list ([group (in-list (skin-spec-extras spec))])
            (page-group->hash group))
          (list (json-file "config.yaml" (skin-spec-config-data spec))))))

(define (static-files store paths)
  (for/hash ([path (in-list paths)])
    (values path
            (string-append
             (render-json
              (hash-ref store path
                        (lambda ()
                          (error 'static-files "missing frozen page content for ~a" path))))
             "\n"))))
