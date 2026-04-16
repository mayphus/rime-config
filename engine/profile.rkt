#lang racket/base

(require racket/path
         racket/list
         racket/string)

(provide default-rime-profile
         default-desktop-profile
         resolve-rime-variant
         resolve-rime-config)

(define default-rime-profile
  (hash 'schemas         '("cangjie6" "jyut6ping3" "bopomofo" "flypy")
        'extra-src-files '("squirrel.custom.yaml")
        'desktop?        #t))

(define default-desktop-profile default-rime-profile)

(define (variant-path root-dir variant)
  (define parts
    (cond
      [(list? variant) variant]
      [(symbol? variant) (list variant)]
      [(string? variant) (string-split variant "/")]
      [else (error 'resolve-rime-variant "Invalid variant: ~v" variant)]))
  (define normalized
    (map (lambda (part)
           (cond
             [(symbol? part) (symbol->string part)]
             [(string? part) part]
             [else (error 'resolve-rime-variant "Invalid variant path element: ~v" part)]))
         parts))
  (define base (build-path root-dir "profiles"))
  (for/fold ([p base]) ([part normalized])
    (build-path p part)))

(define (resolve-rime-variant root-dir variant)
  (cond
    [(or (equal? variant 'desktop)
         (equal? variant "desktop")
         (equal? variant '(desktop))
         (equal? variant '("desktop")))
     default-rime-profile]
    [else
     (define parts
       (cond
         [(list? variant) variant]
         [(symbol? variant) (list variant)]
         [(string? variant) (string-split variant "/")]
         [else (error 'resolve-rime-variant "Invalid variant: ~v" variant)]))
     (define normalized
       (map (lambda (part)
              (cond
                [(symbol? part) (symbol->string part)]
                [(string? part) part]
                [else (error 'resolve-rime-variant "Invalid variant path element: ~v" part)]))
            parts))
     (define base (build-path root-dir "profiles"))
     (define rkt-path
       (if (and (= (length normalized) 1)
                (equal? (path-get-extension (string->path (car normalized))) #".rkt"))
           (build-path base (car normalized))
           (let* ([dir-parts (take normalized (max 0 (sub1 (length normalized))))]
                  [leaf (last normalized)]
                  [dir (for/fold ([p base]) ([part dir-parts]) (build-path p part))])
             (build-path dir (string-append leaf ".rkt")))))
     (if (file-exists? rkt-path)
         (dynamic-require rkt-path 'profile)
         (error 'resolve-rime-variant "Variant not found at ~a" rkt-path))]))

(define (resolve-rime-config root-dir rime-config)
  (cond
    [(hash-has-key? rime-config 'variant)
     (define variant-profile
       (resolve-rime-variant root-dir (hash-ref rime-config 'variant)))
     (for/fold ([merged variant-profile]) ([(k v) (in-hash rime-config)])
       (if (eq? k 'variant)
           merged
           (hash-set merged k v)))]
    [else rime-config]))
