(ns rime-config.ui.page
  (:require [rime-config.api :as api]
            [rime-config.state :as state]
            [reagent.core :as r]))

(def copy
  {:en {:locale-en "EN"
        :locale-zh "繁"
        :eyebrow "Rime Config Studio"
        :title "Rime Config Builder"
        :loading-description "Loading the latest schema and skin metadata from api-rime.mayphus.org."
        :loading-note "Fresh metadata is pulled before you export."
        :status "Status"
        :loading-metadata "Fetching metadata..."
        :metadata-missing "Metadata has not been loaded yet."
        :hero-description "Choose your platform, input schemas, and skins, then generate a downloadable Rime config ZIP from mayphus.org."
        :hero-note "Dependencies are resolved automatically, so the exported bundle stays usable."
        :hero-metric-schemas "Schemas available"
        :hero-metric-skins "Skins available"
        :hero-metric-build "Export format"
        :hero-format-value "ZIP"
        :hero-mobile-preview "Live mobile preview"
        :platform "Platform"
        :platform-description "Desktop exports schemas only. Mobile automatically shows available skins."
        :desktop "Desktop"
        :desktop-hint "rime"
        :mobile "Mobile"
        :mobile-hint "Yuanshu IME"
        :schemas "Schemas"
        :schemas-description "Dependent schemas are added automatically so the exported config stays complete."
        :skins "Skins"
        :skins-description "Skins appear automatically based on the selected schemas, and you can still turn them off manually."
        :summary "Summary"
        :summary-platform "Platform"
        :summary-desktop "Desktop (rime)"
        :summary-mobile "Mobile (Yuanshu IME)"
        :summary-schemas "Schemas"
        :summary-skins "Skins"
        :summary-selection "Current selection"
        :summary-empty "Nothing selected yet."
        :summary-ready "Ready to export"
        :summary-ready-copy "Review the package contents, then generate the archive."
        :auto "Auto"
        :previewing "Previewing"
        :building "Building..."
        :build "Build and Download"
        :zip-help "Output is a ZIP archive."
        :metadata-load-failed "Could not load the available schemas and skins."
        :build-failed "Failed to generate the config."
        :api-unreachable "Could not reach the Rime config API."}
   :zh-Hant {:locale-en "EN"
             :locale-zh "繁"
             :eyebrow "Rime Config Studio"
             :title "Rime 配置生成器"
             :loading-description "正在從 api-rime.mayphus.org 載入最新方案與皮膚資料。"
             :loading-note "匯出前會先抓取最新 metadata。"
             :status "狀態"
             :loading-metadata "正在取得 metadata…"
             :metadata-missing "尚未取得 metadata。"
             :hero-description "選擇平台、輸入方案與皮膚，直接從 mayphus.org 生成可下載的 Rime 配置壓縮包。"
             :hero-note "依賴項目會自動補齊，避免匯出的配置缺件。"
             :hero-metric-schemas "可用方案"
             :hero-metric-skins "可用皮膚"
             :hero-metric-build "輸出格式"
             :hero-format-value "ZIP"
             :hero-mobile-preview "行動端即時預覽"
             :platform "平台"
             :platform-description "桌面端只生成方案，移動端會自動顯示可用皮膚。"
             :desktop "桌面"
             :desktop-hint "rime"
             :mobile "移動端"
             :mobile-hint "元書輸入法"
             :schemas "方案"
             :schemas-description "依賴方案會自動補上，避免導出不完整配置。"
             :skins "皮膚"
             :skins-description "皮膚會根據所選方案自動顯示，你仍然可以手動關閉。"
             :summary "摘要"
             :summary-platform "平台"
             :summary-desktop "桌面 (rime)"
             :summary-mobile "移動端 (元書輸入法)"
             :summary-schemas "方案"
             :summary-skins "皮膚"
             :summary-selection "目前選擇"
             :summary-empty "目前尚未選擇。"
             :summary-ready "可以匯出"
             :summary-ready-copy "確認打包內容後即可生成壓縮檔。"
             :auto "自動"
             :previewing "目前預覽"
             :building "編譯中…"
             :build "編譯並下載"
             :zip-help "輸出為 ZIP 壓縮包。"
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

(defn schema-card [locale {:keys [id name]} selected? auto? on-toggle]
  [:label {:class (str "rime-option-card"
                       (when selected? " is-selected")
                       (when auto? " is-auto"))}
   [:div {:class "rime-option-card-head"}
    [:div {:class "rime-option-copy"}
     [:div {:class "rime-option-title-row"}
      [:span {:class "rime-option-title"} name]
      (when auto?
        [:span {:class "rime-inline-note"} (t locale :auto)])]
     [:span {:class "rime-option-id"} id]]
    [:input {:type "checkbox"
             :checked selected?
             :disabled auto?
             :on-change on-toggle}]]])

(defn skin-card [locale {:keys [id name]} checked? previewing? on-hover-start on-hover-end on-toggle]
  [:div {:class (str "rime-option-card rime-skin-card"
                     (when checked? " is-selected")
                     (when previewing? " is-previewing"))
         :on-mouse-enter on-hover-start
         :on-mouse-leave on-hover-end}
   [:label {:class "rime-option-card-head"}
    [:div {:class "rime-option-copy"}
     [:span {:class "rime-option-title"} name]
     [:span {:class "rime-option-id"} id]]
    [:input {:type "checkbox"
             :checked checked?
             :on-change on-toggle}]]
   (when previewing?
     [:span {:class "rime-preview-hint"} (t locale :previewing)])])

(defn summary-pill [label]
  [:span {:class "rime-summary-pill"} label])

(defn hero-metric [label value]
  [:div {:class "rime-hero-metric"}
   [:span {:class "rime-hero-metric-label"} label]
   [:strong {:class "rime-hero-metric-value"} value]])

(defn keyboard-preview [{:keys [label offsets rows]}]
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
       [:div {:class "keyboard-preview-space"}]])]])

