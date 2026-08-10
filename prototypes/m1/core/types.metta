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
;; the builder never has to know a single operator by name.
;;
;; A DECLARED OPERATOR CANNOT BE CALLED FROM A SOURCE CALL SITE -- only through
;; the evaluator's `reduce`, which never consults declarations. Writing
;; (AND (True False)) literally in a file yields nothing at all: the compiler
;; injects a type check at such a site, and a tuple's type comes back as
;; (Bool Bool), which does not unify with (Seq Bool). That is a property every
;; declared operator here already had; it only became visible when AND and OR
;; were declared, because they were the only ones anything called that way.
;;
;; This file still names AND, OR and NOT in isJunctor and swapAndOr, as do
;; logicalCanonize, negated and baseOf elsewhere. That is not vocabulary
;; hardcoding -- the AND/OR alternation is inherently about those symbols.
;; What the declarations removed is the hardcoded list of what EXISTS.
;;
;; Classic MOSES asks
;; the same questions of a combo signature -- get_signature_inputs,
;; get_signature_output, permitted_op -- but has to hardcode the vocabulary per
;; problem type; here the declarations ARE the vocabulary.
;; ============================================================================

;; Everything the builder needs comes from the declaration. A symbol with no
;; declaration falls back to "a leaf of unknown type" -- that net has to be
;; here, because without it argTypeOf would index into %Undefined% and produce
;; zero solutions in silence. action_success, action_failure and return_success
;; are undeclared today and reach this path.
(= (sigOf $op)
   (let $declared (get-type $op)
     (if (isExpr $declared) $declared (-> Params $ctx Unknown))))

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

(= (opsOfType $type) (declaredOpsOfType $type))

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
;; AND/OR/NOT are declared here like everything else. They could not be while
;; they had a second, context-free set of clauses, because a declaration makes
;; a symbol uncallable from a source call site -- see the note at the top of
;; this file -- and those clauses were the only thing calling them that way.
;; With one definition each, nothing calls them from source, so the cost is
;; zero and their signatures no longer have to be hardcoded.
;;
;; Order matters: it is the order primsOfType and declaredOpsOfType hand the
;; vocabulary back in, and knobs/perms.metta spends a budget walking that
;; vocabulary. domain/berries.metta depends on it deliberately.
;; ============================================================================
(: Act Type)
(: Params Type)

(: action_bool_if (-> (Bool Act Act) $ctx Act))
(: and_seq        (-> (Seq Act) $ctx Act))
(: or_seq         (-> (Seq Act) $ctx Act))
(: action_not     (-> (Act) $ctx Act))

(: AND (-> (Seq Bool) $ctx Bool))
(: OR  (-> (Seq Bool) $ctx Bool))
(: NOT (-> (Bool) $ctx Bool))
