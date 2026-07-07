!(import! &self ../../../utilities/general-helpers)
!(import! &self ../propagate-not)
!(import! &self ../../../scoring/boolean-ops) ;; mirrors moses.metta: AND/OR/NOT become callable AFTER the reduct compiles

;; Test 01
!(assertEqual
    (propagateNot (quote (OR (AND $A $B) (OR $A $C))))
    (quote (OR (AND $A $B) (OR $A $C)))
)

;; Test 02
!(assertEqual
    (propagateNot (quote (AND $A $B)))
    (quote (AND $A $B))
)

;; Test 03
!(assertEqual
    (propagateNot (quote (NOT $A)))
    (quote (NOT $A))
)

;; Test 04
!(assertEqual
    (propagateNot (quote (OR $A (AND $B $C))))
    (quote (OR $A (AND $B $C)))
)

;; Test 05
!(assertEqual
    (propagateNot (quote (NOT (OR $A (AND $B $C)))))
    (quote (AND (NOT $A) (OR (NOT $B) (NOT $C))))
)

;; Test 06
!(assertEqual
    (propagateNot (quote (NOT (AND $A (OR $B $C)))))
    (quote (OR (NOT $A) (AND (NOT $B) (NOT $C))))
)

;; Test 07
!(assertEqual
    (propagateNot (quote (AND $A (NOT (OR $B (AND $C $D))))))
    (quote (AND $A (AND (NOT $B) (OR (NOT $C) (NOT $D)))))
)

;; Test 08
!(assertEqual
    (propagateNot (quote (NOT (AND $A (NOT (OR $B (AND $C $D)))))))
    (quote (OR (NOT $A) (OR $B (AND $C $D))))
)

;; Test 09
!(assertEqual
    (propagateNot (quote (AND $A (OR $B (AND $C $D)))))
    (quote (AND $A (OR $B (AND $C $D))))
)

;; Test 10
!(assertEqual
    (propagateNot (quote (NOT (NOT (NOT (AND $A (AND $B (AND $C $D))))))))
    (quote (OR (NOT $A) (OR (NOT $B) (OR (NOT $C) (NOT $D)))))
)

;; Test 11
!(assertEqual
    (propagateNot (quote (NOT (NOT (NOT (OR $A (AND $B (OR $C $D))))))))
    (quote (AND (NOT $A) (OR (NOT $B) (AND (NOT $C) (NOT $D)))))
)

;; Test 12
!(assertEqual
    (propagateNot (quote (NOT (NOT (NOT (NOT (AND $A (AND $B (AND $C $D)))))))))
    (quote (AND $A (AND $B (AND $C $D))))
)

;; Test 13
!(assertEqual
    (propagateNot (quote (NOT (NOT (NOT (NOT (OR $A (AND $B (OR $C $D)))))))))
    (quote (OR $A (AND $B (OR $C $D))))
)

;; Test 14
!(assertEqual
    (propagateNot (quote (NOT (AND (AND $I (AND $J (NOT (OR $K (OR $L $M))))) (AND $B (NOT (AND $C (OR $D (OR $E (NOT (OR $F (AND $G $H))))))))))))
    (quote (OR (OR (NOT $I) (OR (NOT $J) (OR $K (OR $L $M)))) (OR (NOT $B) (AND $C (OR $D (OR $E (AND (NOT $F) (OR (NOT $G) (NOT $H)))))))))
)

;; Test 15
!(assertEqual
    (propagateNot (quote (NOT (OR (OR $I (OR $J (AND $K (AND $L $M)))) (OR $B (OR $C (AND $D (AND $E (AND $F (AND $G $H))))))))))
    (quote (AND (AND (NOT $I) (AND (NOT $J) (OR (NOT $K) (OR (NOT $L) (NOT $M))))) (AND (NOT $B) (AND (NOT $C) (OR (NOT $D) (OR (NOT $E) (OR (NOT $F) (OR (NOT $G) (NOT $H)))))))))
)

;; Test 16
!(assertEqual
    (propagateNot (quote (NOT (OR (OR (OR $C $D) $B) $A))))
    (quote (AND (AND (AND (NOT $C) (NOT $D)) (NOT $B)) (NOT $A)))
)

;; Test 17
!(assertEqual
    (propagateNot (quote (OR (AND (AND $C $D) $B) (NOT $A))))
    (quote (OR (AND (AND $C $D) $B) (NOT $A)))
)
