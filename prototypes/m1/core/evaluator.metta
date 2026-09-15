;; ============================================================================
;; core/evaluator.metta -- running a program.
;;
;; Two entry points, and the difference between them is the whole design:
;;
;;   evalTerm     context-free. Everything inside core/ uses this one.
;;   evalProgram  the BOUNDARY. Takes a context, runs evalTerm against it,
;;                and hands back (mkRes <value> <context>).
;;
;; AN OPERATOR MUST CALL evalTerm, NEVER evalProgram. evalProgram writes the
;; cell before it starts, so an operator that called it would throw away the
;; context threaded so far and restart from whatever it was handed. This is the
;; one thing to get wrong here, the way eta-expansion used to be; the laziness
;; and threading checks in tests/t-operators.metta are what catch it.
;;
;; Outside core/ nothing changed: domains still write their primitives to take a
;; context and return an mkRes, and evalProgram still has the shape every scorer
;; and test already calls.
;;
;; NOTE ON FAILURE. The worst result is False, and the context is left wherever
;; the program got to. Under the earlier pure design a failed subprogram handed
;; back the context it was GIVEN, because contexts were values; with the context
;; in a cell it would take a snapshot and a restore to keep that, and this
;; prototype deliberately does not. Nothing reaches it today -- the builder only
;; emits well-formed programs from declared vocabulary -- but a program that
;; fails PARTWAY now keeps what it already did.
;;
;; This file must be loaded AFTER core/types.metta, because evalNode asks
;; isPrimitive, and a call to a function that has not been imported yet compiles
;; as data.
;; ============================================================================

;; Is $x a constant (True, 7, "abc") rather than an operator?
;; Asked POSITIVELY, by naming the constant types. The tempting alternative --
;; "does it have no declared type?" -- inverts the moment any operator is given
;; a type, at which point the operator stops being called and starts returning
;; itself, silently.
;;
;; Via containsIn rather than a bare is-member: is-member succeeds once per
;; match, and this answer feeds every dispatch, so a second solution would
;; double the whole run.
(= (isConstantType $type) (containsIn (Bool Number String) $type))

(= (isGroundLiteral $x) (isConstantType (get-type $x)))

;; A NUMBER specifically, which is a different question and must not be
;; confused with the one above. isGroundLiteral is the right test for RENDERING
;; a leaf -- True and "8" print bare exactly as 5 does -- and the wrong test for
;; deciding what may be TUNED: a contin walk adds a step size to its mean, so
;; starting one at True or at "8" is arithmetic on something that is not a
;; number. knobs/builder.metta asks this one.
;;
;; A direct == on the WHOLE type, not a membership test like the one above:
;; get-type answers Number for a numeric literal and an arrow expression for
;; anything callable, so a function returning a Number is correctly not a
;; number. It also answers once, which matters here for the same reason it
;; matters above -- a second solution would double every build.
(= (isNumberLiteral $x) (== Number (get-type $x)))

;; --- running one node -------------------------------------------------------
;; Two kinds of thing can head a node, and the type declarations already say
;; which is which, so no operator is named here:
;;
;;   a PRIMITIVE takes parameters and a context and returns an mkRes. That is
;;   the domain's business, and the domain still writes it exactly that way --
;;   which is why not one file under domain/ had to change. The context is
;;   fetched from the cell, handed over, and the one that comes back is written
;;   into the cell.
;;
;;   an OPERATOR is context-free: called with its children alone, returning a
;;   bare value. Whatever it did to the context it did through the primitives
;;   underneath it.
;;
;; `once` inside both collapses is not optional. collapse backtracks looking for
;; further solutions, and a second solution would run the actions AGAIN --
;; PeTTa's state is nb_setval, which backtracking does not undo. Under the
;; earlier pure design a duplicate solution showed up as a doubled number; here
;; it would show up as extra actions, silently.
;;
;; Destructuring the primitive's result INSIDE the collapse is what filters a
;; malformed one out: an unknown symbol reduces to itself unreduced, fails the
;; (mkRes ...) pattern, and collapses to nothing rather than escaping as though
;; it were a result.
;; The call is LET-BOUND before it is reduced, never written as
;; (reduce (quote ...)) inline: quote strips one layer when its result is bound
;; to a variable, but an inline one survives into the argument and reduce hands
;; the quoted term straight back.
;;
;; (AND ((OR ((sensorFront ())))))
(= (evalNode $op $children)
   (if (isPrimitive $op)
       (let* (($world   (getCtx))
              ($call    (quote ($op $children $world))) ;; TODO: Check ctx type of the operator before passing a ctx.
              ($results (collapse (once (let (mkRes $value $after) (reduce $call)
                                             (mkRes $value $after))))))
         (if (== $results ())
             False
             (let* (((mkRes $value $after) (car-atom $results))
                    ($ignored (putCtx $after)))
               $value)))
       (let* (($call    (quote ($op $children)))
              ($results (collapse (once (reduce $call)))))
         (if (== $results ()) False (car-atom $results)))))

;; --- running a program, context-free ----------------------------------------
;; Shapes:
;;   (op (child ...))  a node
;;   True / 7 / "x"    a constant
;;   op                a bare operator symbol -- treated as (op ())
(= (evalTerm $program)
   (if (isExpr $program)
       (if (== (size-atom $program) 2)
           (let ($op $children) $program (evalNode $op $children))
           False)
       (if (isGroundLiteral $program)
           $program
           (evalNode $program ()))))

;; --- the boundary -----------------------------------------------------------
;; Set the cell, run, read the cell back. This is the only place a context
;; arrives from outside and the only place one is handed back, so every scorer,
;; every episode loop and every test keeps the interface it already had.
(= (evalProgram $program $ctx)
   (let* (($ignored (putCtx $ctx))
          ($value   (evalTerm $program)))
     (mkRes $value (getCtx))))
