!(import! &self ../../../representation/lsk)
!(import! &self ../../../representation/instance)
!(import! &self ../../../representation/build-knobs)
!(import! &self ../../../representation/knob-mapper)
!(import! &self ../../../representation/logical-probe) 
!(import! &self ../../../representation/build-logical)
!(import! &self ../../../representation/representation)
!(import! &self ../../../representation/add-logical-knobs)
!(import! &self ../../../representation/knob-representation)
!(import! &self ../../../representation/sample-logical-perms)
!(import! &self ../../../representation/create-representation)

!(import! &self ../../../utilities/map)
!(import! &self ../../../utilities/tree)
!(import! &self ../../../utilities/pair) 
!(import! &self ../../../utilities/nodeId)
!(import! &self ../../../utilities/list-methods)
!(import! &self ../../../utilities/general-helpers)
!(import! &self ../../../utilities/ordered-multimap)
!(import! &self ../../../utilities/lazy-random-selector)

!(import! &self ../../../deme/score-deme)
!(import! &self ../../../deme/create-deme)
!(import! &self ../../../deme/deme-id-creation)
!(import! &self ../../../deme/expand-deme)

!(import! &self ../../../scoring/cscore)
!(import! &self ../../../scoring/bscore)
!(import! &self ../../../scoring/fitness)
!(import! &self ../../../scoring/complexity-based-scorer)

!(import! &self ../../../moses/neighborhood-sampling)

!(import! &self ../cross-top-one)
!(import! &self ../hill-climbing-helpers)
!(import! &self ../../../feature-selection/feature-selection-helpers)
!(import! &self ../cross-top-one-helpers)

(= (knobmap1)
        (ConsMMap (
                    (mkDiscSpec 1)
                    (mkLSK (mkDiscKnob (mkKnob  (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) ))
        (ConsMMap (
                    (mkDiscSpec 1)
                    (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) ))
        NilMMap)))

(= (knobmap2)
        (ConsMMap (
                    (mkDiscSpec 1)
                    (mkLSK (mkDiscKnob (mkKnob  (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil)))
        (ConsMMap (
                    (mkDiscSpec 1)
                    (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) ))
        NilMMap)))

(= (knobmap3)
  (mkKbMap
    (mkDscKbMp
      (ConsMap ((mkNodeId (1 2)) 0)
        (ConsMap ((mkNodeId (2)) 1)
          (ConsMap ((mkNodeId (3)) 2) NilMap))))
    (mkDscMp 
      (ConsMMap 
        ((mkDiscSpec 3)
         (mkLSK 
           (mkDiscKnob 
             (mkKnob 
               (mkNodeId (1 2)))
             (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil)
           ))
        (ConsMMap 
          ((mkDiscSpec 3)
           (mkLSK 
             (mkDiscKnob 
               (mkKnob 
                 (mkNodeId (2)))
               (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil)
             ))
          (ConsMMap 
            ((mkDiscSpec 3)
             (mkLSK 
               (mkDiscKnob 
                 (mkKnob 
                   (mkNodeId (3)))
                 (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil)
               ))
            NilMMap))))))
;; Test informationTheoreticBits with a knob 
;; map containing two knobs with same multiplicity of 3
!(assertEqual (informationTheoreticBits (knobmap1)) 6)

;; Test informationTheoreticBits with a knob
;; map containing two knobs with different multiplicity of 2 and 3
!(assertEqual (informationTheoreticBits (knobmap2)) 5)
;; Test informationTheoreticBits with a knob 
;; map containing two knobs with same multiplicity of 3
!(assertEqual (informationTheoreticBits (knobmap1)) 6)
; ;; Test informationTheoreticBits with a knob 
; ;; map containing two knobs with same multiplicity of 3
!(assertEqual (informationTheoreticBits (knobmap1)) 6)

;; Test informationTheoreticBits with a knob
;; map containing two knobs with different multiplicity of 2 and 3
!(assertEqual (informationTheoreticBits (knobmap2)) 5)

; ; Testcase for informationTheoreticBitsFs
!(assertEqual
  (informationTheoreticBitsFs (Cons A (Cons B (Cons O Nil)))) 2)

;; Testing estimateNeighborhood on the above knob maps
!(assertEqual (estimateNeighborhood 0 (knobmap1)) 1)
!(assertEqual (estimateNeighborhood 1 (knobmap2)) 10)
!(assertEqual (estimateNeighborhood 2 (knobmap1)) 12)
!(assertEqual (estimateNeighborhood 2 (knobmap2)) 10)

; Testcase for estimateNeighborhoodFs
!(assertEqual
  (estimateNeighborhoodFs 3 (Cons A (Cons B (Cons O Nil)))) 4)

; Testcase for countNeighborhoodFs
!(assertEqual (countNeighborhoodFs (Cons 1 (Cons 0 (Cons 1 Nil))) 2 20) 3)

; Testcase for factorial
!(assertEqual (factorial 3) 6)

; Testcase for binomial
!(assertEqual (binomial 5 2) 10)

; Testcase 1 for countNeighborhood
!(assertEqual 
 (countNeighborhood
  (knobmap3)  ;knobmap
  (mkInst (Cons 1 (Cons 0 (Cons 2 Nil)))) ;instance
  2 ; distance
  20) ; maximum count
  12)

;Testcase 2 for countNeighborhood
!(assertEqual 
 (countNeighborhood
  (knobmap3) ;knobmap
  (mkInst (Cons 1 (Cons 0 (Cons 2 Nil)))) ;instance
  3 ;distance
  20) ;maxCount
  8) 

;Testcase 3 for countNeighborhood
!(assertEqual 
 (let*
    (
       ($totalSize (countNeighborhood (knobmap3) (mkInst (Cons 0 (Cons 0 (Cons 0 Nil)))) 3 20))
       ($generatedSize (eval (List.length (eval (generateAllInNeighborhood (mkMultip 3) (mkInst (Cons 0 (Cons 0 (Cons 0 Nil)))) 3)))))
    )
    (<= (* 3 $totalSize) (* 4 $generatedSize))) True)

;Testcase 4 for countNeighborhood
!(assertEqual 
 (let*
    (
       ($totalSize (countNeighborhood (knobmap3) (mkInst (Cons 0 (Cons 0 (Cons 0 Nil)))) 2 20))
       ($generatedSize (eval (List.length (eval (generateAllInNeighborhood (mkMultip 3) (mkInst (Cons 0 (Cons 0 (Cons 0 Nil)))) 2)))))
    )
    (<= (* 3 $totalSize) (* 4 $generatedSize))) True)

;Testcase 5 for countNeighborhood
!(assertEqual
 (let*
    (
       ($totalSize (countNeighborhood (knobmap3) (mkInst (Cons 0 (Cons 0 (Cons 0 Nil)))) 1 20))
       ($generatedSize (eval (List.length (eval (generateAllInNeighborhood (mkMultip 3) (mkInst (Cons 0 (Cons 0 (Cons 0 Nil)))) 1)))))
    )
(<= (* 3 $totalSize) (* 4 $generatedSize))) True)

(= (deme) (mkDeme (mkRep (mkKbMap (mkDscKbMp (ConsMap ((mkNodeId (1)) 0) (ConsMap ((mkNodeId (2)) 1) NilMap))) (mkDscMp (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) )) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) NilMMap)))) (mkTree (mkNode AND) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) Nil)))) (mkSInstSet Nil) (mkDemeId "1")))
(= (demes) (Cons (mkDeme (mkRep (mkKbMap (mkDscKbMp (ConsMap ((mkNodeId (1)) 0) (ConsMap ((mkNodeId (2)) 1) NilMap))) (mkDscMp (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) )) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) )) NilMMap)))) (mkTree (mkNode AND) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) Nil)))) (mkSInstSet Nil) (mkDemeId "1")) Nil))

