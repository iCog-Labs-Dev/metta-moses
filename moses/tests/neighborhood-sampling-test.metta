!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/nodeId)
!(import! &self ../../utilities/tree)
!(import! &self ../../utilities/ordered-multimap)
!(import! &self ../../utilities/lazy-random-selector)
!(import! &self ../../representation/instance)
!(import! &self ../../representation/knob-representation)

!(import! &self ../../scoring/cscore)
!(import! &self ../../optimization/hillclimbing/hill-climbing-helpers) ;; using / for additional nested dir level 
!(import! &self ../../deme/create-deme)

!(import! &self ../neighborhood-sampling)
!(py-call (random.seed 0))

;; Test the distance function
;; Hamming distance on expressions
!(assertEqual (distance (0 0 0 1) (0 1 0 0)) 2)
!(assertEqual (distance (0 0 0 0) (0 1 0 0)) 1)
!(assertEqual (distance (1 2 0 0) (0 1 0 0)) 2)
!(assertEqual (distance (1 2 1 0) (0 1 0 0)) 3)

;; Hamming distance on instance
!(assertEqual (distance` (mkInst (cons 1 (cons 2 (cons 0 (cons 0 ()))))) (mkInst (cons 0 (cons 1 (cons 0 (cons 0 ())))))) 2)
!(assertEqual (distance` (mkInst (cons 1 (cons 2 (cons 1 (cons 0 ()))))) (mkInst (cons 0 (cons 1 (cons 0 (cons 0 ())))))) 3)


;; Test case to make sure it varyNKnobs generates unique and all available neighbors.
;; After Fix 1: varyNKnobs now generates instances at EXACTLY the target distance,
;; matching C++ vary_n_knobs semantics. C(4,2)*2^2 = 24 for multips=(2 1), dist=2.
!(assertEqual (let*
                (
                  ($original (varyNKnobs (2 1) (0 0 0 1) 2))
                  ($unique (unique-atom (varyNKnobs (2 1) (0 0 0 1) 2))))
                (and (== (length $original) (length $unique)) (== (length $original) 24))) true)

;; At distance 2 should generate total of 24 neighbors (exactly dist=2)
;; C(4,2)*2^2 = 24 after Fix 1 (was 32 when cumulative 1..dist)
;; !(assertEqual (let $a (generateAllInNeighborhood (mkMultip 3) (mkInst (cons 0 (cons 0 (cons 0 (cons 0 ()))))) 2) ((List.length $a) (get-type $a))) (24 (List Instance)))
!(assertEqual (let $a (generateAllInNeighborhood (mkMultip 3) (mkInst (cons 0 (cons 0 (cons 0 (cons 0 ()))))) 2) (List.length $a)) 24) ;; Since the type system isn't working properly the above has been replaced with this test case. Change when type starts working correctly.
;; !(assertEqual (let $a (generateAllInNeighborhood (mkMultip 3) (mkInst (cons 0 (cons 0 (cons 0 (cons 0 ()))))) 1) ((List.length $a) (get-type $a))) (8 (List Instance)))
!(assertEqual (let $a (generateAllInNeighborhood (mkMultip 3) (mkInst (cons 0 (cons 0 (cons 0 (cons 0 ()))))) 1) (List.length $a)) 8) ;; Since the type system isn't working properly the above has been replaced with this test case. Change when type starts working correctly.

;; At distance 3 should generate total of 32 neighbors (exactly dist=3)
;; C(4,3)*2^3 = 32 after Fix 1 (was 64 when cumulative 1..dist)
;; !(assertEqual (let $a (generateAllInNeighborhood (mkMultip 3) (mkInst (cons 0 (cons 0 (cons 0 (cons 0 ()))))) 3) ((List.length $a) (get-type $a))) (32 (List Instance)))
!(assertEqual (let $a (generateAllInNeighborhood (mkMultip 3) (mkInst (cons 0 (cons 0 (cons 0 (cons 0 ()))))) 3) (List.length $a)) 32) ;; Since the type system isn't working properly the above has been replaced with this test case. Change when type starts working correctly.

