!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/tree)
!(import! &self ../fitness)
!(import! &self ../boolean-ops)
!(import! &self ../bscore)

;; Test helper: score one row through the PRODUCTION path — buildTree turns
;; the raw test expression into a Tree, candTemplate builds the
;; labels->fresh-var template, evalParsed unifies the row and evals.
;;
;; Candidate expressions are passed under `quote`: this file imports
;; boolean-ops, so a bare (NOT A) / (AND ...) at a call site would
;; compile as a call into the eval clauses instead of flowing in as
;; data.
(= (callBE $labels $row $cand)
   (evalParsed (candTemplate $labels (buildTree $cand)) $row))

;; ---- AND / OR (wrapped-list, single arity-1 clause = n-ary) ----
;; These are intentional direct calls into the eval clauses.
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

;; ---- boolEval end-to-end (single-row evaluation) via callBE ----
;; Unary NOT.
!(assertEqual (callBE (cons A ()) (cons True ())  (quote (NOT A))) False)
!(assertEqual (callBE (cons A ()) (cons False ()) (quote (NOT A))) True)

;; Binary AND / OR truth-table coverage.
!(assertEqual (callBE (cons A (cons B ())) (cons True  (cons True  ())) (quote (AND A B))) True)
!(assertEqual (callBE (cons A (cons B ())) (cons True  (cons False ())) (quote (AND A B))) False)
!(assertEqual (callBE (cons A (cons B ())) (cons False (cons False ())) (quote (OR A B)))  False)
!(assertEqual (callBE (cons A (cons B ())) (cons False (cons True  ())) (quote (OR A B)))  True)

;; Three-label nested case.
!(assertEqual (callBE (cons A (cons B (cons C ())))
                      (cons True (cons False (cons False ())))
                      (quote (AND (OR A B) (NOT C))))
              True)
!(assertEqual (callBE (cons A (cons B (cons C ())))
                      (cons False (cons False (cons False ())))
                      (quote (AND (OR A B) (NOT C))))
              False)
!(assertEqual (callBE (cons A (cons B (cons C ())))
                      (cons True (cons True (cons True ())))
                      (quote (AND (OR A B) (NOT C))))
              False)

;; N-ary on a real candidate shape -- 4 children, one clause handles it.
!(assertEqual (callBE (cons A (cons B (cons C (cons D ()))))
                      (cons True (cons True (cons True (cons True ()))))
                      (quote (AND A B C D)))
              True)
!(assertEqual (callBE (cons A (cons B (cons C (cons D ()))))
                      (cons True (cons True (cons False (cons True ()))))
                      (quote (AND A B C D)))
              False)

;; Per-row freshness: same candidate, four different rows in sequence.
!(assertEqual (callBE (cons A (cons B ())) (cons True  (cons True  ())) (quote (AND A B))) True)
!(assertEqual (callBE (cons A (cons B ())) (cons True  (cons False ())) (quote (AND A B))) False)
!(assertEqual (callBE (cons A (cons B ())) (cons False (cons True  ())) (quote (AND A B))) False)
!(assertEqual (callBE (cons A (cons B ())) (cons False (cons False ())) (quote (AND A B))) False)

;; Repeated label (one var, both leaves bind to it).
!(assertEqual (callBE (cons A ()) (cons True  ()) (quote (AND A A))) True)
!(assertEqual (callBE (cons A ()) (cons False ()) (quote (AND A A))) False)

;; ---- Parity with the legacy `evaluate` path ----
;; The candidate expression is let-bound from a quote: quoting the whole
;; (labels expr) pair at the call site interacts badly with the clause-head
;; destructure (partial substitution observed); binding the expr first and
;; building the pair around the bound var arrives intact.
!(let $expr (quote (OR (AND A (NOT B)) C))
   (assertEqual
     (callBE (cons A (cons B (cons C ())))
             (cons True (cons False (cons True ())))
             $expr)
     (evaluate (replaceVarsWithTruth ((cons A (cons B (cons C ()))) $expr)
                                     (cons True (cons False (cons True ())))))))
!(let $expr (quote (AND (OR A B) (OR C D)))
   (assertEqual
     (callBE (cons A (cons B (cons C (cons D ()))))
             (cons False (cons True (cons False (cons True ()))))
             $expr)
     (evaluate (replaceVarsWithTruth ((cons A (cons B (cons C (cons D ())))) $expr)
                                     (cons False (cons True (cons False (cons True ()))))))))
