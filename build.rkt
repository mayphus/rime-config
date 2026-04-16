#lang racket/base

(require racket/runtime-path)

(define-runtime-path engine-build "engine/build.rkt")

(module+ main
  (parameterize ([current-command-line-arguments (current-command-line-arguments)])
    (dynamic-require `(submod ,engine-build main) #f)))
