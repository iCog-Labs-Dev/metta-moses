;; Generic action-tree evaluator: the action-domain analog of the boolean
;; columnar design (scoring/boolean-ops + fitness/evalSubtree). The engine
;; below NEVER names a concrete operator.
;;
;; THE CONTRACT: every operator -- structural combinator, domain action, or
;; perception -- is ONE clause
;;     (= (actionOp <name> $children $world) (mkARes <Bool> <World'>))
;; $children arrives UNEVALUATED in wrapped shape (each child is (op (cs)),
;; a bare-symbol/grounded leaf, or a nested node); the clause calls evalAction
;; back for the children it chooses, in the order it chooses -- that is what
;; makes and_seq sequential and action_bool_if lazy. Uniform result
;; (mkARes $bool $world): action success/failure and perception truth share
;; one protocol. $world is opaque to the engine and to all structural ops --
;; only domain clauses inspect it. Unknown operator -> no actionOp clause
;; matches -> the call FAILS (collapse yields ()) -> the engine returns the
;; defined-worst (mkARes False $world), the analog of boolean's
;; unreduced -> -1 at fitness.metta:124.
;;
;; Loads after scoring/action-registry (whose actionOp sentinel clause makes
;; the actionOp call site below compile as a real, dynamically-dispatched
;; call) and before scoring/action-ops and any domain package.

;; isARes: is $r a well-formed (mkARes $v $w) result? Guarded if-chain, NOT
;; `and` -- size-atom/car-atom on a non-expression would error.
(= (isARes $r)
   (if (== (get-metatype $r) Expression)
       (if (== (size-atom $r) 3)
           (if (== (car-atom $r) mkARes) True False)
           False)
       False))

;; evalActionNode: dispatch ONE node to its operator clause. collapse turns
;; the no-clause failure (unknown op, wrong child-count for a fixed-arity op)
;; into (), and a clause that returned a malformed result is also mapped to
;; the defined-worst -- the engine can never fail or return a non-ARes.
(= (evalActionNode $op $children $world)
   (chain (collapse (actionOp $op $children $world)) $rs
     (if (== $rs ())
         (mkARes False $world)
         (let $r (car-atom $rs)
              (if (isARes $r) $r (mkARes False $world))))))

;; evalAction: wrapped expression -> (mkARes Bool World).
;;   (op (children)) node  -> operator clause via evalActionNode
;;   malformed expression  -> defined-worst
;;   grounded literal      -> constant result, world untouched
;;   bare symbol leaf      -> normalized to a childless node (op ())
(= (evalAction $exp $world)
   (if (== (get-metatype $exp) Expression)
       (if (== (size-atom $exp) 2)
           (let ($op $children) $exp
                (evalActionNode $op $children $world))
           (mkARes False $world))
       (if (== (get-metatype $exp) Grounded)
           (mkARes $exp $world)
           (evalActionNode $exp () $world))))

;; actionExp: Tree -> wrapped executable shape; the action analog of
;; preOrderExp (scoring/boolean-ops.metta:20-33), same clause structure
;; including the mkKnob/mkNullVex passthroughs. Every node and every symbol
;; leaf becomes (op (children)) -- uniform dispatch; only grounded literals
;; (True/False, numbers such as repeat_n's count) stay bare. Emissions are
;; quote-protected as in preOrderExp (harmless here -- no operator symbol
;; heads a clause -- but it keeps the emitter shape-identical).
(= (actionExp (mkTree (mkNode $r) ()))
   (if (== (get-metatype $r) Grounded)
       $r
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
