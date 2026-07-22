;; ---------------------------------------------------------------------------
;; zipform/rewrite-cache-space.metta -- hand-rolled &space-cache wrapper
;; around zipform/rewriter.metta's rewriteTree. Runs on BOTH runtimes.
;;
;; Keyed on the wrapped candidate expr; this cache is TABLE-INDEPENDENT
;; (rewriting a formula into its materialized zip term never looks at the
;; scoring table at all) -- unlike the eval caches (evaluator-memo.metta /
;; evaluator-space.metta), which score against a fixed table and so DO need
;; clearing whenever the table is switched, this cache never needs clearing
;; for correctness: the same formula always rewrites to the same term no
;; matter which table is currently installed. Deliberately no reset/clear
;; function is defined for &rewriteTermCache anywhere in this prototype --
;; there is nothing that would ever need to invalidate it. See the harness's
;; table-switch staleness demo, which exercises this directly.
;;
;; NOTE ON IMPORTS: this file has NO `!(import! ...)` of its own -- it needs
;; zipform/rewriter (rewriteTree) and, transitively, common/list-helpers /
;; zipform/ops already loaded; the entry harness is the single choke point
;; that imports the whole chain, exactly once each, before importing this
;; file (re-importing here would double-assert clauses, corrupting `test`'s
;; single-value comparisons -- verified empirically, "import! does not
;; dedupe").
;; ---------------------------------------------------------------------------

!(bind! &rewriteTermCache (new-space))

(= (rewriteTreeCached $exp)
   (chain (collapse (match &rewriteTermCache (rewritten $exp $v) $v)) $hit
     (if (== $hit ())
         (let* (($v (rewriteTree $exp))
                ($_add (add-atom &rewriteTermCache (rewritten $exp $v))))
           $v)
         (car-atom $hit))))
