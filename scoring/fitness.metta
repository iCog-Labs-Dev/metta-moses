
!(bind! &space (new-space))

(= (removeFromSpace $row $space) (remove-atom $space $row))

;  This function counts the total occurrences of variable $X in an expression non-deterministically.
;; (= (findX $expr $x)
;;     (if (== $expr ())
;;         (empty)
;;         (let $a (superpose $expr)
;;             (if (or (== (get-metatype $a) Grounded) (== (get-metatype $a) Symbol))
;;                 (if (== $a $x)
;;                     1
;;                     (empty)
;;                 )
;;                 (findX $a $x)
;;             )
;;         )
;;     )
;; )

(= (findX $expr $x)
   (if (once (is-member $x $expr))
       True
       (List.any (map-atom $expr $ex
             (if (or (== (get-metatype $ex) Grounded) (== (get-metatype $ex) Symbol))
                 (== $ex $x)
                 (findX $ex $x))))))

 ;; Replaces variables in an expression with their corresponding truth values from the space.
 ;; If a variable is not found, it is replaced with undefined.
(= (replaceWithTruth $expr $space $spaceContent)
    (if (== (get-metatype $expr) Expression) 
        (if (== (cdr-atom $expr) ()) ;; Special case: (A) → Should replace as a symbol
            (map-atom $expr $ex (replaceWithTruth $ex $space $spaceContent))
            (let* (
                ($op (car-atom $expr))
                ($tuple (cdr-atom $expr)) 
                ($substitutedArgs (map-atom $tuple $tp (replaceWithTruth $tp $space $spaceContent)))
                ($tupleWithOp (cons-atom $op $substitutedArgs))
            )
                $tupleWithOp
            )
        )
        (let $res (collapse (match $space ($expr $value) $value))
            (if (== $res ()) undefined $res)
        )
    )
)


 ;; A function to evaluateuate the boolean expression
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
(= (evaluateOr $args)
    (if (== $args ())
        False
        (let* 
          (
            ($first (car-atom $args))
            ($rest (cdr-atom $args))
          )
          (if (== (evaluate $first) True)
              True
              (evaluateOr $rest)
          )
        )
    )
)

 ;;  Evaluate AND subexpression
 ;;  Returns False if any argument evaluates to False, otherwise True.
(= (evaluateAnd $args)
    (if (== $args ())
        True
        (let* 
          (
            ($first (car-atom $args))
            ($rest (cdr-atom $args))
          )
          (if (== (evaluate $first) False)
              False
              (evaluateAnd $rest)
          )
        )
    )
)


;; ---------------------------------------------------------------------------
;; Columnar (vectorized) subtree evaluation with memoization.
;;
;; Instead of substituting variables per row and re-evaluating the whole tree,
;; each subtree is evaluated ONCE into a boolean vector over all table rows and
;; memoized in &subtreeCache, keyed by its wrapped (preOrderExp) expression.
;; Common subtrees (e.g. (AND (A B))) recur across candidates, so the hit rate is
;; far higher than the whole-tree cache and shared work is done only once.
;; ---------------------------------------------------------------------------

;; Extract a variable's column (one boolean per row) from the input table.
;(: varColumn (-> (ITable $a) Symbol (List Bool)))
(= (varColumn (mkITable $rows $labels) $label)
   (let $idx (List.index $labels $label)
        (if (== $idx -1)
            ;; Leaf references a label not in the table. Real candidate trees are
            ;; built from the table's features so this is a malformed input; fail
            ;; loudly rather than silently scoring every row -1 (List.getByIdx -1).
            (Error $label "varColumn: label not found in table")
            ;; $idx is already validated (>= 0, and rows are as wide as $labels),
            ;; so index straight into the row with the grounded index-atom builtin
            ;; instead of List.getByIdx, which re-scans the row (size-atom) for a
            ;; redundant bounds check on every cell.
            (map-atom $rows $r (index-atom $r $idx)))))

