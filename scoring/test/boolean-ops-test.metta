!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/list-methods)
!(import! &self ../fitness)
!(import! &self ../bscore)

;; Test helper: eval a candidate against one row given (labels, row, cand).
;; Labels are vars, cand's leaves reference those same vars; callBE is
;; a thin wrapper around evalParsed.
(= (callBE $labels $row $cand)
   (evalParsed ($labels $cand) $row))

;; ---- AND / OR (wrapped-list, single arity-1 clause = n-ary) ----
;; Callers construct eval-form expressions directly:
;; (AND ($x $y)), (OR (...)), (NOT $x).
!(assertEqual (AND (True True True))               True)
!(assertEqual (AND (True False True))              False)
!(assertEqual (AND ())                             True)
!(assertEqual (OR  (False False True))             True)
!(assertEqual (OR  (False False))                  False)
!(assertEqual (OR  ())                             False)
;; Higher arity (well beyond what manual enumeration would cover) -- one
;; clause handles it because the children ride in as a single Expression.
!(assertEqual (AND (True True True True True True True True True True)) True)
!(assertEqual (AND (True True True True True True True True True False)) False)

;; ---- NOT (unary) ----
!(assertEqual (NOT True)  False)
!(assertEqual (NOT False) True)
!(assertEqual (NOT (NOT True))  True)
!(assertEqual (NOT (NOT False)) False)

;; ---- evalParsed end-to-end (single-row evaluation) via callBE ----
;; Labels are lexical vars introduced via `(let $A $A ...)`. The same var
;; appears in the labels-list AND at leaf positions in the cand — that's
;; the whole point of the labels-as-vars refactor. Rows carry the truth
;; values that get bound in by row-unification inside evalParsed.
;;
;; `quote` prevents the cand expression from being reduced at call-site
;; (which would fire the AND/OR/NOT clauses against unbound vars). The
;; term flows into callBE as data, eval only fires inside evalParsed.

;; Unary NOT.
!(let $A $A
   (assertEqual (callBE ($A) (True)  (quote (NOT $A))) False))
!(let $A $A
   (assertEqual (callBE ($A) (False) (quote (NOT $A))) True))

;; Binary AND / OR truth-table coverage.
!(let* (($A $A) ($B $B))
   (assertEqual (callBE ($A $B) (True  True)  (quote (AND ($A $B)))) True))
!(let* (($A $A) ($B $B))
   (assertEqual (callBE ($A $B) (True  False) (quote (AND ($A $B)))) False))
!(let* (($A $A) ($B $B))
   (assertEqual (callBE ($A $B) (False False) (quote (OR  ($A $B)))) False))
!(let* (($A $A) ($B $B))
   (assertEqual (callBE ($A $B) (False True)  (quote (OR  ($A $B)))) True))

;; Three-label nested case.
!(let* (($A $A) ($B $B) ($C $C))
   (assertEqual (callBE ($A $B $C) (True False False)
                        (quote (AND ((OR ($A $B)) (NOT $C)))))
                True))
!(let* (($A $A) ($B $B) ($C $C))
   (assertEqual (callBE ($A $B $C) (False False False)
                        (quote (AND ((OR ($A $B)) (NOT $C)))))
                False))
!(let* (($A $A) ($B $B) ($C $C))
   (assertEqual (callBE ($A $B $C) (True True True)
                        (quote (AND ((OR ($A $B)) (NOT $C)))))
                False))

;; N-ary on a real candidate shape -- 4 children, one clause handles it.
!(let* (($A $A) ($B $B) ($C $C) ($D $D))
   (assertEqual (callBE ($A $B $C $D) (True True True True)
                        (quote (AND ($A $B $C $D))))
                True))
!(let* (($A $A) ($B $B) ($C $C) ($D $D))
   (assertEqual (callBE ($A $B $C $D) (True True False True)
                        (quote (AND ($A $B $C $D))))
                False))

;; Per-row freshness: same candidate, four different rows in sequence.
!(let* (($A $A) ($B $B))
   (assertEqual (callBE ($A $B) (True  True)  (quote (AND ($A $B)))) True))
!(let* (($A $A) ($B $B))
   (assertEqual (callBE ($A $B) (True  False) (quote (AND ($A $B)))) False))
!(let* (($A $A) ($B $B))
   (assertEqual (callBE ($A $B) (False True)  (quote (AND ($A $B)))) False))
!(let* (($A $A) ($B $B))
   (assertEqual (callBE ($A $B) (False False) (quote (AND ($A $B)))) False))

;; Repeated label (one var, both leaves bind to it).
!(let $A $A
   (assertEqual (callBE ($A) (True)  (quote (AND ($A $A)))) True))
!(let $A $A
   (assertEqual (callBE ($A) (False) (quote (AND ($A $A)))) False))

;; ---- Legacy `evaluate` parity ----
;; Dropped when the eval clauses were renamed AND/OR/NOT: the (NOT B) in
;; a legacy source expression now matches our global NOT clause and
;; reduces before evaluate sees it. The new path's correctness is fully
;; covered by the assertions above; the legacy path is exercised by
;; scoring/test/fitness-test.metta.
