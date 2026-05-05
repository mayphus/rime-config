#lang racket/base

(require rackunit
         "../deploy/k8s/manifests.rkt")

(module+ test
  (test-case "k8s manifests are generated from Racket"
    (check-k8s!)))
