#lang racket/base

(require racket/class
         racket/gui/base
         racket/string
         "build.rkt")

(provide start-gui)

(struct option (id name detail) #:transparent)

(define app-profile-name "rime-config")
(define mobile-output-name "gui-mobile")
(define default-schema-ids '("flypy_14"))

(define (schema-options)
  (for/list ([id (in-list (sort generated-config-ids string<?))])
    (define name (or (schema-module-ref id 'chinese-name #f)
                     (read-schema-name-from-yaml id)
                     id))
    (define mobile? (schema-module-ref id 'mobile-only? #f))
    (define deps (read-schema-deps id))
    (define detail
      (string-join
       (filter values
               (list (and mobile? "mobile")
                     (and (pair? deps)
                          (format "deps: ~a" (string-join deps ", ")))))
       " | "))
    (option id name detail)))

(define (option-label item)
  (define detail (option-detail item))
  (if (string=? detail "")
      (format "~a  (~a)" (option-name item) (option-id item))
      (format "~a  (~a, ~a)" (option-name item) (option-id item) detail)))

(define (selected-ids rows)
  (for/list ([row (in-list rows)]
             #:when (send (cdr row) get-value))
    (option-id (car row))))

(define (set-buttons-enabled! buttons enabled?)
  (queue-callback
   (lambda ()
     (for ([button (in-list buttons)])
       (send button enable enabled?)))))

(define (set-status! label text)
  (queue-callback
   (lambda ()
     (send label set-label text))))

(define (with-buttons-disabled buttons thunk)
  (set-buttons-enabled! buttons #f)
  (dynamic-wind
    void
    thunk
    (lambda ()
      (set-buttons-enabled! buttons #t))))

(define (build-mobile-bundle! schemas)
  (define profile
    (hash 'schemas schemas
          'desktop? #f))
  (define profile-out (build-path output-dir mobile-output-name))
  (define zip-path (build-path output-dir (string-append app-profile-name "-mobile.zip")))
  (build-profile-from-hash! profile app-profile-name profile-out)
  (zip-profile-path! app-profile-name profile-out zip-path)
  (values profile-out zip-path))

(define (run-build! schema-rows status buttons)
  (thread
   (lambda ()
     (with-buttons-disabled
      buttons
      (lambda ()
        (with-handlers ([exn:fail?
                         (lambda (exn)
                           (set-status! status (string-append "Build failed: " (exn-message exn))))])
          (define schemas (selected-ids schema-rows))
          (cond
            [(null? schemas)
             (set-status! status "Select at least one schema.")]
            [else
             (set-status! status "Building mobile bundle...")
             (define-values (_profile-out zip-path) (build-mobile-bundle! schemas))
             (set-status! status (format "Built ZIP: ~a" (path->string zip-path)))])))))))

(define (run-push! schema-rows url-field allow-delete include-big-dicts status buttons)
  (thread
   (lambda ()
     (with-buttons-disabled
      buttons
      (lambda ()
        (with-handlers ([exn:fail?
                         (lambda (exn)
                           (set-status! status (string-append "Push failed: " (exn-message exn))))])
          (define schemas (selected-ids schema-rows))
          (cond
            [(null? schemas)
             (set-status! status "Select at least one schema.")]
            [else
             (define raw-url (string-trim (send url-field get-value)))
             (define base-url (and (not (string=? raw-url "")) raw-url))
             (set-status! status "Building mobile bundle...")
             (define-values (profile-out _zip-path) (build-mobile-bundle! schemas))
             (set-status! status "Pushing to Yuanshu WiFi transfer...")
             (do-upload! profile-out
                         #:base-url base-url
                         #:allow-delete (send allow-delete get-value)
                         #:include-big-dicts (send include-big-dicts get-value))
             (set-status! status "Pushed to Yuanshu. Redeploy schemas inside the iPhone app.")])))))))

(define (make-check-list parent title options default-ids)
  (define group (new group-box-panel%
                     [label title]
                     [parent parent]
                     [stretchable-height #t]))
  (for/list ([item (in-list options)])
    (cons item
          (new check-box%
               [label (option-label item)]
               [parent group]
               [value (and (member (option-id item) default-ids) #t)]))))

(define (start-gui)
  (define frame
    (new frame%
         [label "Rime Config"]
         [width 760]
         [height 720]))
  (define root (new vertical-panel%
                    [parent frame]
                    [alignment '(left top)]
                    [spacing 10]
                    [border 16]))

  (new message%
       [parent root]
       [label "Build a Yuanshu mobile bundle locally, then push it to an iPhone running Yuanshu WiFi transfer."])

  (define schema-rows
    (make-check-list root "Schemas" (schema-options) default-schema-ids))

  (define transfer-group
    (new group-box-panel%
         [label "Yuanshu iPhone"]
         [parent root]
         [stretchable-height #f]))
  (define url-field
    (new text-field%
         [label "WiFi transfer URL"]
         [parent transfer-group]
         [init-value ""]
         [min-width 520]))
  (new message%
       [parent transfer-group]
       [label "Leave blank to scan common LAN candidates, or paste the URL shown by Yuanshu."])
  (define allow-delete
    (new check-box%
         [label "Delete remote files no longer in this generated bundle"]
         [parent transfer-group]
         [value #f]))
  (define include-big-dicts
    (new check-box%
         [label "Include large dictionary directories"]
         [parent transfer-group]
         [value #t]))

  (define status
    (new message%
         [parent root]
         [label "Ready."]
         [stretchable-width #t]))
  (define actions
    (new horizontal-panel%
         [parent root]
         [spacing 8]
         [stretchable-height #f]))
  (define build-button #f)
  (define push-button #f)
  (set! build-button
        (new button%
             [label "Build ZIP"]
             [parent actions]
             [callback
              (lambda (_button _event)
                (run-build! schema-rows status (list build-button push-button)))]))
  (set! push-button
        (new button%
             [label "Push to iPhone"]
             [parent actions]
             [callback
              (lambda (_button _event)
                (run-push! schema-rows
                           url-field
                           allow-delete
                           include-big-dicts
                           status
                           (list build-button push-button)))]))

  (send frame show #t))

(module+ main
  (start-gui))
