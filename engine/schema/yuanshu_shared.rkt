#lang racket/base

(require "lib/shared.rkt")

(provide config-files)

(define config-files
  (make-shared-config-files))
