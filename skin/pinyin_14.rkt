#lang s-exp "lib/lang.rkt"

(skin pinyin_14

  (triggers pinyin_14)

  (meta
    (name "Pinyin 14" "全拼十四鍵")
    (summary "A compact Yuanshu skin for the full-pinyin 14-key layout.")
    (features
      "14-key full-pinyin phone layout"
      "Standard iPad pinyin page and secondary pages"))

  (phone-layout pinyin-14)

  (ipad-layout standard-18))
