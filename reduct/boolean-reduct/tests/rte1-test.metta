!(import! &self ../../../utilities/general-helpers)
!(import! &self ../rte-helpers)
!(import! &self ../cut-unnecessary-or)
!(import! &self ../cut-unnecessary-and)
!(import! &self ../delete-inconsistent-handle)
!(import! &self ../zero-constraint-subsumption)
!(import! &self ../one-constraint-subsumption)
!(import! &self ../promote-common-constraints)
!(import! &self ../reduce-to-elegance)
!(import! &self ../../../scoring/boolean-ops) ;; mirrors moses.metta: AND/OR/NOT become callable AFTER the reduct compiles


;; Tests for the component functions of the RTE algorithms.

;; Test for andTransformationNotApplied predicate function

!(assertEqual (transformationsNotApplied (() () (() () False))) True)
!(assertEqual (transformationsNotApplied (() () (() () True))) False)
!(assertEqual (transformationsNotApplied (quote (($A $B (NOT $A)) () ((AND $A $B (OR $C $D)) (OR $C $D) True)))) False)
!(assertEqual (transformationsNotApplied (quote (($A $B (NOT $A)) () ((AND $A $B (OR $C $D)) (OR $C $D) False)))) True)
!(assertEqual (transformationsNotApplied (quote (() ($A $B (NOT $A)) ((OR $A $B (AND $C $D)) (AND $C $D) True)))) False)
!(assertEqual (transformationsNotApplied (quote (() ($A $B (NOT $A)) ((OR $A $B (AND $C $D)) (AND $C $D) False)))) True)


;; Test for orTransformationNotApplied predicate function

!(assertEqual (transformationsNotApplied (() () (() () False))) True)
!(assertEqual (transformationsNotApplied (() () (() () True))) False)
!(assertEqual (transformationsNotApplied (quote (($A $B (NOT $A)) () ((AND $A $B (OR $C $D)) (OR $C $D) True)))) False)
!(assertEqual (transformationsNotApplied (quote (($A $B (NOT $A)) () ((AND $A $B (OR $C $D)) (OR $C $D) False)))) True)
!(assertEqual (transformationsNotApplied (quote (() ($A $B (NOT $A)) ((OR $A $B (AND $C $D)) (AND $C $D) True)))) False)
!(assertEqual (transformationsNotApplied (quote (() ($A $B (NOT $A)) ((OR $A $B (AND $C $D)) (AND $C $D) False)))) True)


;; Test for hasNoNextChild predicate function

!(assertEqual (hasNoNextChild (quote ((AND $A (OR $A $B) (OR $C $D) (OR $E)) True ((OR $A $B) ((OR $C $D) (OR $E)))))) False)
!(assertEqual (hasNoNextChild (quote ((AND $A (OR $A $B) (OR $C $D) (OR $E)) False ((OR $C $D) ((OR $E)))))) False)
!(assertEqual (hasNoNextChild (quote ((AND $A (OR $A $B) (OR $C $D)) False (() ())))) True)
!(assertEqual (hasNoNextChild (quote ((AND $A $E (OR $A $B) (OR $C $D)) True (() ())))) True)
!(assertEqual (hasNoNextChild (quote ((AND $A (OR $A $B) (OR $C $D)) True (() ())))) True)
!(assertEqual (hasNoNextChild (quote (() () ((AND $A $B) () False) ((OR $A $C) ())))) False)
!(assertEqual (hasNoNextChild (quote (($A $B) ($C $D) ((AND $A $B (OR $C $A) (OR $A $D) (OR $E)) (OR $C $A) True) ((OR $A $D) (OR $E))))) False)
!(assertEqual (hasNoNextChild (quote (() () ((AND $A (OR $A $B) (OR $C $D)) (OR $A $B) False) (() (AND $A $B))))) True)
!(assertEqual (hasNoNextChild (quote (() () ((AND $A (OR $A $B) (OR $C $D)) (OR $A $B) False) (() ())))) True)
!(assertEqual (hasNoNextChild (quote (() () ((AND $A (OR $A $B) (OR $C $D)) (OR $C $D) True) (() ())))) True)
!(assertEqual (hasNoNextChild (quote (() () ((AND $A $E (OR $A $B) (OR $C $D)) (OR $A $B) True) (() ())))) True)

