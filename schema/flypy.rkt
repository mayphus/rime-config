#lang s-exp "lib/lang.rkt"

(rime-schema flypy
  (name "小鶴雙拼")
  (deps cangjie6)
  (static-files "flypy.yaml" "luna_pinyin.dict.yaml")
  (custom "flypy.custom.yaml"
    (includes yuanshu_common_patch yuanshu_reverse_lookup_patch)
    (patch
     (custom-patch
      (schema-version "0.1")
      (schema-description "朙月拼音＋小鶴雙拼方案。\n精簡版，適合移動端匯入"))))
  (mobile-skin flypy
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
        [flypy-double 13   #:weight bold]))))
