!(import! &self ../../../utilities/general-helpers)
!(import! &self ../rte-helpers)
!(import! &self ../cut-unnecessary-and)
!(import! &self ../../../scoring/boolean-ops) ;; mirrors moses.metta: AND/OR/NOT become callable AFTER the reduct compiles


;; Test 01
!(assertEqual
    (andCut (quote (OR $A $B (AND (OR (AND $B $C) (AND $E $F))))) (quote (AND (OR (AND $B $C) (AND $E $F)))))
    (quote ((OR $A $B (AND $B $C) (AND $E $F)) () True))
)

;; Test 02
!(assertEqual
    (andCut (quote (OR (AND (OR (AND $C $D) (AND $C $F))) $A)) (quote (AND (OR (AND $C $D) (AND $C $F)))))
    (quote ((OR (AND (OR (AND $C $D) (AND $C $F))) $A) (AND (OR (AND $C $D) (AND $C $F))) False))
)

; ;; Test 03
!(assertEqual
    (andCut (quote (OR $A (AND (OR (AND $B $C) (AND $E $F) (AND $G $H))) $F)) (quote (AND (OR (AND $B $C) (AND $E $F) (AND $G $H)))))
    (quote ((OR $A $F (AND $B $C) (AND $E $F) (AND $G $H)) () True))
)

;; Test 04
!(assertEqual
    (andCut (quote (OR (AND (OR (AND $B $C) (AND $E $F)) (OR (AND $G $H) (AND $I $J))))) (quote (AND (OR (AND $B $C) (AND $E $F)) (OR (AND $G $H) (AND $I $J)))))
    (quote ((OR (AND (OR (AND $B $C) (AND $E $F)) (OR (AND $G $H) (AND $I $J)))) (AND (OR (AND $B $C) (AND $E $F)) (OR (AND $G $H) (AND $I $J))) False))
)

;; Test 05
!(assertEqual
    (andCut (quote (OR $A (AND (OR (AND $B $C) (AND (NOT $E) $F))))) (quote (AND (OR (AND $B $C) (AND (NOT $E) $F)))))
    (quote ((OR $A (AND $B $C) (AND (NOT $E) $F)) () True))
)

;; Test 06
!(assertEqual
    (andCut (quote (OR $A $B (AND $A $D $C (OR (AND $B $C) (AND $E $F))) $C (NOT $D))) (quote (AND $A $D $C (OR (AND $B $C) (AND $E $F)))))
    (quote ((OR $A $B (AND $A $D $C (OR (AND $B $C) (AND $E $F))) $C (NOT $D)) (AND $A $D $C (OR (AND $B $C) (AND $E $F))) False))
)

;;Test 07
!(assertEqual
    (andCut (quote (OR (AND $A (OR (AND (NOT $B) $C) (AND $E $F))))) (quote (AND $A (OR (AND (NOT $B) $C) (AND $E $F)))))
    (quote ((OR (AND $A (OR (AND (NOT $B) $C) (AND $E $F)))) (AND $A (OR (AND (NOT $B) $C) (AND $E $F))) False))
)

;; Test 08: Test case from Holman paper page 42
!(assertEqual
    (andCut (quote (OR $C (AND (OR (AND $B $D) (NOT $E))))) (quote (AND (OR (AND $B $D) (NOT $E)))))
    (quote ((OR $C (NOT $E) (AND $B $D)) () True))
 )

;; Test 09
!(assertEqual
    (andCut (quote (OR $C (AND (OR $A $E (AND $B $D) (NOT $E))))) (quote (AND (OR $A $E (AND $B $D) (NOT $E)))))
    (quote ((OR $C $A $E (NOT $E) (AND $B $D)) () True))
 )


;; Test 09
!(assertEqual
    (andCut (quote (OR (AND (OR (AND $B $D) $A (NOT $E))))) (quote (AND (OR (AND $B $D) $A (NOT $E)))))
    (quote ((OR $A (NOT $E) (AND $B $D)) () True))
 )
