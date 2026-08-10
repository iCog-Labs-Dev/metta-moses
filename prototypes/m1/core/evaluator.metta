;; ============================================================================
;; core/evaluator.metta -- running a program.
;;
;; This is the only file that names the context, and it does so the way an
;; interpreter names its state: it receives one and hands it to the program.
;; It knows nothing about worlds, actions, booleans or tables.
;;
;; It must be loaded BEFORE core/operators.metta, because the operators refer
;; to evalProgram and the runtime resolves that at load time, in file order.
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

;; Run ONE node: build the call (op children context) and dispatch it.
;; `quote` keeps the term from being evaluated while it is being assembled.
;; Every way the call can go wrong -- unknown operator, wrong number of
;; children, a malformed clause -- fails to produce a well-formed (mkRes ...),
;; collapses to nothing, and becomes the worst result. The evaluator cannot
;; crash on a badly formed program, which matters when programs are evolved.
(= (evalNode $op $children $ctx)
   (let* (($call    (quote ($op $children $ctx)))
          ($results (collapse (let (mkRes $value $after) (reduce $call)
                                   (mkRes $value $after)))))
     (if (== $results ()) (mzero $ctx) (car-atom $results))))

;; Run a program.  Shapes:
;;   (op (child ...))  a node
;;   True / 7 / "x"    a constant
;;   op                a bare operator symbol -- treated as (op ())
(= (evalProgram $program $ctx)
   (if (isExpr $program)
       (if (== (size-atom $program) 2)
           (let ($op $children) $program (evalNode $op $children $ctx))
           (mzero $ctx))
       (if (isGroundLiteral $program)
           (mreturn $program $ctx)
           (evalNode $program () $ctx))))

;; the continuation the conditional uses; must sit below evalProgram
(= (pickBranch $then $else $value) (evalProgram (if $value $then $else)))
