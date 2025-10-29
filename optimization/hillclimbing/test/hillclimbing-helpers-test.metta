!(register-module! ../../../../metta-moses)

! (import! &self metta-moses:reduct/boolean-reduct:rte-helpers)
! (import! &self metta-moses:reduct/boolean-reduct:cut-unnecessary-or)
! (import! &self metta-moses:reduct/boolean-reduct:cut-unnecessary-and)
! (import! &self metta-moses:reduct/boolean-reduct:n-ary-propagate-not)
! (import! &self metta-moses:reduct/boolean-reduct:n-ary-gather-junctors)
! (import! &self metta-moses:reduct/boolean-reduct:delete-inconsistent-handle)
! (import! &self metta-moses:reduct/boolean-reduct:zero-constraint-subsumption)
! (import! &self metta-moses:reduct/boolean-reduct:one-constraint-subsumption)
! (import! &self metta-moses:reduct/boolean-reduct:promote-common-constraints)
! (import! &self metta-moses:reduct/boolean-reduct:reduce-to-elegance)

!(import! &self metta-moses:representation:lsk)
!(import! &self metta-moses:representation:instance)
!(import! &self metta-moses:representation:build-knobs)
!(import! &self metta-moses:representation:knob-mapper)
!(import! &self metta-moses:representation:logical-probe) 
!(import! &self metta-moses:representation:build-logical)
!(import! &self metta-moses:representation:representation)
!(import! &self metta-moses:representation:add-logical-knobs)
!(import! &self metta-moses:representation:knob-representation)
!(import! &self metta-moses:representation:sample-logical-perms)
!(import! &self metta-moses:representation:create-representation)

!(import! &self metta-moses:utilities:map)
!(import! &self metta-moses:utilities:tree)
!(import! &self metta-moses:utilities:pair) 
!(import! &self metta-moses:utilities:nodeId)
!(import! &self metta-moses:utilities:list-methods)
;;!(import! &self metta-moses:utilities:python-helpers);; commented out because not compatibel with mettalog
!(import! &self metta-moses:utilities:general-helpers)
!(import! &self metta-moses:utilities:ordered-multimap)
!(import! &self metta-moses:utilities:python-treehelpers)
!(import! &self metta-moses:utilities:lazy-random-selector)

; !(import! &self metta-moses:reduct:enf)

!(import! &self metta-moses:deme:score-deme)
!(import! &self metta-moses:deme:create-deme)
!(import! &self metta-moses:deme:deme-id-creation)
!(import! &self metta-moses:deme:expand-deme)

!(import! &self metta-moses:scoring:cscore)
!(import! &self metta-moses:scoring:bscore)
!(import! &self metta-moses:scoring:fitness)
!(import! &self metta-moses:scoring:complexity-based-scorer)

!(import! &self metta-moses:moses:neighborhood-sampling)

!(import! &self metta-moses:optimization/hillclimbing:cross-top-one)
!(import! &self metta-moses:optimization/hillclimbing:hill-climbing-helpers)
!(import! &self metta-moses:feature-selection:feature-selection-helpers)
!(import! &self metta-moses:optimization/hillclimbing:cross-top-one-helpers)

(= (ARGS) args) 
!(import! &self metta-moses:scoring:bscore)

(= (APPEND_CHILD $tree $nodeId $child ) (py_appendChild $tree $nodeId $child))

(= (GetByID $tree $nodeId) (py_getById $tree $nodeId))
(= (INSERT_ABOVE $tree $nodeId $subtree) (py_insertAbove  $tree $nodeId $subtree))
;; (= (pyExprToList $expr) (py_exprToList $expr))

