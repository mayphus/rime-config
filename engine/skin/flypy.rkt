#lang s-exp "lib/lang.rkt"

(skin flypy

  (triggers flypy flypy_ice)

  (meta
    (name "Flypy" "小鶴雙拼")
    (summary "A Yuanshu skin for Flypy double pinyin with dedicated phone and iPad layouts.")
    (features
      "Flypy legends on both phone and iPad"
      "Standard numeric and symbolic secondary pages"))

  (phone-layout flypy)

  (ipad-layout
    (layers abc flypy)
    (size "1.1/16")
    (centers
      [abc          0.5  0.28]
      [flypy-single 0.5  0.56]
      [flypy-top    0.5  0.47]
      [flypy-bottom 0.5  0.63])
    (fonts
      [abc          11   #:secondary]
      [flypy-single 18.5 #:weight bold]
      [flypy-double 13   #:weight bold])))
