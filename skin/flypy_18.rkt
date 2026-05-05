#lang s-exp "lib/lang.rkt"

(skin flypy_18

  (triggers flypy_18)

  (meta
    (name "Flypy 18" "小鶴十八鍵")
    (summary "A compact Yuanshu skin for the Flypy 18-key layout.")
    (features
      "18-key phone layout"
      "Standard iPad pinyin page and secondary pages"))

  (phone-layout flypy-18)

  (ipad-layout standard-18))
