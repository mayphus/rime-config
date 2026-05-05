#lang s-exp "lib/lang.rkt"

(skin flypy_14

  (triggers flypy_14)

  (meta
    (name "Flypy 14" "小鶴十四鍵")
    (summary "A compact Yuanshu skin for the Flypy 14-key layout.")
    (features
      "14-key phone layout"
      "Standard iPad pinyin page and secondary pages"))

  (phone-layout flypy-14)

  (ipad-layout standard-18))
