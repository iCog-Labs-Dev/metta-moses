;; Types, constructors and functions related to instance.

;; An instance is just a vector of numbers
(: Instance Type)
(: mkInst (-> (List Number) Instance))

;; A scored instance is just a pair of instance and it's score.
(: ScoredInstance (-> $score Type))
(: mkSInst (-> (Pair Instance $score) (ScoredInstance $score)))

;; An instance set is a list of scored instances.
(: InstanceSet (-> $score Type))
(: mkSInstSet (-> (List (ScoredInstance $score)) (InstanceSet $score)))

;; sortDeme -- sort scored instances in a deme by the composite score in a decreasing order
;; this is a wrapper for the actual sorting function sortSInst
(: sortDeme (-> (InstanceSet Cscore) (InstanceSet Cscore)))
(= (sortDeme (mkSInstSet Nil)) (mkSInstSet Nil))
(= (sortDeme (mkSInstSet (Cons $scoredInst $rest)))
    (mkSInstSet (sortSInst (Cons $scoredInst $rest))))

;; sortSInst -- sorts list of scored instances using insertion sort     
(: sortSInst (-> (List (ScoredInstance Cscore)) (List (ScoredInstance Cscore))))
(= (sortSInst Nil) Nil)
(= (sortSInst (Cons $scoredInst $rest))
    (insertSInst $scoredInst (sortSInst $rest)))

;; insertSInst -- implements the decreasing oreder insertion     
(: insertSInst (-> (ScoredInstance Cscore) (List (ScoredInstance Cscore)) (List (ScoredInstance Cscore))))
(= (insertSInst $scoredInst Nil) (Cons $scoredInst Nil))
(= (insertSInst $scoredInst1 (Cons $scoredInst2 $rest))
    (let* (((mkSInst (mkPair (mkInst $inst1) $score1)) $scoredInst1)
            ((mkSInst (mkPair (mkInst $inst2) $score2)) $scoredInst2))
             
            (if (cScore< $score1 $score2)
                (Cons $scoredInst2 (Cons $scoredInst1 $rest))
                (Cons $scoredInst1 (insertSInst $scoredInst2 $rest))))) 

;; extracts the score of a scored instance object
(= (getSInstScore (mkSInst (mkPair $inst $score))) $score)

;; extracts the instance from a scored instance object
(= (getInst (mkSInst (mkPair $inst $score))) $inst)

;; Scored Instance comparator --> instance>=
(: instance>= (-> (ScoredInstance $score) (ScoredInstance $score) Bool))
(= (instance>= (mkSInst (mkPair $inst1 $score1)) (mkSInst (mkPair $inst2 $score2)))
    (cScore>= $score1 $score2))    