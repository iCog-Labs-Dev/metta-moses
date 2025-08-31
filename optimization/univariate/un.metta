;; ================================================================================
;; Univariate Optimization (translated from moses/moses/optimization/univariate.cc)
;; ================================================================================
;;
;; 
;; - Inputs: Deme, Center instance, TruthTableBScore
;; - Loop steps:
;;   1. Estimate neighborhood size from Deme
;;   2. Sample or generate neighbors near Center using sampleNewInstances
;;   3. Score instances using transform with the complexity-based scorer
;;   4. Pick best scored instance using returnBest folding
;;   5. Set next Center to the best instance and iterate for bounded generations
;; - Output: final center instance, updated Deme, and state tuple
;;
;; Simple theoretical example
;; - Instance is a 1D knob with multiplicity three with values 0, 1, 2
;; - Start center is 0; add neighbors 1 and 2
;; - If score of 2 is better than 1, next center becomes 2
;; - Repeat for limited generations and return best center with updated Deme
;;
;; Inputs
;; - Deme contains Representation with knob map and tree, and an InstanceSet possibly scored
;; - TruthTableBScore carries complexity coefficient and input table for scoring
;; - Instance is the initial center from which neighborhood exploration starts
;;
;; Output
;; - Returns an Instance, a Deme with scored instances, and a state tuple

;; Entry point compatible with runMoses/expandDeme (same signature as hillClimbing)
; (: univariate (-> Deme (TruthTableBScore $a) Instance (Instance Deme $state)))
(= (univariate $deme $tTableBscorer $centerInst)
   (let*
       (
         (() (println! (Entering univariate with center: $centerInst)))
         ((mkTruthTableBScore $cpxCoeff $size $iTable) $tTableBscorer)
         (() (println! (Deme: $deme)))
         ((mkDeme $rep (mkSInstSet $instSet) $id) $deme)
         (() (println! (Rep: $rep)))
         (() (println! (About to call getDiscMap)))
         ($discMap (getDiscMap $rep))
         (() (println! (getDiscMap returned: $discMap)))
         (() (println! (About to call MultiMap.length on: $discMap)))
         ($discMapLength (MultiMap.length $discMap))
         (() (println! (MultiMap.length returned: $discMapLength)))
         ($maxGens (max 1 $discMapLength))
         (() (println! (Max generations: $maxGens)))
       )
       (univariateLoop $deme $cpxCoeff $iTable $centerInst 0 $maxGens)
   ))

; (: univariateLoop (-> Deme Number (ITable $a) Instance Number Number (Instance Deme $state)))
(= (univariateLoop (mkDeme $rep (mkSInstSet $instSet) $id)
                    $cpxCoeff $iTable $centerInst $gen $maxGens)
   (if (>= $gen $maxGens)
       (let* (
         (() (println! (Reached max generations: $gen)))
         ($result ($centerInst (mkDeme $rep (mkSInstSet $instSet) $id) ()))
       )
       $result)
       (let* (
             (() (println! (Univariate loop gen: $gen)))
             (() (println! (Total neighbors: $totalNeighbors)))
             ($totalNeighbors (estimateNeighborhood 1 (getDiscMap $rep)))
             ($nNew (min $totalNeighbors 3))
             (() (println! (nNew: $nNew)))
             (() (println! (About to call sampleNewInstances)))
             (($demeWithNewInsts $added) (sampleNewInstances $totalNeighbors $nNew $centerInst (mkDeme $rep (mkSInstSet $instSet) $id) 1))
             (() (println! (sampleNewInstances returned: $demeWithNewInsts $added)))
             (() (println! (About to use deme directly: $demeWithNewInsts)))
             (() (println! (About to call transform)))
             ((mkSInstSet $scored) (transform (getInstanceSet $demeWithNewInsts) (getRep $demeWithNewInsts) $iTable $cpxCoeff))
             (() (println! (Transform returned: $scored)))
             ($demeScored (mkDeme (getRep $demeWithNewInsts) (mkSInstSet $scored) (getDemeId $demeWithNewInsts)))
             (() (println! (About to call returnBest)))
             ((mkSInst $bestPair) (List.foldl ((curry2 returnBest) <) (mkSInst (mkPair $centerInst (worstCscore))) $scored))
             (() (println! (returnBest returned: $bestPair)))
             ($nextCenter (Pair.first $bestPair))
             (() (println! (Next center: $nextCenter)))
           )
           (univariateLoop $demeScored $cpxCoeff $iTable $nextCenter (+ $gen 1) $maxGens)
        )
       )
   )

;; Helper function to extract the discrete map from a representation
(: getDiscMap (-> Representation (MultiMap (DiscSpec $knob))))
(= (getDiscMap (mkRep (mkKbMap $dscKbMp $dscMp) $tree)) (extractMultiMap $dscMp))

;; Helper function to extract MultiMap from DiscMap
(: extractMultiMap (-> DiscMap (MultiMap (DiscSpec $knob))))
(= (extractMultiMap (mkDscMp $multiMap)) $multiMap)

;; Helper functions to extract components from a deme
(: getRep (-> Deme Representation))
(= (getRep (mkDeme $rep $instSet $id)) $rep)

(: getInstanceSet (-> Deme (InstanceSet $score)))
(= (getInstanceSet (mkDeme $rep $instSet $id)) $instSet)

(: getDemeId (-> Deme DemeId))
(= (getDemeId (mkDeme $rep $instSet $id)) $id)
