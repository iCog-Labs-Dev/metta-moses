!(import! &self ../../../utilities/general-helpers)
!(import! &self ../rte-helpers)

!(import! &self ../one-constraint-complement-subtraction)
!(import! &self ../../../scoring/boolean-ops) ;; mirrors moses.metta: AND/OR/NOT become callable AFTER the reduct compiles

;; Test 01
!(assertEqual 
    (oneCcSub (quote (OR (AND $D) (AND $B $C))) (quote (AND $B $C)) (quote ((NOT $B) $C)))
    (quote (OR (AND $D) (AND $C)))
)

;; Test 02
!(assertEqual 
    (oneCcSub (quote (AND (AND $B $A) (AND $B (NOT $C)))) (quote (AND $B $A)) (quote ((NOT $B) $C)))
    (quote (AND (AND $A) (AND $B (NOT $C))))
)

;; Test 03
!(assertEqual 
    (oneCcSub (quote (AND $A (AND $B $A) (NOT $D) (AND $B (NOT $C)))) (quote (AND $B $A)) (quote ((NOT $B) $C)))
    (quote (AND $A (AND $A) (NOT $D) (AND $B (NOT $C))))
)

;; Test 04
!(assertEqual 
    (oneCcSub (quote (AND (AND $D $C) (NOT $B) $A (AND $B $C))) (quote (AND $B $C)) (quote ((NOT $B) $C)))
    (quote (AND (AND $D $C) (NOT $B) $A (AND $C)))
)
;; Test 05
!(assertEqual 
    (oneCcSub (quote (OR (AND (NOT $A) $C) (OR $A $B (AND $B $C)))) (quote (AND (NOT $A) $C)) ($A $B $C))
    (quote (OR (AND $C) (OR $A $B (AND $B $C))))
)

;; No reduction

;; Test 06
!(assertEqual 
    (oneCcSub (quote (AND (AND $D $C) (NOT $B) $A (AND $B $C))) (quote (AND $A $C)) (quote ((NOT $B) $C)))
    (quote (AND (AND $D $C) (NOT $B) $A (AND $B $C)))
)

;; Test 07
!(assertEqual 
    (oneCcSub (quote (OR (AND (NOT $A) $C) (AND $A $B (AND $B $C)))) (quote (AND (NOT $A) $C)) (quote ((NOT $A) $B $C)))
    (quote (OR (AND (NOT $A) $C) (AND $A $B (AND $B $C))))
)

;; Test for helper function ===
!(assertEqual (=== $A $B) False)
!(assertEqual (=== $A $A) True)
!(assertEqual (=== () ($A)) False)
!(assertEqual (=== ($A) () ) False)
!(assertEqual (=== ($A $B) ($A)) False)
!(assertEqual (=== ($A $B) ($A $B)) True)
!(assertEqual (=== ($B $A) ($A $B)) True)
!(assertEqual (=== ($B $C $D $E $A) ($B $C $D $E $A)) True)
!(assertEqual (=== ($B $C $D $E $A) ($C $D $A $E $B)) True)
!(assertEqual (=== ($B $F $D $E $A) ($B $C $D $E $A)) False)
