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
;; Columnar subtree evaluation over the wrapped preOrderExp shape:
;;   node = (AND (c1 .. ck)) / (OR (c1 .. ck)) / (NOT (c));  leaf = label | True/False
;; Every subtree is evaluated ONCE into a boolean column over all rows and
;; memoized in &subtreeCache, keyed by its ground wrapped expr (valid for the
;; run's single fixed table). Operator semantics live solely in the AND/OR/NOT
;; clauses (scoring/boolean-ops): on a cache miss a one-level template with
;; fresh shared vars is built once and every row is scored by unification --
;; sealed freshens the vars, a positional let binds the row's child values,
;; and one let-bound `reduce` dispatches the clause. A head with no clause
;; stays unreduced and scores worst (-1), like the old ERROR column.
;; ---------------------------------------------------------------------------

;; Extract a label's column from the column-major table: the payload is the list
;; of columns, so the label's column is one index-atom away. Unknown label ->
;; loud Error (malformed input).
;; (: varColumn (-> (ITable $a) Symbol (List Bool)))
(= (varColumn (mkITable $columns $labels) $label)
   (let $idx (List.index $labels $label)
        (if (== $idx -1)
            (Error $label "varColumn: label not found in table")
            (index-atom $columns $idx))))

;; Node row-template, built once per cache miss: ($varsTerm $exprTerm) sharing
;; fresh vars, e.g. (($v1 $v2) (AND ($v1 $v2))). map-atom's per-element
;; copy_term mints the k distinct vars; `cons` keeps the node inert (a bare
;; (AND ...) literal would fire the clause at build time).
(= (mkNodeTemplate $op $cvs)
   (let* (($vars (map-atom $cvs $c $v))
          ($e    (cons $op (cons $vars ()))))
     ($vars $e)))

;; One row through the template: sealed copies vars and expr together (the
;; template stays unbound for the next row), the let unifies the row's child
;; values positionally, and `reduce` dispatches the operator clause.
(= (evalRow $template $row)
   (let ($vars $e) $template
        (sealed $vars (let $vars $row (reduce $e)))))

;; Non-empty equal-length columns -> per-row value tuples (ground data only).
(= (transposeCols $cols)
   (if (== (car-atom $cols) ())
       ()
       (cons (map-atom $cols $c (car-atom $c))
             (transposeCols (map-atom $cols $c (cdr-atom $c))))))

;; Child columns -> node column: template once, then each transposed row
;; through evalRow via the var-safe map (map-atom would copy the template
;; per row). Childless AND/OR reduce their identity once and repeat it.
(= (combineNode $op $cvs $n)
   (if (== $cvs ())
       (List.repeat $n (let $e (cons $op (cons () ())) (reduce $e)))
       (let $t (mkNodeTemplate $op $cvs)
         (map evalRow $t (transposeCols $cvs)))))

;; Wrapped (sub)expression -> boolean column. Nodes AND label leaves are
;; memoized, so a label's table walk happens once per run. The map-atom over
;; the destructured children is the engine's only tree recursion.
;; (: evalSubtree (-> Expression (ITable $a) Number (List Bool)))
(= (evalSubtree $exp $itable $n)
   (if (== (get-metatype $exp) Grounded)
       ;; grounded literal (True/False): constant column, not worth caching
       (List.repeat $n $exp)
       ;; operator node or label leaf: one shared memo path
       (chain (collapse (match &subtreeCache (subtree $exp $v) $v)) $hit
         (if (== $hit ())
             (let* (
                     ($col (if (== (get-metatype $exp) Expression)
                              ;; every node is uniformly ($op ($c1 .. $ck))
                              (let* ((($op $children) $exp)
                                     ($cvs (map-atom $children $child (evalSubtree $child $itable $n))))
                                (combineNode $op $cvs $n))
                              (varColumn $itable $exp)))
                    ($_   (add-atom &subtreeCache (subtree $exp $col))))
               $col)
             (car-atom $hit)))))
