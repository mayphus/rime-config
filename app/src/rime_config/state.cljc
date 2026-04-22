(ns rime-config.state)

(def default-api-url "https://api-rime.mayphus.org")

(def keyboard-layouts
  {:qwerty {:label "26 鍵全鍵盤"
            :offsets [0 0.55 1.15]
            :rows [["Q" "W" "E" "R" "T" "Y" "U" "I" "O" "P"]
                   ["A" "S" "D" "F" "G" "H" "J" "K" "L"]
                   ["Z" "X" "C" "V" "B" "N" "M"]]}
   :cangjie6 {:label "倉頡六代"
              :offsets [0 0.55 1.15]
              :rows [["Q" "W" "E" "R" "T" "Y" "U" "I" "O" "P"]
                     ["A" "S" "D" "F" "G" "H" "J" "K" "L"]
                     ["Z" "X" "C" "V" "B" "N" "M"]]}
   :18key {:label "18 鍵"
           :offsets [0.75 0.75 0.75]
           :rows [["Q" "W" "E" "R" "T" "Y"]
                  ["A" "S" "D" "F" "G" "H"]
                  ["Z" "X" "C" "V" "B" "N"]]}
   :17key {:label "17 鍵亂序"
           :offsets [0.75 0.75 1.3]
           :rows [["Q" "W" "E" "R" "T" "Y"]
                  ["A" "S" "D" "F" "G" "H"]
                  ["Z" "X" "C" "V" "B"]]}
   :bopomofo {:label "46 鍵注音"
              :offsets [0 0.45 0.9 1.35 0]
              :rows [["ㄅ" "ㄆ" "ㄇ" "ㄈ" "ㄉ" "ㄊ" "ㄋ" "ㄌ" "ㄍ" "ㄎ" "ㄏ"]
                     ["ㄐ" "ㄑ" "ㄒ" "ㄓ" "ㄔ" "ㄕ" "ㄖ" "ㄗ" "ㄘ" "ㄙ"]
                     ["ㄧ" "ㄨ" "ㄩ" "ㄚ" "ㄛ" "ㄜ" "ㄝ" "ㄞ" "ㄟ" "ㄠ"]
                     ["ㄡ" "ㄢ" "ㄣ" "ㄤ" "ㄥ" "ㄦ" "ˊ" "ˇ" "ˋ" "˙"]
                     ["⌫" "　　　　　" "↵"]]}})

(def skin-layout
  {"flypy" :qwerty
   "flypy_18" :18key
   "cangjie6" :cangjie6
   "bopomofo" :bopomofo
   "hybrid" :qwerty
   "zrm_18" :18key
   "zrm_18_aux" :18key
   "shuffle_17" :17key})

(defn schema-by-id [metadata schema-id]
  (first (filter #(= schema-id (:id %)) (:schemas metadata))))

(defn auto-deps [metadata selected-schema-ids]
  (loop [visited (set selected-schema-ids)
         queue (seq selected-schema-ids)
         auto #{}]
    (if-let [schema-id (first queue)]
      (let [deps (:deps (schema-by-id metadata schema-id))
            new-deps (remove visited deps)]
        (recur (into visited new-deps)
               (concat (rest queue) new-deps)
               (into auto new-deps)))
      auto)))

(defn all-active-schemas [metadata selected-schema-ids]
  (into (set selected-schema-ids)
        (auto-deps metadata selected-schema-ids)))

(defn visible-skins [metadata platform active-schema-ids]
  (if (not= platform :mobile)
    []
    (filter (fn [{:keys [triggers]}]
              (or (= triggers :default)
                  (some active-schema-ids triggers)))
            (:skins metadata))))

(defn active-skins [metadata platform selected-schema-ids manually-unchecked-skin-ids]
  (->> (visible-skins metadata platform (all-active-schemas metadata selected-schema-ids))
       (map :id)
       (remove manually-unchecked-skin-ids)
       vec))