;; Test for applyAndTransformations function.

!(assertEqual (applyAndTransformations (quote (() ($C $D) ((OR $N $O $P (AND $R $X (NOT $C)) $V (AND $Q $S (OR $T $U)) $W) (AND $R $X (NOT $C)) False)))) (quote (() ($C $D) ((OR $N $O $P $V (AND $Q $S (OR $T $U)) $W) () True))))
!(assertEqual (applyAndTransformations (quote (() ($A $D) ((OR $N $O $P (AND $R $X (NOT $C)) $V (AND (OR $T $U)) $W) (AND (OR $T $U)) False)))) (quote (() ($A $D) ((OR $N $O $P $V $W $T $U (AND $R $X (NOT $C))) () True))))
!(assertEqual (applyAndTransformations (quote (() ($A $D) ((OR $N $O $P (AND $R $X (NOT $C)) $V (AND (OR $T $U (AND $X $Y) (AND $Z $B))) $W) (AND (OR $T $U (AND $X $Y) (AND $Z $B))) False)))) (quote (() ($A $D) ((OR $N $O $P $V $W $T $U (AND $R $X (NOT $C)) (AND $X $Y) (AND $Z $B)) () True))))
!(assertEqual (applyAndTransformations (quote (() ($A $D) ((OR $N $O $P (AND $R $X (NOT $C)) $V (AND (OR $T $U)) $W) (AND (OR $T $U)) False)))) (quote (() ($A $D) ((OR $N $O $P $V $W $T $U (AND $R $X (NOT $C))) () True))))
!(assertEqual (applyAndTransformations (quote (() ($A $D) ((OR $N $O $P (AND $R $X (NOT $C)) $V (AND (OR $T $U (AND $X $Y) (AND $Z $B))) $W) (AND (OR $T $U (AND $X $Y) (AND $Z $B))) False)))) (quote (() ($A $D) ((OR $N $O $P $V $W $T $U (AND $R $X (NOT $C)) (AND $X $Y) (AND $Z $B)) () True))))
!(assertEqual (applyAndTransformations (quote (() ($A $D) ((OR $N $O $P (AND $R $X (NOT $C)) $V (AND (OR $T $U (AND $U $Y) (AND $U $B))) $W) (OR $T $U (AND $U $Y) (AND $U $B)) False)))) (quote (() ($A $D) ((OR $N $O $P (AND $R $X (NOT $C)) $V (AND (OR $T $U (AND $U $Y) (AND $U $B))) $W) (OR $T $U (AND $U $Y) (AND $U $B)) False))))
!(assertEqual (applyAndTransformations (quote (() ($A $D) ((OR $N $O $P (AND $R $X (NOT $C)) $V (AND (OR $T $U (AND $U $Y) (AND $U $B))) $W) (AND (OR $T $U (AND $U $Y) (AND $U $B))) False)))) (quote (() ($A $D) ((OR $N $O $P (AND $R $X (NOT $C)) $V (AND $U (OR $T (AND $Y) (AND $B))) $W) (AND $U (OR $T (AND $Y) (AND $B))) True))))
!(assertEqual (applyAndTransformations (quote (() ($A $D) ((OR $N $O $P (AND $R $X (NOT $C)) $V (AND (OR $T $U (AND $U $Y) (AND $U $B))) $W) (AND (OR $T $U (AND $Y) (AND $D) (AND $H $I) (AND $B))) False)))) (quote (() ($A $D) ((OR $N $O $P $V $W $T $U (AND $R $X (NOT $C)) (AND (OR $T $U (AND $U $Y) (AND $U $B))) (AND $Y) (AND $D) (AND $H $I) (AND $B)) () True))))
!(assertEqual (applyAndTransformations (quote (() () ((OR $N $O $P (AND $R $X (NOT $C)) $V (AND $Z (OR $T (AND $Y) (AND $D) (AND $H $I) (AND $B))) $W) (AND $Z (OR $T $U (AND $Y) (AND $D) (AND $H $I) (AND $B))) False)))) (quote (() () ((OR $N $O $P (AND $R $X (NOT $C)) $V (AND $Z (OR $T (AND $Y) (AND $D) (AND $H $I) (AND $B))) $W) (AND $Z (OR $T $U (AND $Y) (AND $D) (AND $H $I) (AND $B))) False))))

