!(register-module! ../../../metta-moses)

!(import! &self metta-moses:moses:neighborhood-sampling)
!(import! &self metta-moses:representation:instance)
!(import! &self metta-moses:representation:knob-representation)

! (import! &self metta-moses:utilities:tree)
! (import! &self metta-moses:utilities:nodeId)
! (import! &self metta-moses:utilities:list-methods)
; ! (import! &self metta-moses:utilities:python-helpers)
! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:utilities:ordered-multimap)
! (import! &self metta-moses:utilities:lazy-random-selector)
! (import! &self metta-moses:optimization/hillclimbing:hill-climbing-helpers) ;; using / for additional nested dir level 
! (import! &self metta-moses:deme:create-deme)
! (import! &self metta-moses:scoring:cscore)


;; Test the distance function
;; Hamming distance on expressions
!(assertEqual (distance (0 0 0 1) (0 1 0 0)) 2)
!(assertEqual (distance (0 0 0 0) (0 1 0 0)) 1)
!(assertEqual (distance (1 2 0 0) (0 1 0 0)) 2)
!(assertEqual (distance (1 2 1 0) (0 1 0 0)) 3)

;; Hamming distance on instance
!(assertEqual (distance` (mkInst (Cons 1 (Cons 2 (Cons 0 (Cons 0 Nil))))) (mkInst (Cons 0 (Cons 1 (Cons 0 (Cons 0 Nil)))))) 2)
!(assertEqual (distance` (mkInst (Cons 1 (Cons 2 (Cons 1 (Cons 0 Nil))))) (mkInst (Cons 0 (Cons 1 (Cons 0 (Cons 0 Nil)))))) 3)


;; ;; Test case to check valid reduction of vary1Knobs
!(assertEqualToResult (vary1Knobs (2 1) (0 0 0 0)) ((0 0 0 2) (0 0 0 1) (0 0 2 0) (0 0 0 2) (0 0 0 1) (0 0 1 0) (0 2 0 0) (0 0 0 2) (0 0 0 1) (0 0 2 0) (0 0 0 2) (0 0 0 1) (0 0 1 0) (0 1 0 0) (2 0 0 0) (0 0 0 2) (0 0 0 1) (0 0 2 0) (0 0 0 2) (0 0 0 1) (0 0 1 0) (0 2 0 0) (0 0 0 2) (0 0 0 1) (0 0 2 0) (0 0 0 2) (0 0 0 1) (0 0 1 0) (0 1 0 0) (1 0 0 0)))
;; Test case to make sure it varyNKnobs reduce
!(assertEqualToResult (let $a (varyNKnobs (2 1) (0 0 0 1) 2) (if (== (distance $a (0 0 0 1)) 0) (empty) $a)) ((1 0 0 2) (1 0 0 0) (1 0 2 1) (1 0 1 1) (1 2 0 1) (1 1 0 1) (2 0 0 1) (2 0 0 2) (2 0 0 0) (2 0 2 1) (2 0 1 1) (2 2 0 1) (2 1 0 1) (1 0 0 1) (0 1 0 2) (0 1 0 0) (0 1 2 1) (0 1 1 1) (0 2 0 1) (2 1 0 1) (1 1 0 1) (0 2 0 2) (0 2 0 0) (0 2 2 1) (0 2 1 1) (0 1 0 1) (2 2 0 1) (1 2 0 1) (0 0 1 2) (0 0 1 0) (0 0 2 1) (0 2 1 1) (0 1 1 1) (2 0 1 1) (1 0 1 1) (0 0 2 2) (0 0 2 0) (0 0 1 1) (0 2 2 1) (0 1 2 1) (2 0 2 1) (1 0 2 1) (0 0 0 2) (0 0 2 0) (0 0 1 0) (0 2 0 0) (0 1 0 0) (2 0 0 0) (1 0 0 0) (0 0 0 0) (0 0 2 2) (0 0 1 2) (0 2 0 2) (0 1 0 2) (2 0 0 2) (1 0 0 2)))

;; At distance 2 should generate total of 32 neighbors
; !(assertEqual (let $a (generateAllInNeighborhood (mkMultip 3) (mkInst (Cons 0 (Cons 0 (Cons 0 (Cons 0 Nil))))) 2) ((List.length $a) (get-type $a))) (32 (List Instance)))
;; mettalog appears to be not able to handle large (Cons (Cons ..)) data structures so the following test case is editted so that the output list is not too big
!(assertEqual (let $a (generateAllInNeighborhood (mkMultip 3) (mkInst (Cons 0 (Cons 0 (Cons 0 (Cons 0 Nil))))) 1) ((List.length $a) (get-type $a))) (8 (List Instance)))

