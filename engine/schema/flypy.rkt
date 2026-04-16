#lang racket/base

(require "lib/shared.rkt"
         "lib/core/dsl.rkt")

(provide config-files static-dep-files chinese-name)

(define chinese-name    "小鶴雙拼")
(define static-dep-files '("flypy.yaml" "luna_pinyin.dict.yaml"))

(define config-files
  (make-mobile-custom-file
   "flypy.custom.yaml"
   '("yuanshu_common_patch" "yuanshu_reverse_lookup_patch")
   (mapping
    (kv "schema/version" "0.1")
    (kv "schema/description"
        "朙月拼音＋小鶴雙拼方案。\n精簡版，適合移動端匯入"))))
