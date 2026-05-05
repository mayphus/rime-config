#lang s-exp "lib/lang.rkt"

(skin hybrid

  (triggers default)

  (meta
    (name "QuadHarmonic Keyboard" "四合一鍵盤")
    (summary "A hybrid Yuanshu skin that combines Cangjie and Flypy legends on the same phone layout.")
    (features
      "Cangjie and Flypy legends on shared keys"
      "Standard iPad pinyin, numeric, and symbolic pages"))

  (phone-layout
    (layers abc cangjie flypy symbol)
    (centers
      [abc          0.72  0.40]
      [cangjie      0.37  0.34]
      [flypy-single 0.5   0.74]
      [flypy-top    0.5   0.68]
      [flypy-bottom 0.5   0.79]
      [symbol       0.73  0.24])
    (fonts
      [abc     10.5 #:secondary]
      [cangjie 15.5]
      [symbol  8.5]
      [flypy-single 12]
      [flypy-double 7.25]))

  (ipad-layout standard-18))
