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
;; still appears to run. That is why tests/t-operators.metta checks the arity
;; of every operator individually, and why those checks come first.
;;
;; ONE DEFINITION PER OPERATOR. There is no separate version for a context-free
;; boolean: a boolean IS evaluated against a context, one that a perception
;; hands back untouched. core/monad.metta is what makes that cost nothing.
;; ============================================================================

;; --- sequences: run children in order, threading the context ---------------
;; Point-free, as they would be in Haskell. There is no guard against
;; malformed children: allM and anyM match on the SHAPE of the list, so
;; children that are not a list match no clause and the call fails -- which is
;; exactly what evalNode's collapse turns into the worst result.
(= (and_seq $children) (allM evalProgram $children))
(= (or_seq  $children) (anyM evalProgram $children))

;; --- the conditional: the only operator that truly needs `bind`, because
;;     the value decides which branch runs and that branch changes the context.
;;     The untaken branch is never evaluated.
(= (action_bool_if ($cond $then $else)) (mbind (evalProgram $cond) (pickBranch $then $else)))

;; --- reshaping a result: `fmap`, not `bind` (neither touches the context) ---
(= (action_not ($child))     (mfmap not       (evalProgram $child)))
(= (return_success ($child)) (mfmap constTrue (evalProgram $child)))

(= (action_success ()) (mreturn True))
(= (action_failure ()) (mreturn False))

;; --- boolean combinators ----------------------------------------------------
;; Same bodies as the sequences above. That is not duplication: they are the
;; same operation used in a different ROLE, and the role is carried by the type
;; signature (see core/types.metta), not by the body.
;;
;; The empty cases matter to the search: an all-knobs-off condition must be
;; True rather than worst, or turning a condition off looks like a disaster
;; instead of like "no condition". allM's first clause is what gives that.
(= (AND $children) (allM evalProgram $children))
(= (OR  $children) (anyM evalProgram $children))
(= (NOT ($child))  (mfmap not (evalProgram $child)))
