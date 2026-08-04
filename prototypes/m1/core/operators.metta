;; ============================================================================
;; core/operators.metta -- the operator vocabulary.
;;
;; NOTICE WHAT IS MISSING: not one of these mentions a context. The runtime
;; supplies it, because each body ends in a partially applied call and the
;; compiler completes the arity. That is the whole trick, and it has one rule:
;;
;;     EVERY BODY MUST END IN A CALL.
;;
;; A body that ends in a bare `if` (or case/collapse/match) does NOT get the
;; extra parameter. It then compiles with one argument too few, the evaluator's
;; dispatch quietly fails, and every program scores worst while everything
;; still appears to run. That is what `ifM` exists to avoid, and why
;; tests/t-operators.metta checks the arity of every operator individually.
;; ============================================================================

;; --- sequences: run children in order, threading the context ---------------
(= (and_seq $children) (ifM (isExpr $children) (allM evalProgram $children) mzero))
(= (or_seq  $children) (ifM (isExpr $children) (anyM evalProgram $children) mzero))

;; --- the conditional: the only operator that truly needs `bind`, because
;;     the value decides which branch runs and that branch changes the context.
;;     The untaken branch is never evaluated.
(= (action_bool_if ($c $t $e)) (mbind (evalProgram $c) (pickBranch $t $e)))

;; --- reshaping a result: `fmap`, not `bind` (neither touches the context) ---
(= (action_not ($x))     (mfmap not       (evalProgram $x)))
(= (return_success ($x)) (mfmap constTrue (evalProgram $x)))

(= (action_success ()) (mreturn True))
(= (action_failure ()) (mreturn False))

;; --- boolean combinators, context-threading form ----------------------------
;; Same bodies as the sequences above. That is not duplication: they are the
;; same operation used in a different ROLE, and the role is carried by the
;; type signature (see core/types.metta), not by the body.
;;
;; The empty cases matter to the search: an all-knobs-off condition must be
;; True rather than worst, or turning a condition off looks like a disaster
;; instead of like "no condition".
(= (AND $children) (ifM (isExpr $children) (allM evalProgram $children) mzero))
(= (OR  $children) (ifM (isExpr $children) (anyM evalProgram $children) mzero))
(= (NOT ($x))      (mfmap not (evalProgram $x)))

;; --- boolean combinators, plain-value form ----------------------------------
;; The same three symbols, used on values that are already computed. They do
;; not clash with the versions above: these bodies are COMPLETE applications,
;; so they do not get an extra parameter, and the two families end up as
;; separate definitions distinguished by how many arguments they take.
(= (AND $args) (allT $args))
(= (OR  $args) (anyT $args))
(= (NOT ($x))  (not $x))

(= (allT $xs) (foldl-atom $xs True  $a $x (and $a $x)))
(= (anyT $xs) (foldl-atom $xs False $a $x (or  $a $x)))
