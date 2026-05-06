#lang racket/base

(provide default-rime-profile
         default-desktop-profile)

(define default-rime-profile
  (hash 'schemas         '("cangjie6" "jyut6ping3" "bopomofo" "flypy" "luna_pinyin" "terra_pinyin")
        'extra-src-files '("squirrel.custom.yaml")
        'desktop?        #t))

(define default-desktop-profile default-rime-profile)