;; ---------------------------------------------------------------------------
;; Wrapped-shape columnar evaluation.
;;
;; $exp is the wrapped eval shape produced by preOrderExp (scoring/boolean-ops):
;;   node:          (AND (k1 .. kk)) / (OR (k1 .. kk)) / (NOT (k))  -- 2-element
;;   symbol leaf:   a bare label (A, B, ...)  -> its table column
;;   grounded leaf: True / False              -> a constant column
;; Each node is evaluated ONCE into a boolean vector over all rows and memoized
;; in &subtreeCache keyed by its (ground) wrapped expr, so subtrees shared across
;; candidates are scored once.
;;
;; Operator SEMANTICS live in exactly one place: the (AND/OR/NOT) clauses in
;; scoring/boolean-ops.metta. Here we never re-implement and/or/not: on a cache
;; miss the node's ONE-LEVEL row template is built ONCE -- fresh MeTTa vars, one
;; per child, as a vars-term ($v1 .. $vk) plus the node expr (AND ($v1 .. $vk))
;; / (OR ($v1 .. $vk)) / (NOT ($v1)) SHARING those vars -- and each row is then
;; scored by native unification: sealed freshens the vars (and, because the expr
;; shares them, the expr with them -- copy_term preserves the identity),
;; (let $vars $row ...) unifies the fresh vars against that row's child values
;; positionally in one step, and a single `reduce` dispatches the operator
;; clause. This is feat's evalParsed pattern (whole-tree template) adapted to
;; one level per subtree -- real variables, real unification, real dispatch.
;; Children arrive as already-evaluated VALUE columns, so the single-step
;; `reduce` suffices (no recursive reduceExp).
;;
;; Template terms are built with cons-atom: a bare (AND ...) literal in a body
;; would FIRE the clause at build time, while cons-atom results stay inert and
;; preserve var identity between the vars-term and the expr. `reduce` dispatches
;; its literal head and does not pre-evaluate its argument, so the expr rides in
;; let-bound. All of this -- shared-var template shape, per-row sealed freshness
;; (the template stays unbound across rows), n-ary dispatch -- is validated in
;; the importless probe tmp/probe-sealed.metta.
;;
;; Unknown-head contract: a head with no operator clause (e.g. a stray reduct
;; wrapper) leaves `reduce` returning the node unreduced -- a non-boolean tuple
;; -- so compareAndScore mismatches every row and the tree scores worst (-1),
;; exactly matching the old ERROR-column behavior (verified: probe-sealed.metta
;; reduces a (FOO ($v1 $v2)) template row to (FOO (True False))).
;;
;; Structure -- recursion lives in exactly one place. Reading bottom-up:
;;   mkOpNode, nodeKids, mkNodeTemplate, evalRowT   non-recursive builders
;;   transposeCols                                  linear walk over one flat
;;                                                  list (no cycles)
;;   combineNode                                    column-level only, never
;;                                                  touches the tree
;;   evalSubtree                                    THE tree recursion; its one
;;                                                  self-call is the map-atom
;;                                                  over (nodeKids $exp)

;; Build an inert operator node from a symbol and an argument tuple (template
;; vars, or () for the empty identities). Every operator uniformly takes the
;; tuple as its single argument list: (Op (x1 .. xk)) -- NOT included.
(= (mkOpNode $op $rv)
   (cons-atom $op (cons-atom $rv ())))

