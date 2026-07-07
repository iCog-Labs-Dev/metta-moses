!(import! &self ../../../utilities/general-helpers)
!(import! &self ../n-ary-gather-junctors)
!(import! &self ../../../scoring/boolean-ops) ;; mirrors moses.metta: AND/OR/NOT become callable AFTER the reduct compiles


;; Test 01
!(assertEqual
    (gatherJunctors (quote (OR $A $B)))
    (quote (OR $A $B))
)

;; Test 02
!(assertEqual
    (gatherJunctors (quote (OR $A $F (OR $B (OR $C $D)))) )
    (quote (OR $A $F $B $C $D))
)

;; Test 03
!(assertEqual
    (gatherJunctors (quote (OR (OR (OR $C $D) $B) $A (AND $F $H (AND $K $L) $V))))
    (quote (OR $C $D $B $A (AND $F $H $K $L $V)))
)

;; Test 04
!(assertEqual
    (gatherJunctors (quote (OR (OR $B $K (OR $C $D $J)) $A)))
    (quote (OR $B $K $C $D $J $A))
)

;; Test 05
!(assertEqual
    (gatherJunctors (quote (AND $A $F (AND $B (AND $C $D)))))
    (quote (AND $A $F $B $C $D))
)

;; Test 06
!(assertEqual
    (gatherJunctors (quote (AND (OR $L $U (OR $M $I $J)) (AND (AND $C $D) $B) $A)))
    (quote (AND (OR $L $U $M $I $J) $C $D $B $A))
)

;; Test 07
!(assertEqual
    (gatherJunctors (quote (AND (AND $B (AND $C $D)) $A $N)))
    (quote (AND $B $C $D $A $N))
)

;; Test 08
!(assertEqual
    (gatherJunctors (quote (AND $A (AND $B $H (OR $C (OR $D $K (AND $E (AND $F $B $G))))))))
    (quote (AND $A $B $H (OR $C $D $K (AND $E $F $B $G))))
)

;; Test 09
!(assertEqual
    (gatherJunctors (quote (AND $A (OR $B (OR $C (AND $D (OR $E $F)))))))
    (quote (AND $A (OR $B $C (AND $D (OR $E $F)))))
)

;; Test 10
!(assertEqual
    (gatherJunctors (quote (OR $A (OR $B (AND $C (AND $D (OR $E (OR $F $G))))))))
    (quote (OR $A $B (AND $C $D (OR $E $F $G))))
)

;; Test 11
!(assertEqual (gatherJunctors (quote (OR (NOT $A) $B (NOT $B))))
                 (quote (OR (NOT $A) $B (NOT $B))))

;; Test 12
!(assertEqual (gatherJunctors (quote (OR (NOT $A) (OR $B (NOT $C) (OR (NOT $C) $D)))))
                  (quote (OR (NOT $A) $B (NOT $C) (NOT $C) $D)) )
;; Test 13
!(assertEqual (gatherJunctors (quote (AND (OR (OR $C $D $K) (NOT $B)) (NOT $A))))
                 (quote (AND (OR $C $D $K (NOT $B)) (NOT $A))))

;; Test 14
!(assertEqual (gatherJunctors (quote (AND (AND (OR $C (NOT $D)) (NOT $B)) $A)))
                 (quote (AND (OR $C (NOT $D)) (NOT $B) $A)))

;; Test 15
!(assertEqual (gatherJunctors (quote (AND (NOT $A) (AND $B (NOT $V) (OR $C (OR (NOT $D) (NOT $K) (AND $E (AND $F (NOT $G)))))))))
                 (quote (AND (NOT $A) $B (NOT $V) (OR $C (NOT $D) (NOT $K) (AND $E $F (NOT $G))))) )

;; Test for andAND function
!(assertEqual (addAND (quote (OR $A $B $C $D))) 
                (quote (AND (OR (AND $A) (AND $B) (AND $C) (AND $D)))))

!(assertEqual (addAND (quote (NOT $A))) 
                (quote (AND (NOT $A))))

!(assertEqual (addAND (quote (OR (NOT $A) $B (NOT $C) (AND $C (OR $A $B)) $D)))
                (quote (AND (OR (AND (NOT $A)) (AND $B) (AND (NOT $C)) (AND $C (OR (AND $A) (AND $B))) (AND $D)))))

!(assertEqual (addAND (quote (AND (OR $A $B) $A))) (quote (AND (OR (AND $A) (AND $B)) $A)))

!(assertEqual (addAND (quote (OR (AND (NOT $A) (OR $B $C) $A)))) (quote (AND (OR (AND (NOT $A) (OR (AND $B) (AND $C)) $A)))))
