;; ================================================================================
;; Univariate Optimization (translated from moses/moses/optimization/univariate.cc)
;; ================================================================================
;;
;; ASCII overview
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
         ((mkDeme (mkRep (mkKbMap (mkDscKbMp $idxMp) (mkDscMp $disc)) $tree) (mkSInstSet $instSet) $id) $deme)
         ($maxGens (max 1 (MultiMap.length $disc)))
       )
       (univariateLoop $deme $cpxCoeff $iTable $centerInst 0 $maxGens)
   ))

; (: univariateLoop (-> Deme Number (ITable $a) Instance Number Number (Instance Deme $state)))
(= (univariateLoop (mkDeme (mkRep (mkKbMap (mkDscKbMp $idxMp) (mkDscMp $disc)) $tree) (mkSInstSet $instSet) $id)
                    $cpxCoeff $iTable $centerInst $gen $maxGens)
   (if (>= $gen $maxGens)
       ($centerInst (mkDeme (mkRep (mkKbMap (mkDscKbMp $idxMp) (mkDscMp $disc)) $tree) (mkSInstSet $instSet) $id) ())
       (let*
           (
             (() (println! (Univariate loop gen: $gen)))
             ($totalNeighbors (estimateNeighborhood 1 $disc))
             ($nNew (min $totalNeighbors 3))
             (((mkDeme (mkRep $repKb $repTree) (mkSInstSet $insts1) $id1) $added)
                 (sampleNewInstances $totalNeighbors $nNew $centerInst (mkDeme (mkRep (mkKbMap (mkDscKbMp $idxMp) (mkDscMp $disc)) $tree) (mkSInstSet $instSet) $id) 1))
             ((mkSInstSet $scored) (transform (mkSInstSet $insts1) $repKb $iTable $cpxCoeff))
             ($demeScored (mkDeme (mkRep $repKb $repTree) (mkSInstSet $scored) $id1))
             ((mkSInst $bestPair) (List.foldl ((curry2 returnBest) <) (mkSInst (mkPair $centerInst (worstCscore))) $scored))
             ($nextCenter (Pair.first $bestPair))
           )
           (univariateLoop $demeScored $cpxCoeff $iTable $nextCenter (+ $gen 1) $maxGens)
       )
   ))

;; Public entrypoint, mirrors univariate_optimization::operator()
;; (Removed scaffolded evolve/population utilities; univariate operates on Deme/Instance only.)


