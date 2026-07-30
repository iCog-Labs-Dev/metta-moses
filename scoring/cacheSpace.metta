;; lib_memo must be imported HERE, not merely by scoring/fitness.metta: this
;; file loads BEFORE fitness in every import chain, and a call to a not-yet-
;; imported function compiles as inert DATA, so resetSubtreeCache's
;; `invalidate-memoize` would silently never fire. A runtime without lib_memo
;; either no-ops the import (leaving the call harmlessly unreduced) or refuses
;; it outright -- there is no runtime-independent guarantee here.
!(import! &self (library lib_memo))

!(bind! &treeSpace (new-space))
;; Retained only for signature compatibility: scoreTree still accepts a cache
;; space argument, but scoring is now memoized through lib_memo (evalSubtree in
;; scoring/fitness.metta). &bscoreCache is no longer read or written.
!(bind! &bscoreCache (new-space))
;; Subtree-level (columnar) score cache: (subtree <canonicalExpr> <bool-vector>)
;; entries for operator nodes AND label leaves, keyed by the symbolic expression
;; so identical subtrees across candidates share an entry. NO LONGER WRITTEN --
;; the zipform engine memoizes through lib_memo instead; the binding and the
;; drain below survive for callers that predate the change.
!(bind! &subtreeCache (new-space))

;; Empty the subtree cache. A run scores ONE fixed table, and every entry is
;; valid only for that table -- call this before scoring against a DIFFERENT
;; table in the same process (e.g. a test file exercising two tables).
;; It also drops evalSubtree's lib_memo columns (scoring/fitness.metta), which
;; are table-dependent for the same reason. The rewrite cache (rewriteTreeCached)
;; is deliberately NOT invalidated -- rewriting never looks at the table.
(= (resetSubtreeCache)
   (let* (($entries (collapse (match &subtreeCache $e $e)))
          ($_ (map-atom $entries $e (remove-atom &subtreeCache $e))))
     (invalidate-memoize evalSubtree)))
