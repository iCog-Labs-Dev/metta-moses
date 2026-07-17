;; Generic action-tree evaluator: the action-domain analog of the boolean
;; columnar design (scoring/boolean-ops + fitness/evalSubtree). The engine
;; below NEVER names a concrete operator.
;;
;; THE CONTRACT: every operator -- structural combinator, domain action, or
;; perception -- is ONE bare-head clause over the node's argument list:
;;     (= (<combinator> $children $world) (mkARes <Bool> <World'>))
;;     (= (<primitive>  $params   $world) (mkARes <Bool> <World'>))
;; Same slot, two roles: a structural combinator receives CHILD SUBPROGRAMS
;; ($children); a domain primitive receives its PARAMETERS ($params -- () for
;; nullary leaves, destructured by a parametrized action). The argument list
;; arrives UNEVALUATED in wrapped shape (each element is (op (args)), a
;; bare-symbol/grounded leaf, or a nested node); a combinator calls evalAction
;; back for the children it chooses, in the order it chooses -- that is what
;; makes and_seq sequential and action_bool_if lazy. Uniform result
;; (mkARes $bool $world): action success/failure and perception truth share
;; one protocol. $world is opaque to the engine and to all structural ops --
;; only domain clauses inspect it. Dispatch is a `reduce` on a cons-built
;; ($op $children $world) term, exactly the boolean engine's mechanism
;; (fitness.metta:141-167 dispatching AND/OR/NOT) -- clauses loaded at ANY
;; later time are found, no sentinel needed. Three failure paths, all mapped
;; to the defined-worst (mkARes False $world), the analog of boolean's
;; unreduced -> -1 at fitness.metta:124:
;;   * unknown operator -> reduce returns the term UNREDUCED;
;;   * known operator whose head destructure rejects the children (wrong
;;     child-count for a fixed-arity op) -> silent failure;
;;   * symbol heading clauses of some OTHER arity -> reduce returns a
;;     runtime `partial` term.
;; All three are filtered by the (mkARes $v $w) unification INSIDE the
;; collapse in evalActionNode -- anything that is not a well-formed mkARes
;; collapses to () and becomes the defined-worst.
;;
;; Loads after scoring/action-registry and before scoring/action-ops and any
;; domain package.

;; isARes: is $r a well-formed (mkARes $v $w) result? Guarded if-chain, NOT
;; `and` -- size-atom/car-atom on a non-expression would error. No longer on
;; the engine's dispatch path (evalActionNode filters result shapes via the
;; in-collapse unification instead: passing a runtime `partial` term as an
;; argument would RESUME the application and silently fail); retained as the
;; public result-shape predicate, pinned by scoring/test/action-eval-test.
(= (isARes $r)
   (if (== (get-metatype $r) Expression)
       (if (== (size-atom $r) 3)
           (if (== (car-atom $r) mkARes) True False)
           False)
       False))

;; evalActionNode: dispatch ONE node to its operator clause -- reduce on a
;; cons-built term (`cons` keeps the node inert while building; a bare
;; ($op ...) literal could fire a clause at compile time). The
;; (mkARes $v $w) unify-destructure sits INSIDE the collapse: only a
;; well-formed mkARes survives it, so an unreduced term (unknown op), a
;; silent head-destructure failure (wrong child-count for a fixed-arity op),
;; a runtime `partial` term (symbol heading clauses of another arity -- that
;; partial must never escape the collapse: passed to any callee it RESUMES
;; the application and silently fails; probe rv-probe11/pTotality) and a
;; malformed clause return all collapse to () and map to the defined-worst
;; -- the engine can never fail or return a non-ARes.
(= (evalActionNode $op $children $world)
   (let* (($e (cons $op ($children $world)))
          ($rs (collapse (let (mkARes $v $w) (reduce $e) (mkARes $v $w)))))
     (if (== $rs ())
         (mkARes False $world)
         (car-atom $rs))))

;; isActionGroundLiteral: is atom $x a constant literal (True/False, numbers
;; such as repeat_n's count)? With bare operator heads, ANY clause-headed
;; symbol has metatype Grounded in PeTTaV1 (probe-verified), so metatype
;; alone cannot separate operator leaves from constant literals; get-type
;; can: True/False -> Bool, numbers -> Number, while a clause-headed operator
;; symbol (operator clauses carry no type declaration) -> %Undefined%.
;; WARNING: adding a (: <op> ...) type declaration to ANY operator would make
;; get-type return a non-%Undefined% type and silently reroute that
;; operator's bare-symbol leaves to the constant-literal branch below instead
;; of clause dispatch -- keep operator clauses undeclared.
(= (isActionGroundLiteral $x) (not (== (get-type $x) %Undefined%)))

;; evalAction: wrapped expression -> (mkARes Bool World).
;;   (op (children)) node  -> operator clause via evalActionNode
;;   malformed expression  -> defined-worst
;;   grounded literal      -> constant result, world untouched
;;   bare op-symbol leaf   -> normalized to a childless node (op ())
(= (evalAction $exp $world)
   (if (== (get-metatype $exp) Expression)
       (if (== (size-atom $exp) 2)
           (let ($op $children) $exp
                (evalActionNode $op $children $world))
           (mkARes False $world))
       (if (== (get-metatype $exp) Grounded)
           (if (isActionGroundLiteral $exp)
               (mkARes $exp $world)
               (evalActionNode $exp () $world))
           (evalActionNode $exp () $world))))

;; actionExp: Tree -> wrapped executable shape; the action analog of
;; preOrderExp (scoring/boolean-ops.metta:20-33), same clause structure
;; including the mkKnob/mkNullVex passthroughs. Every node and every symbol
;; leaf becomes (op (children)) -- uniform dispatch; only grounded literals
;; (True/False, numbers such as repeat_n's count) stay bare. Emissions are
;; quote-protected as in preOrderExp -- REQUIRED here: every operator symbol
;; heads a bare clause (scoring/action-ops), so an unquoted ($r $children)
;; emission in this evaluated body position would fire it.
(= (actionExp (mkTree (mkNode $r) ()))
   (if (== (get-metatype $r) Grounded)
       (if (isActionGroundLiteral $r) $r (quote ($r ())))
       (quote ($r ()))))
(= (actionExp (mkKnob (mkNullVex $tree) $lsk $i)) ())
(= (actionExp (mkKnob (mkTree $node $children) $lsk $i))
   (actionExp (mkTree $node $children)))
(= (actionExp (mkTree (mkNode $r) (cons $x $xs)))
   (let $childrenExp (actionChildrenExp (cons $x $xs))
        (quote ($r $childrenExp))))

;; actionChildrenExp: actionExp over child Trees, dropping empty knob
;; passthroughs (mirrors childrenExp in boolean-ops).
(= (actionChildrenExp $children)
   (filter-atom (map-atom $children $c (actionExp $c)) $x (!= $x ())))
