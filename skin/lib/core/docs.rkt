#lang racket/base

(require racket/file
         racket/format
         racket/list
         racket/path
         racket/port
         racket/runtime-path
         racket/string
         racket/system
         json
         "preview-svg.rkt")

(provide (struct-out skin-meta)
         make-skin-meta
         make-skin-demo-files
         make-skin-doc-files)

(struct skin-meta (slug english-name chinese-name summary features) #:transparent)

(define-runtime-path render-skin-demo-script "../../../tools/render_skin_demo.py")

(define (require-executable name who)
  (or (find-executable-path name)
      (error who "~a not found in PATH" name)))

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

(define (render-demo-png meta demo-svg)
  (define python-exe
    (require-executable "python3" 'make-skin-doc-files))
  (define tmp-path
    (make-temporary-file
     (~a (path->string (find-system-path 'temp-dir))
         "/yuanshu-skin-demo-"
         (skin-meta-slug meta)
         "-~a.png")))
  (define svg-path
    (make-temporary-file
     (~a (path->string (find-system-path 'temp-dir))
         "/yuanshu-skin-demo-"
         (skin-meta-slug meta)
         "-~a.svg")))
  (dynamic-wind
    void
    (lambda ()
      (call-with-output-file svg-path
        #:exists 'truncate/replace
        (lambda (out)
          (display demo-svg out)))
      (define status
        (system* python-exe
                 render-skin-demo-script
                 "--svg"
                 (path->string svg-path)
                 "--output"
                 (path->string tmp-path)))
      (unless status
        (error 'make-skin-doc-files
               "failed to render demo image for ~a"
               (skin-meta-slug meta)))
      (file->bytes tmp-path))
    (lambda ()
      (when (file-exists? svg-path)
        (delete-file svg-path))
      (when (file-exists? tmp-path)
        (delete-file tmp-path)))))

(define (demo-svg meta preview-spec)
  (define light-preview
    (if (and (hash? preview-spec) (hash-has-key? preview-spec 'dark))
        (hash-remove preview-spec 'dark)
        preview-spec))
  (demo-preview-svg (skin-meta-chinese-name meta) light-preview))

(define (make-skin-demo-files meta preview-spec)
  (if (and preview-spec
           (string=? (or (getenv "RIME_RENDER_SKIN_DOCS") "") "1"))
      (with-handlers ([exn:fail?
                       (lambda (_)
                         (hash))])
        (define svg (demo-svg meta preview-spec))
        (hash "demo.svg" svg
              "demo.png" (render-demo-png meta svg)))
      (hash)))

(define (make-skin-doc-files meta preview-spec)
  (define readme (render-readme meta))
  (if (and preview-spec
           (string=? (or (getenv "RIME_RENDER_SKIN_DOCS") "") "1"))
      (with-handlers ([exn:fail?
                       (lambda (_)
                         (hash "README.md" readme))])
        (define svg (demo-svg meta preview-spec))
        (hash "README.md" readme
              "demo.svg" svg
              "demo.png" (render-demo-png meta svg)))
      (hash "README.md" readme)))
