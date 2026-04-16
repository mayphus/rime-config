#lang racket/base

(require racket/file
         racket/format
         racket/list
         racket/path
         racket/port
         racket/runtime-path
         racket/string
         racket/system)

(provide (struct-out skin-meta)
         make-skin-meta
         make-skin-doc-files)

(struct skin-meta (slug english-name chinese-name summary features) #:transparent)

(define-runtime-path render-skin-demo-script "../../../tools/render_skin_demo.py")
(define python3-exe
  (or (find-executable-path "python3")
      (error 'make-skin-doc-files "python3 not found in PATH")))

(define (make-skin-meta #:slug slug
                        #:english-name english-name
                        #:chinese-name chinese-name
                        #:summary summary
                        #:features [features '()])
  (skin-meta slug english-name chinese-name summary features))

(define (render-readme meta)
  (define features (skin-meta-features meta))
  (string-append
   "# "
   (skin-meta-english-name meta)
   " ("
   (skin-meta-chinese-name meta)
   ")\n\n"
   (skin-meta-summary meta)
   "\n\n"
   (if (null? features)
       ""
       (string-append
        "## Features\n\n"
        (string-join
         (for/list ([feature (in-list features)])
           (string-append "- " feature))
         "\n")
        "\n\n"))
   "This README and `demo.png` are generated from the skin metadata.\n"))

(define (render-demo-png meta)
  (define tmp-path
    (make-temporary-file
     (~a (path->string (find-system-path 'temp-dir))
         "/yuanshu-skin-demo-"
         (skin-meta-slug meta)
         "-~a.png")))
  (dynamic-wind
    void
    (lambda ()
      (define status
        (system* python3-exe
                 render-skin-demo-script
                 "--title"
                 (skin-meta-chinese-name meta)
                 "--output"
                 (path->string tmp-path)))
      (unless status
        (error 'make-skin-doc-files
               "failed to render demo image for ~a"
               (skin-meta-slug meta)))
      (file->bytes tmp-path))
    (lambda ()
      (when (file-exists? tmp-path)
        (delete-file tmp-path)))))

(define (make-skin-doc-files meta)
  (hash "README.md" (render-readme meta)
        "demo.png" (render-demo-png meta)))
