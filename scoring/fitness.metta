 ;; A function to evaluate the boolean expression
 ;;     - If the input expression is a grounded value (True or False), it returns the value directly.
 ;;     - Otherwise, it extracts the operator from the expression and applies the corresponding evaluation function:
 ;;         - evaluateAnd for AND expressions
 ;;         - evaluateOr for OR expressions
 ;;         - not for NOT expressions
 ;;         - If the operator is unknown, it returns an error message.

(= (evaluate $expr)
    (if (== (get-metatype $expr) Grounded) ;; T / F
        $expr
        (if (== (cdr-atom $expr) ())  ;;  Handle (True) or (False)
            (evaluate (car-atom $expr))  ;; Extract the actual boolean value
            (case (car-atom $expr) 
                (
                    (AND (evaluateAnd (cdr-atom $expr)))
                    (OR (evaluateOr (cdr-atom $expr)))
                    (NOT (not (evaluate (cdr-atom $expr)))) 
                    ($_ ERROR)
                )
            )
        )
    )
)

 ;;  Evaluate OR subexpression
 ;;  Returns True if any argument evaluates to True, otherwise False.
(= (evaluateOr ()) False)
(= (evaluateOr (cons $first $rest))
   (if (== (evaluate $first) True)
       True
       (evaluateOr $rest)))

 ;;  Evaluate AND subexpression
 ;;  Returns False if any argument evaluates to False, otherwise True.
(= (evaluateAnd ()) True)
(= (evaluateAnd (cons $first $rest))
   (if (== (evaluate $first) False)
       False
       (evaluateAnd $rest)))


;; ---------------------------------------------------------------------------
;; Columnar scoring engine: compile the candidate once, then one memoized walk.
;; rewriteTree compiles a candidate Tree into a column term, for example
;;   (AND x (OR y z)) -> (zipWithN AND ((col x) (zipWithN OR ((col y) (col z)))))
;; evalSubtree walks that term. lib_memo caches each sub-term, so a sub-formula
;; that many candidates share computes its column one time. zipWithN applies
;; the op to each row through its WRAPPED clause, (AND (a b)) or (NOT (a)) in
;; scoring/boolean-ops, so each op has one clause. A head with no
;; clause stays unreduced in its rows, AND/OR treat it as not False, and the
;; candidate scores as the old per-row engine scored it.
;;
;; The table is in the parameter registry, not in the term, so it is not part
;; of a memo key. An entry file that scores must bind &params and import
;; parameters/registry before this file. If not, evalTree gives zero solutions.
;;
;; HAZARD: col, zipWithN and the op symbols are live heads.
;; Every term that this file emits as data is quoted.
;; ---------------------------------------------------------------------------

;; The memoize directives need lib_memo, so this module imports it.
;; Keys are per sub-term: about 2 to 2.5 times the distinct candidates.
;; HAZARD: a call site compiled before !(memoize f 1) does not use the memo.
;; So the directives come first, before every caller of f.
!(import! &self (library lib_memo))
!(config-memoize (unique-limit 100000) (strategy wtinylfu) (size-limit 5))
!(memoize rewriteTreeCached 1)
!(memoize evalSubtree 1)

;; Score entry: publish the table, then compile and walk the candidate.
;; (: evalTree (-> (Tree $a) (ITable $a) (List Bool)))
(= (evalTree $tree $itable)
   (let $_ (useTable $itable)
     (evalTerm (rewriteTreeCached $tree))))

;; Publish the table that col reads. lib_memo does not see a table change, so
;; a new table empties the memo: each cached column belongs to one table.
(= (useTable $itable)
   (if (== (param scoringTable) $itable)
       True
       (let* (((mkITable $columns $labels) $itable)
              ($_ (set-param scoringTable $itable))
              ($_2 (set-param scoringRowCount (ITable.rowCount $columns))))
         (resetSubtreeCache))))

;; Empty the scoring memo (evalSubtree and rewriteTreeCached). This also
;; resets the lib_memo counters.
(= (resetSubtreeCache) (clear-memoize))