!(bind! knobmap1
        (ConsMMap (
                    (mkDiscSpec 1)
                    (mkLSK (mkDiscKnob (mkKnob  (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) ))
        (ConsMMap (
                    (mkDiscSpec 1)
                    (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) ))
        NilMMap)))

!(bind! knobmap2
        (ConsMMap (
                    (mkDiscSpec 1)
                    (mkLSK (mkDiscKnob (mkKnob  (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil)))
        (ConsMMap (
                    (mkDiscSpec 1)
                    (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) ))
        NilMMap)))

!(bind! knobmap3
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
!(assertEqual (informationTheoreticBits knobmap1) 6)

;; Test informationTheoreticBits with a knob
;; map containing two knobs with different multiplicity of 2 and 3
!(assertEqual (informationTheoreticBits knobmap2) 5)
; ;; Test informationTheoreticBits with a knob 
; ;; map containing two knobs with same multiplicity of 3
; !(assertEqual (informationTheoreticBits knobmap1) 6)
!(bind! knobmap3
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
!(assertEqual (informationTheoreticBits knobmap1) 6)

;; Test informationTheoreticBits with a knob
;; map containing two knobs with different multiplicity of 2 and 3
!(assertEqual (informationTheoreticBits knobmap2) 5)

; Testcase for informationTheoreticBitsFs
!(assertEqual
  (informationTheoreticBitsFs (Cons A (Cons B (Cons O Nil)))) 2)

;; Testing estimateNeighborhood on the above knob maps
!(assertEqual (estimateNeighborhood 0 knobmap1) 1)
!(assertEqual (estimateNeighborhood 1 knobmap2) 10)
!(assertEqual (estimateNeighborhood 2 knobmap1) 12)
!(assertEqual (estimateNeighborhood 2 knobmap2) 10)

; Testcase for estimateNeighborhoodFs
!(assertEqual
  (estimateNeighborhoodFs 3 (Cons A (Cons B (Cons O Nil)))) 4)

; Testcase for countNeighborhoodFs
!(assertEqual (countNeighborhoodFs (Cons 1 (Cons 0 (Cons 1 Nil))) 2 20) 3)

; Testcase for factorial
!(assertEqual (factorial 3) 6)

; Testcase for binomial
!(assertEqual (binomial 5 2) 10)

;Testcase 1 for countNeighborhood
!(assertEqual 
 (countNeighborhood
  knobmap3  ;knobmap
  (mkInst (Cons 1 (Cons 0 (Cons 2 Nil)))) ;instance
  2 ; distance
  20) ; maximum count
  12)
;Testcase 1 for countNeighborhood
!(assertEqual 
 (countNeighborhood
  knobmap3  ;knobmap
  (mkInst (Cons 1 (Cons 0 (Cons 2 Nil)))) ;instance
  2 ; distance
  20) ; maximum count
  12)

;Testcase 2 for countNeighborhood
!(assertEqual 
 (countNeighborhood
  knobmap3 ;knobmap
  (mkInst (Cons 1 (Cons 0 (Cons 2 Nil)))) ;instance
  3 ;distance
  20) ;maxCount
  8) 
;Testcase 2 for countNeighborhood
!(assertEqual 
 (countNeighborhood
  knobmap3 ;knobmap
  (mkInst (Cons 1 (Cons 0 (Cons 2 Nil)))) ;instance
  3 ;distance
  20) ;maxCount
  8) 

;Testcase 3 for countNeighborhood
!(assertEqual 
 (let*
    (
       ($totalSize (countNeighborhood knobmap3 (mkInst (Cons 0 (Cons 0 (Cons 0 Nil)))) 3 20))
       ($generatedSize (List.length (generateAllInNeighborhood (mkMultip 3) (mkInst (Cons 0 (Cons 0 (Cons 0 Nil)))) 3)))
    )
    (<= (* 3 $totalSize) (* 4 $generatedSize))) True)
;Testcase 3 for countNeighborhood
!(assertEqual 
 (let*
    (
       ($totalSize (countNeighborhood knobmap3 (mkInst (Cons 0 (Cons 0 (Cons 0 Nil)))) 3 20))
       ($generatedSize (List.length (generateAllInNeighborhood (mkMultip 3) (mkInst (Cons 0 (Cons 0 (Cons 0 Nil)))) 3)))
    )
    (<= (* 3 $totalSize) (* 4 $generatedSize))) True)

;Testcase 4 for countNeighborhood
!(assertEqual 
 (let*
    (
       ($totalSize (countNeighborhood knobmap3 (mkInst (Cons 0 (Cons 0 (Cons 0 Nil)))) 2 20))
       ($generatedSize (List.length (generateAllInNeighborhood (mkMultip 3) (mkInst (Cons 0 (Cons 0 (Cons 0 Nil)))) 2)))
    )
    (<= (* 3 $totalSize) (* 4 $generatedSize))) True)
;Testcase 4 for countNeighborhood
!(assertEqual 
 (let*
    (
       ($totalSize (countNeighborhood knobmap3 (mkInst (Cons 0 (Cons 0 (Cons 0 Nil)))) 2 20))
       ($generatedSize (List.length (generateAllInNeighborhood (mkMultip 3) (mkInst (Cons 0 (Cons 0 (Cons 0 Nil)))) 2)))
    )
    (<= (* 3 $totalSize) (* 4 $generatedSize))) True)

;Testcase 5 for countNeighborhood
!(assertEqual
 (let*
    (
       ($totalSize (countNeighborhood knobmap3 (mkInst (Cons 0 (Cons 0 (Cons 0 Nil)))) 1 20))
       ($generatedSize (List.length (generateAllInNeighborhood (mkMultip 3) (mkInst (Cons 0 (Cons 0 (Cons 0 Nil)))) 1)))
    )
(<= (* 3 $totalSize) (* 4 $generatedSize))) True)
;Testcase 5 for countNeighborhood
!(assertEqual
 (let*
    (
       ($totalSize (countNeighborhood knobmap3 (mkInst (Cons 0 (Cons 0 (Cons 0 Nil)))) 1 20))
       ($generatedSize (List.length (generateAllInNeighborhood (mkMultip 3) (mkInst (Cons 0 (Cons 0 (Cons 0 Nil)))) 1)))
    )
(<= (* 3 $totalSize) (* 4 $generatedSize))) True)

!(bind! deme (mkDeme (mkRep (mkKbMap (mkDscKbMp (ConsMap ((mkNodeId (1)) 0) (ConsMap ((mkNodeId (2)) 1) NilMap))) (mkDscMp (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) )) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) NilMMap)))) (mkTree (mkNode AND) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) Nil)))) (mkSInstSet Nil) (mkDemeId "1")))
!(bind! demes (Cons (mkDeme (mkRep (mkKbMap (mkDscKbMp (ConsMap ((mkNodeId (1)) 0) (ConsMap ((mkNodeId (2)) 1) NilMap))) (mkDscMp (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) )) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) )) NilMMap)))) (mkTree (mkNode AND) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) Nil)))) (mkSInstSet Nil) (mkDemeId "1")) Nil))

