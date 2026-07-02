!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/tree)

!(import! &self ../cacheSpace)
!(import! &self ../fitness)
!(import! &self ../bscore)

;; Columnar subtree evaluation (scoring/fitness.metta).
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

;; --- reduceColumns: elementwise reduce of a column list with a boolean op ---
!(assertEqual (reduceColumns and (True True) ((False True))) (False True))
!(assertEqual (reduceColumns or  (True True) ((False True))) (True True))
;; n-ary: reduce across three columns
!(assertEqual (reduceColumns and (True True) ((True True) (False True))) (False True))

;; --- combineSubtrees: n-ary fold with identity, and NOT on single child ---
!(assertEqual (combineSubtrees AND ((True True) (False True)) 2) (False True))
!(assertEqual (combineSubtrees OR  ((True True) (False True)) 2) (True True))
!(assertEqual (combineSubtrees NOT ((False True)) 2) (True False))
;; empty AND / OR fall back to the identity column (preOrder may filter to empty)
!(assertEqual (combineSubtrees AND () 2) (True True))
!(assertEqual (combineSubtrees OR  () 2) (False False))

;; --- evalSubtree end-to-end on canonical expressions ---
;; (AND A B) over the reference table: and((T T),(F T)) = (F T)
!(assertEqual
   (evalSubtree (AND A B) (mkITable ((True False False) (True True True)) (A B O)) 2)
   (False True))
;; (OR A B) = (T T) ; (NOT B) = (T F) ; bare leaf A = (T T)
!(assertEqual
   (evalSubtree (OR A B) (mkITable ((True False False) (True True True)) (A B O)) 2)
   (True True))
!(assertEqual
   (evalSubtree (NOT B) (mkITable ((True False False) (True True True)) (A B O)) 2)
   (True False))
!(assertEqual
   (evalSubtree A (mkITable ((True False False) (True True True)) (A B O)) 2)
   (True True))

;; --- memoization: after evaluating (AND A B), the column is cached in &subtreeCache ---
!(assertEqual
   (let $_ (evalSubtree (AND A B) (mkITable ((True False False) (True True True)) (A B O)) 2)
        (collapse (match &subtreeCache (subtree (AND A B) $v) $v)))
   ((False True)))

;; --- equivalence with the whole-tree scorer (same contract as bscore-test) ---
;; (OR A B): outputs (False True) -> compareAndScore -> (-1 0)
!(assertEqual
   (scoreTree (mkITable ((True False False) (True True True)) (A B O))
              (buildTree (OR A B)) &bscoreCache)
   (mkBScore (-1 0)))
