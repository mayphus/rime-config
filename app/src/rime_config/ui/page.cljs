(ns rime-config.ui.page
  (:require [rime-config.api :as api]
            [rime-config.state :as state]
            [clojure.string :as str]
            [reagent.core :as r]))

(def copy
  {:en {:locale-en "EN"
        :locale-zh "繁"
        :title "Rime Config Builder"
        :status "Status"
        :loading-metadata "Fetching metadata..."
        :metadata-missing "Metadata has not been loaded yet."
        :retry "Retry"
        :platform "Platform"
        :platform-description "Desktop exports schemas only. Mobile automatically shows available skins."
        :desktop "Desktop"
        :desktop-hint "rime"
        :mobile "Mobile"
        :mobile-hint "Yuanshu IME"
        :schemas "Schemas"
        :schemas-description "Dependent schemas are added automatically so the exported config stays complete."
        :include "Include"
        :selected "Selected"
        :skins "Skins"
        :skins-description "Skins appear automatically based on the selected schemas, and you can still turn them off manually."
        :preview "Preview"
        :summary "Summary"
        :summary-platform "Platform"
        :summary-desktop "Desktop (rime)"
        :summary-mobile "Mobile (Yuanshu IME)"
        :summary-schemas "Schemas"
        :summary-skins "Skins"
        :summary-empty "Nothing selected yet."
        :summary-ready-copy "Review the package contents, then generate the archive."
        :auto "Auto"
        :previewing "Previewing"
        :building "Building..."
        :building-note "pb62 mini is packing this for you. Hamster paws at work. 🐹"
        :build "Build and Download"
        :zip-help "Output is a ZIP archive."
        :yuanshu-help "Use in Yuanshu"
        :yuanshu-step-download "1. Install Yuanshu IME on iPhone or iPad."
        :yuanshu-step-import "2. Open the ZIP in Yuanshu, or use Input Schemas -> ... -> Import."
        :yuanshu-step-skin "3. Skins are managed separately from schemas. Remove any old skin with the same name before importing."
        :yuanshu-app-link "Import in Yuanshu"
        :yuanshu-guide-link "See official guide"
        :support "Support"
        :metadata-load-failed "Could not load the available schemas and skins."
        :build-failed "Failed to generate the config."
        :api-unreachable "Could not reach the Rime config API."}
   :zh-Hant {:locale-en "EN"
             :locale-zh "繁"
             :title "Rime 配置生成器"
             :status "狀態"
             :loading-metadata "正在取得 metadata…"
             :metadata-missing "尚未取得 metadata。"
             :retry "重新載入"
             :platform "平台"
             :platform-description "桌面端只生成方案，移動端會自動顯示可用皮膚。"
             :desktop "桌面"
             :desktop-hint "rime"
             :mobile "移動端"
             :mobile-hint "元書輸入法"
             :schemas "方案"
             :schemas-description "依賴方案會自動補上，避免導出不完整配置。"
             :include "加入"
             :selected "已選"
             :skins "皮膚"
             :skins-description "皮膚會根據所選方案自動顯示，你仍然可以手動關閉。"
             :preview "預覽"
             :summary "摘要"
             :summary-platform "平台"
             :summary-desktop "桌面 (rime)"
             :summary-mobile "移動端 (元書輸入法)"
             :summary-schemas "方案"
             :summary-skins "皮膚"
             :summary-empty "目前尚未選擇。"
             :summary-ready-copy "確認打包內容後即可生成壓縮檔。"
             :auto "自動"
             :previewing "目前預覽"
             :building "編譯中…"
             :building-note "pb62 mini 正在幫你打包。倉鼠小爪爪開工中。🐹"
             :build "編譯並下載"
             :zip-help "輸出為 ZIP 壓縮包。"
             :yuanshu-help "如何在元書中使用"
             :yuanshu-step-download "1. 先在 iPhone 或 iPad 安裝元書輸入法。"
             :yuanshu-step-import "2. 用元書打開這個 ZIP，或在「輸入方案」->「...」->「導入方案」中導入。"
             :yuanshu-step-skin "3. 皮膚與方案是分開管理的。導入前請先刪除同名舊皮膚。"
             :yuanshu-app-link "在元書中導入"
             :yuanshu-guide-link "查看官方說明"
             :support "支持"
             :metadata-load-failed "無法載入可用方案與皮膚。"
             :build-failed "配置生成失敗。"
             :api-unreachable "無法連接 Rime 配置 API。"}})

