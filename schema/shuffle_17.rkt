#lang racket/base

(require "lib/shared.rkt"
         "lib/core/dsl.rkt")

(provide config-files mobile-only? schema-deps static-dep-files static-dep-dirs chinese-name)

(define chinese-name    "亂序17")
(define mobile-only?    #t)
(define schema-deps     '())
(define static-dep-files '("rime_ice.dict.yaml"))
(define static-dep-dirs  '("rime_ice_dicts"))

(define schema-doc
  (mapping
   (kv "schema"
       (mapping
        (kv "schema_id" "shuffle_17")
        (kv "name" "亂序17")
        (kv "version" "0.1")
        (kv "author"
            (sequence "layout reference from Log Input docs"
                      "dictionary import from iDvel/rime-ice"
                      "Rime schema adapted in this workspace"))
        (kv "description"
            "朙月拼音＋亂序17方案，使用 rime-ice 詞庫。\n移動端優先，17 鍵內碼採用 a-q。")))
   (kv "switches"
       (sequence
        (mapping (kv "name" "ascii_mode")
                 (kv "reset" 0)
                 (kv "states" (sequence "17" "A")))
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
                      "script_translator"))
        (kv "filters" common-schema-filters)))
   (kv "speller"
       (mapping
        (kv "alphabet" "abcdefghijklmnopq")
        (kv "delimiter" " '")
        (kv "algebra"
            (sequence
             "xform/^(a|ai|an|ang|ao|e|ei|en|eng|er|o|ou)$/N$1/"
             "xform/^([jqxy])u$/$1v/"
             "xform/^sh/B/"
             "xform/^zh/C/"
             "xform/^ch/M/"
             "xform/^(h|p)/A/"
             "xform/^b/D/"
             "xform/^x/E/"
             "xform/^(s|m)/F/"
             "xform/^l/G/"
             "xform/^d/H/"
             "xform/^y/I/"
             "xform/^(w|z)/J/"
             "xform/^(j|k)/K/"
             "xform/^(r|n)/L/"
             "xform/^q/N/"
             "xform/^g/O/"
             "xform/^(c|f)/P/"
             "xform/^t/Q/"
             "xform/(iang|ui)$/M/"
             "xform/(uang|ian)$/N/"
             "xform/iong$/D/"
             "xform/iao$/C/"
             "xform/(uai|uan)$/E/"
             "xform/(ie|uo)$/F/"
             "xform/(ue|ve|ai)$/G/"
             "xform/(eng|ing)$/I/"
             "xform/(iu|ou)$/P/"
             "xform/(er|ong)$/Q/"
             "xform/(ia|ua)$/A/"
             "xform/(en|in)$/B/"
             "xform/ao$/D/"
             "xform/ang$/C/"
             "xform/(ei|un)$/O/"
             "xform/(o|v)$/E/"
             "xform/a$/A/"
             "xform/u$/H/"
             "xform/e$/J/"
             "xform/i$/K/"
             "xform/an$/L/"
             "xlit/ABCDEFGHIJKLMNOPQ/abcdefghijklmnopq/"))))
   (kv "translator"
       (mapping
        (kv "dictionary" "rime_ice")
        (kv "prism" "shuffle_17")))
   (kv "punctuator" (mapping (kv "import_preset" "default")))
   (kv "key_binder" (mapping (kv "import_preset" "default")))
   (kv "recognizer" (mapping (kv "import_preset" "default")))))

(define custom-doc
  (mapping
   (kv "schema/version" "0.1")
   (kv "schema/description"
       "朙月拼音＋亂序17方案。\n使用 rime-ice 詞庫，精簡版，適合移動端匯入")))

(define config-files
  (bundle
   (yaml-file "shuffle_17.schema.yaml" schema-doc)
   (make-mobile-custom-file
    "shuffle_17.custom.yaml"
    '("yuanshu_common_patch" "yuanshu_script_patch")
    custom-doc)))
