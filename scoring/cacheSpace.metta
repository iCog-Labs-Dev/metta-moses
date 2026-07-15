!(bind! &treeSpace (new-space))
;; Retained only for signature compatibility: scoreTree still accepts a cache
;; space argument, but scoring is now memoized entirely in &subtreeCache below.
;; &bscoreCache is no longer read or written.
!(bind! &bscoreCache (new-space))
;; Subtree-level (columnar) score cache: (subtree <canonicalExpr> <bool-vector>)
;; entries for operator nodes AND label leaves, plus one (outputsCol <vector>)
;; entry for the table's output column. Keyed by the symbolic expression
;; (variables intact, never replaced with row truth values), so identical
;; subtrees across candidates share an entry. Every subtree — including each
;; tree's root — is memoized here, making this the sole score memo. Persists
;; for the whole run (a run scores one fixed table); it is NOT cleared per
;; generation, mirroring the old &bscoreCache lifetime.
!(bind! &subtreeCache (new-space))

;; Empty the subtree cache. A run scores ONE fixed table, and every entry
;; (subtree columns, leaf columns, outputsCol) is valid only for that table --
;; call this before scoring against a DIFFERENT table in the same process
;; (e.g. a test file exercising two tables, or a future multi-problem driver).
(= (resetSubtreeCache)
   (let $entries (collapse (match &subtreeCache $e $e))
     (map-atom $entries $e (remove-atom &subtreeCache $e))))
