#lang racket/base

(require racket/runtime-path)

(define-runtime-path engine-web "engine/web.rkt")

(module+ main
  (parameterize ([current-command-line-arguments (current-command-line-arguments)])
    (dynamic-require `(submod ,engine-web main) #f)))
