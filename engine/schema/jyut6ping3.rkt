#lang racket/base

(require "lib/shared.rkt"
         "lib/core/dsl.rkt")

(provide config-files static-dep-files static-dep-dirs chinese-name)

(define chinese-name    "粵拼")
(define static-dep-files '("jyut6ping3.dict.yaml" "symbols_cantonese.yaml"))
(define static-dep-dirs  '("jyut6ping3_dicts"))

(define config-files
  (make-mobile-custom-file
   "jyut6ping3.custom.yaml"
   '("yuanshu_common_patch")
   (mapping
    (kv "schema/version" "0.1")
    (kv "schema/description"
        "香港語言學學會粵拼方案。\n精簡版，適合移動端匯入")
    (kv "recognizer/patterns/punct" "^/([0-9]0?|[a-z]+)$")
    (kv "recognizer/patterns/flypy" "^`[a-z']*;?$")
    (kv "recognizer/patterns/cangjie6" "^v[a-z]*;?$"))))
