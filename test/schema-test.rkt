#lang racket/base

(require rackunit
         racket/string
         (prefix-in flypy_14: "../schema/flypy_14.rkt")
         (prefix-in jyut6ping3: "../schema/jyut6ping3.rkt"))

(define (generated-file files path)
  (hash-ref files path (lambda () (error 'generated-file "missing ~a" path))))

(module+ test
  (test-case "flypy_14 schema DSL emits stable schema YAML"
    (define yaml (generated-file flypy_14:config-files "flypy_14.schema.yaml"))
    (check-not-false (string-contains? yaml "schema_id: flypy_14"))
    (check-not-false (string-contains? yaml "name: \"14鍵\""))
    (check-not-false (string-contains? yaml "dependencies:\n    - cangjie6"))
    (check-not-false (string-contains? yaml "alphabet: qetuoadgjlzcbm"))
    (check-not-false (string-contains? yaml "dictionary: rime_ice"))
    (check-not-false (string-contains? yaml "prism: flypy_14")))

  (test-case "custom patch DSL emits direct Rime patch fields"
    (define yaml (generated-file jyut6ping3:config-files "jyut6ping3.custom.yaml"))
    (check-not-false (string-contains? yaml "schema/version: \"0.1\""))
    (check-not-false (string-contains? yaml "recognizer/patterns/punct: \"^/([0-9]0?|[a-z]+)$\""))
    (check-not-false (string-contains? yaml "recognizer/patterns/cangjie6: \"^v[a-z]*;?$\""))))
