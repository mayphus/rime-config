#lang racket/base

(require "lib/shared.rkt"
         "lib/core/dsl.rkt")

(provide config-files mobile-only? schema-deps static-dep-files static-dep-dirs chinese-name)

(define chinese-name    "18鍵改")
(define mobile-only?    #t)
(define schema-deps     '("cangjie6"))
(define static-dep-files '("rime_ice.dict.yaml"))
(define static-dep-dirs  '("rime_ice_dicts"))

(define schema-doc
  (mapping
   (kv "schema"
       (mapping
        (kv "schema_id" "flypy_18_alt")
        (kv "name" "18鍵改")
        (kv "version" "0.1")
        (kv "author"
            (sequence "double pinyin layout by 鶴"
                      "18-key merge layout adapted in this workspace"
                      "dictionary import from iDvel/rime-ice"))
        (kv "description"
            "朙月拼音＋小鶴雙拼 18 鍵方案，使用 rime-ice 詞庫。\niPhone 佈局採用相鄰共鍵：\nQ / WE / RT / YU / IO / P\nA / SD / FG / HJ / KL\nZ / X / C / V / B / N / M")
        (kv "dependencies" (sequence "cangjie6"))))
   (kv "switches"
       (sequence
        (mapping (kv "name" "ascii_mode")
                 (kv "reset" 0)
                 (kv "states" (sequence "18鍵改" "A")))
        (mapping (kv "name" "simplification")
                 (kv "states" (sequence "漢字" "汉字")))
        (mapping (kv "name" "full_shape")
                 (kv "states" (sequence "半角" "全角")))
        (mapping (kv "name" "ascii_punct")
                 (kv "states" (sequence "。，" "．，")))))
   (kv "engine"
       (mapping
        (kv "processors" common-schema-processors)
        (kv "segmentors" common-schema-segmentors)
        (kv "translators"
            (sequence "punct_translator"
                      "reverse_lookup_translator"
                      "script_translator"))
        (kv "filters" common-schema-filters)))
   (kv "speller"
       (mapping
        (kv "alphabet" "qwryipasfhkzxcvbnm")
        (kv "delimiter" " '")
        (kv "algebra"
            (sequence
             "erase/^xx$/"
             "derive/^([jqxy])u$/$1v/"
             "derive/^([aoe])([ioun])$/$1$1$2/"
             "xform/^([aoe])(ng)?$/$1$1$2/"
             "xform/iu$/Q/"
             "xform/(.)ei$/$1W/"
             "xform/uan$/R/"
             "xform/[uv]e$/T/"
             "xform/un$/Y/"
             "xform/^sh/U/"
             "xform/^ch/I/"
             "xform/^zh/V/"
             "xform/uo$/O/"
             "xform/ie$/P/"
             "xform/i?ong$/S/"
             "xform/ing$|uai$/K/"
             "xform/(.)ai$/$1D/"
             "xform/(.)en$/$1F/"
             "xform/(.)eng$/$1G/"
             "xform/[iu]ang$/L/"
             "xform/(.)ang$/$1H/"
             "xform/ian$/M/"
             "xform/(.)an$/$1J/"
             "xform/(.)ou$/$1Z/"
             "xform/[iu]a$/X/"
             "xform/iao$/N/"
             "xform/(.)ao$/$1C/"
             "xform/ui$/V/"
             "xform/in$/B/"
             "xform/([A-Z])/$1/"
             "xlit/QWRTYUIOPSDFGHJKLZXCVBNM/qwrtyuiopsdfghjklzxcvbnm/"
             "xlit/etudgjlo/wrysfhki/"))))
   (kv "translator"
       (mapping
        (kv "dictionary" "rime_ice")
        (kv "prism" "flypy_18_alt")))
   (kv "reverse_lookup"
       (mapping
        (kv "dictionary" "cangjie6")
        (kv "enable_completion" #t)
        (kv "prefix" "`")
        (kv "suffix" "'")
        (kv "tips" "〔蒼頡〕")
        (kv "preedit_format"
            (sequence "xlit|abcdefghijklmnopqrstuvwxyz|日月金木水火土的戈十大中一弓人心手口尸廿山女田止卜片|"))
        (kv "comment_format"
            (sequence "xlit|abcdefghijklmnopqrstuvwxyz|日月金木水火土的戈十大中一弓人心手口尸廿山女田止卜片|"))))
   (kv "punctuator" (mapping (kv "import_preset" "default")))
   (kv "key_binder" (mapping (kv "import_preset" "default")))
   (kv "recognizer"
       (mapping
        (kv "import_preset" "default")
        (kv "patterns"
            (mapping
             (kv "reverse_lookup" "`[a-z]*'?$")))))))

(define custom-doc
  (mapping
   (kv "schema/version" "0.1")
   (kv "schema/description"
       "朙月拼音＋小鶴雙拼 18 鍵方案。\n使用 rime-ice 詞庫，適合 Yuanshu iPhone 18 鍵皮膚。")))

(define config-files
  (bundle
   (yaml-file "flypy_18_alt.schema.yaml" schema-doc)
   (make-mobile-custom-file
    "flypy_18_alt.custom.yaml"
    '("yuanshu_common_patch" "yuanshu_reverse_lookup_patch")
    custom-doc)))
