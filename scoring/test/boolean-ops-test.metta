!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/list-methods)
!(import! &self ../fitness)
!(import! &self ../bscore)

;; Test helper: scoreTree now hands boolEval pre-built strings. Callers in
;; this test still want to think in (labels, row, tree) triples, so wrap
;; the string serialization here to keep the assertions readable.
(= (callBE $labels $row $cand)
   (boolEval (labels-vstr $labels) $row (tree-vstr $cand)))

;; ---- And / Or (wrapped-list, single arity-1 clause = n-ary) ----
;; (CapFirst names: the reduct keeps AND/OR/NOT; tree-vstr rewrites
;;  AND->And etc. while emitting the parseable string.)
!(assertEqual (And (True True True))               True)
!(assertEqual (And (True False True))              False)
!(assertEqual (And ())                             True)
!(assertEqual (Or  (False False True))             True)
!(assertEqual (Or  (False False))                  False)
!(assertEqual (Or  ())                             False)
;; Higher arity (well beyond what manual enumeration would cover) -- one
;; clause handles it because the children ride in as a single Expression.
!(assertEqual (And (True True True True True True True True True True)) True)
!(assertEqual (And (True True True True True True True True True False)) False)

;; ---- Not (unary) ----
!(assertEqual (Not True)  False)
!(assertEqual (Not False) True)
!(assertEqual (Not (Not True))  True)
!(assertEqual (Not (Not False)) False)

;; ---- boolEval end-to-end (single-row evaluation) via callBE ----
;; Unary NOT.
!(assertEqual (callBE (cons A ()) (cons True ())  (NOT A)) False)
!(assertEqual (callBE (cons A ()) (cons False ()) (NOT A)) True)

;; Binary AND / OR truth-table coverage.
!(assertEqual (callBE (cons A (cons B ())) (cons True  (cons True  ())) (AND A B)) True)
!(assertEqual (callBE (cons A (cons B ())) (cons True  (cons False ())) (AND A B)) False)
!(assertEqual (callBE (cons A (cons B ())) (cons False (cons False ())) (OR A B))  False)
!(assertEqual (callBE (cons A (cons B ())) (cons False (cons True  ())) (OR A B))  True)

;; Three-label nested case.
!(assertEqual (callBE (cons A (cons B (cons C ())))
                      (cons True (cons False (cons False ())))
                      (AND (OR A B) (NOT C)))
              True)
!(assertEqual (callBE (cons A (cons B (cons C ())))
                      (cons False (cons False (cons False ())))
                      (AND (OR A B) (NOT C)))
              False)
!(assertEqual (callBE (cons A (cons B (cons C ())))
                      (cons True (cons True (cons True ())))
                      (AND (OR A B) (NOT C)))
              False)

;; N-ary on a real candidate shape -- 4 children, one clause handles it.
!(assertEqual (callBE (cons A (cons B (cons C (cons D ()))))
                      (cons True (cons True (cons True (cons True ()))))
                      (AND A B C D))
              True)
!(assertEqual (callBE (cons A (cons B (cons C (cons D ()))))
                      (cons True (cons True (cons False (cons True ()))))
                      (AND A B C D))
              False)

;; Per-row freshness: same candidate, four different rows in sequence.
!(assertEqual (callBE (cons A (cons B ())) (cons True  (cons True  ())) (AND A B)) True)
!(assertEqual (callBE (cons A (cons B ())) (cons True  (cons False ())) (AND A B)) False)
!(assertEqual (callBE (cons A (cons B ())) (cons False (cons True  ())) (AND A B)) False)
!(assertEqual (callBE (cons A (cons B ())) (cons False (cons False ())) (AND A B)) False)

;; Repeated label (one var, both leaves bind to it).
!(assertEqual (callBE (cons A ()) (cons True  ()) (AND A A)) True)
!(assertEqual (callBE (cons A ()) (cons False ()) (AND A A)) False)

;; ---- Parity with the legacy `evaluate` path ----
!(assertEqual
   (callBE (cons A (cons B (cons C ())))
           (cons True (cons False (cons True ())))
           (OR (AND A (NOT B)) C))
   (evaluate (replaceVarsWithTruth ((cons A (cons B (cons C ()))) (OR (AND A (NOT B)) C))
                                   (cons True (cons False (cons True ()))))))
!(assertEqual
   (callBE (cons A (cons B (cons C (cons D ()))))
           (cons False (cons True (cons False (cons True ()))))
           (AND (OR A B) (OR C D)))
   (evaluate (replaceVarsWithTruth ((cons A (cons B (cons C (cons D ())))) (AND (OR A B) (OR C D)))
                                   (cons False (cons True (cons False (cons True ())))))))