;; Generated neighbors should be 24 in length and center shouldn't be member.
;;    Distance 0 indicates a center node being present.
;; After Fix 1: exactly dist=2 → C(4,2)*2^2 = 24 (was 32 when cumulative)
!(assertEqual
   (let $distList
        (List.map ((curry distance) (mkInst (cons 0 (cons 0 (cons 0 (cons 0 ())))))) 
                  (generateAllInNeighborhood (mkMultip 3) (mkInst (cons 0 (cons 0 (cons 0 (cons 0 ()))))) 2))
        ((List.length $distList) (List.contains 0 $distList))) 
   (24 False))

;; Verify all generated neighbors are at EXACTLY the target distance
;; (matching C++ NeighborSamplingUTest.cxxtest assertions).
;; Uses foldl to check every distance equals the target.
!(assertEqual
   (let*
      (
        ($center (mkInst (cons 0 (cons 0 (cons 0 (cons 0 ()))))))
        ($neighbors (generateAllInNeighborhood (mkMultip 3) $center 2))
        ($dists (List.map ((curry distance') $center) $neighbors))
        ($allExact (foldl-atom $dists True $acc $d (and $acc (== $d 2))))
      )
      ((List.length $dists) $allExact))
   (24 True))

;; Same check at distance 1
!(assertEqual
   (let*
      (
        ($center (mkInst (cons 0 (cons 0 (cons 0 (cons 0 ()))))))
        ($neighbors (generateAllInNeighborhood (mkMultip 3) $center 1))
        ($dists (List.map ((curry distance') $center) $neighbors))
        ($allExact (foldl-atom $dists True $acc $d (and $acc (== $d 1))))
      )
      ((List.length $dists) $allExact))
   (8 True))

;; Same check at distance 3
!(assertEqual
   (let*
      (
        ($center (mkInst (cons 0 (cons 0 (cons 0 (cons 0 ()))))))
        ($neighbors (generateAllInNeighborhood (mkMultip 3) $center 3))
        ($dists (List.map ((curry distance') $center) $neighbors))
        ($allExact (foldl-atom $dists True $acc $d (and $acc (== $d 3))))
      )
      ((List.length $dists) $allExact))
   (32 True))

(= (tree1)
        (mkTree (mkNode AND)
          (cons (mkKnob (mkTree (mkNode A) ()) (lsk3) 2)
          (cons (mkTree (mkNode OR)
                  (cons (mkTree (mkNode B) ())
                  (cons (mkTree (mkNode C) ())
                  (cons (mkKnob (mkNullVex
                          (cons (mkTree (mkNode D) ()) ())) (lsk2) 1) ()))))
          (cons (mkKnob (mkNullVex
                  (cons (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) ())) ())) (lsk1) 0) ())))))

(= (lsk1)
        (mkLSK
            (mkDiscKnob
              (mkMultip 3)
              (mkDiscSpec 0)
              (mkDiscSpec 0)
              ())
            ))

(= (lsk2)
        (mkLSK
            (mkDiscKnob
              (mkMultip 3)
              (mkDiscSpec 0)
              (mkDiscSpec 0)
              ())
            ))

(= (lsk3)
        (mkLSK
            (mkDiscKnob
              (mkMultip 3)
              (mkDiscSpec 1)
              (mkDiscSpec 1)
              ())
            ))

(= (knobMapObj) (mkKbMap
                      (mkDscMp (cons ((mkDiscSpec 1) (lsk1)) (cons ((mkDiscSpec 0) (lsk2)) (cons ((mkDiscSpec 1) (lsk3)) ()))))))
(= (deme) (mkDeme 
(mkRep (mkKbMap 
    (mkDscMp 
      (cons 
        ((mkDiscSpec 3)
         (mkLSK 
           (mkDiscKnob 
             (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())
           ))
        (cons 
          ((mkDiscSpec 3)
           (mkLSK 
             (mkDiscKnob 
               (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())
             ))
          (cons 
            ((mkDiscSpec 3)
             (mkLSK 
               (mkDiscKnob 
                 (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())
               ))
            ()))))) (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) (cons (mkKnob (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 0) (cons (mkKnob (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode B) ()) ()))) ())) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 1) (cons (mkKnob (mkNullVex (cons (mkTree (mkNode B) ()) ())) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 2) (cons (mkKnob (mkNullVex (cons (mkTree (mkNode A) ()) ())) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 3) ())))))) (cons (mkKnob (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 4) (cons (mkKnob (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode B) ()) ()))) ())) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 5) (cons (mkKnob (mkNullVex (cons (mkTree (mkNode B) ()) ())) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 6) (cons (mkKnob (mkNullVex (cons (mkTree (mkNode A) ()) ())) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 7) ()))))))) (mkSInstSet ()) (mkDemeId "1")))

