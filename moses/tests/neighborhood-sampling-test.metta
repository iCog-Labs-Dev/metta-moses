!(import! &self ../neighborhood-sampling)
!(import! &self ../../representation/instance)
!(import! &self ../../representation/knob-representation)

!(import! &self ../../utilities/tree)
!(import! &self ../../utilities/nodeId)
!(import! &self ../../utilities/list-methods)
;;! (import! &self metta-moses:utilities:python-helpers)
!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/ordered-multimap)
!(import! &self ../../utilities/lazy-random-selector)
!(import! &self ../../optimization/hillclimbing/hill-climbing-helpers) ;; using / for additional nested dir level 
!(import! &self ../../deme/create-deme)
!(import! &self ../../scoring/cscore)
!(py-call (random.seed 0))

;; Test the distance function
;; Hamming distance on expressions
!(assertEqual (distance (0 0 0 1) (0 1 0 0)) 2)
!(assertEqual (distance (0 0 0 0) (0 1 0 0)) 1)
!(assertEqual (distance (1 2 0 0) (0 1 0 0)) 2)
!(assertEqual (distance (1 2 1 0) (0 1 0 0)) 3)

;; Hamming distance on instance
!(assertEqual (distance` (mkInst (Cons 1 (Cons 2 (Cons 0 (Cons 0 Nil))))) (mkInst (Cons 0 (Cons 1 (Cons 0 (Cons 0 Nil)))))) 2)
!(assertEqual (distance` (mkInst (Cons 1 (Cons 2 (Cons 1 (Cons 0 Nil))))) (mkInst (Cons 0 (Cons 1 (Cons 0 (Cons 0 Nil)))))) 3)


;; Test case to make sure it varyNKnobs generates unique and all available neighbors.
!(assertEqual (let*
                (
                  ($original (varyNKnobs (2 1) (0 0 0 1) 2))
                  ($unique (unique-atom (varyNKnobs (2 1) (0 0 0 1) 2))))
                (and (== (length $original) (length $unique)) (== (length $original) 32))) true)

;; At distance 2 should generate total of 32 neighbors
;; !(assertEqual (let $a (generateAllInNeighborhood (mkMultip 3) (mkInst (Cons 0 (Cons 0 (Cons 0 (Cons 0 Nil))))) 2) ((List.length $a) (get-type $a))) (32 (List Instance)))
!(assertEqual (let $a (generateAllInNeighborhood (mkMultip 3) (mkInst (Cons 0 (Cons 0 (Cons 0 (Cons 0 Nil))))) 2) (List.length $a)) 32) ;; Since the type system isn't working properly the above has been replaced with this test case. Change when type starts working correctly.
;; !(assertEqual (let $a (generateAllInNeighborhood (mkMultip 3) (mkInst (Cons 0 (Cons 0 (Cons 0 (Cons 0 Nil))))) 1) ((List.length $a) (get-type $a))) (8 (List Instance)))
!(assertEqual (let $a (generateAllInNeighborhood (mkMultip 3) (mkInst (Cons 0 (Cons 0 (Cons 0 (Cons 0 Nil))))) 1) (List.length $a)) 8) ;; Since the type system isn't working properly the above has been replaced with this test case. Change when type starts working correctly.

;; At distance 3 should generate total of 64 neighbors
;; !(assertEqual (let $a (generateAllInNeighborhood (mkMultip 3) (mkInst (Cons 0 (Cons 0 (Cons 0 (Cons 0 Nil))))) 3) ((List.length $a) (get-type $a))) (64 (List Instance)))
!(assertEqual (let $a (generateAllInNeighborhood (mkMultip 3) (mkInst (Cons 0 (Cons 0 (Cons 0 (Cons 0 Nil))))) 3) (List.length $a)) 64) ;; Since the type system isn't working properly the above has been replaced with this test case. Change when type starts working correctly.

