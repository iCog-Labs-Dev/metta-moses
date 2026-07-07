!(import! &self ../../../utilities/general-helpers)
!(import! &self ../gather-junctors)
!(import! &self ../../../scoring/boolean-ops) ;; mirrors moses.metta: AND/OR/NOT become callable AFTER the reduct compiles

;; Test 01
!(assertEqual
    (gatherJunctors (quote (OR $A $B)) ())
    (quote (OR $A $B))
)

;; Test 02
!(assertEqual
    (gatherJunctors (quote (OR $A (OR $B (OR $C $D)))) ())
    (quote (OR $A $B $C $D))
)

;; Test 03
!(assertEqual
    (gatherJunctors (quote (OR (OR (OR $C $D) $B) $A)) ())
    (quote (OR $C $D $B $A))
)

;; Test 04
!(assertEqual
    (gatherJunctors (quote (OR (OR $B (OR $C $D)) $A)) ())
    (quote (OR $B $C $D $A))
)

;; Test 05
!(assertEqual
    (gatherJunctors (quote (AND $A (AND $B (AND $C $D)))) ())
    (quote (AND $A $B $C $D))
)

;; Test 06
!(assertEqual
    (gatherJunctors (quote (AND (AND (AND $C $D) $B) $A)) ())
    (quote (AND $C $D $B $A))
)

;; Test 07
!(assertEqual
    (gatherJunctors (quote (AND (AND $B (AND $C $D)) $A)) ())
    (quote (AND $B $C $D $A))
)

;; Test 08
!(assertEqual
    (gatherJunctors (quote (AND $A (AND $B (OR $C (OR $D (AND $E (AND $F $G))))))) ())
    (quote (AND $A $B (OR $C $D (AND $E $F $G))))
)

;; Test 09
!(assertEqual
    (gatherJunctors (quote (AND $A (OR $B (OR $C (AND $D (OR $E $F)))))) ())
    (quote (AND $A (OR $B $C (AND $D (OR $E $F)))))
)

;; Test 10
!(assertEqual
    (gatherJunctors (quote (OR $A (OR $B (AND $C (AND $D (OR $E (OR $F $G))))))) ())
    (quote (OR $A $B (AND $C $D (OR $E $F $G))))
)

;; Test 11
!(assertEqual
    (gatherJunctors (quote (OR $A (AND $B (AND $C (OR $D (AND $E $F)))))) ())
    (quote (OR $A (AND $B $C (OR $D (AND $E $F)))))
)

;; Test 12
!(assertEqual
    (gatherJunctors (quote (AND $A (AND $B (AND $C (OR $D (OR $E (OR $F (AND $G $H)))))))) ())
    (quote (AND $A $B $C (OR $D $E $F (AND $G $H))))
)

;; Test 13
!(assertEqual
    (gatherJunctors (quote (AND (AND $I (AND $J (OR $K (OR $L $M)))) (AND $B (AND $C (OR $D (OR $E (OR $F (AND $G $H)))))))) ())
    (quote (AND $I $J (OR $K $L $M) $B $C (OR $D $E $F (AND $G $H))))
)

;; Test 14
!(assertEqual
    (gatherJunctors (quote (OR (OR $I (OR $J (AND $K (AND $L $M)))) (OR $B (OR $C (AND $D (AND $E (AND $F (AND $G $H)))))))) ())
    (quote (OR $I $J (AND $K $L $M) $B $C (AND $D $E $F $G $H)))
)

;; Test 15
!(assertEqual
    (gatherJunctors (quote (AND (AND $B (AND (OR $D (OR $E (OR (AND $G $H) $F))) $C)) $A)) ())
    (quote (AND $B (OR $D $E (AND $G $H) $F) $C $A))
)

;; Test 16
!(assertEqual (gatherJunctors (quote (OR (NOT $A) $B)) ())
                 (quote (OR (NOT $A) $B)))

;; Test 17 
!(assertEqual (gatherJunctors (quote (OR (NOT $A) (OR $B (OR (NOT $C) $D)))) ())
                  (quote (OR (NOT $A) $B (NOT $C) $D)) )
;; Test 18
!(assertEqual (gatherJunctors (quote (AND (OR (OR $C $D) (NOT $B)) (NOT $A))) ())
                 (quote (AND (OR $C $D (NOT $B)) (NOT $A))))

;; Test 19
!(assertEqual (gatherJunctors (quote (AND (AND (OR $C (NOT $D)) (NOT $B)) $A)) ())
                 (quote (AND (OR $C (NOT $D)) (NOT $B) $A)))

;; Test 20
!(assertEqual (gatherJunctors (quote (AND (NOT $A) (AND $B (OR $C (OR (NOT $D) (AND $E (AND $F (NOT $G)))))))) ())
                 (quote (AND (NOT $A) $B (OR $C (NOT $D) (AND $E $F (NOT $G))))) )
