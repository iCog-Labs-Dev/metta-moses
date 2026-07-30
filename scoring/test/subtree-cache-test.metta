!(import! &self ../../utilities/general-helpers)
;; ENTRY-FILE REQUIREMENT: scoring/fitness publishes the run's table through the
;; parameter registry, so a scoring entry file must bind &params and load the
;; registry first, else evalTree silently yields zero solutions.
!(bind! &params (new-space))
!(import! &self ../../parameters/registry)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/tree)

!(import! &self ../cacheSpace)
!(import! &self ../fitness)
!(import! &self ../boolean-ops)
!(import! &self ../bscore)

;; Columnar subtree evaluation over the candidate Tree ADT:
;;   node   = (mkTree (mkNode AND) (c1 .. ck)) / (mkNode OR ..) / (mkNode NOT ..)
;;   leaf   = (mkTree (mkNode <label>) ()), or a True/False constant node
;; evalTree (fitness.metta) compiles the Tree into a materialized column term
;; (rewriteTree) and walks it (evalSubtree); operator semantics live solely in
;; the AND/OR/NOT clauses (boolean-ops.metta), which the walk reduce-dispatches.
;; This file imports boolean-ops, so every bare (AND ..)/(OR ..)/(NOT ..) DATA
;; literal below is quote-guarded rather than firing the clause.
;;
;; Reference table: two rows, labels (A B O); O is the (ignored) output column.
;;   row0 = (True False False)   -> A=True,  B=False
;;   row1 = (True True  True )   -> A=True,  B=True

;; --- varColumn: extract a variable's column (one bool per row) ---
!(assertEqual
   (varColumn (mkITable ((True False False) (True True True)) (A B O)) A)
   (True True))
!(assertEqual
   (varColumn (mkITable ((True False False) (True True True)) (A B O)) B)
   (False True))

;; --- operator clauses: the single source of AND/OR/NOT semantics ---
;; (these replace the old combineSubtrees/reduceColumns unit asserts). n-ary
;; AND/OR ride in as one Expression argument; empties give the identities.
!(assertEqual (AND (True True))                     True)
!(assertEqual (AND (True False))                    False)
!(assertEqual (AND (True True True True))           True)   ;; n-ary, one clause
!(assertEqual (AND ())                              True)   ;; empty AND identity
!(assertEqual (OR  (False True))                    True)
!(assertEqual (OR  (False False))                   False)
!(assertEqual (OR  ())                              False)  ;; empty OR identity
!(assertEqual (NOT (True))                          False)
!(assertEqual (NOT (False))                         True)

;; --- evalTree end-to-end on candidate Trees (column-level dispatch) ---
;; AND[A B] over the reference table: and((T T),(F T)) = (F T)
!(assertEqual
   (evalTree (buildTree (quote (AND A B)))
             (mkITable ((True False False) (True True True)) (A B O)) 2)
   (False True))
;; OR[A B] = (T T)
!(assertEqual
   (evalTree (buildTree (quote (OR A B)))
             (mkITable ((True False False) (True True True)) (A B O)) 2)
   (True True))
;; NOT[B] = (T F)
!(assertEqual
   (evalTree (buildTree (quote (NOT B)))
             (mkITable ((True False False) (True True True)) (A B O)) 2)
   (True False))
;; bare leaf A = (T T)
!(assertEqual
   (evalTree (buildTree (quote A))
             (mkITable ((True False False) (True True True)) (A B O)) 2)
   (True True))
;; childless AND / OR -> identity column repeated over the n rows
!(assertEqual
   (evalTree (buildTree (quote (AND)))
             (mkITable ((True False False) (True True True)) (A B O)) 2)
   (True True))
!(assertEqual
   (evalTree (buildTree (quote (OR)))
             (mkITable ((True False False) (True True True)) (A B O)) 2)
   (False False))
;; nested: AND[ OR[A B]  NOT[B] ] = and((T T),(T F)) = (T F)
!(assertEqual
   (evalTree (buildTree (quote (AND (OR A B) (NOT B))))
             (mkITable ((True False False) (True True True)) (A B O)) 2)
   (True False))

;; --- sub-term reuse across evaluations --------------------------------------
;; A sub-formula's column is computed once and REUSED -- both by a larger
;; candidate containing it and by a later re-evaluation of the same candidate.
;; Asserted as the OBSERVABLE property rather than by inspecting the memo, so it
;; holds on runtimes with and without lib_memo (is-memoized / get-memoize-stats
;; are lib_memo builtins and stay unreduced elsewhere -- see the diagnostic).
;;
;; $shared = AND[A B] is evaluated three ways in one let*: standalone, as the
;; left child of OR[ AND[A B]  NOT[B] ] (the sharing case -- rewriteTree
;; compiles both to the SAME (zipWith AND (col A) (col B)) sub-term, which is
;; the memo key), and standalone again. A stale or cross-contaminated entry
;; shows up as a wrong column here.
;;   AND[A B] = (False True);  NOT[B] = (True False)
;;   OR[AND[A B] NOT[B]] = or((F T),(T F)) = (True True)
!(assertEqual
   (let* (($t      (mkITable ((True False False) (True True True)) (A B O)))
          ($shared (buildTree (quote (AND A B))))
          ;; raw ADT: buildTree takes a flat expr, so it cannot embed $shared itself
          ($outer  (mkTree (mkNode OR) (cons $shared (cons (buildTree (quote (NOT B))) ()))))
          ($first  (evalTree $shared $t 2))
          ($inLarger (evalTree $outer $t 2))
          ($repeat (evalTree $shared $t 2)))
     ($first $inLarger $repeat))
   ((False True) (True True) (False True)))

;; DIAGNOSTIC, not an assertion: with lib_memo this reports that evalSubtree/1
;; is memoized and prints the counters the asserts above accumulated; without
;; it both heads stay unreduced and print as themselves. No ✅/❌ either way.
!(println! (memo-diagnostic (is-memoized evalSubtree 1) (get-memoize-stats)))

;; --- equivalence with the whole-tree scorer (same contract as bscore-test) ---
;; (OR A B): outputs (False True) -> compareAndScore -> (-1 0)
!(assertEqual
   (scoreTree (mkITable ((True False False) (True True True)) (A B O))
              (buildTree (quote (OR A B))) &bscoreCache)
   (mkBScore (-1 0)))
