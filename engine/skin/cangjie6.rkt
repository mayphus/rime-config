#lang s-exp "lib/lang.rkt"

(skin cangjie6

  (triggers cangjie6)

  (meta
    (name "Cangjie 6" "倉頡六代")
    (summary "A Yuanshu skin focused on Cangjie 6 labels across phone and iPad layouts.")
    (features
      "Cangjie-centered legends"
      "Standard numeric and symbolic secondary pages"))

  (phone-layout
    (layers cangjie)
    (fonts [cangjie 14 #:weight bold]))

  (ipad-layout
    (layers cangjie)
    (size "1.1/16")
    (fonts
      [cangjie 17.5 #:weight bold])))
