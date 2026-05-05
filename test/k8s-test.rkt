#lang racket/base

(require rackunit
         "../k8s.rkt")

(module+ test
  (test-case "k8s manifests are generated from Racket"
    (check-k8s!)))