;; Generated neighbors should be 32 in length and center shouldn't be member.
;;    Distance 0 indicates a center node being present.
!(assertEqual
   (let $distList
        (List.map ((curry distance) (mkInst (Cons 0 (Cons 0 (Cons 0 (Cons 0 Nil)))))) 
                  (generateAllInNeighborhood (mkMultip 3) (mkInst (Cons 0 (Cons 0 (Cons 0 (Cons 0 Nil))))) 2))
        ((List.length $distList) (List.contains 0 $distList))) 
   (32 False))

(= (tree1)
        (mkTree (mkNode AND)
          (Cons (mkTree (mkNode A) Nil)
          (Cons (mkTree (mkNode OR)
                  (Cons (mkTree (mkNode B) Nil)
                  (Cons (mkTree (mkNode C) Nil)
                  (Cons (mkNullVex
                          (Cons (mkTree (mkNode D) Nil) Nil)) Nil))))
          (Cons (mkNullVex
                  (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) Nil)) Nil)) Nil)))))

(= (lsk1)
        (mkLSK
            (mkDiscKnob
              (mkKnob (mkNodeId (2 3)))
              (mkMultip 3)
              (mkDiscSpec 0)
              (mkDiscSpec 0)
              Nil)
            ))

(= (lsk2)
        (mkLSK
            (mkDiscKnob
              (mkKnob (mkNodeId (3)))
              (mkMultip 3)
              (mkDiscSpec 0)
              (mkDiscSpec 0)
              Nil)
            ))

(= (lsk3)
        (mkLSK
            (mkDiscKnob
              (mkKnob (mkNodeId (1)))
              (mkMultip 3)
              (mkDiscSpec 1)
              (mkDiscSpec 1)
              Nil)
            ))

(= (knobMapObj) (mkKbMap
                      (mkDscKbMp (ConsMap ((mkNodeId (2 3)) 0) (ConsMap ((mkNodeId (3)) 1) (ConsMap ((mkNodeId (1)) 2) NilMap))))
                      (mkDscMp (ConsMMap ((mkDiscSpec 1) (lsk1)) (ConsMMap ((mkDiscSpec 0) (lsk2)) (ConsMMap ((mkDiscSpec 1) (lsk3)) NilMMap))))))
(= (deme) (mkDeme 
(mkRep (mkKbMap 
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
            NilMMap))))) (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) Nil)))))) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) Nil))))))) (mkSInstSet Nil) (mkDemeId "1")))

; Test case for sampleFromNeighborhood function
; Function should returned two instances at the specified distance

