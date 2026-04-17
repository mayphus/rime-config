#lang s-exp "lib/lang.rkt"

(skin bopomofo

  (triggers bopomofo)

  (meta
    (name "Bopomofo" "注音")
    (summary "A Yuanshu skin for Bopomofo input with the standard secondary pages.")
    (features
      "Standard phone and iPad pinyin pages"
      "Generated README.md and demo.png bundle assets"))

  (phone-layout bopomofo)
)