;; Build a node's row template ONCE per cache miss: fresh vars (one per child)
;; plus the operator expr sharing those vars. Returns ($varsTerm $exprTerm),
;; e.g. (($v1 $v2) (AND ($v1 $v2))) or (($v1) (NOT ($v1))).
;; The vars are minted by a plain (map-atom $cvs $c $v): its per-element
;; copy_term -- the very behavior that BREAKS shared-var threading elsewhere
;; (see combineNode's var-safe map) -- is exactly what mints k DISTINCT fresh
;; vars here. The sharing we DO need (vars-term <-> expr) is established
;; afterwards by cons-atom, which does not copy. Distinctness, arity, expr
;; identity and sealed row reuse are all validated in the importless probe
;; tmp/probe-mapvars.metta.
(= (mkNodeTemplate $op $cvs)
   (let* (($vars (map-atom $cvs $c $v))
          ($e    (mkOpNode $op $vars)))
     ($vars $e)))

;; Score one row through a node template: sealed lists only the vars-term, but
;; copy_term freshens the body goal together with it, so the expr (sharing the
;; vars) is freshened in lockstep and the original template stays unbound for
;; the next row. The inner let unifies the fresh vars against the row's child
;; values in one positional step; `reduce` then dispatches the operator clause.
(= (evalRowT $template $row)
   (let ($vars $e) $template
        (sealed $vars (let $vars $row (reduce $e)))))

;; Transpose a non-empty list of equal-length columns into a list of per-row
;; value tuples. Pure ground data -> map-atom is safe. Terminates when the first
;; column is exhausted (all columns share length n).
(= (transposeCols $cols)
   (if (== (car-atom $cols) ())
       ()
       (cons (map-atom $cols $c (car-atom $c))
                  (transposeCols (map-atom $cols $c (cdr-atom $c))))))

;; Child exprs of a wrapped node -- every operator uniformly carries its
;; children as one wrapped list: (Op (k1 .. kk)) -> (k1 .. kk). Pure accessor,
;; no recursion.
(= (nodeKids $exp)
   (car-atom (cdr-atom $exp)))

;; Combine already-evaluated child columns into the node's column: build the
;; shared-var row template ONCE, transpose the columns into per-row value
;; tuples, and score each row through the template (evalRowT). Column-level
;; only -- this never touches the tree. The template threads through the
;; var-safe (map $f $a $xs) from general-helpers -- map-atom's lambda would
;; copy_term it per row (evalRowT seals its own per-row copy instead; same
;; reasoning as feat's scoreTree). Empty AND/OR (no children) reduce their
;; identity node once and repeat it over all rows.
(= (combineNode $op $cvs $n)
   (if (== $cvs ())
       (List.repeat $n (let $e (mkOpNode $op ()) (reduce $e)))
       (let $t (mkNodeTemplate $op $cvs)
         (map evalRowT $t (transposeCols $cvs)))))

;; Evaluate a wrapped (sub)expression into a boolean vector over all rows,
;; memoizing operator nodes in &subtreeCache keyed by the ground wrapped expr.
;; This is the ONLY tree-recursive function: the map-atom over (nodeKids $exp)
;; below is its single self-call; everything downstream (combineNode and the
;; builders it uses) is column-level.
;(: evalSubtree (-> Expression (ITable $a) Number (List Bool)))
(= (evalSubtree $exp $itable $n)
   (if (== (get-metatype $exp) Expression)
       ;; operator node: cache lookup, else recurse children + combine + memoize
       (chain (collapse (match &subtreeCache (subtree $exp $v) $v)) $hit
         (if (== $hit ())
             (let* (($cvs (map-atom (nodeKids $exp) $k (evalSubtree $k $itable $n)))
                    ($col (combineNode (car-atom $exp) $cvs $n))
                    ($_   (add-atom &subtreeCache (subtree $exp $col))))
               $col)
             (car-atom $hit)))
       ;; atom leaf: grounded literal (True/False) vs variable column
       (if (== (get-metatype $exp) Grounded)
           (List.repeat $n $exp)
           (varColumn $itable $exp))))


 ;; Evaluates the accuracy of the expression for a single input row (target, inputs) pair.
 ;; This function determines whether the given boolean expression produces the expected result.
 ;;
 ;; Parameters:
 ;; - $expr: The boolean expression to evaluate.
 ;; - $row: A pair consisting of:
 ;;    - $target: The expected output.
 ;;    - $inputs: A set of truth assignments for variables.
 ;;
 ;; approach:
 ;;     - Extract $target (expected output) and $inputs (variable assignments).
 ;;     - Add the $inputs to the space using `add-reduct`.
 ;;     - Replace variables in $expr with their truth values from the space.
 ;;     - Evaluate the substituted expression.
 ;;     - Remove the added $inputs from the space to restore the original state.
 ;;     - If the evaluated result matches the $target, return 1 (correct); otherwise, return 0

(= (rowFitness $expr $row )
    (let*
      (
        ($target (car-atom $row))
        ($inputs (cdr-atom $row))
        ($add (map-atom $inputs $z (add-atom &space $z)))
        ($replacedExpr (let $acc (replaceWithTruth $expr &space (collapse (match &space $x $x))) (if (== (get-metatype $acc) Symbol) ($acc) $acc))) ;; This is a guard added to prevent a symbol being returned here which will cause the rest of the logic to fail. It is an edge case that happens if none of the variables are defined or the first variable explored is an undefined variable.
        ($isFaulty  (findX $replacedExpr undefined))  ;; Check if there are any undefined variables in the expression
        ($evaluateuatedResult  (if (not $isFaulty) (evaluate $replacedExpr) null )) ;; No need to evaluate if there are undefined variables in the experession
        ($remove (map-atom $inputs $z (remove-atom &space $z)))
      )
      (if (== $evaluateuatedResult $target) 1 0)
      )
)


 ;; Measure the accuracy of the expression based on the given dataset.
 ;; The function evaluates how well the boolean expression matches the given truth table.
 ;;
 ;; Args:
 ;;     - $expr: The boolean expression to be evaluated.
 ;;     - $data: A dataset containing multiple rows of input-output mappings.

(= (fitness $expr $data)
    (if (== $data ())
        0
        (let $result (map-atom $data $d (rowFitness $expr $d)) (sum $result))
    )
)

;  ;; Computes the penalized fitness of an expression by balancing accuracy and complexity.
;  ;; The penalty factor $lambda(just like learning rate) controls the trade-off between correctness and simplicity.

(= (penalizedFitness $expr $data $lambda)
    (let*
      (
        ($accuracy (fitness $expr $data))
        ($complexity (counter $expr))
      )
        (- $accuracy (* $lambda $complexity))
    )
)



;; helper function to calculate the how many AND and OR operators are in the expression

(= (counter $expr)
    (if (or (== $expr ()) (== (get-metatype $expr) Symbol))
        0
        (let*
          (
            ($head  (car-atom $expr))
            ($tail (cdr-atom $expr))
          )
          (if (== (get-metatype $head) Expression)
              (+ (counter $head) (counter $tail))
              (if (or (== $head AND) (== $head OR))
                  (+ 1 (counter $tail))
                  (counter $tail)
              )
          )
        )
    )
)
