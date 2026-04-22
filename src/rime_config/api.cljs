(ns rime-config.api)

(defn json-text [value]
  (.stringify js/JSON (clj->js value)))

(defn wait! [ms]
  (js/Promise.
   (fn [resolve _]
     (js/setTimeout resolve ms))))

(defn fetch-json! [url]
  (-> (js/fetch url)
      (.then (fn [response]
               (if (.-ok response)
                 (.json response)
                 (throw (js/Error. (str "Request failed: " (.-status response)))))))))

(defn fetch-metadata!
  ([api-url on-success on-error on-complete]
   (fetch-metadata! api-url on-success on-error on-complete 6 400))
  ([api-url on-success on-error on-complete attempts delay-ms]
   (letfn [(attempt! [remaining]
             (-> (fetch-json! (str api-url "/metadata"))
                 (.then (fn [payload]
                          (on-success (js->clj payload :keywordize-keys true))))
                 (.catch (fn [_]
                           (if (> remaining 1)
                             (-> (wait! delay-ms)
                                 (.then (fn [] (attempt! (dec remaining)))))
                             (do
                               (on-error :metadata-load-failed)
                               (js/Promise.resolve nil)))))))]
     (-> (attempt! attempts)
         (.finally on-complete)))))

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