;; Test for applyOrTransformations function

!(assertEqual (applyOrTransformations (quote (() () ((AND $N $O $P (OR $R $X (NOT $C)) $V (OR $Q $S (AND $T $U)) $W (OR $Y)) (OR $Y) False)))) (quote (() () ((AND $N $O $P $V $W $Y (OR $R $X (NOT $C)) (OR $Q $S (AND $T $U))) () True))))

!(assertEqual (applyOrTransformations (quote (() () ((AND $A $B (OR $C $D) (OR $E $F (AND $G $H) (AND $I $J (OR $K $L)) (AND))) (OR $E $F (AND $G $H) (AND $I $J (OR $K $L)) (AND)) False)))) (quote (() () ((AND $A $B (OR $C $D) (OR $E $F (AND $G $H) (AND $I $J (OR $K $L)))) (OR $E $F (AND $G $H) (AND $I $J (OR $K $L))) True)))) ;; FIXED

!(assertEqual (applyOrTransformations (quote (() () ((AND $A $B (OR $C $D) (OR $E $F (AND $G $H) (AND $I $J (OR $K $L)) (OR))) (OR $E $F (AND $G $H) (AND $I $J (OR $K $L)) (OR)) False)))) (quote (() () ((AND $A $B (OR $C $D) (OR $E $F (AND $G $H) (AND $I $J (OR $K $L)))) (OR $E $F (AND $G $H) (AND $I $J (OR $K $L))) True)))) ;; FIXED

!(assertEqual (applyOrTransformations (quote (() () ((AND $N $O $P (OR $R $X (NOT $C)) $V (OR $Q $S (AND $T $U)) $W) (OR $R $X (NOT $C)) False)))) (quote (() () ((AND $N $O $P (OR $R $X (NOT $C)) $V (OR $Q $S (AND $T $U)) $W) (OR $R $X (NOT $C)) False))))
!(assertEqual (applyOrTransformations (quote (() () ((AND $N $O $P (OR $R $X (NOT $C)) $V (OR $Q $S (AND $T $U)) $W (OR (AND $Y))) (OR (AND $Y)) False)))) (quote (() () ((AND $N $O $P $V $W (OR $R $X (NOT $C)) (OR $Q $S (AND $T $U)) $Y) () True))))
!(assertEqual (applyOrTransformations (quote (() () ((AND $N $O $P (OR $R $X (NOT $C)) $V (OR $Q $S (AND $T $U)) $W (OR $Y)) (OR $Y) False)))) (quote (() () ((AND $N $O $P $V $W $Y (OR $R $X (NOT $C)) (OR $Q $S (AND $T $U))) () True))))

!(assertEqual (applyOrTransformations (quote (() () ((AND $N $O $P (OR $R $X (NOT $C)) $V (OR $Q $S (AND $T $U)) $W (OR $Y (AND $Z $A))) (OR $Y (AND $Z $A)) False)))) (quote (() () ((AND $N $O $P (OR $R $X (NOT $C)) $V (OR $Q $S (AND $T $U)) $W (OR $Y (AND $Z $A))) (OR $Y (AND $Z $A)) False)))) ;; FIX: Failing test

