!(import! &self ../../../utilities/general-helpers)
!(import! &self ../rte-helpers)
!(import! &self ../promote-common-constraints)
!(import! &self ../../../scoring/boolean-ops) ;; mirrors moses.metta: AND/OR/NOT become callable AFTER the reduct compiles


;; Test 01
!(assertEqual
    (promoteCommonConstraints (quote (AND (OR $A $C (AND $A $B) (AND $A $C)))) (quote (OR $A $C (AND $A $B) (AND $A $C)))) (quote ((AND $A (OR $C (AND $B) (AND $C))) (OR $C (AND $B) (AND $C)) True))
)

;; Test 02
!(assertEqual
    (promoteCommonConstraints (quote (AND (OR (AND (NOT $A) $B) (AND (NOT $A) $C)))) (quote (OR (AND (NOT $A) $B) (AND (NOT $A) $C))))
    (quote ((AND (NOT $A) (OR (AND $B) (AND $C))) (OR (AND $B) (AND $C)) True))
)

;; Test 03
!(assertEqual
    (promoteCommonConstraints (quote (AND (OR $E $F (AND $F (NOT $G)) (AND $H $I)))) (quote (OR $E $F (AND $F (NOT $G)) (AND $H $I))))
    (quote ((AND (OR $E $F (AND $F (NOT $G)) (AND $H $I))) (OR $E $F (AND $F (NOT $G)) (AND $H $I)) False))
)

;; Test 04
!(assertEqual
    (promoteCommonConstraints (quote (AND (OR $J (AND $J $K) (AND $J $L) (AND $J $M)))) (quote (OR $J (AND $J $K) (AND $J $L) (AND $J $M))))
    (quote ((AND $J (OR (AND $K) (AND $L) (AND $M))) (OR (AND $K) (AND $L) (AND $M)) True))
)

;; Test 05
!(assertEqual
    (promoteCommonConstraints (quote (AND (OR (NOT $N) (AND $N $O) (AND $N $P) (AND $M $Q)))) (quote (OR (NOT $N) (AND $N $O) (AND $N $P) (AND $M $Q))))
    (quote ((AND (OR (NOT $N) (AND $N $O) (AND $N $P) (AND $M $Q))) (OR (NOT $N) (AND $N $O) (AND $N $P) (AND $M $Q)) False))
)

;; Test 06
!(assertEqual
    (promoteCommonConstraints (quote (AND (OR (NOT $N) (AND (NOT $N) $O) (AND (NOT $N) $P) (AND (NOT $N) $Q)))) (quote (OR (NOT $N) (AND (NOT $N) $O) (AND (NOT $N) $P) (AND (NOT $N) $Q))))
    (quote ((AND (NOT $N) (OR (AND $O) (AND $P) (AND $Q))) (OR (AND $O) (AND $P) (AND $Q)) True))
)

;; Test 07: Test case from Holman paper page #39
!(assertEqual
    (promoteCommonConstraints (quote (AND $A (OR (AND (NOT $B) $C) (AND (NOT $B))) (OR (AND (NOT $C)) (AND (NOT $B) (NOT $D))))) (quote (OR (AND (NOT $B) $C) (AND (NOT $B)))))
    (quote ((AND $A (NOT $B) (OR (AND $C) (AND)) (OR (AND (NOT $C)) (AND (NOT $B) (NOT $D)))) (OR (AND $C) (AND)) True))
)

;;remove element Test

;; Test 01
!(assertEqual 
  (removeElement ($A $B) ($A $C $B $H))
  ($C $H)
 )

 ;; Test 02
 !(assertEqual 
  (removeElement ($A) ($A $C $B $H))
  ($C $B $H)
 )

 ;; Test 03
  !(assertEqual 
  (removeElement () ($A $C $B $H))
  ($A $C $B $H)
 )

 ;; Test 04
  !(assertEqual 
  (removeElement ($A $B) ($C  $H))
  ($C $H)
 )

;; Test 05
!(assertEqual 
  (removeElement ($A $B) ())
  ()
 )

;; test removeCommonLiterals
;; Test 01
!(assertEqual
   (removeCommonLiterals ($A $B) (($A $C $B $H) ($A $B $D) ($A $C $F $B)))
   (($C $H) ($D) ($C $F))
 )

;; Test 02
!(assertEqual
  (removeCommonLiterals ($A) (($A $C $B $H) ($A $B $D) ($A $C $F $B)))
  (($C $B $H) ($B $D) ($C $F $B))
)
;; Test 03
!(assertEqual
   (removeCommonLiterals () (($A $C $B $H) ($A $B $D) ($A $C $F $B)))
   (($A $C $B $H) ($A $B $D) ($A $C $F $B))
)
;; Test 04
!(assertEqual
 (removeCommonLiterals ($A $B) (($C $H) ( $B $D) ($A $C $F $B)))
 (($C $H) ($D) ($C $F ))
)
;; Test 05
!(assertEqual
  (removeCommonLiterals ($A $B) ())
  ()
)

