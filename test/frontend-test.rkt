#lang racket/base

(require rackunit
         net/url
         racket/promise
         web-server/http
         "../frontend.rkt")

(define schemas
  (list (hash 'id "flypy"
              'name "小鶴雙拼"
              'deps '()
              'mobile-only? #f)
        (hash 'id "flypy_14"
              'name "小鶴十四鍵"
              'deps '("flypy")
              'mobile-only? #t)))

(define skins
  (list (list "flypy_14" '("flypy_14") "小鶴十四鍵" #f (hash 'light "<svg/>"))))

(define (req path #:method [method #"GET"] #:headers [headers '()] #:bindings [bindings '()])
  (request method
           (string->url path)
           headers
           (delay bindings)
           #f
           "127.0.0.1"
           5001
           "127.0.0.1"))

(module+ test
  (test-case "home page has one platform chooser"
    (define html (render-page (req "/") schemas skins #:route 'home))
    (check-false (regexp-match? #rx"rime-platform-tabs" html))
    (check-true (regexp-match? #rx"rime-entry-grid" html))
    (check-true (regexp-match? #rx"href=\"/desktop\"" html))
    (check-true (regexp-match? #rx"href=\"/mobile\"" html)))

  (test-case "mobile page defaults to the 14-key schema"
    (define html (render-page (req "/mobile") schemas skins #:route 'mobile))
    (check-true (regexp-match? #rx"小鶴十四鍵" html))
    (check-true (regexp-match? #rx"/skins/flypy_14/preview.svg" html))
    (check-true (regexp-match? #rx"<ol class=\"rime-help-list\">" html))
    (check-true (regexp-match? #rx"htmx.org" html)))

  (test-case "form posts become build profiles"
    (define request
      (req "/build"
           #:method #"POST"
           #:headers (list (header #"Content-Type" #"application/x-www-form-urlencoded"))
           #:bindings (list (binding:form #"desktop?" #"false")
                            (binding:form #"schemas" #"flypy_14")
                            (binding:form #"skins" #"flypy_14"))))
    (check-true (form-request? request))
    (check-equal? (form-profile request)
                  (hash 'schemas '("flypy_14")
                        'extra-skins '("flypy_14")
                        'desktop? #f))))
