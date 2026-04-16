#lang racket/base

(require racket/hash
         racket/list
         racket/string
         "../core/dsl.rkt"
         "../keysets/pinyin-common.rkt"
         "base-page.rkt")

(provide make-flypy-phone-files
         make-cangjie6-phone-files
         make-standard-phone-pinyin-files
         button-size+bounds
         hint-size
         standard-phone-keyboard-layout
         phone-legend-centers
         standard-phone-portrait-light-base
         standard-phone-portrait-dark-base
         standard-phone-landscape-light-base
         standard-phone-landscape-dark-base)

(define (standard-phone-base dark? portrait?)
  (make-phone-base-page dark? portrait?
                        #:keyboard-height (if portrait? "216" "160")))

(define standard-phone-portrait-light-base  (standard-phone-base #f #t))
(define standard-phone-portrait-dark-base   (standard-phone-base #t #t))
(define standard-phone-landscape-light-base (standard-phone-base #f #f))
(define standard-phone-landscape-dark-base  (standard-phone-base #t #f))

(define normal-button-size
  (object ["width" "112.5/1125"]))

(define wide-button-size
  (object ["width" "168.75/1125"]))

(define left-wide-bounds
  (object ["alignment" "right"]
          ["width" "111/168.75"]))

(define right-wide-bounds
  (object ["alignment" "left"]
          ["width" "111/168.75"]))

(define hint-size
  (object ["height" 50]
          ["width" 50]))

(define standard-phone-keyboard-layout
  (array
   (object ["HStack"
            (object ["subviews"
                     (array (object ["Cell" "qButton"])
                            (object ["Cell" "wButton"])
                            (object ["Cell" "eButton"])
                            (object ["Cell" "rButton"])
                            (object ["Cell" "tButton"])
                            (object ["Cell" "yButton"])
                            (object ["Cell" "uButton"])
                            (object ["Cell" "iButton"])
                            (object ["Cell" "oButton"])
                            (object ["Cell" "pButton"]))])])
   (object ["HStack"
            (object ["subviews"
                     (array (object ["Cell" "aButton"])
                            (object ["Cell" "sButton"])
                            (object ["Cell" "dButton"])
                            (object ["Cell" "fButton"])
                            (object ["Cell" "gButton"])
                            (object ["Cell" "hButton"])
                            (object ["Cell" "jButton"])
                            (object ["Cell" "kButton"])
                            (object ["Cell" "lButton"]))])])
   (object ["HStack"
            (object ["subviews"
                     (array (object ["Cell" "shiftButton"])
                            (object ["Cell" "zButton"])
                            (object ["Cell" "xButton"])
                            (object ["Cell" "cButton"])
                            (object ["Cell" "vButton"])
                            (object ["Cell" "bButton"])
                            (object ["Cell" "nButton"])
                            (object ["Cell" "mButton"])
                            (object ["Cell" "backspaceButton"]))])])
   (object ["HStack"
            (object ["subviews"
                     (array (object ["Cell" "numericButton"])
                            (object ["Cell" "spaceButton"])
                            (object ["Cell" "enterButton"]))])])))

(define phone-legend-centers
  (hash 'abc          (object ["x" (json-number "0.5")] ["y" (json-number "0.28")])
        'flypy-single (object ["x" (json-number "0.5")] ["y" (json-number "0.56")])
        'flypy-top    (object ["x" (json-number "0.5")] ["y" (json-number "0.47")])
        'flypy-bottom (object ["x" (json-number "0.5")] ["y" (json-number "0.63")])
        'cangjie      (object ["x" (json-number "0.5")] ["y" (json-number "0.5")])
        'symbol       (object ["x" (json-number "0.72999999999999998")] ["y" (json-number "0.23999999999999999")])))

(define (button-size+bounds spec)
  (case (string-ref (key-spec-letter spec) 0)
    [(#\a) (values wide-button-size left-wide-bounds '())]
    [(#\l) (values wide-button-size right-wide-bounds '())]
    [else (values normal-button-size #f '())]))

(define (make-phone-letter-config layers)
  (hash
   'enabled-layers layers
   'size-for button-size+bounds
   'centers phone-legend-centers
   'abc-font-size 10
   'abc-secondary? #t
   'cangjie-font-size 14
   'cangjie-font-weight "bold"
   'symbol-font-size 10
   'flypy-single-font-size (json-number "13.5")
   'flypy-single-font-weight "bold"
   'flypy-double-font-size 10
   'flypy-double-font-weight "bold"
   'hint-style-extra (list (cons "size" hint-size))))

(define (ordered-page base-page letter-builder dark? portrait?)
  (define combined
    (hash-union (base-page dark? portrait?)
                (hash-set (letter-builder dark?) "keyboardLayout" standard-phone-keyboard-layout)
                #:combine/key (lambda (_ left _right) left)))
  (auto-ordered-page combined))

(define (make-standard-phone-files base-page letter-builder)
  (bundle
   (json-file (yaml-page "light" "pinyinPortrait")
              (ordered-page base-page letter-builder #f #t))
   (json-file (yaml-page "dark" "pinyinPortrait")
              (ordered-page base-page letter-builder #t #t))
   (json-file (yaml-page "light" "pinyinLandscape")
              (ordered-page base-page letter-builder #f #f))
   (json-file (yaml-page "dark" "pinyinLandscape")
              (ordered-page base-page letter-builder #t #f))))

(define (make-standard-phone-pinyin-files base-page letter-config)
  (make-standard-phone-files
   base-page
   (lambda (dark?) (make-letter-entry-hash dark? hybrid-letter-specs letter-config))))

(define (make-flypy-phone-files base-page)
  (define config (make-phone-letter-config '(abc flypy)))
  (make-standard-phone-pinyin-files base-page config))

(define (make-cangjie6-phone-files base-page)
  (define config (make-phone-letter-config '(cangjie)))
  (make-standard-phone-pinyin-files base-page config))

