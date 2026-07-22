;; ---------------------------------------------------------------------------
;; Variant M: lib_memo-backed columnar scoring kernel. PR-165 PeTTa ONLY --
;; PeTTaV1 (production) has no lib_memo, so this file must never be
;; imported from a harness that also needs to run on PeTTaV1. See
;; kernel-space.metta / correctness-harness-space.metta for the variant
;; that runs on both runtimes.
;;
;; Import-path note (verified empirically, see REDUCT-REFACTOR-FINDINGS
;; style probing): both /home/yab/PeTTaV1/src/metta.pl and
;; /home/yab/PeTTa-pr165/src/metta.pl resolve every relative import! path
;; against a single working_dir/1 fact that main.pl asserts ONCE at
;; startup from the directory of the file passed straight to run.sh --
;; nested imports never change it (importer_helper/2 always reads the same
;; working_dir/1). Concretely: `(library X)` resolves via a separate
;; library_path/1 base (metta.pl: library/2 clauses), but a bare relative
;; path like `common/kernel-common` always resolves relative to the ENTRY
;; script's own directory, no matter which file contains the import!
;; statement. Since every file in this prototype lives directly under
;; experiments/memo-prototype/, and every harness here is invoked directly
;; (never imported transitively from outside this directory), writing
;; import paths relative to experiments/memo-prototype/ works uniformly
;; whether the import! appears in the harness or in a file the harness
;; imports.
;; ---------------------------------------------------------------------------

!(import! &self (library lib_memo))
!(import! &self common/list-helpers)
!(import! &self common/kernel-common)

;; Reproducible cache preset (lib_memo_doc.md "Clear before experiments").
!(config-memoize (unique-limit 10000) (strategy wtinylfu) (size-limit 5))

;; Table + row count live in the shared hyperparameter registry (param
;; memoTable / param memoRowCount, see parameters/registry.metta) instead of
;; ad-hoc change-state!/get-state cells, so the memoized evalCol/1 doesn't
;; need to thread them as extra (unmemoized-key) arguments. The entry
;; harness is responsible for `!(bind! &params (new-space))` + importing the
;; registry BEFORE importing this file. Names are kept DISTINCT from
;; kernel-space.metta's proto*/zipform's zip* names on purpose (no entry
;; file in this prototype loads two kernels at once, so there is no actual
;; collision today -- kept distinct anyway as a forward-safety margin, since
;; &params is one shared global space across whatever gets loaded into a
;; single process).
(= (setMemoTable $itable)
   (let (mkITable $rows $labels) $itable
     (let* (($_  (set-param memoTable $itable))
            ($_2 (set-param memoRowCount (List.length $rows))))
       (List.length $rows))))

;; evalCol: wrapped (sub)expression -> boolean column, memoized per
;; expression by lib_memo. Every distinct subtree (operator node or label
;; leaf) is evaluated once per table; grounded True/False leaves are cheap
;; constant columns and deliberately excluded from the memoized path (same
;; rationale as scoring/fitness.metta's evalSubtree: not worth caching).
!(memoize evalCol 1)
(= (evalCol $exp)
   (if (== (get-metatype $exp) Grounded)
       (List.repeat (param memoRowCount) $exp)
       (if (== (get-metatype $exp) Expression)
           ;; every node is uniformly ($op ($c1 .. $ck))
           (let ($op $children) $exp
             (combineOp $op (map-atom $children $c (evalCol $c)) (param memoRowCount)))
           ;; bare label leaf
           (varColumn (param memoTable) $exp))))
