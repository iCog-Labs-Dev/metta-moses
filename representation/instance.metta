;; Types, constructors and functions related to instance.

;; An instance is just a vector of numbers
(: Instance Type)
(: mkInst (-> (List Number) Instance))

;; A scored instance is just a pair of instance and it's score.
(: ScoredInstance (-> $score Type))
(: mkSInst (-> $score (Pair Instance $score) (ScoredInstance $score)))

;; An instance set is a list of scored instances.
(: InstanceSet (-> $score Type))
(: mkSInstSet (-> $score (List (ScoredInstance $score)) (InstanceSet $score)))
