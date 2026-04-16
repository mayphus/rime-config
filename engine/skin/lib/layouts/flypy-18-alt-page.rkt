#lang racket/base

(require "../core/dsl.rkt"
         "../keysets/pinyin-common.rkt"
         "flypy18-page.rkt"
         "flypy18-bases.rkt")

(provide flypy-18-alt-iphone-pinyin-files)

(define six-column-size
  (object ["width" "187.5/1125"]))

(define five-column-size
  (object ["width" "225/1125"]))

(define eight-column-size
  (object ["width" "140.625/1125"]))

(define keyboard-layout
  (array
   (object ["HStack"
            (object ["subviews"
                     (array (object ["Cell" "q18Button"])
                            (object ["Cell" "we18Button"])
                            (object ["Cell" "rt18Button"])
                            (object ["Cell" "yu18Button"])
                            (object ["Cell" "io18Button"])
                            (object ["Cell" "p18Button"]))])])
   (object ["HStack"
            (object ["subviews"
                     (array (object ["Cell" "a18Button"])
                            (object ["Cell" "sd18Button"])
                            (object ["Cell" "fg18Button"])
                            (object ["Cell" "hj18Button"])
                            (object ["Cell" "kl18Button"]))])])
   (object ["HStack"
            (object ["subviews"
                     (array (object ["Cell" "z18Button"])
                            (object ["Cell" "x18Button"])
                            (object ["Cell" "c18Button"])
                            (object ["Cell" "v18Button"])
                            (object ["Cell" "b18Button"])
                            (object ["Cell" "n18Button"])
                            (object ["Cell" "m18Button"])
                            (object ["Cell" "backspaceButton"]))])])
   (object ["HStack"
            (object ["subviews"
                     (array (object ["Cell" "numericButton"])
                            (object ["Cell" "spaceButton"])
                            (object ["Cell" "enterButton"]))])])))

(define button-specs
  (list
   (merged18-spec "q18Button" "q" "Q" "iu" six-column-size #f #f)
   (merged18-spec "we18Button" "w" "WE" "ei e" six-column-size #f (key-spec-swipe-down (find-hybrid-letter-spec "e")))
   (merged18-spec "rt18Button" "r" "RT" "uan ue" six-column-size #f #f)
   (merged18-spec "yu18Button" "y" "YU" "un sh" six-column-size #f #f)
   (merged18-spec "io18Button" "i" "IO" "ch uo" six-column-size #f #f)
   (merged18-spec "p18Button" "p" "P" "ie" six-column-size #f #f)
   (merged18-spec "a18Button" "a" "A" "a" five-column-size #f #f)
   (merged18-spec "sd18Button" "s" "SD" "ong ai" five-column-size #f #f)
   (merged18-spec "fg18Button" "f" "FG" "en eng" five-column-size #f #f)
   (merged18-spec "hj18Button" "h" "HJ" "ang an" five-column-size #f #f)
   (merged18-spec "kl18Button" "k" "KL" "ing iang" five-column-size #f #f)
   (merged18-spec "z18Button" "z" "Z" "ou" eight-column-size #f #f)
   (merged18-spec "x18Button" "x" "X" "ia ua" eight-column-size #f #f)
   (merged18-spec "c18Button" "c" "C" "ao" eight-column-size #f #f)
   (merged18-spec "v18Button" "v" "V" "zh ui" eight-column-size #f #f)
   (merged18-spec "b18Button" "b" "B" "in" eight-column-size #f #f)
   (merged18-spec "n18Button" "n" "N" "iao" eight-column-size #f #f)
   (merged18-spec "m18Button" "m" "M" "ian" eight-column-size #f #f)))

(define (base-page dark? portrait?)
  (cond
    [(and (not dark?) portrait?) flypy18-alt-portrait-light-base]
    [(and dark? portrait?) flypy18-alt-portrait-dark-base]
    [(and (not dark?) (not portrait?)) flypy18-alt-landscape-light-base]
    [else flypy18-alt-landscape-dark-base]))

(define flypy-18-alt-iphone-pinyin-files
  (make-flypy18-files
   #:portrait-name "pinyinPortrait"
   #:landscape-name "pinyinLandscape"
   #:base-page base-page
   #:keyboard-layout keyboard-layout
   #:button-specs button-specs
   #:detail-font-size 8.5))