;; At distance 3 should generate total of 64 neighbors
;; the following will be too much
; !(assertEqual (let $a (generateAllInNeighborhood (mkMultip 3) (mkInst (Cons 0 (Cons 0 (Cons 0 (Cons 0 Nil))))) 3) ((List.length $a) (get-type $a))) (64 (List Instance)))

;; Generated neighbors should be 32 in length and center shouldn't be member.
;;    Distance 0 indicates a center node being present.
!(assertEqual
   (let $distList
        (List.map ((curry distance) (mkInst (Cons 0 (Cons 0 (Cons 0 (Cons 0 Nil)))))) 
                  (generateAllInNeighborhood (mkMultip 3) (mkInst (Cons 0 (Cons 0 (Cons 0 (Cons 0 Nil))))) 2))
        ((List.length $distList) (List.contains 0 $distList))) 
   (32 False))

! (bind! tree1
        (mkTree (mkNode AND)
          (Cons (mkTree (mkNode A) Nil)
          (Cons (mkTree (mkNode OR)
                  (Cons (mkTree (mkNode B) Nil)
                  (Cons (mkTree (mkNode C) Nil)
                  (Cons (mkNullVex
                          (Cons (mkTree (mkNode D) Nil) Nil)) Nil))))
          (Cons (mkNullVex
                  (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) Nil)) Nil)) Nil)))))

! (bind! lsk1
        (mkLSK
            (mkDiscKnob
              (mkKnob (mkNodeId (2 3)))
              (mkMultip 3)
              (mkDiscSpec 0)
              (mkDiscSpec 0)
              Nil)
            ))

! (bind! lsk2
        (mkLSK
            (mkDiscKnob
              (mkKnob (mkNodeId (3)))
              (mkMultip 3)
              (mkDiscSpec 0)
              (mkDiscSpec 0)
              Nil)
            ))

! (bind! lsk3
        (mkLSK
            (mkDiscKnob
              (mkKnob (mkNodeId (1)))
              (mkMultip 3)
              (mkDiscSpec 1)
              (mkDiscSpec 1)
              Nil)
            ))

! (bind! knobMapObj (mkKbMap
                      (mkDscKbMp (ConsMap ((mkNodeId (2 3)) 0) (ConsMap ((mkNodeId (3)) 1) (ConsMap ((mkNodeId (1)) 2) NilMap))))
                      (mkDscMp (ConsMMap ((mkDiscSpec 1) lsk1) (ConsMMap ((mkDiscSpec 0) lsk2) (ConsMMap ((mkDiscSpec 1) lsk3) NilMMap))))))
