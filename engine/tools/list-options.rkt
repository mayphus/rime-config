#lang racket/base
(require "build.rkt"
         racket/file
         racket/path
         racket/list)

(define (list-static-schemas)
  (filter-map
   (lambda (f)
     (define name (path->string f))
     (and (regexp-match? #rx"\\.schema\\.yaml$" name)
          (regexp-replace #rx"\\.schema\\.yaml$" name "")))
   (directory-list data-dir)))

(define (list-skins)
  (filter-map
   (lambda (f)
     (and (equal? (path-get-extension f) #".rkt")
          (path->string (path-replace-extension f #""))))
   (directory-list skins-dir)))

(printf "Schemas: ~v\n" (remove-duplicates (append generated-config-ids (list-static-schemas))))
(printf "Skins: ~v\n" (list-skins))