(= (table1) (eval (createTruthTableBScore 2 (mkITable
                         (Cons (Cons False (Cons False (Cons False Nil))) 
                         (Cons (Cons True (Cons False (Cons False Nil))) 
                         (Cons (Cons False (Cons True (Cons False Nil)))
                         (Cons (Cons True (Cons True (Cons True Nil))) Nil))))
                         (Cons A (Cons B (Cons O Nil)))))))

(= (itable) (mkITable
                         (Cons (Cons False (Cons False (Cons False Nil))) 
                         (Cons (Cons True (Cons False (Cons False Nil))) 
                         (Cons (Cons False (Cons True (Cons False Nil)))
                         (Cons (Cons True (Cons True (Cons True Nil))) Nil))))
                         (Cons A (Cons B (Cons O Nil)))))

; (: isScored (-> (ScoredInstance Cscore) Bool))
(= (isScored (mkSInst (mkPair $instance $score))) (~= $score (worstCscore)))

!(hillclimbing test ----------)
!(assertEqual
   (let*
     (
       (($instance (mkDeme $rep (mkSInstSet $instSet) $id) $state) (hillClimbing (deme) (table1) (mkInst (Cons 0 (Cons 0 Nil))) (mkParams applyComplexityBasedScore ())))
       ($instanceCount (eval (List.length $instSet)))
       ($scoredElems (eval (List.map isScored $instSet)))
     )
     ((>= $instanceCount 4) (eval (List.any $scoredElems))))
   (True True))

!(assertEqual
   (let*
     (
       (($instance (mkSInstSet $instSet) $state) (hillClimbing (mkSInstSet Nil) (itable) (mkInst (Cons 1 (Cons 0 Nil))) (mkParams applyMutualInformationBasedScore mi)))
       ($instanceCount (eval (List.length $instSet)))
       ($scoredElems (eval (List.map isScored $instSet)))
     )
     ((>= $instanceCount 4) (eval (List.any $scoredElems))))
   (True True))
