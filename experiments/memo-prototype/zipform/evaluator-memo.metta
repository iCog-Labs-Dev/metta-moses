;; ---------------------------------------------------------------------------
;; zipform/evaluator-memo.metta -- lib_memo-backed zip-term evaluator.
;; PR-165 PeTTa ONLY -- imports (library lib_memo), which does not exist on
;; PeTTaV1. See evaluator-space.metta for the twin that runs on both
;; runtimes.
;;
;; Caches PER SUBTERM: evalZipTerm IS the recursion callback passed into
;; evalZipTermCore, so every distinct materialized zip subterm reached during
;; a scoring run gets its own memo entry, independent of which top-level
;; formula it was reached from -- mirroring kernel-memo.metta's evalCol.
;;
;; NOTE ON IMPORTS: this file only imports (library lib_memo) -- it does NOT
;; re-import common/list-helpers / common/kernel-common / zipform/ops (unused
;; here directly, and already pulled in by whichever chain the entry harness
;; used to load zipform/evaluator-common; re-importing them here would
;; double-assert their clauses, corrupting `test`'s single-value comparisons
;; with duplicate solutions -- verified empirically, "import! does not
;; dedupe"). The entry harness must import zipform/evaluator-common (and its
;; own prerequisites) BEFORE importing this file.
;; ---------------------------------------------------------------------------

!(import! &self (library lib_memo))

;; Reproducible cache preset (lib_memo_doc.md "Clear before experiments").
!(config-memoize (unique-limit 10000) (strategy wtinylfu) (size-limit 5))

!(memoize evalZipTerm 1)
(= (evalZipTerm $term) (evalZipTermCore $term evalZipTerm))
