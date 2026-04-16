(ns rime-config.state-test
  (:require [clojure.test :refer [deftest is]]
            [rime-config.state :as state]))

(def sample-metadata
  {:schemas
   [{:id "flypy" :name "小鶴雙拼" :deps ["cangjie6"] :mobile-only? false}
    {:id "cangjie6" :name "蒼頡六代" :deps ["flypy"] :mobile-only? false}
    {:id "flypy_18" :name "18鍵" :deps ["cangjie6"] :mobile-only? true}]
   :skins
   [{:id "flypy" :name "小鶴雙拼" :triggers ["flypy"]}
    {:id "cangjie6" :name "倉頡六代" :triggers ["cangjie6"]}
    {:id "hybrid" :name "四合一鍵盤" :triggers :default}]})

(deftest resolves-schema-dependencies
  (is (= #{"cangjie6"}
         (state/auto-deps sample-metadata #{"flypy"})))
  (is (= #{"flypy" "cangjie6"}
         (state/all-active-schemas sample-metadata #{"flypy"}))))

(deftest visible-skins-follow-platform-and-schemas
  (is (empty? (state/visible-skins sample-metadata :desktop #{"flypy"})))
  (is (= ["flypy" "cangjie6" "hybrid"]
         (map :id (state/visible-skins sample-metadata :mobile #{"flypy" "cangjie6"})))))

(deftest active-skins-honor-manual-uncheck
  (is (= ["flypy" "hybrid"]
         (state/active-skins sample-metadata :mobile #{"flypy"} #{"cangjie6"}))))
