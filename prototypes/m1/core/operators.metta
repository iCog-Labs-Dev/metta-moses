;; ============================================================================
;; core/operators.metta -- the operator vocabulary.
;;
;; NOTICE WHAT IS MISSING: not one of these mentions a context. That used to be
;; a trick -- each body ended in a partially applied call and the compiler
;; appended the missing parameter -- and it came with a rule that had to be
;; obeyed on pain of silent failure: EVERY BODY MUST END IN A CALL, or the
;; operator compiled one argument short and every program scored worst while
;; the run still looked healthy.
;;
;; That rule is gone, along with the whole class of failure behind it. These are
;; now ordinary one-argument functions. The context is ambient -- it lives in
;; the cell in core/monad.metta -- so there is nothing to pass and nothing to
;; forget to pass.
;;
;; THEY CALL evalTerm, NOT evalProgram. evalProgram is the boundary: it writes
;; the cell from its argument, so calling it here would discard the context
;; threaded so far. That is now the mistake to watch for.
;;
;; ONE DEFINITION PER OPERATOR. There is no separate version for a context-free
;; boolean: a boolean IS evaluated against a context, one that a perception
;; hands back untouched.
;; ============================================================================

;; --- sequences: run children in order, threading the context ---------------
;; Point-free, as they would be in Haskell. There is no guard against malformed
;; children: allM and anyM match on the SHAPE of the list, so children that are
;; not a list match no clause and the call fails -- which is exactly what
;; evalNode's collapse turns into the worst result.
(= (and_seq $children) (allM evalTerm $children))
(= (or_seq  $children) (anyM evalTerm $children))

;; --- the conditional --------------------------------------------------------
;; `if` is the monad's ifM here, and it is a special form rather than a function
;; precisely so the untaken branch is never evaluated. Written as a function
;; both branches would run before the test was looked at, and every laziness
;; check in tests/t-operators.metta would fail.
(= (action_bool_if ($cond $then $else))
   (if (evalTerm $cond) (evalTerm $then) (evalTerm $else)))

;; --- reshaping a result: what used to be fmap -------------------------------
;; With the context ambient, `fmap f m` is just `(f m)`: the child runs because
;; arguments are built strictly, and the function transforms what it produced
;; without touching the context.
(= (action_not ($child)) (not (evalTerm $child)))

;; --- boolean combinators ----------------------------------------------------
;; Same bodies as the sequences above. That is not duplication: they are the
;; same operation used in a different ROLE, and the role is carried by the type
;; signature (see core/types.metta), not by the body.
;;
;; The empty cases matter to the search: an all-knobs-off condition must be
;; True rather than worst, or turning a condition off looks like a disaster
;; instead of like "no condition". allM's first clause is what gives that.
(= (AND $children) (allM evalTerm $children))
(= (OR  $children) (anyM evalTerm $children))
(= (NOT ($child))  (not (evalTerm $child)))

;; --- the three that still name a context ------------------------------------
;; These are UNDECLARED, and evalNode routes an undeclared symbol as a leaf --
;; so they are called the way a domain primitive is, with the context, and must
;; hand back an mkRes.
;;
;; Declaring them would fix that and is the wrong trade: declaredOpsOfType would
;; then put them in `opsOfType Act`, which changes every candidate list, knob
;; count and expected score in all four domains. Nothing in the search reaches
;; them -- they are vocabulary only the tests use -- so the wart stays here
;; rather than moving into every suite.
(= (return_success ($child) $ctx) (mkRes (constTrue (evalTerm $child)) (getCtx)))
(= (action_success () $ctx)       (mkRes True  $ctx))
(= (action_failure () $ctx)       (mkRes False $ctx))