!(assertEqual
     (let $returned (sampleFromNeighborhood 2 2 (knobMapObj) (mkInst (Cons 1 (Cons 2 (Cons 0 Nil)))))
       (List.map ((curry distance') (mkInst (Cons 1 (Cons 2 (Cons 0 Nil))))) $returned))
     (Cons 2 (Cons 2 Nil)))
!(assertEqual
     (let $returned (sampleFromNeighborhood 2 3 (knobMapObj) (mkInst (Cons 1 (Cons 2 (Cons 0 Nil)))))
       (List.map ((curry distance') (mkInst (Cons 1 (Cons 2 (Cons 0 Nil))))) $returned))
     (Cons 3 (Cons 3 Nil)))
!(assertEqual
     (let $returned (sampleFromNeighborhood 2 1 (knobMapObj) (mkInst (Cons 1 (Cons 2 (Cons 0 Nil)))))
       (List.map ((curry distance') (mkInst (Cons 1 (Cons 2 (Cons 0 Nil))))) $returned))
     (Cons 1 (Cons 1 Nil)))

;; Invalid (knobMapObj) or instance
!(assertEqual
     (let $returned
       (sampleFromNeighborhood 1 2 (knobMapObj) (mkInst Nil)) $returned)
     (Cons (Error (3 0) "Not Equal") Nil))

;; Testcases for removeInstScore
!(assertEqual 
 (removeInstScore (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 (Cons 3 (Cons 2.0 Nil))))) 3.2)))
 (mkInst (Cons 1 (Cons 2 (Cons 3 (Cons 2.0 Nil)))))
 )
!(assertEqual 
 (removeInstScore (mkSInst (mkPair (mkInst (Cons 0 (Cons 0 (Cons 0 (Cons 0 Nil))))) 3.2)))
 (mkInst (Cons 0 (Cons 0 (Cons 0 (Cons 0 Nil)))))
 )

; Testcase-1 for sampleNewInstances
; totalNeighbors & numNewInstances won't be updated, samples new instances 
!(assertEqual 
   (let ((mkDeme $rep (mkSInstSet $updatedInstList) $demeId) $num) 
   (sampleNewInstances 
   20 
   3 
   (mkInst (Cons 0 (Cons 0 (Cons 0 Nil)))) 
   (deme) 
   2)
   (List.map (distance' (mkInst (Cons 0 (Cons 0 (Cons 0 Nil))))) (List.map removeInstScore $updatedInstList)))
   (Cons 2 (Cons 2 (Cons 2 Nil))))

; Testcase-2 for sampleNewInstances
; totalNeighbors will be updated, samples new instances 
!(assertEqual 
   (let ((mkDeme $rep (mkSInstSet $updatedInstList) $demeId) $num) 
   (sampleNewInstances 
   10 
   7 
   (mkInst (Cons 0 (Cons 0 (Cons 0 Nil)))) 
   (deme) 
   2)
   (List.map (distance' (mkInst (Cons 0 (Cons 0 (Cons 0 Nil))))) (List.map removeInstScore $updatedInstList)))
   (Cons 2 (Cons 2 (Cons 2 (Cons 2 (Cons 2 (Cons 2 (Cons 2 Nil))))))))

; Testcase-3 for sampleNewInstances
; totalNeighbors will be updated, generates all instances in neighborhood
!(assertEqual 
   (let ((mkDeme $rep (mkSInstSet $updatedInstList) $demeId) $num) 
   (sampleNewInstances 
   4
   5 
   (mkInst (Cons 0 (Cons 0 (Cons 0 Nil)))) 
   (deme) 
   2)
   (List.map (distance' (mkInst (Cons 0 (Cons 0 (Cons 0 Nil))))) (List.map removeInstScore $updatedInstList)))
   (Cons 2 (Cons 2 (Cons 2 (Cons 2 (Cons 2 Nil))))))

; Testcase-4 for sampleNewInstances
; totalNeighbors & numNewInstances won't be updated, samples new instances
!(assertEqual 
   (let ((mkDeme $rep (mkSInstSet $updatedInstList) $demeId) $num) 
   (sampleNewInstances 
   20 
   0 
   (mkInst (Cons 0 (Cons 0 (Cons 0 Nil)))) 
   (deme) 
   2)
   (List.map (distance' (mkInst (Cons 0 (Cons 0 (Cons 0 Nil))))) (List.map removeInstScore $updatedInstList)))
Nil)

; ; Testcase for sampleFromNeighborhood function when requested sample size is more than possible instances
!(assertEqual (let $result (sampleFromNeighborhood 13 2 (knobMapObj) (mkInst (Cons 1 (Cons 2 (Cons 0 Nil))))) (List.length $result)) 13) ;; This test case has been changed to generate the size even if there is a duplicate instead of throwing an error. That's how the classic version does it.



;;testcase for isPossibleSize function
;; Formula: n! / ((n - d)! * d!) * (m-1)^d  (n = instance length, d = distance, m = knob multiplicity)
!(assertEqual (isPossibleSize 13 2 (mkInst (Cons 1 (Cons 2 (Cons 0 Nil))))) False)
!(assertEqual (isPossibleSize 10 2 (mkInst (Cons 1 (Cons 2 (Cons 0 Nil))))) True)
