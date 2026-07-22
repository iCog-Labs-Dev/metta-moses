;; ---------------------------------------------------------------------------
;; zipform/evaluator-dispatch.metta -- the evalAction-style evaluator for the
;; materialized zip term. Replaces evaluator-common.metta's single-clause
;; if-chain-on-head (+ the $eval callback threaded by evaluator-memo.metta)
;; with CLAUSE dispatch, exactly the spirit of the action domain's
;; evalAction/evalActionNode (scoring/action-eval.metta): a thin memoized
;; entry point plus one bare clause per node shape, each recursing back
;; through the memoized entry.
;;
;; WHY PATTERN-MATCH DISPATCH, NOT `reduce` (the action domain's mechanism):
;; the action engine dispatches with `(reduce (quote ($op $children $world)))`
;; because domain operators are OPEN -- loaded by later domain packages the
;; engine cannot name. The zip term's STRUCTURAL vocabulary is CLOSED: the
;; rewriter only ever emits four tags (col/fmap/zipWith/zipWithN). For a fixed
;; tag set, four disjoint-head clauses of `dispatchZip` are simpler and need
;; no quote/reduce machinery -- and crucially they keep col/fmap/zipWith/
;; zipWithN as INERT tags (never defined functions), so the rewriter can still
;; build `(col x)` etc. as plain data without them firing at rewrite time.
;; (A `(reduce (quote $wholeTerm))` does NOT fire -- quote of a single bound
;; variable does not strip into an application, verified; the action domain
;; only quotes a freshly-built literal ($op $children $world).)
;;
;; The row OPERATORS (AND/OR/NOT/XOR/...) remain fully open -- they are the
;; $f/$op arguments applied var-headed inside List.zipWith / map-atom, so a
;; new operator is still one clause in the ops file and never touches this
;; dispatch. Extensibility lives where it belongs (the operators), not in the
;; fixed structural vocabulary.
;;
;; SAFETY: dispatchZip's four clauses have distinct literal heads
;; (col/fmap/zipWith/zipWithN) and there is NO variable catch-all clause -- the
;; Grounded case is peeled off by evalZipTerm BEFORE dispatchZip is called, so
;; dispatchZip never needs (and must never get) an overlapping variable-head
;; clause. Structurally-disjoint literal heads are safe; a literal-vs-variable
;; overlap for one head is the documented infinite-backtracking hazard.
;;
;; CACHING: evalZipTerm is the single memoized function; dispatchZip's clauses
;; recurse through it on the SYMBOLIC child subterms (never pre-reduced), so
;; the memo keys are per-subterm expressions -- identical symbolic caching to
;; evaluator-memo.metta, and identical cross-candidate subterm sharing (the
;; boss's design). No `$eval` callback and no whole-term-vs-subterm split.
;;
;; NOTE ON IMPORTS: no `!(import! ...)` of its own (choke-point convention).
;; Needs common/list-helpers (List.repeat/zipWith), common/kernel-common
;; (varColumn) and (library lib_memo) already loaded by the entry file.
;; ---------------------------------------------------------------------------

!(import! &self (library lib_memo))
!(config-memoize (unique-limit 10000) (strategy wtinylfu) (size-limit 5))

;; setZipTable: install the fixed table + cache its row count (unchanged).
(= (setZipTable $itable)
   (let* (
            ((mkITable $rows $labels) $itable)
            ($_  (set-param zipTable $itable))
            ($_2 (set-param zipRowCount (List.length $rows))))
       (List.length $rows)))

;; transposeCols: non-empty equal-length columns -> per-row value tuples.
(= (transposeCols $cols)
   (if (== (car-atom $cols) ())
       ()
       (cons (map-atom $cols $c (car-atom $c))
             (transposeCols (map-atom $cols $c (cdr-atom $c))))))

;; evalZipTerm: the memoized entry. Grounded constant -> broadcast column;
;; everything else -> dispatchZip. Single clause, no head if-chain.
!(memoize evalZipTerm 1)
(= (evalZipTerm $term)
   (if (== (get-metatype $term) Grounded)
       (List.repeat (param zipRowCount) $term)
       (dispatchZip $term)))

;; dispatchZip: one bare clause per node shape; each recurses via the
;; memoized evalZipTerm on its symbolic children (per-subterm caching).
(= (dispatchZip (col $label))
   (varColumn (param zipTable) $label))
(= (dispatchZip (fmap $f $c))
   (map-atom (evalZipTerm $c) $v ($f $v)))
(= (dispatchZip (zipWith $f $a $b))
   (List.zipWith $f (evalZipTerm $a) (evalZipTerm $b)))
(= (dispatchZip (zipWithN $op $cols))
   (map-atom (transposeCols (map-atom $cols $c (evalZipTerm $c))) $row ($op $row)))