! (bind! deme (mkDeme 
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
! (assertEqual
     (let $returned (sampleFromNeighborhood 2 2 knobMapObj (mkInst (Cons 1 (Cons 2 (Cons 0 Nil)))))
       (List.map ((curry distance') (mkInst (Cons 1 (Cons 2 (Cons 0 Nil))))) $returned))
     (Cons 2 (Cons 2 Nil)))
! (assertEqual
     (let $returned (sampleFromNeighborhood 2 3 knobMapObj (mkInst (Cons 1 (Cons 2 (Cons 0 Nil)))))
       (List.map ((curry distance') (mkInst (Cons 1 (Cons 2 (Cons 0 Nil))))) $returned))
     (Cons 3 (Cons 3 Nil)))
! (assertEqual
     (let $returned (sampleFromNeighborhood 2 1 knobMapObj (mkInst (Cons 1 (Cons 2 (Cons 0 Nil)))))
       (List.map ((curry distance') (mkInst (Cons 1 (Cons 2 (Cons 0 Nil))))) $returned))
     (Cons 1 (Cons 1 Nil)))

;; Invalid knobMapObj or instance
; ! (assertEqual
;      (let $returned
;        (sampleFromNeighborhood 1 2  knobMapObj (mkInst Nil)) (List.length $returned))
;      (Error (3 0) "Not Equal"))

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
   deme 
   2)
   (List.map ((curry distance') (mkInst (Cons 0 (Cons 0 (Cons 0 Nil))))) (List.map removeInstScore $updatedInstList)))
   (Cons 2 (Cons 2 (Cons 2 Nil))))

; Testcase-2 for sampleNewInstances
; totalNeighbors will be updated, samples new instances 
!(assertEqual 
   (let ((mkDeme $rep (mkSInstSet $updatedInstList) $demeId) $num) 
   (sampleNewInstances 
   10 
   7 
   (mkInst (Cons 0 (Cons 0 (Cons 0 Nil)))) 
   deme 
   2)
   (List.map ((curry distance') (mkInst (Cons 0 (Cons 0 (Cons 0 Nil))))) (List.map removeInstScore $updatedInstList)))
   (Cons 2 (Cons 2 (Cons 2 (Cons 2 (Cons 2 (Cons 2 (Cons 2 Nil))))))))

; Testcase-3 for sampleNewInstances
; totalNeighbors will be updated, generates all instances in neighborhood
!(assertEqual 
   (let ((mkDeme $rep (mkSInstSet $updatedInstList) $demeId) $num) 
   (sampleNewInstances 
   4
   5 
   (mkInst (Cons 0 (Cons 0 (Cons 0 Nil)))) 
   deme 
   2)
   (List.map ((curry distance') (mkInst (Cons 0 (Cons 0 (Cons 0 Nil))))) (List.map removeInstScore $updatedInstList)))
   (Cons 2 (Cons 2 (Cons 2 (Cons 2 (Cons 2 Nil))))))

; Testcase-4 for sampleNewInstances
; totalNeighbors & numNewInstances won't be updated, samples new instances
!(assertEqual 
   (let ((mkDeme $rep (mkSInstSet $updatedInstList) $demeId) $num) 
   (sampleNewInstances 
   20 
   0 
   (mkInst (Cons 0 (Cons 0 (Cons 0 Nil)))) 
   deme 
   2)
   (List.map ((curry distance') (mkInst (Cons 0 (Cons 0 (Cons 0 Nil))))) (List.map removeInstScore $updatedInstList)))
Nil)

; Testcase for sampleFromNeighborhood function when requested sample size is more than possible instances
!(assertEqual (sampleFromNeighborhood 13 2 knobMapObj (mkInst (Cons 1 (Cons 2 (Cons 0 Nil)))))
        (Error ("Cannot generate " 13 " instances at distance " 2 " from " (mkInst (Cons 1 (Cons 2 (Cons 0 Nil))))) (Requested sample size too large)))
  


; ; testcase for isPossibleSize function
; Formula: n! / ((n - d)! * d!) * (m-1)^d  (n = instance length, d = distance, m = knob multiplicity)
 !(assertEqual (isPossibleSize 13 2 3 (mkInst (Cons 1 (Cons 2 (Cons 0 Nil))))) False)
 !(assertEqual (isPossibleSize 10 2 3 (mkInst (Cons 1 (Cons 2 (Cons 0 Nil))))) True)

; test cases for overloaded function sampleFromNeighborhood`  and sampleFromNeighborhood using for feature selection.
!(bind! table (mkITable
                         (Cons (Cons False (Cons False (Cons False Nil))) 
                         (Cons (Cons True (Cons False (Cons False Nil))) 
                         (Cons (Cons False (Cons True (Cons False Nil)))
                         (Cons (Cons True (Cons True (Cons True Nil))) Nil))))
                         (Cons A (Cons B (Cons O (Cons Output Nil))))))


; ;Testcase for sampleFromNeighborhood function when requested sample size is more than possible instances in feature selection overloaded function.

; !(assertEqual (sampleFromNeighborhood 3 2 table (mkInst (Cons 0 (Cons 0 (Cons 1 Nil)))) False)
; (Cons (mkInst (Cons 1 (Cons 1 (Cons 1 Nil)))) (Cons (mkInst (Cons 0 (Cons 1 (Cons 0 Nil)))) (Cons (mkInst (Cons 0 (Cons 1 (Cons 0 Nil)))) Nil))))

; !(assertEqual (sampleFromNeighborhood 3 1 table (mkInst (Cons 0 (Cons 0 (Cons 1 Nil)))) False)
; (Cons (mkInst (Cons 1 (Cons 0 (Cons 1 Nil)))) (Cons (mkInst (Cons 0 (Cons 0 (Cons 0 Nil)))) (Cons (mkInst (Cons 1 (Cons 0 (Cons 1 Nil)))) Nil)))
; )