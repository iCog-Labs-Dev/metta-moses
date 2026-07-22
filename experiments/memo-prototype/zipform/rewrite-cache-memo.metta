;; ---------------------------------------------------------------------------
;; zipform/rewrite-cache-memo.metta -- lib_memo-backed memoized wrapper
;; around zipform/rewriter.metta's rewriteTree. PR-165 PeTTa ONLY.
;;
;; Keyed on the wrapped candidate expr; this cache is TABLE-INDEPENDENT
;; (rewriting a formula into its materialized zip term never looks at the
;; scoring table at all) -- unlike the eval caches (evaluator-memo.metta /
;; evaluator-space.metta), which score against a fixed table and so DO need
;; clearing whenever the table is switched, this cache never needs clearing
;; for correctness: the same formula always rewrites to the same term no
;; matter which table is currently installed. See the harness's table-switch
;; staleness demo, which exercises this directly.
;;
;; NOTE ON IMPORTS: this file only imports (library lib_memo) -- it does NOT
;; re-import common/list-helpers / zipform/ops / zipform/rewriter (already
;; pulled in by whichever chain the entry harness used to load
;; zipform/rewriter; re-importing them here would double-assert their
;; clauses, corrupting `test`'s single-value comparisons with duplicate
;; solutions -- verified empirically, "import! does not dedupe"). The entry
;; harness must import zipform/rewriter (and its own prerequisites) BEFORE
;; importing this file.
;; ---------------------------------------------------------------------------

!(import! &self (library lib_memo))

!(memoize rewriteTreeCached 1)
(= (rewriteTreeCached $exp) (rewriteTree $exp))
