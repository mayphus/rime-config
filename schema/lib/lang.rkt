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
;;     (schema
;;       (version "0.1")
;;       (authors "dictionary import from iDvel/rime-ice")
;;       (description "...")
;;       (switches ...)
;;       (engine ...)
;;       (speller ...)
;;       (translator ...))
;;     (custom "flypy_14.custom.yaml"
;;       (includes yuanshu_common_patch yuanshu_reverse_lookup_patch)
;;       (version "0.1")
;;       (description "..."))
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
         (all-from-out "shared.rkt")
         (rename-out [rime-schema-module-begin #%module-begin])
         rime-schema
         include-ref
         switch
         engine
         speller
         translator
         section
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
       (apply
        mapping
        (append
         (list
          (kv "schema_id" (dsl-name id))
          (kv "name" name)
          (kv "version" version)
          (kv "author" (dsl-sequence authors))
          (kv "description" description))
         (if (null? dependencies)
             '()
             (list (kv "dependencies" (dsl-sequence dependencies)))))))
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

(define (include-ref target)
  (mapping (kv "__include" target)))

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

(define (translator #:dictionary dictionary
                    #:prism prism
                    #:preedit-format [preedit-format #f])
  (apply
   section
   'translator
   (append
    (list
     (kv "dictionary" (dsl-name dictionary))
     (kv "prism" (dsl-name prism)))
    (if preedit-format
        (list (kv "preedit_format" preedit-format))
        '()))))

(define (section name . entries)
  (kv (dsl-name name) (apply mapping entries)))

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

  (define (clause-tag clause)
    (define lst (syntax->list clause))
    (and lst (pair? lst) (syntax-e (car lst))))

  (define (drop-clause-tags clauses tags)
    (filter (lambda (clause) (not (memq (clause-tag clause) tags))) clauses))

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
           (define includes (clause-items->strings includes-cl))
           (define patch-expr
             (if patch-cl
                 (cadr (syntax->list patch-cl))
                 (let* ([version-cl (find-clause clauses 'version)]
                        [description-cl (find-clause clauses 'description)]
                        [field-clauses (filter (lambda (clause)
                                                 (eq? (clause-tag clause) 'field))
                                               clauses)])
                   #`(custom-patch
                      #,@(if version-cl
                             (list #`(schema-version #,(cadr (syntax->list version-cl))))
                             '())
                      #,@(if description-cl
                             (list #`(schema-description #,(cadr (syntax->list description-cl))))
                             '())
                      #,@(for/list ([field-cl (in-list field-clauses)])
                           (define parts (syntax->list field-cl))
                           (unless (= (length parts) 3)
                             (raise-syntax-error 'field "expected (field key value)" field-cl))
                           #`(patch-field #,(cadr parts) #,(caddr parts)))))))
	           #`(make-mobile-custom-file
	              filename
	              (list #,@(for/list ([include includes])
	                         (string-expr custom-cl include)))
	              #,patch-expr)])
        #'(hash)))

  (define (schema-clause-expr stx schema-id schema-name deps schema-cl)
    (if schema-cl
        (let* ([items (syntax->list schema-cl)]
               [body (cdr items)])
          (if (and (= (length body) 1)
                   (not (and (syntax->list (car body))
                             (pair? (syntax->list (car body))))))
              (car body)
              (let* ([version-cl (find-clause body 'version)]
                     [authors-cl (find-clause body 'authors)]
                     [description-cl (find-clause body 'description)]
                     [sections (drop-clause-tags body '(version authors description))])
                (unless version-cl
                  (raise-syntax-error 'schema "missing (version ...)" schema-cl))
                (unless authors-cl
                  (raise-syntax-error 'schema "missing (authors ...)" schema-cl))
                (unless description-cl
                  (raise-syntax-error 'schema "missing (description ...)" schema-cl))
                #`(schema-document
                   #:id '#,schema-id
                   #:name #,schema-name
                   #:version #,(cadr (syntax->list version-cl))
                   #:authors (list #,@(cdr (syntax->list authors-cl)))
                   #:description #,(cadr (syntax->list description-cl))
                   #:dependencies (list #,@(for/list ([dep deps])
                                             (string-expr schema-cl dep)))
                   #,@sections))))
        #'#f))

  (define (mobile-skin-clause? clause)
    (define lst (syntax->list clause))
    (and lst (pair? lst) (eq? (syntax-e (car lst)) 'mobile-skin)))

  (define (mobile-skin-id skin-cl)
    (define items (syntax->list skin-cl))
    (unless (>= (length items) 2)
      (raise-syntax-error 'mobile-skin "missing skin id" skin-cl))
    (id-or-string->string (cadr items)))

  (define (mobile-skin-def skin-cl)
    (define items (syntax->list skin-cl))
    (define skin-id (id-or-string->string (cadr items)))
    (define body (map syntax->datum (cddr items)))
    #`(cons #,(string-expr skin-cl skin-id) '#,body))

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
     (define embedded-mobile-skin-defs
       (map mobile-skin-def mobile-skin-clauses))
     (define mobile-skins
       (if explicit-mobile-skins
           explicit-mobile-skins
           embedded-mobile-skins))
     (define deps (clause-items->strings deps-cl))
     (define static-files (clause-items->strings files-cl))
     (define static-dirs (clause-items->strings dirs-cl))
     (define custom-expr (custom-clause-expr custom-cl))
     (define schema-doc (schema-clause-expr stx #'schema-id schema-name deps schema-cl))
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
         (define mobile-skin-defs
           (list #,@embedded-mobile-skin-defs))
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
                  mobile-skin-defs
                  schema-deps
                  static-dep-files
                  static-dep-dirs
                  chinese-name))]))
