;; scored Tree -- exemplar
;; deme ID
(: DemeId Type)
(: mkDemeId (-> Number DemeId))

;; composite_score
(: ScoreT Type)
(: mkScoreT (-> Number ScoreT))

(: Complexity Type)
(: mkComplexity (-> Number Complexity))

(: CompositeScore Type)
(: mkCscore (-> ScoreT Complexity ScoreT ScoreT CompositeScore))

;; behavioral_score
(: BehavioralScore Type)
(: mkBscore (-> (List Number) BehavioralScore))

(: Xmplr Type)
(: mkXmplr (-> (Tree $a) DemeId CompositeScore BehavioralScore Xmplr))

; ! (mkXmplr (mkTree (mk)))
;; Initialize an exemplar with the following values
;;  Raw Score: very_worst_score (e.g., -1e37)??
;;  Complexity: least_complexity (e.g., 0) ??
;;  Complexity Penalty: 0.0.
;;  Uniformity Penalty: 0.0.
;;  Penalized Score: very_worst_score (e.g., -1e37) ??
;;  Behavioral Score: empty set -- Nil

(: xmplrInit (-> (Tree $a) DemeId Xmplr))
(= (xmplrInit $tree  (mkDemeId $id))
    (let ($iScore $iComplexity $iComplexityPen $iUinformityPen $iBehavioralScore) ((pow-math 10 -37) 0 0 (pow-math 10 -37) Nil)
        (mkXmplr 
            $tree 
            (mkDemeId $id) 
            (mkCscore 
                    (mkScoreT $iScore)
                    (mkComplexity $iComplexity)
                    (mkScoreT $iComplexityPen)
                    (mkScoreT $iUinformityPen))
            (mkBscore $iBehavioralScore))))

;; Type for list of ScoreT's for roullete selection
(: probs (List ScoreT))

;; compareXmplr -- Exemplar comparator
;; compares two exemplars using series of scores
;;      penalized, $p1 and $p2, of the two exemplars are used first -- the higher the penalized score the better
;;      if the two scores are equal then complexity scores are used as tie breaker -- the smaller complexity score the better
;;TODO XXX : original implemntaion of examplar comparison takes the difference between scores and 
;;          allows the difference to be a small non-zero number for equality
(: compareXmplr (-> Xmplr Xmplr Atom))
(= (compareXmplr 
        (mkXmplr $tree1 (mkDemeId $id1) (mkCscore (mkScoreT $s1) (mkComplexity $cs1) (mkScoreT $cp1) (mkScoreT $up1)) (mkBscore $bs1))
        (mkXmplr $tree2 (mkDemeId $id2) (mkCscore (mkScoreT $s2) (mkComplexity $cs2) (mkScoreT $cp2) (mkScoreT $up2)) (mkBscore $bs2)))
    
    (let ($p1 $p2) ((- (- $s1 $cp1) $up1) (- (- $s2 $cp2) $up2))
        (case ((> $p1 $p2) (== $p1 $p2) (< $cs1 $cs2) (== $cs1 $cs2))
            
            (((True $t $u $v) G)
            ((False True True $v) G)
            ((False True False True) E)
            ((False True False False) L)
            ((False False $u $v) L) ))))
