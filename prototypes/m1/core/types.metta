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
;; From that, a handful of questions answer everything the builder needs, and
;; the builder never has to know a single operator by name. Classic MOSES asks
;; the same questions of a combo signature -- get_signature_inputs,
;; get_signature_output, permitted_op -- but has to hardcode the vocabulary per
;; problem type; here the declarations ARE the vocabulary.
;; ============================================================================

;; AND/OR/NOT cannot carry a (: ...) declaration: a declaration applies to a
;; symbol regardless of how many arguments a use of it has, and these symbols
;; deliberately have two forms. Their signatures live here instead.
;; One clause with a chain of tests -- two clauses with the same head would
;; both apply and produce duplicate answers.
(= (sigFallback $op)
   (if (== $op AND) (-> (Seq Bool) $ctx Bool)
   (if (== $op OR)  (-> (Seq Bool) $ctx Bool)
   (if (== $op NOT) (-> (Bool) $ctx Bool)
                    (-> Params $ctx Unknown)))))

(= (sigOf $op) (let $declared (get-type $op) (if (isExpr $declared) $declared (sigFallback $op))))

;; classic: get_signature_inputs / get_signature_output
(= (argTypeOf $op) (index-atom (sigOf $op) 1))
(= (retTypeOf $op) (lastOf (sigOf $op)))

;; What does child number $slot want to be?  (classic: std::next(arg_types, a))
(= (slotType $op $slot)
   (let $argTypes (argTypeOf $op)
     (if (isExpr $argTypes)
         (if (== (car-atom $argTypes) Seq)
             (index-atom $argTypes 1)
             (index-atom $argTypes $slot))
         Params)))

;; classic calls this is_argument (metta-moses: isAnArgument) -- the same test,
;; generalised past "is it a column of the input table".
(= (isPrimitive $op) (== (argTypeOf $op) Params))
(= (isVariadic $op)
   (let $argTypes (argTypeOf $op) (if (isExpr $argTypes) (== (car-atom $argTypes) Seq) False)))

;; Which primitives produce type $type?  This is the vocabulary the builder
;; draws on, and it is read straight out of the declarations -- declare a new
;; primitive and it joins the vocabulary with no other change anywhere.
(= (primsOfType $type) (collapse (match &self (: $op (-> Params $ctx $type)) $op)))

;; Which OPERATORS produce type $type -- the ones that take children rather
;; than parameters? Same source, same story: declare one and it joins.
;;
;; `quote` on the result of the match is not optional. The pair ($op $argTypes)
;; is a two-element term headed by a live operator, so without it the match
;; template CALLS the operator and hands back a half-applied term.
(= (declaredOpsOfType $type)
   (let $signatures (collapse (match &self (: $op (-> $argTypes $ctx $type))
                                     (quote ($op $argTypes))))
     (map-atom (filter-atom $signatures $sig (!= (index-atom $sig 1) Params))
               $sig (car-atom $sig))))

;; AND/OR/NOT carry no declaration (see the note above), so they are named here
;; -- this file is the one place in the prototype where an operator name may
;; appear, and everything else asks these questions instead.
(= (undeclaredOpsOfType $type) (if (== $type Bool) (quote (AND OR NOT)) ()))

(= (opsOfType $type) (union-atom (undeclaredOpsOfType $type) (declaredOpsOfType $type)))

;; --- boolean structure ------------------------------------------------------
;; AND and OR alternate as you go down a boolean expression: the children of an
;; AND are ORs and vice versa. `swapAndOr` is that alternation, and carries the
;; same name it has in the production tree (classic: swap_and_or).
(= (isJunctor $op) (if (== $op AND) True (if (== $op OR) True False)))
(= (swapAndOr $op) (if (== $op AND) OR AND))


;; ============================================================================
;; The declarations for the operators in core/operators.metta.
;;
;; They live HERE and not in a domain file because they are not any domain's
;; business: `Act` is the type the action operators are written over, and each
;; domain then declares its own primitives as producing it. Repeating this
;; block per domain -- which is what happened first -- means two domains cannot
;; be loaded together without duplicating every one of these, and a duplicated
;; declaration doubles every answer that goes through sigOf.
;;
;; AND, OR and NOT are absent on purpose: a declaration applies to a symbol no
;; matter how many arguments a use of it has, and those three deliberately have
;; two forms. sigFallback above carries their signatures instead.
;; ============================================================================
(: Act Type)
(: Params Type)

(: action_bool_if (-> (Bool Act Act) $ctx Act))
(: and_seq        (-> (Seq Act) $ctx Act))
(: or_seq         (-> (Seq Act) $ctx Act))
(: action_not     (-> (Act) $ctx Act))
