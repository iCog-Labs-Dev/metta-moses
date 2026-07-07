!(import! &self ../../../utilities/general-helpers)
!(import! &self ../rte-helpers)
!(import! &self ../cut-unnecessary-or)
!(import! &self ../cut-unnecessary-and)
!(import! &self ../delete-inconsistent-handle)
!(import! &self ../zero-constraint-subsumption)
!(import! &self ../one-constraint-subsumption)
!(import! &self ../promote-common-constraints)
!(import! &self ../n-ary-gather-junctors)
!(import! &self ../n-ary-propagate-not)
!(import! &self ../reduce-to-elegance)
!(import! &self ../../../scoring/boolean-ops) ;; mirrors moses.metta: AND/OR/NOT become callable AFTER the reduct compiles

;; Test 04: Test case from Mosh's paper. Page 37

;; (AND (OR G (AND A B (OR (NOT C) (NOT D) E) (OR C (AND C F))))) ==> (AND (OR G (AND A B C (OR (NOT D) E))))
!(assertEqual (reduceToElegance (quote (AND (OR (AND $G) (AND $A $B (OR (AND (NOT $C)) (AND (NOT $D)) (AND $E)) (OR (AND $C) (AND $C $F)))))) (quote (OR (AND $G) (AND $A $B (OR (AND (NOT $C)) (AND (NOT $D)) (AND $E)) (OR (AND $C) (AND $C $F))))) () ()) (quote ((AND (OR (AND $G) (AND $A $B $C (OR (AND (NOT $D)) (AND $E)) $F))) (OR (AND $G) (AND $A $B $C (OR (AND (NOT $D)) (AND $E)) $F)) false))) ;; INFO: Tested against classic and this is the result of the reduct
;; (AND (OR G (AND A B C (OR (NOT D) E)))) ==> (AND (OR G (AND A B C (OR (NOT D) E))))
!(assertEqual (reduceToElegance (quote (AND (OR (AND $G) (AND $A $B $C (OR (AND (NOT $D)) (AND $E)))))) (quote (OR (AND $G) (AND $A $B $C (OR (AND (NOT $D)) (AND $E))))) () ()) (quote ((AND (OR (AND $G) (AND $A $B $C (OR (AND (NOT $D)) (AND $E))))) (OR (AND $G) (AND $A $B $C (OR (AND (NOT $D)) (AND $E)))) False)))
!(assertEqual (reduceToElegance (quote (AND $E (OR (AND $A) (AND $B) (AND $C $D)))) (quote (OR (AND $A) (AND $B) (AND $C $D))) () ()) (quote ((AND $E (OR (AND $A) (AND $B) (AND $C $D))) (OR (AND $A) (AND $B) (AND $C $D)) False)))
!(assertEqual (reduceToElegance (quote (OR (AND $A) (AND $B) (AND $C $D))) (quote (AND $C $D)) () ()) (quote ((OR (AND $A) (AND $B) (AND $C $D)) (AND $C $D) False)))

!(assertEqual (reduce-to (quote (AND (OR (AND $G) (AND $A $B (OR (AND (NOT $C)) (AND (NOT $D)) (AND $E)) (OR (AND $C) (AND $C $F))))))) (quote (AND (OR $G (AND $A $B $C $F (OR (NOT $D) $E)))))) ;; INFO: Tested against classic and this is the result.
!(assertEqual (reduce-to (quote (AND (OR $A $B) $A))) $A)

!(assertEqual (reduce-to (quote (AND (OR (AND (OR)) (AND (OR (AND (NOT $X1)))))))) (quote (NOT $X1)))

!(assertEqual (reduce-to (quote (AND (OR (AND (OR (AND (NOT $X1) (NOT $X2) (NOT $X3) (OR (AND $X2) (AND (NOT $X3))) (OR (AND (NOT $X1)) (AND (NOT $X3))) (OR (AND $X1) (AND (NOT $X2))) (OR (AND $X2) (AND $X1) (AND $X3) (AND $X1 $X2) (AND (NOT $X2) $X3) (AND $X1 $X3)) $X3 (OR (AND (NOT $X1)) (AND $X2)) (OR (AND $X2) (AND $X3)) (OR (AND $X1) (AND $X2)) (OR (AND $X1) (AND $X2) (AND $X3) (AND $X2 $X3) (AND (NOT $X1) $X3) (AND (NOT $X1)) (AND (NOT $X3)))) (AND (OR (AND (NOT $X3))) (OR (AND $X1) (AND $X2) (AND)) (OR)) (AND)) (OR)) (AND))))) (quote (AND (NOT $X3) (OR $X1 $X2))))

!(assertEqual (reduce-to (quote (OR (AND (OR (NOT (AND $D0 $Addr)))) (AND)))) (quote (AND (OR (NOT $D0) (NOT $Addr)))))
!(assertEqual (reduce-to (quote (OR (AND (OR (AND $D0 $Addr))) (AND)))) (quote (AND $D0 $Addr)))
!(assertEqual (reduce-to (quote (OR (AND (OR (NOT (AND $D1 $Addr)))) (AND)))) (quote (AND (OR (NOT $D1) (NOT $Addr)))) )
!(assertEqual (reduce-to (quote (OR (AND (OR)) (NOT (AND $D1 $Addr)) (AND)))) (quote (AND (OR (NOT $D1) (NOT $Addr)))) )
!(assertEqual (reduce-to (quote (OR (AND (OR (AND $D1 $Addr))) (AND)))) (quote (AND $D1 $Addr)))
!(assertEqual (reduce-to (quote (OR (AND (OR (NOT (AND (NOT $D1) $D0)))) (AND)))) (quote (AND (OR $D1 (NOT $D0)))))

;; Duplicate-literal elimination (dedupJunctors stage in applyReduce):
;; AND/OR are idempotent, so repeated identical siblings collapse to one.
;; uniqueStruct compares with == (var identity) — distinct labels never merge.
!(assertEqual (reduce-to (quote (AND $A $A))) $A)
!(assertEqual (reduce-to (quote (OR (AND $A $A) (AND $B $B)))) (quote (AND (OR $A $B))))
!(assertEqual (reduce-to (quote (AND $A (NOT $B) $A (NOT $B)))) (quote (AND $A (NOT $B))))
!(assertEqual (reduce-to (quote (AND (OR $A $B $A)))) (quote (AND (OR $A $B))))
!(assertEqual (reduce-to (quote (AND (OR (AND $A $A) (AND $B))))) (quote (AND (OR $A $B))))
