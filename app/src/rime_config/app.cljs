(ns rime-config.app
  (:require [rime-config.ui.page :as page]
            [reagent.core :as r]
            ["react-dom/client" :as react-dom-client]))

(def root-id "app")

(defn root-element []
  (.getElementById js/document root-id))

(defn app-props [element]
  {:api-url (or (.getAttribute element "data-api-url")
                (some-> js/window (aget "__RIME_CONFIG_API_URL__"))
                "/api/rime-config")
   :metadata nil})

(defn render! [element component]
  (let [root (.createRoot react-dom-client element)]
    (.render root (r/as-element component))))

(defn init []
  (when-let [element (root-element)]
    (render! element
             [page/rime-config-app (app-props element)])))
