(ns rime-config.ui.page
  (:require [rime-config.api :as api]
            [rime-config.state :as state]
            [reagent.core :as r]))

(defn schema-card [{:keys [id name]} selected? auto? on-toggle]
  [:label {:class (str "rime-option-card"
                       (when selected? " is-selected")
                       (when auto? " is-auto"))}
   [:div {:class "rime-option-card-head"}
    [:div {:class "rime-option-copy"}
     [:div {:class "rime-option-title-row"}
      [:span {:class "rime-option-title"} name]
      (when auto?
        [:span {:class "rime-inline-note"} "自動"])]
     [:span {:class "rime-option-id"} id]]
    [:input {:type "checkbox"
             :checked selected?
             :disabled auto?
             :on-change on-toggle}]]])

(defn skin-card [{:keys [id name]} checked? previewing? on-hover-start on-hover-end on-toggle]
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
     [:span {:class "rime-preview-hint"} "目前預覽"])])

(defn summary-pill [label]
  [:span {:class "rime-summary-pill"} label])

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

(defn rime-loading-view [metadata-loading? error]
  [:div {:class "rime-config-shell"}
   [:section {:class "rime-hero-card"}
    [:div {:class "rime-hero-copy"}
     [:h1 {:class "page-title"} "Rime 配置生成器"]
     [:p {:class "page-description"}
      "正在從 api-rime.mayphus.org 載入最新方案與皮膚資料。"]]]
   [:section {:class "rime-notes-card"}
    [:h2 {:class "rime-section-title"} "狀態"]
    [:p {:class "rime-section-copy"}
     (if metadata-loading?
       "正在取得 metadata…"
       "尚未取得 metadata。")]
    (when error
      [:p {:class "rime-error-text"} error])]])

(defn rime-ready-view
  [{:keys [metadata platform selected-schemas manually-unchecked-skins
           preview-skin-id is-building? error on-platform-change on-schema-toggle
           on-skin-preview-start on-skin-preview-end on-skin-toggle on-build]}]
  (let [auto-deps (state/auto-deps metadata selected-schemas)
        active-schema-ids (state/all-active-schemas metadata selected-schemas)
        visible-skins (vec (state/visible-skins metadata platform active-schema-ids))
        active-skins (state/active-skins metadata platform selected-schemas manually-unchecked-skins)
        preview-skin-id (or preview-skin-id (some-> visible-skins first :id))
        preview-layout-key (get state/skin-layout preview-skin-id :qwerty)
        preview-layout (merge {:layout-key preview-layout-key}
                              (get state/keyboard-layouts preview-layout-key))
        build-disabled? (or (zero? (count selected-schemas)) is-building?)]
    [:div {:class "rime-config-shell"}
     [:section {:class "rime-hero-card"}
      [:div {:class "rime-hero-copy"}
       [:h1 {:class "page-title"} "Rime 配置生成器"]
       [:p {:class "page-description"}
        "選擇平台、輸入方案與皮膚，直接從 mayphus.org 生成可下載的 Rime 配置壓縮包。"]]]

     [:div {:class "rime-config-grid"}
      [:div {:class "rime-primary-column"}
       [:section {:class "rime-section"}
        [:div {:class "rime-section-header"}
         [:h2 {:class "rime-section-title"} "平台"]
         [:p {:class "rime-section-copy"} "桌面端只生成方案，移動端會自動顯示可用皮膚。"]]
        [:div {:class "rime-platform-grid"}
         [:button {:class (str "rime-platform-button" (when (= platform :desktop) " is-active"))
                   :type "button"
                   :on-click #(on-platform-change :desktop)}
          [:span {:class "rime-platform-label"} "桌面"]
          [:span {:class "rime-platform-hint"} "rime"]]
         [:button {:class (str "rime-platform-button" (when (= platform :mobile) " is-active"))
                   :type "button"
                   :on-click #(on-platform-change :mobile)}
          [:span {:class "rime-platform-label"} "移動端"]
          [:span {:class "rime-platform-hint"} "元書輸入法"]]]]

       [:section {:class "rime-section"}
        [:div {:class "rime-section-header"}
         [:h2 {:class "rime-section-title"} "方案"]
         [:p {:class "rime-section-copy"} "依賴方案會自動補上，避免導出不完整配置。"]]
        [:div {:class "rime-option-grid"}
         (for [schema (:schemas metadata)
               :let [mobile-only? (:mobile-only? schema)]
               :when (not (and (= platform :desktop) mobile-only?))]
           ^{:key (:id schema)}
           [schema-card schema
            (contains? active-schema-ids (:id schema))
            (contains? auto-deps (:id schema))
            #(on-schema-toggle schema)])]]

       (when (and (= platform :mobile) (seq visible-skins))
         [:section {:class "rime-section"}
          [:div {:class "rime-section-header"}
           [:h2 {:class "rime-section-title"} "皮膚"]
           [:p {:class "rime-section-copy"} "皮膚會根據所選方案自動顯示，你仍然可以手動關閉。"]]
          [:div {:class "rime-skin-layout"}
           [:div {:class "rime-option-grid"}
            (for [skin visible-skins]
              ^{:key (:id skin)}
              [skin-card skin
               (not (contains? manually-unchecked-skins (:id skin)))
               (= preview-skin-id (:id skin))
               #(on-skin-preview-start skin)
               on-skin-preview-end
               #(on-skin-toggle skin)])]
           [:div {:class "rime-preview-panel"}
            [keyboard-preview preview-layout]]]])]

      [:aside {:class "rime-summary-column"}
       [:div {:class "rime-summary-card"}
        [:div {:class "rime-section-header"}
         [:h2 {:class "rime-section-title"} "摘要"]]
        [:div {:class "rime-summary-block"}
         [:p {:class "rime-summary-label"} "平台"]
         [summary-pill (if (= platform :desktop) "桌面 (rime)" "移動端 (元書輸入法)")]]
        [:div {:class "rime-summary-block"}
         [:p {:class "rime-summary-label"} (str "方案 (" (count active-schema-ids) ")")]
         [:div {:class "rime-summary-pills"}
          (for [schema-id active-schema-ids
                :let [schema (state/schema-by-id metadata schema-id)]]
            ^{:key schema-id}
            [summary-pill
             (str (:name schema schema-id)
                  (when (contains? auto-deps schema-id) " · 自動"))])]]
        (when (and (= platform :mobile) (seq active-skins))
          [:div {:class "rime-summary-block"}
           [:p {:class "rime-summary-label"} (str "皮膚 (" (count active-skins) ")")]
           [:div {:class "rime-summary-pills"}
            (for [skin-id active-skins
                  :let [skin (first (filter #(= skin-id (:id %)) (:skins metadata)))]]
              ^{:key skin-id}
              [summary-pill (:name skin skin-id)])]])
        [:button {:class (str "rime-build-button" (when build-disabled? " is-disabled"))
                  :type "button"
                  :disabled build-disabled?
                  :on-click on-build}
         (if is-building? "編譯中…" "編譯並下載")]
        [:p {:class "rime-help-text"} "輸出為 ZIP 壓縮包。"]
        (when error
          [:p {:class "rime-error-text"} error])]]]]))

(defn rime-config-app [{:keys [api-url metadata]}]
  (let [metadata* (r/atom metadata)
        metadata-loading?* (r/atom (nil? metadata))
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
           {:metadata metadata
            :platform @platform*
            :selected-schemas @selected-schemas*
            :manually-unchecked-skins @manually-unchecked-skins*
            :preview-skin-id @preview-skin-id*
            :is-building? @is-building*
            :error @error*
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
          [rime-loading-view @metadata-loading?* @error*]))})))