;; Extract a label's column from the column-major table: the payload is the list
;; of columns, so the label's column is one index-atom away. Unknown label ->
;; loud Error (malformed input).
;; (: varColumn (-> (ITable $a) Symbol (List Bool)))
(= (varColumn (mkITable $columns $labels) $label)
   (let $idx (List.index $labels $label)
        (if (== $idx -1)
            (Error $label "varColumn: label not found in table")
            (index-atom $columns $idx))))

;; --- The column vocabulary of a compiled term -------------------------------
;; col reads the published table. zipWithN gives the op one row tuple per row,
;; the argument shape of its wrapped clause. This is the same for 1, 2 or n
;; columns: one column gives the rows ((x1) (x2) ...). The op is a variable
;; head, so a clause added later is found too.
(= (col $label) (varColumn (param scoringTable) $label))
(= (fmap $f $xs) (map-atom $xs $x ($f $x)))
(= (zipWithN $op $columns) (fmap $op (transposeCols $columns)))

;; Non-empty equal-length columns -> per-row value tuples (ground data only).
(= (transposeCols $cols)
   (if (== (car-atom $cols) ())
       ()
       (cons (map-atom $cols $c (car-atom $c))
             (transposeCols (map-atom $cols $c (cdr-atom $c))))))

;; --- Monoids ----------------------------------------------------------------
;; mempty: the identity of a monoid op, or () for any other op. A monoid node
;; folds into nested binary zipWithN terms. Each level is a memo key, and
;; candidates share these keys. To add a monoid, add one case line here.
(= (mempty $op) (case $op ((AND True) (OR False) ($_ ()))))
(= (isMonoid $op) (!= (mempty $op) ()))

;; One binary zipWithN term. Quoted: zipWithN is a live head.
(= (zipNode $op $left $right) (quote (zipWithN $op ($left $right))))

;; --- rewriteTree: candidate Tree -> column term ------------------------------
;; A compiler, not an evaluator: it never reads the table.
;; Childless node: a monoid gives its identity, a constant gives its Bool, and
;; any other symbol is a label. TRUE/FALSE are the reduct constants.
(= (rewriteTree (mkTree (mkNode $r) ()))
   (if (isMonoid $r)
       (mempty $r)
       (case $r
         ((TRUE True)
          (FALSE False)
          (True True)
          (False False)
          ($_ (quote (col $r)))))))

;; A null knob gives nothing (the operator clause drops it). A real knob
;; compiles its inner tree.
(= (rewriteTree (mkKnob (mkNullVex $tree) $lsk $i)) ())
(= (rewriteTree (mkKnob (mkTree $node $children) $lsk $i))
   (rewriteTree (mkTree $node $children)))

;; Operator node. Only the children that SURVIVE the null-knob filter count,
;; so 0 is possible. A non-monoid op with 0 children gives
;; zero solutions, as the old engine did.
(= (rewriteTree (mkTree (mkNode $r) (cons $x $xs)))
   (let $cols (filter-atom (map-atom (cons $x $xs) $c (rewriteTree $c)) $y (!= $y ()))
     (if (isMonoid $r)
         (if (== $cols ())
             (mempty $r)
             (List.foldr1 (zipNode $r) $cols))
         (if (== $cols ())
             (empty)
             (quote (zipWithN $r $cols))))))

;; Memoized compile of the root only. The compile does not read the table.
(= (rewriteTreeCached $tree) (rewriteTree $tree))

;; --- evalSubtree: one memoized walk over a compiled term --------------------
;; evalTerm sends only Expressions and Bool constants through the memo. A
;; symbol (an op, a label, col) passes unchanged, so it takes no memo lookup.
(= (evalTerm $term)
   (if (== (get-metatype $term) Symbol)
       $term
       (evalSubtree $term)))

;; A Bool constant becomes a full column. An Expression evaluates its children
;; first (through evalTerm), then reduces the rebuilt node: col or zipWithN
;; fires. Any other atom passes.
(= (evalSubtree $term)
   (if (or (== $term True) (== $term False))
       (List.repeat (param scoringRowCount) $term)
       (if (== (get-metatype $term) Expression)
           (let $node (map-atom $term $c (evalTerm $c))
             (reduce $node))
           $term)))