; Test case for sampleFromNeighborhood function
; Function should returned two instances at the specified distance

!(assertEqual
     (let $returned (sampleFromNeighborhood 2 2 (knobMapObj) (mkInst (cons 1 (cons 2 (cons 0 ())))))
       (List.map ((curry distance') (mkInst (cons 1 (cons 2 (cons 0 ()))))) $returned))
     (cons 2 (cons 2 ())))
!(assertEqual
     (let $returned (sampleFromNeighborhood 2 3 (knobMapObj) (mkInst (cons 1 (cons 2 (cons 0 ())))))
       (List.map ((curry distance') (mkInst (cons 1 (cons 2 (cons 0 ()))))) $returned))
     (cons 3 (cons 3 ())))
!(assertEqual
     (let $returned (sampleFromNeighborhood 2 1 (knobMapObj) (mkInst (cons 1 (cons 2 (cons 0 ())))))
       (List.map ((curry distance') (mkInst (cons 1 (cons 2 (cons 0 ()))))) $returned))
     (cons 1 (cons 1 ())))

;; Invalid (knobMapObj) or instance
!(assertEqual
     (let $returned
       (sampleFromNeighborhood 1 2 (knobMapObj) (mkInst ())) $returned)
     (cons (Error (3 0) "Not Equal") ()))

;; Testcases for removeInstScore
!(assertEqual 
 (removeInstScore (mkSInst (mkPair (mkInst (cons 1 (cons 2 (cons 3 (cons 2.0 ()))))) 3.2)))
 (mkInst (cons 1 (cons 2 (cons 3 (cons 2.0 ())))))
 )
!(assertEqual 
 (removeInstScore (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 0 (cons 0 ()))))) 3.2)))
 (mkInst (cons 0 (cons 0 (cons 0 (cons 0 ())))))
 )

; Testcase-1 for sampleNewInstances
; totalNeighbors & numNewInstances won't be updated, samples new instances 
!(assertEqual 
   (let ((mkDeme $rep (mkSInstSet $updatedInstList) $demeId) $num) 
   (sampleNewInstances 
   20 
   3 
   (mkInst (cons 0 (cons 0 (cons 0 ())))) 
   (deme) 
   2)
   (List.map (distance' (mkInst (cons 0 (cons 0 (cons 0 ()))))) (List.map removeInstScore $updatedInstList)))
   (cons 2 (cons 2 (cons 2 ()))))

; Testcase-2 for sampleNewInstances
; Duplicate knob vectors are suppressed, so the returned count is the six
; distinct distance-two neighbors rather than the seven nominal samples.
!(assertEqual 
   (let ((mkDeme $rep (mkSInstSet $updatedInstList) $demeId) $num)
   (sampleNewInstances 
   10 
   7 
   (mkInst (cons 0 (cons 0 (cons 0 ())))) 
   (deme) 
   2)
   ($num
    (List.map (distance' (mkInst (cons 0 (cons 0 (cons 0 ())))))
              (List.map removeInstScore $updatedInstList))))
   (6 (2 2 2 2 2 2)))

; Testcase-3 for sampleNewInstances
; The exhaustive branch also removes duplicate vectors before appending them.
!(assertEqual 
   (let ((mkDeme $rep (mkSInstSet $updatedInstList) $demeId) $num)
   (sampleNewInstances 
   4
   5 
   (mkInst (cons 0 (cons 0 (cons 0 ())))) 
   (deme) 
   2)
   ($num
    (List.map (distance' (mkInst (cons 0 (cons 0 (cons 0 ())))))
              (List.map removeInstScore $updatedInstList))))
   (4 (2 2 2 2)))

; Testcase-4 for sampleNewInstances
; totalNeighbors & numNewInstances won't be updated, samples new instances
!(assertEqual 
   (let ((mkDeme $rep (mkSInstSet $updatedInstList) $demeId) $num) 
   (sampleNewInstances 
   20 
   0 
   (mkInst (cons 0 (cons 0 (cons 0 ())))) 
   (deme) 
   2)
   (List.map (distance' (mkInst (cons 0 (cons 0 (cons 0 ()))))) (List.map removeInstScore $updatedInstList)))
())

; ; Testcase for sampleFromNeighborhood function when requested sample size is more than possible instances
!(assertEqual (let $result (sampleFromNeighborhood 13 2 (knobMapObj) (mkInst (cons 1 (cons 2 (cons 0 ()))))) (List.length $result)) 13) ;; This test case has been changed to generate the size even if there is a duplicate instead of throwing an error. That's how the classic version does it.



;;testcase for isPossibleSize function
;; Formula: n! / ((n - d)! * d!) * (m-1)^d  (n = instance length, d = distance, m = knob multiplicity)
!(assertEqual (isPossibleSize 13 2 (mkInst (cons 1 (cons 2 (cons 0 ()))))) False)
!(assertEqual (isPossibleSize 10 2 (mkInst (cons 1 (cons 2 (cons 0 ()))))) True)

;; Disc-probed knobs use effective multiplicity, so fully pruned knobs do not
;; contribute neighbors and partially pruned knobs only expose allowed specs.
!(assertEqual
   (let*
      (
        ($disc
          (mkDscMp
            (cons ((mkDiscSpec 3)
                   (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0)
                                      (cons (mkDiscSpec 1) (cons (mkDiscSpec 2) ())))))
            (cons ((mkDiscSpec 3)
                   (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0)
                                      (cons (mkDiscSpec 2) ()))))
            ()))))
        ($neighbors (generateAllInNeighborhoodForDisc $disc (mkInst (cons 0 (cons 0 ()))) 1))
      )
      $neighbors)
   (cons (mkInst (cons 0 (cons 1 ()))) ()))

;; Shared sampling retains the first occurrence of each new knob vector and
;; drops both repeated samples and vectors already present in the scored deme.
!(assertEqual
   (let* (
          ($old0
            (mkSInst (mkPair (mkInst (0 0))
                             (mkCscore -89 0 0 0 -89))))
          ($new1
            (mkSInst (mkPair (mkInst (1 0)) (worstCscore))))
          ($new2
            (mkSInst (mkPair (mkInst (0 1)) (worstCscore))))
         )
     (uniqueUnseenScoredInstances
       ($new1 $new1
        (mkSInst (mkPair (mkInst (0 0)) (worstCscore)))
        $new2)
       ($old0)))
   ((mkSInst (mkPair (mkInst (1 0)) (worstCscore)))
    (mkSInst (mkPair (mkInst (0 1)) (worstCscore)))))

;; Feature-selection sampling uses the same duplicate suppression and returns
;; the size of the genuinely new suffix, not the nominal request.
!(assertEqual
  (let* (
         ($retained
           (mkSInst (mkPair (mkInst (1 0)) 0.5)))
         (($updated $actualNew)
           (sampleNewInstancesFs
             2 2 (mkInst (0 0))
             (mkITable () (A B O))
             (mkSInstSet ($retained))
             1))
         ((mkSInstSet $rows) $updated)
        )
    ($actualNew
     (map-atom $rows $row (removeInstScore $row))
     (getSInstScore (List.head $rows))))
  (1 ((mkInst (1 0)) (mkInst (0 1))) 0.5))
