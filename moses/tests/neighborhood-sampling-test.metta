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
!(assertEqual (let*
                (
                  ($original (varyNKnobs (2 1) (0 0 0 1) 2))
                  ($unique (unique-atom (varyNKnobs (2 1) (0 0 0 1) 2))))
                (and (== (length $original) (length $unique)) (== (length $original) 32))) true)

;; At distance 2 should generate total of 32 neighbors
;; !(assertEqual (let $a (generateAllInNeighborhood (mkMultip 3) (mkInst (cons 0 (cons 0 (cons 0 (cons 0 ()))))) 2) ((List.length $a) (get-type $a))) (32 (List Instance)))
!(assertEqual (let $a (generateAllInNeighborhood (mkMultip 3) (mkInst (cons 0 (cons 0 (cons 0 (cons 0 ()))))) 2) (List.length $a)) 32) ;; Since the type system isn't working properly the above has been replaced with this test case. Change when type starts working correctly.
;; !(assertEqual (let $a (generateAllInNeighborhood (mkMultip 3) (mkInst (cons 0 (cons 0 (cons 0 (cons 0 ()))))) 1) ((List.length $a) (get-type $a))) (8 (List Instance)))
!(assertEqual (let $a (generateAllInNeighborhood (mkMultip 3) (mkInst (cons 0 (cons 0 (cons 0 (cons 0 ()))))) 1) (List.length $a)) 8) ;; Since the type system isn't working properly the above has been replaced with this test case. Change when type starts working correctly.

;; At distance 3 should generate total of 64 neighbors
;; !(assertEqual (let $a (generateAllInNeighborhood (mkMultip 3) (mkInst (cons 0 (cons 0 (cons 0 (cons 0 ()))))) 3) ((List.length $a) (get-type $a))) (64 (List Instance)))
!(assertEqual (let $a (generateAllInNeighborhood (mkMultip 3) (mkInst (cons 0 (cons 0 (cons 0 (cons 0 ()))))) 3) (List.length $a)) 64) ;; Since the type system isn't working properly the above has been replaced with this test case. Change when type starts working correctly.

;; Generated neighbors should be 32 in length and center shouldn't be member.
;;    Distance 0 indicates a center node being present.
!(assertEqual
   (let $distList
        (List.map ((curry distance) (mkInst (cons 0 (cons 0 (cons 0 (cons 0 ())))))) 
                  (generateAllInNeighborhood (mkMultip 3) (mkInst (cons 0 (cons 0 (cons 0 (cons 0 ()))))) 2))
        ((List.length $distList) (List.contains 0 $distList))) 
   (32 False))

(= (tree1)
        (mkTree (mkNode AND)
          (cons (mkTree (mkNode A) ())
          (cons (mkTree (mkNode OR)
                  (cons (mkTree (mkNode B) ())
                  (cons (mkTree (mkNode C) ())
                  (cons (mkNullVex
                          (cons (mkTree (mkNode D) ()) ())) ()))))
          (cons (mkNullVex
                  (cons (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) ())) ())) ())))))

(= (lsk1)
        (mkLSK
            (mkDiscKnob
              (mkKnob (mkNodeId (2 3)))
              (mkMultip 3)
              (mkDiscSpec 0)
              (mkDiscSpec 0)
              ())
            ))

(= (lsk2)
        (mkLSK
            (mkDiscKnob
              (mkKnob (mkNodeId (3)))
              (mkMultip 3)
              (mkDiscSpec 0)
              (mkDiscSpec 0)
              ())
            ))

(= (lsk3)
        (mkLSK
            (mkDiscKnob
              (mkKnob (mkNodeId (1)))
              (mkMultip 3)
              (mkDiscSpec 1)
              (mkDiscSpec 1)
              ())
            ))

(= (knobMapObj) (mkKbMap
                      (mkDscKbMp (cons ((mkNodeId (2 3)) 0) (cons ((mkNodeId (3)) 1) (cons ((mkNodeId (1)) 2) ()))))
                      (mkDscMp (cons ((mkDiscSpec 1) (lsk1)) (cons ((mkDiscSpec 0) (lsk2)) (cons ((mkDiscSpec 1) (lsk3)) ()))))))
(= (deme) (mkDeme 
(mkRep (mkKbMap 
    (mkDscKbMp 
      (cons ((mkNodeId (1 2)) 0)
        (cons ((mkNodeId (2)) 1)
          (cons ((mkNodeId (3)) 2) ()))))
    (mkDscMp 
      (cons 
        ((mkDiscSpec 3)
         (mkLSK 
           (mkDiscKnob 
             (mkKnob 
               (mkNodeId (1 2)))
             (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())
           ))
        (cons 
          ((mkDiscSpec 3)
           (mkLSK 
             (mkDiscKnob 
               (mkKnob 
                 (mkNodeId (2)))
               (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())
             ))
          (cons 
            ((mkDiscSpec 3)
             (mkLSK 
               (mkDiscKnob 
                 (mkKnob 
                   (mkNodeId (3)))
                 (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())
               ))
            ()))))) (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode B) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode A) ()) ())) ())))))) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode B) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode A) ()) ())) ()))))))) (mkSInstSet ()) (mkDemeId "1")))

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
; totalNeighbors will be updated, samples new instances 
!(assertEqual 
   (let ((mkDeme $rep (mkSInstSet $updatedInstList) $demeId) $num) 
   (sampleNewInstances 
   10 
   7 
   (mkInst (cons 0 (cons 0 (cons 0 ())))) 
   (deme) 
   2)
   (List.map (distance' (mkInst (cons 0 (cons 0 (cons 0 ()))))) (List.map removeInstScore $updatedInstList)))
   (cons 2 (cons 2 (cons 2 (cons 2 (cons 2 (cons 2 (cons 2 ()))))))))

; Testcase-3 for sampleNewInstances
; totalNeighbors will be updated, generates all instances in neighborhood
!(assertEqual 
   (let ((mkDeme $rep (mkSInstSet $updatedInstList) $demeId) $num) 
   (sampleNewInstances 
   4
   5 
   (mkInst (cons 0 (cons 0 (cons 0 ())))) 
   (deme) 
   2)
   (List.map (distance' (mkInst (cons 0 (cons 0 (cons 0 ()))))) (List.map removeInstScore $updatedInstList)))
   (cons 2 (cons 2 (cons 2 (cons 2 (cons 2 ()))))))

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

