#lang racket/base

(require "lib/shared.rkt"
         "lib/core/dsl.rkt")

(provide config-files static-dep-files chinese-name)

(define chinese-name    "蒼頡六代")
(define static-dep-files '("cangjie6.dict.yaml"))

(define config-files
  (make-mobile-custom-file
   "cangjie6.custom.yaml"
   '("yuanshu_common_patch")
   (mapping
    (kv "schema/description"
        "第六代蒼頡檢字法\n精簡版，適合移動端匯入")
    (kv "translator/dictionary" "cangjie6")
    (kv "flypy_reverse_lookup/dictionary" "cangjie6")
    (kv "engine/filters"
        (sequence "simplifier@simplify"
                  "reverse_lookup_filter@flypy_reverse_lookup"
                  "uniquifier"))
    (kv "recognizer/patterns/reverse_lookup" "`[a-z]*;?$"))))
