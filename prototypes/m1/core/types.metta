;; ============================================================================
;; core/types.metta -- what the builder asks instead of naming operators.
;;
;; Every operator declares a signature (see domain/tape.metta for examples):
;;
;;     (: m1Grab        (-> Params      $ctx Act))   a primitive
;;     (: and_seq       (-> (Seq Act)   $ctx Act))   any number of Act children
;;     (: action_bool_if (-> (Bool Act Act) $ctx Act))  three children, typed
;;
;; The ARGUMENT part says what the operator's children are:
;;     Params           it has none -- it is a leaf that takes parameters
;;     (Seq $t)         any number, all of type $t
;;     ($t1 $t2 ...)    exactly this many, each with its own type
;;
;; From that, four questions answer everything the builder needs, and the
;; builder never has to know a single operator by name.
;; ============================================================================

;; AND/OR/NOT cannot carry a (: ...) declaration: a declaration applies to a
;; symbol regardless of how many arguments a use of it has, and these symbols
;; deliberately have two forms. Their signatures live here instead.
;; One clause with a chain of tests -- two clauses with the same head would
;; both apply and produce duplicate answers.
(= (sigFallback $op)
   (if (== $op AND) (-> (Seq Bool) $c Bool)
   (if (== $op OR)  (-> (Seq Bool) $c Bool)
   (if (== $op NOT) (-> (Bool) $c Bool)
                    (-> Params $c Unknown)))))

(= (sigOf $op) (let $t (get-type $op) (if (isExpr $t) $t (sigFallback $op))))

(= (argTypeOf $op) (index-atom (sigOf $op) 1))
(= (retTypeOf $op) (lastOf (sigOf $op)))

;; What does child number $i want to be?
(= (slotType $op $i)
   (let $a (argTypeOf $op)
     (if (isExpr $a)
         (if (== (car-atom $a) Seq) (index-atom $a 1) (index-atom $a $i))
         Params)))

(= (isPrimitive $op) (== (argTypeOf $op) Params))
(= (isVariadic $op)
   (let $a (argTypeOf $op) (if (isExpr $a) (== (car-atom $a) Seq) False)))

;; Which primitives produce type $t?  This is the vocabulary the builder draws
;; on, and it is read straight out of the declarations -- declare a new
;; primitive and it joins the vocabulary with no other change anywhere.
(= (primsOfType $t) (collapse (match &self (: $op (-> Params $c $t)) $op)))

;; Which OPERATORS produce type $t -- the ones that take children rather than
;; parameters? Same source, same story: declare one and it joins.
;;
;; `quote` on the result of the match is not optional. The pair ($op $a) is a
;; two-element term headed by a live operator, so without it the match template
;; CALLS the operator and hands back a half-applied term.
(= (declaredOpsOfType $t)
   (let $pairs (collapse (match &self (: $op (-> $a $c $t)) (quote ($op $a))))
     (map-atom (filter-atom $pairs $p (!= (index-atom $p 1) Params)) $p (car-atom $p))))

;; AND/OR/NOT carry no declaration (see the note above), so they are named here
;; -- this file is the one place in the prototype where an operator name may
;; appear, and everything else asks these questions instead.
(= (undeclaredOpsOfType $t) (if (== $t Bool) (quote (AND OR NOT)) ()))

(= (opsOfType $t) (union-atom (undeclaredOpsOfType $t) (declaredOpsOfType $t)))

;; Negation is a knob SETTING, not a candidate of its own: an LSK's third
;; setting already negates whatever it holds. So the negator is never offered
;; as an operator to build a candidate out of.
(= (isNegator $op) (== $op NOT))

;; --- boolean structure ------------------------------------------------------
;; AND and OR alternate as you go down a boolean expression: the children of an
;; AND are ORs and vice versa. `flip` is that alternation.
(= (isJunctor $op) (if (== $op AND) True (if (== $op OR) True False)))
(= (flipJunctor $op) (if (== $op AND) OR AND))
