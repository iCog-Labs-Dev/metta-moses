!(import! &self ../../utilities/general-helpers)
;; scoring/fitness publishes the table through the parameter registry, so bind
;; &params and import the registry before it.
!(bind! &params (new-space))
!(import! &self ../../parameters/registry)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/tree)

!(import! &self ../cacheSpace)
!(import! &self ../fitness)
!(import! &self ../boolean-ops)
!(import! &self ../bscore)

;; Columnar evaluation of a candidate Tree: evalTree (fitness.metta) compiles
;; the Tree into a column term (rewriteTree) and walks it with the memoized
;; evalSubtree. Operator semantics live solely in the AND/OR/NOT clauses
;; (boolean-ops.metta). Because this file imports boolean-ops, every bare
;; (AND ...)/(OR ...)/(NOT ...) DATA literal below is quote-guarded so it flows
;; in as data instead of firing the clause.
;;
;; Reference table: two rows, labels (A B O); O is the (ignored) output column.
;;   row0 = (True False False)   -> A=True,  B=False
;;   row1 = (True True  True )   -> A=True,  B=True
;; The ITable payload is COLUMN-major -- one sublist per label -- so the same
;; table is written ((True True) (False True) (False True)).

;; --- varColumn: extract a variable's column (one bool per row) ---
!(assertEqual
   (varColumn (mkITable ((True True)
                         (False True)
                         (False True)) (A B O)) A)
   (True True))
!(assertEqual
   (varColumn (mkITable ((True True)
                         (False True)
                         (False True)) (A B O)) B)
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
;; (AND (A B)) over the reference table: and((T T),(F T)) = (F T)
!(assertEqual
   (evalTree (buildTree (quote (AND A B))) (mkITable ((True True)
                                               (False True)
                                               (False True)) (A B O)))
   (False True))
;; (OR (A B)) = (T T)
!(assertEqual
   (evalTree (buildTree (quote (OR A B))) (mkITable ((True True)
                                              (False True)
                                              (False True)) (A B O)))
   (True True))
;; (NOT (B)) = (T F)
!(assertEqual
   (evalTree (buildTree (quote (NOT B))) (mkITable ((True True)
                                             (False True)
                                             (False True)) (A B O)))
   (True False))
;; bare leaf A = (T T)
!(assertEqual
   (evalTree (buildTree (quote A)) (mkITable ((True True)
                             (False True)
                             (False True)) (A B O)))
   (True True))
;; childless AND / OR -> identity column repeated over the n rows
!(assertEqual
   (evalTree (buildTree (quote (AND))) (mkITable ((True True)
                                            (False True)
                                            (False True)) (A B O)))
   (True True))
!(assertEqual
   (evalTree (buildTree (quote (OR))) (mkITable ((True True)
                                           (False True)
                                           (False True)) (A B O)))
   (False False))
;; nested: (AND ((OR (A B)) (NOT (B)))) = and((T T),(T F)) = (T F)
!(assertEqual
   (evalTree (buildTree (quote (AND (OR A B) (NOT B)))) (mkITable ((True True)
                                                                (False True)
                                                                (False True)) (A B O)))
   (True False))

;; --- memoization: after evalTree scores AND[A B], the memo holds its column
;; under the compiled sub-term. A later evalSubtree of that term is ONE memo hit
;; and no miss: a hit returns the stored column and does not walk the children.
;; The quoted key MUST be let-bound: col/zipWithN are live heads here. ---
!(assertEqual
   (let* (($_ (evalTree (buildTree (quote (AND A B)))
                        (mkITable ((True True)
                                   (False True)
                                   (False True)) (A B O))))
          ($k (quote (zipWithN AND ((col A) (col B)))))
          ($_2 (clear-memoize-stats))
          ($v (evalSubtree $k)))
        ($v (get-memoize-stats)))
   ((False True) ((cache_hit 1))))

;; --- equivalence with the whole-tree scorer (same contract as bscore-test) ---
;; (OR A B): outputs (False True) -> compareAndScore -> (-1 0)
!(assertEqual
   (scoreTree (mkITable ((True True)
                         (False True)
                         (False True)) (A B O))
              (buildTree (quote (OR A B))) &bscoreCache)
   (mkBScore (-1 0)))
;; An op with no clause (FOO) stays unreduced in its cells. AND treats such a
;; cell as not False, so AND[A FOO[B]] = A = (T T) and scores (-1 0), as the
;; old per-row engine scored it. A zero-solution result here drops the
;; candidate from the deme with no error.
!(assertEqual
   (scoreTree (mkITable ((True True)
                         (False True)
                         (False True)) (A B O))
              (buildTree (quote (AND A (FOO B)))) &bscoreCache)
   (mkBScore (-1 0)))

;; --- compile shape, single solutions, memo reset on a table change ---
;; An n-ary monoid folds into nested binary terms; TRUE compiles to its Bool.
!(let* (($cand (quote (AND A B C D)))
        ($exp (quote (zipWithN AND ((col A) (zipWithN AND ((col B) (zipWithN AND ((col C) (col D))))))))))
   (assertEqual (rewriteTree (buildTree $cand)) $exp))
!(let* (($cand (quote (OR A TRUE))) ($exp (quote (zipWithN OR ((col A) True)))))
   (assertEqual (rewriteTree (buildTree $cand)) $exp))
;; A constant broadcasts over the rows: OR[A TRUE] is True on every row.
!(assertEqual
   (evalTree (buildTree (quote (OR A TRUE)))
             (mkITable ((True True) (False True) (False True)) (A B O)))
   (True True))
;; One solution each from the compiler and from the walk.
!(assertEqual
   (size-atom (collapse (rewriteTree (buildTree (quote (OR (AND A B) (NOT B)))))))
   1)
!(assertEqual
   (size-atom (collapse (evalTree (buildTree (quote (OR (AND A B) (NOT B))))
                                  (mkITable ((True True) (False True) (False True)) (A B O)))))
   1)
;; lib_memo does not see a table change. evalTree must empty the memo, or the
;; second table gets the first table's cached AND[A B] column (False True).
;;   table 1: A=(T T) B=(F T) -> (F T);  table 2: A=(T F) B=(T T) -> (T F)
!(assertEqual
   (let* (($tree (buildTree (quote (AND A B))))
          ($t1 (mkITable ((True True) (False True) (False True)) (A B O)))
          ($t2 (mkITable ((True False) (True True) (False True)) (A B O)))
          ($first (evalTree $tree $t1))
          ($second (evalTree $tree $t2))
          ($back (evalTree $tree $t1)))
     ($first $second $back))
   ((False True) (True False) (False True)))