!(assertEqual (applyOrTransformations (quote (() () ((AND $N $O $P (OR $R $X (NOT $C)) $V (OR $Q $S (AND $T $U)) $W (OR (AND $Z $A))) (OR (AND $Z $A)) False)))) (quote (() () ((AND $N $O $P $V $W (OR $R $X (NOT $C)) (OR $Q $S (AND $T $U)) $Z $A) () True))))
!(assertEqual (applyOrTransformations (quote (($O $X $D) () ((AND $N $O $P (OR $R $X (NOT $C)) $V (OR (AND $T $U)) $W) (OR (AND $T $U)) False)))) (quote (($O $X $D) () ((AND $N $O $P $V $W (OR $R $X (NOT $C)) $T $U) () True))))
!(assertEqual (applyOrTransformations (quote (($A $D) () ((AND $N $O $P (OR $R $X (NOT $C)) $V (OR (AND $T $U (OR $X $Y) (OR $Z $B))) $W) (OR (AND $T $U (OR $X $Y) (OR $Z $B))) False)))) (quote (($A $D) () ((AND $N $O $P $V $W (OR $R $X (NOT $C)) $T $U (OR $X $Y) (OR $Z $B)) () True))))
!(assertEqual (applyOrTransformations (quote (($A $D) () ((AND $N $O $P (OR $R $X (NOT $C)) $V (OR (AND $T $U)) $W) (OR (AND $T $U)) False)))) (quote (($A $D) () ((AND $N $O $P $V $W (OR $R $X (NOT $C)) $T $U) () True))))
!(assertEqual (applyOrTransformations (quote (($A $D) () ((AND $N $O $P (OR $R $X (NOT $C)) $V (OR (AND $T $U (OR $X $Y) (OR $Z $B))) $W) (OR (AND $T $U (OR $X $Y) (OR $Z $B))) False)))) (quote (($A $D) () ((AND $N $O $P $V $W (OR $R $X (NOT $C)) $T $U (OR $X $Y) (OR $Z $B)) () True))))
!(assertEqual (applyOrTransformations (quote (($A $D) () ((AND $N $O $P (OR $R $X (NOT $C)) $V (OR (AND $T $U (OR $U $Y) (OR $U $B))) $W) (AND $T $U (OR $U $Y) (OR $U $B)) False)))) (quote (($A $D) () ((AND $N $O $P (OR $R $X (NOT $C)) $V (OR (AND $T $U (OR $U $Y) (OR $U $B))) $W) (AND $T $U (OR $U $Y) (OR $U $B)) False))))
!(assertEqual (applyOrTransformations (quote (() ($A $D) ((AND $N $O $P (OR $R $X (NOT $C)) $V (OR (AND $T $U (OR $U $Y) (OR $U $B))) $W) (OR (AND $T $U (OR $U $Y) (OR $U $B))) False)))) (quote (() ($A $D) ((AND $N $O $P $V $W (OR $R $X (NOT $C)) $T $U (OR $U $Y) (OR $U $B)) () True))))

!(assertEqual (applyOrTransformations (quote (() ()  ((AND $E (OR $A $B (AND $C $D))) (OR $A $B (AND $C $D)) False)))) (quote (() () ((AND $E (OR $A $B (AND $C $D))) (OR $A $B (AND $C $D)) False)))) ;; FIXED: Possisional mismatch semantically correct!! | Classic says this should be and(or(and($3 $4) $1 $2) $5)


;; Test for applyReduceToEleganceToAnd function

