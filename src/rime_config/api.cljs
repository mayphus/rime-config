(ns rime-config.api)

(defn json-text [value]
  (.stringify js/JSON (clj->js value)))

(defn fetch-metadata! [api-url on-success on-error on-complete]
  (-> (js/fetch (str api-url "/metadata"))
      (.then (fn [response]
               (if (.-ok response)
                 (.json response)
                 (throw (js/Error. "Metadata request failed")))))
      (.then (fn [payload]
               (on-success (js->clj payload :keywordize-keys true))))
      (.catch (fn [_]
                (on-error :metadata-load-failed)))
      (.finally on-complete)))

(defn fetch-blob! [response]
  (.blob response))

(defn trigger-download! [blob filename]
  (let [url (.createObjectURL js/URL blob)
        anchor (.createElement js/document "a")]
    (set! (.-href anchor) url)
    (set! (.-download anchor) filename)
    (.appendChild (.-body js/document) anchor)
    (.click anchor)
    (.remove anchor)
    (.revokeObjectURL js/URL url)))

(defn perform-build! [api-url request-body on-error on-complete]
  (-> (js/fetch (str api-url "/build")
                #js {:method "POST"
                     :headers #js {"Content-Type" "application/json"}
                     :body (json-text request-body)})
      (.then (fn [response]
               (if (.-ok response)
                 (fetch-blob! response)
                 (.json response))))
      (.then (fn [payload]
               (if (instance? js/Blob payload)
                 (trigger-download! payload "rime-config.zip")
                 (on-error [:build-failed (aget payload "error")]))))
      (.catch (fn [_]
                (on-error :api-unreachable)))
      (.finally on-complete)))
