;; List type
(: List (-> $a Type))
(: Cons (-> $a (List $a) (List $a)))
(: Nil (List $a))

;; Tree type
(: Tree (-> $a Type))
(: Node (-> $a Type))
(: mkNode (-> $a (Node $a)))

(: A Bool)

(: mkTree (-> (Node $a) (List (Tree $a)) (Tree $a)))

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

! (get-type (mkTree (mkNode A) Nil))
! (get-type (mkTree (mkNode $a) Nil))
! (get-type (mkXmplr (mkTree (mkNode $a) Nil) (mkDemeId $n) (mkCscore (mkScoreT $cs) (mkComplexity $cp) (mkScoreT $cs) (mkScoreT $up)) (mkBscore Nil)))

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