!(assertEqual (applyReduceToEleganceToAnd (quote (($E) () ((AND $A $B (OR $C $D (AND $E $F)) (OR $G $H) (OR $I)) (OR $C $D (AND $E $F)) False) (() ())))) (quote (($E) () ((AND $A $B (OR $C $D (AND $E $F)) (OR $G $H) (OR $I)) (OR $C $D (AND $E $F)) False) (() ()))))
!(assertEqual (applyReduceToEleganceToAnd (quote (() ($E $F) ((AND $A $B (OR $C $D (AND $E $F)) (OR $G $H) (OR $I)) (OR $C $D (AND $E $F)) False) (() ())))) (quote (() ($E $F) ((AND $A $B (OR $C $D (AND $E $F)) (OR $G $H) (OR $I)) (OR $C $D (AND $E $F)) False) (() ()))))
!(assertEqual (applyReduceToEleganceToAnd (quote (() ($J $K) ((AND $A $B (OR $C $D (AND $E $F)) (OR $G $H) (OR $I)) (OR $C $D (AND $E $F)) False) (() ())))) (quote (() ($J $K) ((AND $A $B (OR $C $D (AND $E $F)) (OR $G $H) (OR $I)) (OR $C $D (AND $E $F)) False) (() ()))))
!(assertEqual (applyReduceToEleganceToAnd (quote (() ($E $K) ((AND $A $B (OR $C $D (AND $E $F)) (OR $G $H) (OR $I)) (OR $C $D (AND $E $F)) False) (() ())))) (quote (() ($E $K) ((AND $A $B (OR $C $D (AND $E $F)) (OR $G $H) (OR $I)) (OR $C $D (AND $E $F)) False) (() ()))))
!(assertEqual (applyReduceToEleganceToAnd (quote (() ($F $J) ((AND $A $B (OR $C $D (AND $E $F)) (OR $G $H) (OR $I)) (OR $C $D (AND $E $F)) False) (() ())))) (quote (() ($F $J) ((AND $A $B (OR $C $D (AND $E $F)) (OR $G $H) (OR $I)) (OR $C $D (AND $E $F)) False) (() ()))))
!(assertEqual (applyReduceToEleganceToAnd (quote (() ((NOT $E) $F) ((AND $A $B (OR $C $D (AND $E $F)) (OR $G $H) (OR $I)) (OR $C $D (AND $E $F)) False) (() ())))) (quote (() ((NOT $E) $F) ((AND $A $B (OR $C $D (AND $E $F)) (OR $G $H) (OR $I)) (OR $C $D (AND $E $F)) False) (() ()))))
!(assertEqual (applyReduceToEleganceToAnd (quote (() ((NOT $E)) ((AND $A $B (OR $C $D (AND $E $F)) (OR $G $H) (OR $I)) (OR $C $D (AND $E $F)) False) (() ())))) (quote (() ((NOT $E)) ((AND $A $B (OR $C $D (AND $E $F)) (OR $G $H) (OR $I)) (OR $C $D (AND $E $F)) False) (() ()))))
!(assertEqual (applyReduceToEleganceToAnd (quote (() ((NOT $F) $J) ((AND $A $B (OR $C $D (AND $E $F)) (OR $G $H) (OR $I)) (OR $C $D (AND $E $F)) False) (() ())))) (quote (() ((NOT $F) $J) ((AND $A $B (OR $C $D (AND $E $F)) (OR $G $H) (OR $I)) (OR $C $D (AND $E $F)) False) (() ()))))
!(assertEqual (applyReduceToEleganceToAnd (quote (() ($F) ((AND $A $B (OR $C $D (AND $E $F)) (OR $G $H) (OR $I)) (OR $C $D (AND $E $F)) False) (() ())))) (quote (() ($F) ((AND $A $B (OR $C $D (AND $E $F)) (OR $G $H) (OR $I)) (OR $C $D (AND $E $F)) False) (() ()))))
!(assertEqual (applyReduceToEleganceToAnd (quote (($E) () ((OR $A $B (AND $C $D (OR $E $F)) (AND $G $H) (AND $I)) (AND $C $D (OR $E $F)) False) (() ())))) (quote (($E) () ((OR $A $B (AND $C $D (OR $E $F)) (AND $G $H) (AND $I)) (AND $C $D (OR $E $F)) False) (() ()))))
!(assertEqual (applyReduceToEleganceToAnd (quote (() ($E $F) ((OR $A $B (AND $C $D (OR $E $F)) (AND $G $H) (AND $I)) (AND $C $D (OR $E $F)) False) (() ())))) (quote (() ($E $F) ((OR $A $B (AND $C $D (OR $E $F)) (AND $G $H) (AND $I)) (AND $C $D (OR $E $F)) False) (() ()))))

