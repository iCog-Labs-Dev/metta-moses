;; ---------------------------------------------------------------------------
;; Action Reduction Dispatcher & Integration
;; ---------------------------------------------------------------------------

;; applyActionRuleDownwards mirrors C++ `downwards(rule)`: apply one rule to
;; the current expression node, then recursively apply the same rule to the
;; reduced node's children. Action programs are reduced as MeTTa expressions;

(= (applyActionRuleDownwards $rule $expr)
   (let $reducedNode ($rule $expr)
     (if (and (== (get-metatype $reducedNode) Expression) (!= $reducedNode ()))
         (let* ((($op $args) (decons $reducedNode))
                ($reducedArgs (map-atom $args $arg (applyActionRuleDownwards $rule $arg))))
           (cons-atom $op $reducedArgs))
         $reducedNode)))

;; C++ includes `preconditions_check()` at the end of action_reduction.cc, but
;; its implementation is currently commented out there. Keep this as a named
;; no-op so the pipeline shape remains visible and future domain preconditions
;; can be added deliberately.
(= (preconditionsCheck $expr) $expr)

;; applyDefaultRulesPass performs one full default action_reduction.cc
;; iteration. Each rule runs as its own downwards pass before the next rule
;; starts, matching the C++ reducer's iterative(sequential(downwards(...)))
;; ordering.
(= (applyDefaultRulesPass $expr)
   (let* (($e0 (applyActionRuleDownwards levelNode $expr))
          ($e1 (applyActionRuleDownwards reduceActionIf $e0))
          ($e2 (applyActionRuleDownwards reduceActionActionIfSameBranch $e1))
          ($e3 (applyActionRuleDownwards reduceConstCondActionIf $e2))
          ($e4 (applyActionRuleDownwards reduceConstActionSeq $e3))
          ($e5 (applyActionRuleDownwards reduceEmptyArgSeq $e4))
          ($e6 (applyActionRuleDownwards reduceRepeatOutActionWhile $e5))
          ($e7 (applyActionRuleDownwards reduceRepeatInActionWhile $e6))
          ($e8 (applyActionRuleDownwards reduceIdempotent $e7))
          ($e9 (applyActionRuleDownwards reduceOpposite $e8))
          ($e10 (applyActionRuleDownwards reduceAdditive $e9))
          ($e11 (applyActionRuleDownwards reduceZeroNeutral $e10))
          ($e12 (applyActionRuleDownwards reduceModularArgument $e11))
          ($e13 (preconditionsCheck $e12)))
     $e13))

;; One default reduction iteration over a PeTTa expression.
(= (actionReduce $expr)
   (let $result (applyDefaultRulesPass $expr)
     (if (== $result $expr)
         $expr
         (actionReduce $result))))

;; Tree-level helpers are local so action cleanup does not rely on caller import
;; order for preOrder/buildTree. They preserve zero-arity action sequence
;; operators while converting to and from normal MeTTa expression form.

(= (actionTreeToExpression (mkNullVex $children)) ())
(= (actionTreeToExpression (mkTree (mkNode $rootOp) $children))
   (if (== $children ())
       (if (is-member $rootOp (and_seq or_seq exec_seq AND OR))
           ($rootOp)
           $rootOp)
       (let* (($exprChildren (map-atom $children $child (actionTreeToExpression $child)))
              ($filteredChildren (filter-atom $exprChildren (!= ()))))
         (cons-atom $rootOp $filteredChildren))))

(= (actionExpressionToTree $expr)
   (if (and (== (get-metatype $expr) Expression) (!= $expr ()))
       (let* ((($rootOp $args) (decons $expr))
              ($children (map-atom $args $arg (actionExpressionToTree $arg))))
         (mkTree (mkNode $rootOp) $children))
       (mkTree (mkNode $expr) ())))

(= (cleanActionTree $tree)
   (actionExpressionToTree (actionReduce (actionTreeToExpression $tree))))