(defn build-request-body [platform selected-schemas active-skins]
  {:schemas (vec (sort selected-schemas))
   :extra-skins active-skins
   :desktop? (= platform :desktop)})

(defn rime-loading-view [locale metadata-loading? error on-locale-change]
  [:div {:class "rime-config-shell"}
   [:section {:class "rime-hero-card"}
    [:div {:class "rime-hero-head"}
     [:div {:class "rime-hero-copy"}
      [:p {:class "rime-hero-eyebrow"} (t locale :eyebrow)]
      [:h1 {:class "page-title"} (t locale :title)]
      [:p {:class "page-description"} (t locale :loading-description)]
      [:p {:class "rime-hero-note"} (t locale :loading-note)]]
     [language-toggle locale on-locale-change]]]
   [:section {:class "rime-notes-card"}
    [:h2 {:class "rime-section-title"} (t locale :status)]
    [:p {:class "rime-section-copy"}
     (if metadata-loading?
       (t locale :loading-metadata)
       (t locale :metadata-missing))]
    (when error
      [:p {:class "rime-error-text"} (localize-error locale error)])]])

(defn rime-ready-view
  [{:keys [locale metadata platform selected-schemas manually-unchecked-skins
           preview-skin-id is-building? error on-platform-change on-schema-toggle
           on-skin-preview-start on-skin-preview-end on-skin-toggle on-build
           on-locale-change]}]
  (let [auto-deps (state/auto-deps metadata selected-schemas)
        active-schema-ids (state/all-active-schemas metadata selected-schemas)
        visible-skins (vec (state/visible-skins metadata platform active-schema-ids))
        active-skins (state/active-skins metadata platform selected-schemas manually-unchecked-skins)
        schema-count (count (:schemas metadata))
        skin-count (count (or (:skins metadata) []))
        preview-skin-id (or preview-skin-id (some-> visible-skins first :id))
        preview-layout-key (get state/skin-layout preview-skin-id :qwerty)
        preview-layout (merge {:layout-key preview-layout-key}
                              (get state/keyboard-layouts preview-layout-key))
        build-disabled? (or (zero? (count selected-schemas)) is-building?)]
    [:div {:class "rime-config-shell"}
     [:section {:class "rime-hero-card"}
      [:div {:class "rime-hero-head"}
       [:div {:class "rime-hero-copy"}
        [:p {:class "rime-hero-eyebrow"} (t locale :eyebrow)]
        [:h1 {:class "page-title"} (t locale :title)]
        [:p {:class "page-description"} (t locale :hero-description)]
        [:p {:class "rime-hero-note"} (t locale :hero-note)]]
       [language-toggle locale on-locale-change]]
      [:div {:class "rime-hero-metrics"}
       [hero-metric (t locale :hero-metric-schemas) schema-count]
       [hero-metric (t locale :hero-metric-skins) skin-count]
       [hero-metric (t locale :hero-metric-build)
        (if (= platform :mobile)
          (t locale :hero-mobile-preview)
          (t locale :hero-format-value))]]]
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
         (for [schema (:schemas metadata)
               :let [mobile-only? (:mobile-only? schema)]
               :when (not (and (= platform :desktop) mobile-only?))]
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
           [:div {:class "rime-option-grid"}
            (for [skin visible-skins]
              ^{:key (:id skin)}
              [skin-card locale skin
               (not (contains? manually-unchecked-skins (:id skin)))
               (= preview-skin-id (:id skin))
               #(on-skin-preview-start skin)
               on-skin-preview-end
               #(on-skin-toggle skin)])]
           [:div {:class "rime-preview-panel"}
            [keyboard-preview preview-layout]]]])]
      [:aside {:class "rime-summary-column"}
       [:div {:class "rime-summary-card"}
        [:div {:class "rime-summary-intro"}
         [:p {:class "rime-summary-kicker"} (t locale :summary-selection)]
         [:h2 {:class "rime-section-title"} (t locale :summary)]
         [:p {:class "rime-section-copy"} (t locale :summary-ready-copy)]]
        [:div {:class "rime-summary-status"}
         [:span {:class "rime-summary-status-dot"}]
         [:span {:class "rime-summary-status-text"} (t locale :summary-ready)]]
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
        [:p {:class "rime-help-text"} (t locale :zip-help)]
        (when error
          [:p {:class "rime-error-text"} (localize-error locale error)])]]]]))

(defn rime-config-app [{:keys [api-url metadata]}]
  (let [metadata* (r/atom metadata)
        metadata-loading?* (r/atom (nil? metadata))
        locale* (r/atom :en)
        platform* (r/atom :desktop)
        selected-schemas* (r/atom #{"flypy"})
        manually-unchecked-skins* (r/atom #{})
        preview-skin-id* (r/atom nil)
        is-building* (r/atom false)
        error* (r/atom nil)]
    (r/create-class
     {:display-name "RimeConfigApp"
     :component-did-mount
      (fn [_]
        (set-document-lang! :en)
        (when-not @metadata*
          (reset! metadata-loading?* true)
          (api/fetch-metadata!
           api-url
           #(do (reset! metadata* %)
                (reset! error* nil))
           #(reset! error* %)
           #(reset! metadata-loading?* false))))
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
            :on-skin-preview-start #(reset! preview-skin-id* (:id %))
            :on-skin-preview-end #(reset! preview-skin-id* nil)
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
                 #(reset! is-building* false))))}]
          [rime-loading-view @locale* @metadata-loading?* @error*
           (fn [next-locale]
             (reset! locale* next-locale)
             (set-document-lang! next-locale))]))})))