;; Test for applyReduceToEleganceToOr function

!(assertEqual (applyReduceToEleganceToOr (quote (($E) () ((AND $A $B (OR $C $D (AND $E $F) (AND $K $L) (AND $M $J)) (OR $G $H) (OR $I)) (OR $C $D (AND $E $F) (AND $K $L) (AND $M $J)) False) ((AND $E $F) ((AND $K $L) (AND $M $J)))))) (quote (($E) () ((AND $A $B (OR $C $D (AND $F) (AND $K $L) (AND $M $J)) (OR $G $H) (OR $I)) (OR $C $D (AND $F) (AND $K $L) (AND $M $J)) True) ((AND $F) ((AND $K $L) (AND $M $J))))))
!(assertEqual (applyReduceToEleganceToOr (quote (() ((NOT $F)) ((AND $A $B (OR $C $D (AND $E $F) (AND $K $L) (AND $M $J)) (OR $G $H) (OR $I)) (OR $C $D (AND $E $F) (AND $K $L) (AND $M $J)) False) ((AND $E $F) ((AND $K $L) (AND $M $J)))))) (quote (() ((NOT $F)) ((AND $A $B (OR $C $D (AND $K $L) (AND $M $J)) (OR $G $H) (OR $I)) (OR $C $D (AND $K $L) (AND $M $J)) False) ((AND $K $L) ((AND $M $J)))))) ;;( (() ((NOT F)) ((AND A B (OR C D (AND K L) (AND M J)) (OR G H) (OR I)) (OR C D (AND K L) (AND M J)) False) ((AND K L) ((AND M J)))))
!(assertEqual (applyReduceToEleganceToOr (quote (() ($E) ((AND $A $B (OR $C $D (AND $E $F) (AND $K $L) (AND $M $J)) (OR $G $H) (OR $I)) (OR $C $D (AND $E $F) (AND $K $L) (AND $M $J)) False) ((AND $E $F) ((AND $K $L) (AND $M $J)))))) (quote (() ($E) ((AND $A $B (OR $C $D (AND $F) (AND $K $L) (AND $M $J)) (OR $G $H) (OR $I)) (OR $C $D (AND $F) (AND $K $L) (AND $M $J)) True) ((AND $F) ((AND $K $L) (AND $M $J))))))
!(assertEqual (applyReduceToEleganceToOr (quote (() ((NOT $E)) ((AND $A $B (OR $C $D (AND $E $F) (AND $K $L) (AND $M $J)) (OR $G $H) (OR $I)) (OR $C $D (AND $E $F) (AND $K $L) (AND $M $J)) False) ((AND $E $F) ((AND $K $L) (AND $M $J)))))) (quote (() ((NOT $E)) ((AND $A $B (OR $C $D (AND $K $L) (AND $M $J)) (OR $G $H) (OR $I)) (OR $C $D (AND $K $L) (AND $M $J)) False) ((AND $K $L) ((AND $M $J))))));;( (() ((NOT E)) ((AND A B (OR C D (AND K L) (AND M J)) (OR G H) (OR I)) (OR C D (AND K L) (AND M J)) False) ((AND K L) ((AND M J)))))
!(assertEqual (applyReduceToEleganceToOr (quote (($K) () ((AND $A $B (OR $C $D (AND $E $F) (AND $K $L) (AND $M $J)) (OR $G $H) (OR $I)) (OR $C $D (AND $E $F) (AND $K $L) (AND $M $J)) False) ((AND $K $L) ((AND $M $J)))))) (quote (($K) () ((AND $A $B (OR $C $D (AND $E $F) (AND $L) (AND $M $J)) (OR $G $H) (OR $I)) (OR $C $D (AND $E $F) (AND $L) (AND $M $J)) True) ((AND $E $F) ((AND $L) (AND $M $J))))))
!(assertEqual (applyReduceToEleganceToOr (quote (() ((NOT $L)) ((AND $A $B (OR $C $D (AND $E $F) (AND $K $L) (AND $M $J)) (OR $G $H) (OR $I)) (OR $C $D (AND $E $F) (AND $K $L) (AND $M $J)) False) ((AND $K $L) ((AND $M $J)))))) (quote (() ((NOT $L)) ((AND $A $B (OR $C $D (AND $E $F) (AND $M $J)) (OR $G $H) (OR $I)) (OR $C $D (AND $E $F) (AND $M $J)) False) ((AND $M $J) ()))));;(  (() ((NOT L)) ((AND A B (OR C D (AND E F) (AND M J)) (OR G H) (OR I)) (OR C D (AND E F) (AND M J)) False) ((AND M J) ())))
!(assertEqual (applyReduceToEleganceToOr (quote (($K $I) ($J) ((AND $A $B (OR $C $D (AND $E $F) (AND $K $L) (AND $M $J)) (OR $G $H) (OR $I)) (OR $C $D (AND $E $F) (AND $K $L) (AND $M $J)) False) ((AND $K $L) ((AND $M $J)))))) (quote (($K $I) ($J) ((AND $A $B (OR $C $D (AND $E $F) (AND $L) (AND $M $J)) (OR $G $H) (OR $I)) (OR $C $D (AND $E $F) (AND $L) (AND $M $J)) True) ((AND $E $F) ((AND $L) (AND $M $J))))))
!(assertEqual (applyReduceToEleganceToOr (quote (($K $M) () ((AND $A $B (OR $C $D (AND $E $F) (AND $K $L) (AND $M $J)) (OR $G $H) (OR $I)) (OR $C $D (AND $E $F) (AND $K $L) (AND $M $J)) False) ((AND $M $J) ())))) (quote (($K $M) () ((AND $A $B (OR $C $D (AND $E $F) (AND $K $L) (AND $J)) (OR $G $H) (OR $I)) (OR $C $D (AND $E $F) (AND $K $L) (AND $J)) True) ((AND $E $F) ((AND $K $L) (AND $J))))))
!(assertEqual (applyReduceToEleganceToOr (quote (($K $M) ((NOT $J)) ((AND $A $B (OR $C $D (AND $E $F) (AND $K $L) (AND $M $J)) (OR $G $H) (OR $I)) (OR $C $D (AND $E $F) (AND $K $L) (AND $M $J)) False) ((AND $M $J) ())))) (quote (($K $M) ((NOT $J)) ((AND $A $B (OR $C $D (AND $E $F) (AND $K $L)) (OR $G $H) (OR $I)) (OR $C $D (AND $E $F) (AND $K $L)) True) ((AND $E $F) ((AND $K $L))))));;( ((K M) ((NOT J)) ((AND A B (OR C D (AND E F) (AND K L)) (OR G H) (OR I)) (OR C D (AND E F) (AND K L)) True) ((AND E F) ((AND K L)))))
!(assertEqual (applyReduceToEleganceToOr (quote (($K $M) ((NOT $M)) ((AND $A $B (OR $C $D (AND $E $F) (AND $K $L) (AND $M $J)) (OR $G $H) (OR $I)) (OR $C $D (AND $E $F) (AND $K $L) (AND $M $J)) False) ((AND $M $J) ())))) (quote (($K $M) ((NOT $M)) ((AND $A $B (OR $C $D (AND $E $F) (AND $K $L) (AND $J)) (OR $G $H) (OR $I)) (OR $C $D (AND $E $F) (AND $K $L) (AND $J)) True) ((AND $E $F) ((AND $K $L) (AND $J))))))
!(assertEqual (applyReduceToEleganceToOr (quote (($K $M) ((NOT $M)) ((OR $A $B (AND $C $D (OR $E $F) (OR $K $L) (OR $M $J)) (AND $G $H) (AND $I)) (AND $C $D (OR $E $F) (OR $K $L) (OR $M $J)) False) ((OR $M $J) ())))) (quote (($K $M) ((NOT $M)) ((OR $A $B (AND $C $D (OR $E $F) (OR $K $L) (OR $M $J)) (AND $G $H) (AND $I)) (AND $C $D (OR $E $F) (OR $K $L) (OR $M $J)) False) (() ()))))
!(assertEqual (applyReduceToEleganceToOr (quote (($K $M) ((NOT $M)) ((OR $A $B (AND $C $D (OR $E $F) (OR $K $L) (OR $M $J)) (AND $G $H) (AND $I)) (AND $C $D (OR $E $F) (OR $K $L) (OR $M $J)) False) ((OR $M $J) ())))) (quote (($K $M) ((NOT $M)) ((OR $A $B (AND $C $D (OR $E $F) (OR $K $L) (OR $M $J)) (AND $G $H) (AND $I)) (AND $C $D (OR $E $F) (OR $K $L) (OR $M $J)) False) (() ()))))


