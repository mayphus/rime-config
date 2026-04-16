(ns rime-config.test-runner
  (:require [clojure.test :as t]
            rime-config.state-test))

(defn -main [& _]
  (let [{:keys [error fail]} (t/run-tests 'rime-config.state-test)]
    (System/exit (if (zero? (+ error fail)) 0 1))))
