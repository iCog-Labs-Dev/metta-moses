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
(= (isConstantType $t)
   (if (== $t Bool) True (if (== $t Number) True (if (== $t String) True False))))

(= (isGroundLiteral $x) (isConstantType (get-type $x)))

;; Run ONE node: build the call (op children context) and dispatch it.
;; `quote` keeps the term from being evaluated while it is being assembled.
;; Every way the call can go wrong -- unknown operator, wrong number of
;; children, a malformed clause -- fails to produce a well-formed (mkRes ...),
;; collapses to nothing, and becomes the worst result. The evaluator cannot
;; crash on a badly formed program, which matters when programs are evolved.
(= (evalNode $op $children $ctx)
   (let* (($e (quote ($op $children $ctx)))
          ($rs (collapse (let (mkRes $v $w) (reduce $e) (mkRes $v $w)))))
     (if (== $rs ()) (mzero $ctx) (car-atom $rs))))

;; Run a program.  Shapes:
;;   (op (child ...))  a node
;;   True / 7 / "x"    a constant
;;   op                a bare operator symbol -- treated as (op ())
(= (evalProgram $exp $ctx)
   (if (isExpr $exp)
       (if (== (size-atom $exp) 2)
           (let ($op $children) $exp (evalNode $op $children $ctx))
           (mzero $ctx))
       (if (isGroundLiteral $exp)
           (mreturn $exp $ctx)
           (evalNode $exp () $ctx))))

;; the continuation the conditional uses; must sit below evalProgram
(= (pickBranch $then $else $v) (evalProgram (if $v $then $else)))
