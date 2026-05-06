#lang racket/base

;; Rime schema DSL language module.
;;
;; Usage:
;;   #lang s-exp "lib/lang.rkt"
;;
;;   (rime-schema flypy_14
;;     (name "14鍵")
;;     (mobile-only)
;;     (deps cangjie6)
;;     (static-files "rime_ice.dict.yaml")
;;     (static-dirs "rime_ice_dicts")
;;     (schema schema-doc) ; optional for custom-only modules
;;     (custom "flypy_14.custom.yaml"
;;       (includes yuanshu_common_patch yuanshu_reverse_lookup_patch)
;;       (patch custom-doc))
;;     (mobile-skin flypy_14
;;       (meta ...)
;;       (phone-layout flypy-14)
;;       (ipad-layout standard-18)))

(require "shared.rkt"
         "core/dsl.rkt"
         (for-syntax racket/base
                     syntax/parse))

(provide (except-out (all-from-out racket/base) #%module-begin)
         #%datum
         (all-from-out "shared.rkt"
                       "core/dsl.rkt")
         (rename-out [rime-schema-module-begin #%module-begin])
         rime-schema
         schema-document
         custom-patch
         patch-field
         schema-version
         schema-description
         switch
         engine
         speller
         translator
         reverse-lookup
         recognizer
         preset-section
         switches
         pattern)

(define (embedded-skin-module-name skin-id)
  (string->symbol (string-append "embedded-skin:" skin-id)))

(define (dsl-name value)
  (cond
    [(symbol? value) (symbol->string value)]
    [(string? value) value]
    [else (error 'dsl-name "expected symbol or string, got ~v" value)]))

(define (dsl-sequence values)
  (apply sequence (map dsl-name values)))

(define (schema-document #:id id
                         #:name name
                         #:version version
                         #:authors authors
                         #:description description
                         #:dependencies [dependencies '()]
                         . sections)
  (apply
   mapping
   (kv "schema"
       (mapping
        (kv "schema_id" (dsl-name id))
        (kv "name" name)
        (kv "version" version)
        (kv "author" (dsl-sequence authors))
        (kv "description" description)
        (kv "dependencies" (dsl-sequence dependencies))))
   sections))

(define (custom-patch . entries)
  (apply mapping entries))

(define (patch-field key value)
  (kv key
      (cond
        [(list? value) (dsl-sequence value)]
        [(or (symbol? value) (string? value)) (dsl-name value)]
        [else value])))

(define (schema-version value)
  (kv "schema/version" value))

(define (schema-description value)
  (kv "schema/description" value))

(define (switch name #:reset [reset #f] #:states states)
  (apply
   mapping
   (append
    (list (kv "name" (dsl-name name)))
    (if reset (list (kv "reset" reset)) '())
    (list (kv "states" (dsl-sequence states))))))

(define (engine #:processors [processors common-schema-processors]
                #:segmentors [segmentors common-schema-segmentors]
                #:translators translators
                #:filters [filters common-schema-filters])
  (kv "engine"
      (mapping
       (kv "processors" processors)
       (kv "segmentors" segmentors)
       (kv "translators" (dsl-sequence translators))
       (kv "filters" filters))))

(define (speller #:alphabet alphabet #:delimiter delimiter #:algebra algebra)
  (kv "speller"
      (mapping
       (kv "alphabet" alphabet)
       (kv "delimiter" delimiter)
       (kv "algebra" (apply sequence algebra)))))

(define (translator #:dictionary dictionary #:prism prism)
  (kv "translator"
      (mapping
       (kv "dictionary" (dsl-name dictionary))
       (kv "prism" (dsl-name prism)))))

(define (reverse-lookup #:dictionary dictionary
                        #:enable-completion [enable-completion #t]
                        #:prefix prefix
                        #:suffix suffix
                        #:tips tips
                        #:preedit-format preedit-format
                        #:comment-format comment-format)
  (kv "reverse_lookup"
      (mapping
       (kv "dictionary" (dsl-name dictionary))
       (kv "enable_completion" enable-completion)
       (kv "prefix" prefix)
       (kv "suffix" suffix)
       (kv "tips" tips)
       (kv "preedit_format" (apply sequence preedit-format))
       (kv "comment_format" (apply sequence comment-format)))))

(define (pattern name value)
  (kv (dsl-name name) value))

(define (recognizer #:import-preset [import-preset 'default] #:patterns [patterns '()])
  (kv "recognizer"
      (mapping
       (kv "import_preset" (dsl-name import-preset))
       (kv "patterns" (apply mapping patterns)))))

(define (preset-section name)
  (kv (dsl-name name) (mapping (kv "import_preset" "default"))))

(define (switches . values)
  (kv "switches" (apply sequence values)))

(define-syntax (rime-schema-module-begin stx)
  (syntax-parse stx
    [(_ body ...)
     #'(#%plain-module-begin body ...)]))

(begin-for-syntax
  (define (find-clause clauses tag)
    (for/first ([c (in-list clauses)]
                #:when (let ([lst (syntax->list c)])
                         (and lst
                              (pair? lst)
                              (eq? (syntax-e (car lst)) tag))))
      c))

  (define (id-or-string->string stx)
    (define v (syntax-e stx))
    (cond
      [(symbol? v) (symbol->string v)]
      [(string? v) v]
      [else (raise-syntax-error #f "expected an identifier or string" stx)]))

  (define (clause-items->strings clause)
    (if clause
        (for/list ([item (in-list (cdr (syntax->list clause)))])
          (id-or-string->string item))
        '()))

  (define (string-expr ctx value)
    #`(symbol->string (quote #,(datum->syntax ctx (string->symbol value)))))

  (define (custom-clause-expr custom-cl)
    (if custom-cl
        (syntax-parse custom-cl
          [(_ filename clause ...)
           (define clauses (syntax->list #'(clause ...)))
           (define includes-cl (find-clause clauses 'includes))
           (define patch-cl (find-clause clauses 'patch))
           (unless patch-cl
             (raise-syntax-error 'custom "missing (patch ...)" custom-cl))
           (define includes (clause-items->strings includes-cl))
           (define patch-expr (cadr (syntax->list patch-cl)))
	           #`(make-mobile-custom-file
	              filename
	              (list #,@(for/list ([include includes])
	                         (string-expr custom-cl include)))
	              #,patch-expr)])
        #'(hash)))

  (define (mobile-skin-clause? clause)
    (define lst (syntax->list clause))
    (and lst (pair? lst) (eq? (syntax-e (car lst)) 'mobile-skin)))

  (define (mobile-skin-id skin-cl)
    (define items (syntax->list skin-cl))
    (unless (>= (length items) 2)
      (raise-syntax-error 'mobile-skin "missing skin id" skin-cl))
    (id-or-string->string (cadr items)))

)

(define-syntax (rime-schema stx)
  (syntax-parse stx
    [(_ schema-id:id clause ...)
     (define clauses (syntax->list #'(clause ...)))
     (define name-cl (find-clause clauses 'name))
     (define mobile-only-cl (find-clause clauses 'mobile-only))
     (define mobile-skins-cl
       (or (find-clause clauses 'mobile-skins)
           (find-clause clauses 'mobile-skin)))
     (define mobile-skin-clauses
       (filter mobile-skin-clause? clauses))
     (define deps-cl (find-clause clauses 'deps))
     (define files-cl (find-clause clauses 'static-files))
     (define dirs-cl (find-clause clauses 'static-dirs))
     (define schema-cl (find-clause clauses 'schema))
     (define custom-cl (find-clause clauses 'custom))

     (unless name-cl
       (raise-syntax-error 'rime-schema "missing (name ...)" stx))
     (unless (or schema-cl custom-cl mobile-skin-clauses)
       (raise-syntax-error 'rime-schema "missing (schema ...), (custom ...), or (mobile-skin ...)" stx))

     (define schema-name (cadr (syntax->list name-cl)))
     (define schema-doc (and schema-cl (cadr (syntax->list schema-cl))))
     (define mobile-only?
       (and mobile-only-cl
            (let ([items (cdr (syntax->list mobile-only-cl))])
              (if (null? items) #'#t (car items)))))
     (define explicit-mobile-skins
       (and mobile-skins-cl
            (not (mobile-skin-clause? mobile-skins-cl))
            (clause-items->strings mobile-skins-cl)))
     (define embedded-mobile-skins
       (map mobile-skin-id mobile-skin-clauses))
     (define mobile-skins
       (if explicit-mobile-skins
           explicit-mobile-skins
           embedded-mobile-skins))
     (define deps (clause-items->strings deps-cl))
     (define static-files (clause-items->strings files-cl))
     (define static-dirs (clause-items->strings dirs-cl))
     (define custom-expr (custom-clause-expr custom-cl))
	     (define schema-expr
	       (if schema-cl
	           #`(yaml-file #,(string-expr stx (string-append (symbol->string (syntax-e #'schema-id)) ".schema.yaml"))
	                        #,schema-doc)
	           #'(hash)))

	     #`(begin
         (define chinese-name #,(string-expr stx (syntax-e schema-name)))
	         (define mobile-only? #,(or mobile-only? #'#f))
	         (define mobile-skins (list #,@(for/list ([skin mobile-skins])
	                                         (string-expr stx skin))))
	         (define schema-deps (list #,@(for/list ([dep deps])
	                                        (string-expr stx dep))))
	         (define static-dep-files (list #,@(for/list ([file static-files])
	                                             (string-expr stx file))))
	         (define static-dep-dirs (list #,@(for/list ([dir static-dirs])
	                                            (string-expr stx dir))))
         (define config-files
           (bundle
            #,schema-expr
            #,custom-expr))
         (provide config-files
                  mobile-only?
                  mobile-skins
                  schema-deps
                  static-dep-files
                  static-dep-dirs
                  chinese-name))]))