!(bind! table (createTruthTableBScore 2 (mkITable
                         (Cons (Cons False (Cons False (Cons False Nil))) 
                         (Cons (Cons True (Cons False (Cons False Nil))) 
                         (Cons (Cons False (Cons True (Cons False Nil)))
                         (Cons (Cons True (Cons True (Cons True Nil))) Nil))))
                         (Cons A (Cons B (Cons O Nil))))))

!(bind! itable (mkITable
                         (Cons (Cons False (Cons False (Cons False Nil))) 
                         (Cons (Cons True (Cons False (Cons False Nil))) 
                         (Cons (Cons False (Cons True (Cons False Nil)))
                         (Cons (Cons True (Cons True (Cons True Nil))) Nil))))
                         (Cons A (Cons B (Cons O Nil)))))

(: isScored (-> (ScoredInstance Cscore) Bool))
(= (isScored (mkSInst (mkPair $instance $score))) (~= $score (worstCscore)))

;; NOTE!!!!!!!
;; merger -- this is a function implemented as part if the main crossTopOne in optimization/hillclimbing/cross-top-one.metta but results in error unless this is imported in the test file
(: merger (-> Expression Instance Instance Expression))
(= (merger $targetInstances $baseInst $referenceInst)
    (collapse (let (mkSInst (mkPair $targetInst $score)) (superpose $targetInstances)
        (mkSInst (mkPair (mergeInstance $targetInst $baseInst $referenceInst) (worstCscore))))))

!(assertEqual
   (let*
     (
       (($instance (mkDeme $rep (mkSInstSet $instSet) $id) $state) (hillClimbing deme table (mkInst (Cons 0 (Cons 0 Nil))) (applyComplexityBasedScore ())))
       ($instanceCount (List.length $instSet))
       ($scoredElems (List.map isScored $instSet))
     )
     ((>= $instanceCount 4) (List.any $scoredElems)))
   (True True))


!(assertEqual
   (let*
     (
       (($instance (mkSInstSet $instSet) $state) (hillClimbing (mkSInstSet Nil) itable (mkInst (Cons 1 (Cons 0 Nil))) (applyMutualInformationBasedScore mi)))
       ($instanceCount (List.length $instSet))
       ($scoredElems (List.map isScored $instSet))
     )
     ((>= $instanceCount 4) (List.any $scoredElems)))
   (True True))