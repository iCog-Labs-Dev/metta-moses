;; ---------------------------------------------------------------------------
;; zipform/evaluator-common.metta -- shared table state + recursive evaluator
;; core for materialized zip terms (built by zipform/rewriter.metta). Both
;; cache variants (evaluator-memo.metta: lib_memo, PR-165 only; evaluator-
;; space.metta: hand-rolled &space cache, both runtimes) import this file and
;; supply their own top-level cached `evalZipTerm(Cached)`, passing
;; THEMSELVES as the recursion callback `$eval` to evalZipTermCore so that
;; recursive sub-evaluations go through the SAME caching wrapper -- this is
;; what makes the cache SUBTERM-level rather than whole-term-level, mirroring
;; kernel-memo.metta / kernel-space.metta's evalCol / evalColCached
;; recursion pattern (there hard-coded to one function; here parameterized).
;;
;; evalZipTermCore does its OWN explicit recursion into children via the
;; $eval callback -- it never hands a raw, unevaluated child subterm to a
;; structural list function (List.zipWith, map-atom, transposeCols): every
;; child is passed back through $eval FIRST. This sidesteps the silent-
;; failure trap documented in probe-zip-reduce-groundterm (an unevaluated
;; child subterm structurally unifies with a builtin's own cons-headed
;; pattern, e.g. `(colR x)` unifying with `(cons $x $xs)`, producing wrong
;; bindings with no error at all).
;;
;; NOTE ON IMPORTS: this file deliberately has NO `!(import! ...)` of its own
;; (matching common/kernel-common.metta's existing convention). It needs
;; common/list-helpers (List.repeat / List.zipWith) and common/kernel-common
;; (varColumn) already loaded; the entry harness is the single choke point
;; that imports both, exactly once each, before importing this file --
;; importing them a second time here would double-assert their clauses
;; (verified: "import! does not dedupe" corrupts `test`'s single-value
;; comparison with duplicate solutions).
;;
;; PARAM NOTE: table + row count are stored in the shared hyperparameter
;; registry (parameters/registry.metta: (param $name)/(set-param $name $v))
;; instead of ad-hoc change-state!/get-state cells. The entry harness is
;; responsible for `!(bind! &params (new-space))` + importing the registry
;; BEFORE importing this file -- see that harness's import block. No
;; initializer call is needed here: (param zipTable)/(param zipRowCount)
;; returning () before installation is fine, since setZipTable is always
;; called first by every entry file.
;; ---------------------------------------------------------------------------

;; setZipTable: install the fixed table for this scoring run and cache its
;; row count (mirrors setMemoTable / setProtoTable).
(= (setZipTable $itable)
   (let* (
            ((mkITable $rows $labels) $itable)
            ($_  (set-param zipTable $itable))
            ($_2 (set-param zipRowCount (List.length $rows))))
       (List.length $rows)))

;; transposeCols: non-empty equal-length columns -> per-row value tuples
;; (ground data only). Ported verbatim from scoring/fitness.metta:154-158.
(= (transposeCols $cols)
   (if (== (car-atom $cols) ())
       ()
       (cons (map-atom $cols $c (car-atom $c))
             (transposeCols (map-atom $cols $c (cdr-atom $c))))))

;; evalZipTermCore: materialized zip term x recursion callback -> boolean
;; column. Single dispatch via if-chain on the term's head (never overlapping
;; literal/variable clauses for the same head -- probe-zip-deep-column-4096).
(= (evalZipTermCore $term $eval)
   (if (== (get-metatype $term) Grounded)
       (List.repeat (param zipRowCount) $term)
       (let $h (car-atom $term)
         (if (== $h col)
             (let (col $label) $term (varColumn (param zipTable) $label))
             (if (== $h fmap)
                 (let (fmap $f $c) $term
                   (map-atom ($eval $c) $v ($f $v)))
                 (if (== $h zipWith)
                     (let (zipWith $f $a $b) $term
                       (List.zipWith $f ($eval $a) ($eval $b)))
                     (if (== $h zipWithN)
                         (let (zipWithN $op $children) $term
                           (let $cols (map-atom $children $c ($eval $c))
                             (map-atom (transposeCols $cols) $row ($op $row))))
                         (Error $term "evalZipTermCore: unknown zip-term head"))))))))
