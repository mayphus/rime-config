#lang s-exp "lib/lang.rkt"

(rime-schema bopomofo
  (name "注音")
  (mobile-skin bopomofo
    (meta
      (name "Bopomofo" "注音")
      (summary "A Yuanshu skin for Bopomofo input with the standard secondary pages.")
      (features
        "Bopomofo phone layout"
        "Bundled custom iPad pages"))
    (phone-layout bopomofo)))