(defn t [locale k]
  (get-in copy [locale k] (name k)))

(defn localize-error [locale error]
  (cond
    (keyword? error) (t locale error)
    (and (vector? error) (= :build-failed (first error)))
    (or (second error) (t locale :build-failed))
    (string? error) error
    :else nil))

(defn language-toggle [locale on-change]
  [:div {:class "rime-language-toggle"
         :role "group"
         :aria-label "Language selector"}
   (for [[value label] [[:en (t locale :locale-en)]
                        [:zh-Hant (t locale :locale-zh)]]]
     ^{:key (name value)}
     [:button {:class (str "rime-language-button" (when (= locale value) " is-active"))
               :type "button"
               :on-click #(on-change value)}
      label])])

(defn set-document-lang! [locale]
  (set! (.-lang (.-documentElement js/document))
        (if (= locale :zh-Hant) "zh-Hant" "en")))

(defn browser-locales []
  (let [languages (some-> js/navigator .-languages array-seq)
        language (some-> js/navigator .-language)]
    (vec (remove nil? (concat languages (when language [language]))))))

(defn zh-hant-locale? [locale]
  (let [normalized (some-> locale str/lower-case)]
    (boolean
     (and normalized
          (or (str/includes? normalized "hant")
              (str/starts-with? normalized "zh-tw")
              (str/starts-with? normalized "zh-hk")
              (str/starts-with? normalized "zh-mo"))))))

(defn preferred-locale []
  (if (some zh-hant-locale? (browser-locales))
    :zh-Hant
    :en))

(defn schema-card [locale {:keys [id name]} selected? auto? on-toggle]
  [:div {:class (str "rime-option-card"
                     (when selected? " is-selected")
                     (when auto? " is-auto"))}
   [:div {:class "rime-option-copy"}
    [:div {:class "rime-option-title-row"}
     [:span {:class "rime-option-title"} name]
     (when auto?
       [:span {:class "rime-inline-note"} (t locale :auto)])]
    [:span {:class "rime-option-id"} id]]
   [:label {:class "rime-option-toggle"}
    [:input {:type "checkbox"
             :checked selected?
             :disabled auto?
             :on-change on-toggle}]
    [:span {:class "rime-option-toggle-label"}
     (if selected? (t locale :selected) (t locale :include))]]])

(defn skin-card [locale {:keys [id name]} checked? previewing? on-preview on-toggle]
  [:div {:class (str "rime-option-card rime-skin-card"
                     (when checked? " is-selected")
                     (when previewing? " is-previewing"))}
   [:div {:class "rime-skin-row"}
    [:div {:class "rime-option-copy"}
     [:span {:class "rime-option-title"} name]
     [:span {:class "rime-option-id"} id]]
    [:div {:class "rime-skin-actions"}
     [:button {:class "rime-skin-preview-button"
               :type "button"
               :on-click on-preview}
      [:span {:class "rime-option-action"} (t locale :preview)]]
     [:label {:class "rime-option-toggle rime-skin-toggle"}
      [:input {:type "checkbox"
               :checked checked?
               :on-change on-toggle}]
      [:span {:class "rime-option-toggle-label"}
       (if checked? (t locale :selected) (t locale :include))]]]]
   (when previewing?
     [:span {:class "rime-preview-hint"} (t locale :previewing)])])

(defn summary-pill [label]
  [:span {:class "rime-summary-pill"} label])

(def special-preview-label
  {"shift" "⇧"
   "backspace" "⌫"
   "enter" "↵"
   "space" "space"
   "numeric" "123"})

(defn preview-key-label [{:keys [label kind icon]}]
  (cond
    (and (string? label) (not= label "")) label
    (and (string? kind) (contains? special-preview-label kind)) (get special-preview-label kind)
    (and (string? icon) (not= icon "")) icon
    :else ""))

(defn rich-preview-key [key]
  [:div {:class (str "keyboard-preview-key is-rich"
                     (when (contains? #{"shift" "backspace" "enter" "numeric"} (:kind key))
                       " is-special")
                     (when (= "space" (:kind key))
                       " is-space"))
         :style {:flex (str (or (:width key) 1) " 1 0%")
                 :background (:background key)}}
   (if (seq (:layers key))
     (into
      [:<>]
      (for [[layer-index layer] (map-indexed vector (:layers key))]
        ^{:key (str (:id key) "-layer-" layer-index)}
        [:span {:class (str "keyboard-preview-layer"
                            (when (= layer-index 0) " is-primary"))
                :style {:left (str (* 100 (or (:x layer) 0.5)) "%")
                        :top (str (* 100 (or (:y layer) 0.5)) "%")
                        :font-size (str (max 9 (* 0.72 (or (:font-size layer) 14))) "px")
                        :font-weight (or (:font-weight layer) "400")
                        :color (:color layer)
                        :transform "translate(-50%, -50%)"}}
         (:text layer)]))
     [:span {:class "keyboard-preview-fallback-label"}
      (preview-key-label key)])])

(defn rich-keyboard-preview [{:keys [background rows size]}]
  [:div {:class "keyboard-preview"}
   [:div {:class "keyboard-preview-shell"
          :style (cond-> {:background background}
                   (and (:width size) (:height size))
                   (assoc :aspect-ratio (str (:width size) " / " (:height size))))}
    [:div {:class "keyboard-preview-grid is-rich"}
     (for [[row-index row] (map-indexed vector rows)]
       ^{:key (str "rich-row-" row-index)}
       [:div {:class "keyboard-preview-row is-rich"}
        (for [key row
              :when key]
          ^{:key (:id key)}
          [rich-preview-key key])])]]])

(defn keyboard-preview [{:keys [label background offsets rows size]}]
  (if (and (seq rows) (map? (first (first rows))))
    [rich-keyboard-preview {:background background
                            :size size
                            :rows rows}]
    [:div {:class "keyboard-preview"}
     [:p {:class "keyboard-preview-label"} label]
     [:div {:class "keyboard-preview-grid"}
      (for [[row-index row] (map-indexed vector rows)]
        ^{:key (str "row-" row-index)}
        [:div {:class "keyboard-preview-row"
               :style {:padding-left (str (nth offsets row-index 0) "rem")}}
         (for [keycap row]
           ^{:key (str row-index "-" keycap)}
           [:div {:class (str "keyboard-preview-key"
                              (when (> (count keycap) 2) " is-wide")
                              (when (= "　　　　　" keycap) " is-blank"))}
            (when-not (= "　　　　　" keycap)
              keycap)])])
      (when (not-any? #{"⌫"} (flatten rows))
        [:div {:class "keyboard-preview-space-row"}
         [:div {:class "keyboard-preview-space"}]])]]))

(defn build-request-body [platform selected-schemas active-skins]
  {:schemas (vec (sort selected-schemas))
   :extra-skins active-skins
   :desktop? (= platform :desktop)})

(defn rime-loading-view [locale metadata-loading? error on-locale-change on-retry]
  [:div {:class "rime-config-shell"}
   [:section {:class "rime-hero-card"}
    [:div {:class "rime-hero-head"}
     [:h1 {:class "page-title"} (t locale :title)]
     [language-toggle locale on-locale-change]]]
   [:section {:class "rime-notes-card"}
    [:h2 {:class "rime-section-title"} (t locale :status)]
    [:p {:class "rime-section-copy"}
     (if metadata-loading?
       (t locale :loading-metadata)
       (t locale :metadata-missing))]
    (when error
      [:<>
       [:p {:class "rime-error-text"} (localize-error locale error)]
       [:button {:class "rime-build-button"
                 :type "button"
                 :on-click on-retry}
        (t locale :retry)]])]])

(defn rime-ready-view
  [{:keys [locale metadata platform selected-schemas manually-unchecked-skins
           preview-skin-id is-building? error on-platform-change on-schema-toggle
           on-skin-preview on-skin-toggle on-build
           on-locale-change]}]
  (let [auto-deps (state/auto-deps metadata selected-schemas)
        active-schema-ids (state/all-active-schemas metadata selected-schemas)
        visible-schemas (vec
                         (for [schema (:schemas metadata)
                               :let [mobile-only? (:mobile-only? schema)]
                               :when (not (and (= platform :desktop) mobile-only?))]
                           schema))
        visible-skins (vec (state/visible-skins metadata platform active-schema-ids))
        active-skins (state/active-skins metadata platform selected-schemas manually-unchecked-skins)
        preview-skin-id (or preview-skin-id (some-> visible-skins first :id))
        preview-skin (first (filter #(= preview-skin-id (:id %)) visible-skins))
        preview-layout (:preview preview-skin)
        build-disabled? (or (zero? (count selected-schemas)) is-building?)]
    [:div {:class "rime-config-shell"}
     [:section {:class "rime-hero-card"}
      [:div {:class "rime-hero-head"}
       [:h1 {:class "page-title"} (t locale :title)]
       [language-toggle locale on-locale-change]]]
     [:div {:class "rime-config-grid"}
      [:div {:class "rime-primary-column"}
       [:section {:class "rime-section"}
        [:div {:class "rime-section-header"}
         [:h2 {:class "rime-section-title"} (t locale :platform)]
         [:p {:class "rime-section-copy"} (t locale :platform-description)]]
        [:div {:class "rime-platform-grid"}
         [:button {:class (str "rime-platform-button" (when (= platform :desktop) " is-active"))
                   :type "button"
                   :on-click #(on-platform-change :desktop)}
          [:span {:class "rime-platform-label"} (t locale :desktop)]
          [:span {:class "rime-platform-hint"} (t locale :desktop-hint)]]
         [:button {:class (str "rime-platform-button" (when (= platform :mobile) " is-active"))
                   :type "button"
                   :on-click #(on-platform-change :mobile)}
          [:span {:class "rime-platform-label"} (t locale :mobile)]
          [:span {:class "rime-platform-hint"} (t locale :mobile-hint)]]]]
       [:section {:class "rime-section"}
        [:div {:class "rime-section-header"}
         [:h2 {:class "rime-section-title"} (t locale :schemas)]
         [:p {:class "rime-section-copy"} (t locale :schemas-description)]]
        [:div {:class "rime-option-grid"}
         (for [schema visible-schemas]
           ^{:key (:id schema)}
           [schema-card locale schema
            (contains? active-schema-ids (:id schema))
            (contains? auto-deps (:id schema))
            #(on-schema-toggle schema)])]]
       (when (and (= platform :mobile) (seq visible-skins))
         [:section {:class "rime-section"}
          [:div {:class "rime-section-header"}
           [:h2 {:class "rime-section-title"} (t locale :skins)]
           [:p {:class "rime-section-copy"} (t locale :skins-description)]]
         [:div {:class "rime-skin-layout"}
           [:div {:class "rime-skin-picker"}
            (for [skin visible-skins]
              ^{:key (:id skin)}
              [skin-card locale skin
               (not (contains? manually-unchecked-skins (:id skin)))
               (= preview-skin-id (:id skin))
               #(on-skin-preview skin)
               #(on-skin-toggle skin)])]
           [:div {:class "rime-preview-panel"}
            (when preview-skin
              [:div {:class "rime-preview-head"}
               [:div {:class "rime-option-copy"}
                [:span {:class "rime-option-title"} (:name preview-skin)]
                [:span {:class "rime-option-id"} (:id preview-skin)]]
               [:span {:class "rime-preview-hint"} (t locale :preview)]])
            (when preview-layout
              [keyboard-preview preview-layout])]]])]
      [:aside {:class "rime-summary-column"}
       [:div {:class "rime-summary-card"}
        [:div {:class "rime-summary-intro"}
         [:h2 {:class "rime-section-title"} (t locale :summary)]
         [:p {:class "rime-section-copy"} (t locale :summary-ready-copy)]]
        [:div {:class "rime-summary-block"}
         [:p {:class "rime-summary-label"} (t locale :summary-platform)]
         [summary-pill (if (= platform :desktop)
                         (t locale :summary-desktop)
                         (t locale :summary-mobile))]]
        [:div {:class "rime-summary-block"}
         [:p {:class "rime-summary-label"}
          (str (t locale :summary-schemas) " (" (count active-schema-ids) ")")]
         (if (seq active-schema-ids)
           [:div {:class "rime-summary-pills"}
            (for [schema-id active-schema-ids
                  :let [schema (state/schema-by-id metadata schema-id)]]
              ^{:key schema-id}
              [summary-pill
               (str (:name schema schema-id)
                    (when (contains? auto-deps schema-id)
                      (str " · " (t locale :auto))))])]
           [:p {:class "rime-empty-state"} (t locale :summary-empty)])]
        (when (and (= platform :mobile) (seq active-skins))
          [:div {:class "rime-summary-block"}
           [:p {:class "rime-summary-label"}
            (str (t locale :summary-skins) " (" (count active-skins) ")")]
           [:div {:class "rime-summary-pills"}
            (for [skin-id active-skins
                  :let [skin (first (filter #(= skin-id (:id %)) (:skins metadata)))]]
              ^{:key skin-id}
              [summary-pill (:name skin skin-id)])]])
        [:button {:class (str "rime-build-button" (when build-disabled? " is-disabled"))
                  :type "button"
                  :disabled build-disabled?
                  :on-click on-build}
         (if is-building? (t locale :building) (t locale :build))]
        (when is-building?
          [:p {:class "rime-build-note"} (t locale :building-note)])
        [:p {:class "rime-help-text"} (t locale :zip-help)]
        [:div {:class "rime-help-block"}
         [:p {:class "rime-summary-label"} (t locale :yuanshu-help)]
         [:p {:class "rime-help-text"} (t locale :yuanshu-step-download)]
         [:p {:class "rime-help-text"} (t locale :yuanshu-step-import)]
         [:p {:class "rime-help-text"} (t locale :yuanshu-step-skin)]
         [:div {:class "rime-help-links"}
          [:a {:class "rime-help-link"
               :href "https://apps.apple.com/cn/app/%E5%85%83%E4%B9%A6%E8%BE%93%E5%85%A5%E6%B3%95/id6744464701"
               :target "_blank"
               :rel "noreferrer"}
           (t locale :yuanshu-app-link)]
          [:a {:class "rime-help-link"
               :href "https://ihsiao.com/apps/hamster/v3/docs/guides/schema/"
               :target "_blank"
               :rel "noreferrer"}
           (t locale :yuanshu-guide-link)]]]
        [:div {:class "rime-support-block"}
         [:p {:class "rime-summary-label"} (t locale :support)]
         [:div {:class "rime-support-image-frame"}
          [:img {:class "rime-support-image"
                 :src "/support/qr-source.jpg"
                 :alt "Support QR code"}]]]
        (when error
          [:p {:class "rime-error-text"} (localize-error locale error)])]]]]))

(defn rime-config-app [{:keys [api-url metadata]}]
  (let [metadata* (r/atom metadata)
        metadata-loading?* (r/atom (nil? metadata))
        locale* (r/atom (preferred-locale))
        platform* (r/atom :desktop)
        selected-schemas* (r/atom #{"flypy"})
        manually-unchecked-skins* (r/atom #{})
        preview-skin-id* (r/atom nil)
        is-building* (r/atom false)
        error* (r/atom nil)]
    (letfn [(load-metadata! []
              (reset! metadata-loading?* true)
              (api/fetch-metadata!
               api-url
               #(do (reset! metadata* %)
                    (reset! error* nil))
               #(reset! error* %)
               #(reset! metadata-loading?* false)))]
    (r/create-class
     {:display-name "RimeConfigApp"
     :component-did-mount
      (fn [_]
        (set-document-lang! @locale*)
        (when-not @metadata*
          (load-metadata!)))
      :reagent-render
      (fn [{:keys [api-url]}]
        (if-let [metadata @metadata*]
          [rime-ready-view
           {:locale @locale*
           :metadata metadata
           :platform @platform*
           :selected-schemas @selected-schemas*
           :manually-unchecked-skins @manually-unchecked-skins*
            :preview-skin-id @preview-skin-id*
            :is-building? @is-building*
            :error @error*
            :on-locale-change (fn [next-locale]
                                (reset! locale* next-locale)
                                (set-document-lang! next-locale))
            :on-platform-change #(reset! platform* %)
            :on-schema-toggle
            (fn [schema]
              (swap! selected-schemas*
                     (fn [selected]
                       (if (contains? selected (:id schema))
                         (disj selected (:id schema))
                         (conj selected (:id schema))))))
            :on-skin-preview #(reset! preview-skin-id* (:id %))
            :on-skin-toggle
            (fn [skin]
              (swap! manually-unchecked-skins*
                     (fn [unchecked]
                       (if (contains? unchecked (:id skin))
                         (disj unchecked (:id skin))
                         (conj unchecked (:id skin))))))
            :on-build
            (fn []
              (let [platform @platform*
                    selected-schemas @selected-schemas*
                    active-skins (state/active-skins metadata
                                                     platform
                                                     selected-schemas
                                                     @manually-unchecked-skins*)]
                (reset! is-building* true)
                (reset! error* nil)
                (api/perform-build!
                 api-url
                 (build-request-body platform selected-schemas active-skins)
                 #(reset! error* %)
                 #(reset! is-building* false))))
            }]
          [rime-loading-view @locale* @metadata-loading?* @error*
           (fn [next-locale]
             (reset! locale* next-locale)
             (set-document-lang! next-locale))
           load-metadata!]))}))))
