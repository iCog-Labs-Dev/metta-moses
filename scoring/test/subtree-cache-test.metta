!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/tree)

!(import! &self ../cacheSpace)
!(import! &self ../fitness)
!(import! &self ../boolean-ops)
!(import! &self ../bscore)

;; Columnar subtree evaluation over the WRAPPED eval shape (preOrderExp):
;;   node   = (AND (k1 .. kk)) / (OR (k1 .. kk)) / (NOT k)
;;   leaf   = a bare label symbol, or a grounded True/False constant
;; Operator semantics live solely in the AND/OR/NOT clauses (boolean-ops.metta);
;; evalSubtree reduce-dispatches them per row. Because this file imports
;; boolean-ops, every bare (AND ...)/(OR ...)/(NOT ...) DATA literal below is
;; quote-guarded so it flows in as data instead of firing the clause.
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

;; --- evalSubtree end-to-end on WRAPPED shapes (column-level dispatch) ---
;; (AND (A B)) over the reference table: and((T T),(F T)) = (F T)
!(assertEqual
   (evalSubtree (quote (AND (A B))) (mkITable ((True True)
                                               (False True)
                                               (False True)) (A B O)) 2)
   (False True))
;; (OR (A B)) = (T T)
!(assertEqual
   (evalSubtree (quote (OR (A B))) (mkITable ((True True)
                                              (False True)
                                              (False True)) (A B O)) 2)
   (True True))
;; (NOT (B)) = (T F)
!(assertEqual
   (evalSubtree (quote (NOT (B))) (mkITable ((True True)
                                             (False True)
                                             (False True)) (A B O)) 2)
   (True False))
;; bare leaf A = (T T)
!(assertEqual
   (evalSubtree A (mkITable ((True True)
                             (False True)
                             (False True)) (A B O)) 2)
   (True True))
;; empty AND / OR -> identity column repeated over the n rows
!(assertEqual
   (evalSubtree (quote (AND ())) (mkITable ((True True)
                                            (False True)
                                            (False True)) (A B O)) 2)
   (True True))
!(assertEqual
   (evalSubtree (quote (OR ())) (mkITable ((True True)
                                           (False True)
                                           (False True)) (A B O)) 2)
   (False False))
;; nested: (AND ((OR (A B)) (NOT (B)))) = and((T T),(T F)) = (T F)
!(assertEqual
   (evalSubtree (quote (AND ((OR (A B)) (NOT (B))))) (mkITable ((True True)
                                                                (False True)
                                                                (False True)) (A B O)) 2)
   (True False))

;; --- memoization: after evaluating (AND (A B)) its column is cached in
;; &subtreeCache keyed by the WRAPPED expr. The quoted key MUST be let-bound
;; before the match: `match` does not evaluate its pattern, so a (quote ...)
;; written inline in the pattern would stay literal and never match the stored
;; plain key. ---
!(assertEqual
   (let* (($_ (evalSubtree (quote (AND (A B))) (mkITable ((True True)
                                                          (False True)
                                                          (False True)) (A B O)) 2))
          ($k (quote (AND (A B)))))
        (collapse (match &subtreeCache (subtree $k $v) $v)))
   ((False True)))

;; --- equivalence with the whole-tree scorer (same contract as bscore-test) ---
;; (OR A B): outputs (False True) -> compareAndScore -> (-1 0)
!(assertEqual
   (scoreTree (mkITable ((True True)
                         (False True)
                         (False True)) (A B O))
              (buildTree (quote (OR A B))) &bscoreCache)
   (mkBScore (-1 0)))
