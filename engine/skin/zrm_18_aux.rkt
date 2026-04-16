#lang s-exp "lib/lang.rkt"

(skin zrm_18_aux

  (triggers zrm_18_aux)

  (meta
    (name "Ziranma 18 Aux" "自然碼十八鍵(輔助)")
    (summary "Yuanshu skin for Ziranma 18-key with auxiliary code legends.")
    (features
      "18-key phone layout"
      "Auxiliary code legends on keys"
      "Standard iPad pinyin page and secondary pages"))

  (phone-layout
    (template make-flypy18-files)
    (grid
      [q18AuxButton we18AuxButton rt18AuxButton y18AuxButton u18AuxButton io18AuxButton p18AuxButton]
      [a18AuxButton sd18AuxButton fg18AuxButton h18AuxButton jk18AuxButton l18AuxButton]
      [shiftButton  z18AuxButton  xc18AuxButton v18AuxButton  bn18AuxButton m18AuxButton backspaceButton]
      [numericButton emojiButton spaceButton semicolonButton enterButton])
    (buttons
      (merged18-spec "q18AuxButton" "q" "Q" "iu 犭" seven-column-size #f #f)
      (merged18-spec "we18AuxButton" "w" "WE" "ia ua e 文" seven-column-size #f (key-spec-swipe-down (find-hybrid-letter-spec "e")))
      (merged18-spec "rt18AuxButton" "r" "RT" "uan ue 土" seven-column-size #f #f)
      (merged18-spec "y18AuxButton" "y" "Y" "ing uai 言" seven-column-size #f #f)
      (merged18-spec "u18AuxButton" "u" "U" "sh 山" seven-column-size #f #f)
      (merged18-spec "io18AuxButton" "i" "IO" "ch uo 厂日" seven-column-size #f #f)
      (merged18-spec "p18AuxButton" "p" "P" "un 丿" seven-column-size #f #f)
      (merged18-spec "a18AuxButton" "a" "A" "a 一" side-inset-size side-inset-right-bounds #f)
      (merged18-spec "sd18AuxButton" "s" "SD" "ong ai 纟氵" six-column-size #f #f)
      (merged18-spec "fg18AuxButton" "f" "FG" "en eng 扌广" six-column-size #f #f)
      (merged18-spec "h18AuxButton" "h" "H" "ang 禾" six-column-size #f #f)
      (merged18-spec "jk18AuxButton" "j" "JK" "an ao 金口" six-column-size #f #f)
      (merged18-spec "l18AuxButton" "l" "L" "iang uang" side-inset-size side-inset-left-bounds #f)
      (merged18-spec "z18AuxButton" "z" "Z" "ei 乙" seven-column-size #f #f)
      (merged18-spec "xc18AuxButton" "x" "XC" "ie iao 心艹" seven-column-size #f #f)
      (merged18-spec "v18AuxButton" "v" "V" "zh ui 止" seven-column-size #f #f)
      (merged18-spec "bn18AuxButton" "b" "BN" "ou in 宀女" seven-column-size #f #f)
      (merged18-spec "m18AuxButton" "m" "M" "ian" seven-column-size #f #f))
    (fonts 7))

  (ipad-layout standard-18))
