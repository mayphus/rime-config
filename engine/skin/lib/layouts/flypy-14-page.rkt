#lang racket/base

(require "../core/dsl.rkt"
         "../keysets/pinyin-common.rkt"
         "flypy18-page.rkt"
         "flypy18-bases.rkt")

(provide flypy-14-iphone-pinyin-files)

(define five-column-size
  (object ["width" "225/1125"]))

(define keyboard-layout
  (array
   (object ["HStack"
            (object ["subviews"
                     (array (object ["Cell" "qw14Button"])
                            (object ["Cell" "er14Button"])
                            (object ["Cell" "ty14Button"])
                            (object ["Cell" "ui14Button"])
                            (object ["Cell" "op14Button"]))])])
   (object ["HStack"
            (object ["subviews"
                     (array (object ["Cell" "as14Button"])
                            (object ["Cell" "df14Button"])
                            (object ["Cell" "gh14Button"])
                            (object ["Cell" "jk14Button"])
                            (object ["Cell" "l14Button"]))])])
   (object ["HStack"
            (object ["subviews"
                     (array (object ["Cell" "shiftButton"])
                            (object ["Cell" "zx14Button"])
                            (object ["Cell" "cv14Button"])
                            (object ["Cell" "bn14Button"])
                            (object ["Cell" "m14Button"])
                            (object ["Cell" "backspaceButton"]))])])
   (object ["HStack"
            (object ["subviews"
                     (array (object ["Cell" "numericButton"])
                            (object ["Cell" "emojiButton"])
                            (object ["Cell" "spaceButton"])
                            (object ["Cell" "semicolonButton"])
                            (object ["Cell" "enterButton"]))])])))

(define button-specs
  (list
   (merged18-spec "qw14Button" "q" "QW" "iu ei ia ua" five-column-size #f #f)
   (merged18-spec "er14Button" "e" "ER" "e uan" five-column-size #f (key-spec-swipe-down (find-hybrid-letter-spec "e")))
   (merged18-spec "ty14Button" "t" "TY" "ue un ing uai" five-column-size #f #f)
   (merged18-spec "ui14Button" "u" "UI" "sh ch u" five-column-size #f #f)
   (merged18-spec "op14Button" "o" "OP" "uo ie" five-column-size #f #f)
   (merged18-spec "as14Button" "a" "AS" "a ong" five-column-size #f #f)
   (merged18-spec "df14Button" "d" "DF" "ai en" five-column-size #f #f)
   (merged18-spec "gh14Button" "g" "GH" "eng ang" five-column-size #f #f)
   (merged18-spec "jk14Button" "j" "JK" "an ing" five-column-size #f #f)
   (merged18-spec "l14Button" "l" "L" "iang uang" five-column-size #f #f)
   (merged18-spec "zx14Button" "z" "ZX" "ou ia" six-column-size #f #f)
   (merged18-spec "cv14Button" "c" "CV" "ao zh ui" six-column-size #f #f)
   (merged18-spec "bn14Button" "b" "BN" "in iao" six-column-size #f #f)
   (merged18-spec "m14Button" "m" "M" "ian" six-column-size #f #f)))

(define (base-page dark? portrait?)
  (cond
    [(and (not dark?) portrait?)       flypy18-portrait-light-base]
    [(and dark?       portrait?)       flypy18-portrait-dark-base]
    [(and (not dark?) (not portrait?)) flypy18-landscape-light-base]
    [else                              flypy18-landscape-dark-base]))

(define flypy-14-iphone-pinyin-files
  (make-flypy18-files
   #:portrait-name   "pinyinPortrait"
   #:landscape-name  "pinyinLandscape"
   #:base-page       base-page
   #:keyboard-layout keyboard-layout
   #:button-specs    button-specs
   #:detail-font-size 7.5))