;; Test for localCommandSet function

!(assertEqual (localCommandSet () () ($A $B $C) ($D)) ($A $B $C $D))
!(assertEqual (localCommandSet () () ($A $B $C) ()) ($A $B $C))
!(assertEqual (localCommandSet (quote (AND $I (OR $A $B))) (quote ((AND $A $B (OR $C $D)) (AND $E $F) (AND $G) (AND $H) (AND $I (OR $A $B)))) ($J $K $L) ($M)) ($J $K $L $G $H $M))
!(assertEqual (localCommandSet (quote (AND $E $F)) (quote ((AND $A $B (OR $C $D)) (AND $E $F) (AND $G) (AND $H) (AND $I (OR $A $B)))) ($J $K $L) ($M)) ($J $K $L $G $H $M))
!(assertEqual (localCommandSet (quote (AND $G)) (quote ((AND $A $B (OR $C $D)) (AND $E $F) (AND $G) (AND $H) (AND $I (OR $A $B)))) ($J $K $L) ($M)) ($J $K $L $H $M))
!(assertEqual (localCommandSet (quote (AND $I (OR $A $B))) (quote ((AND $A $B (OR $C $D)) (AND $E $F) (AND $G) (AND $H) (AND $I (OR $A $B)))) ($J $K $L) ($M)) ($J $K $L $G $H $M))
!(assertEqual (localCommandSet (quote (OR $I (AND $A $B))) (quote ((OR $A $B (AND $C $D)) (OR $E $F) (OR $G) (OR $H) (OR $I (AND $A $B)))) ($J $K $L) ($M)) ($J $K $L $M))
!(assertEqual (localCommandSet (quote (OR $E $F)) (quote ((OR $A $B (AND  $C $D)) (OR $E $F) (OR $G) (OR $H) (OR $I (AND $A $B)))) ($J $K $L) ($M)) ($J $K $L $M))
!(assertEqual (localCommandSet (quote (OR $G)) (quote ((OR $A $B (AND $C $D)) (OR $E $F) (OR $G) (OR $H) (OR $I (AND $A $B)))) ($J $K $L) ($M)) ($J $K $L $M))
!(assertEqual (localCommandSet (quote (OR $I (AND $A $B))) (quote ((OR $A $B (AND $C $D)) (OR $E $F) (OR $G) (OR $H) (OR $I (AND $A $B)))) ($J $K $L) ($M)) ($J $K $L $M))



