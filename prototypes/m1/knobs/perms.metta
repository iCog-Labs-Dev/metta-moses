;; ============================================================================
;; knobs/perms.metta -- the candidates offered at one position in a program.
;;
;; A CANDIDATE (a "perm") is one complete subtree the search may switch on
;; there. Two kinds, and the second is what gives the search any reach at all:
;;
;;   a single primitive                  m1Grab            m1FoodHere
;;   an operator with EVERY argument
;;   filled by a primitive of the type
;;   that argument asks for              (or_seq m1Grab m1Step)
;;                                       (action_bool_if m1FoodHere m1Grab m1Step)
;;                                       (OR (NOT m1FoodHere) m1FoodAhead)
;;
;; A partly filled operator is not a candidate. It becomes one only when the
;; last argument has been supplied -- which is why the types matter: a slot
;; that asks for a Bool is filled from the things that produce a Bool, and an
;; Act slot from the things that produce an Act, so no candidate is ever
;; nonsense.
;;
;; ONE CANDIDATE IS ONE KNOB -- always, whether it is a bare primitive or a
;; three-argument conditional. How many candidates there are and how many
;; settings a knob has are unrelated questions. A knob's settings are the ways
;; the SAME candidate can be handled:
;;
;;     an action candidate   drop it, or keep it                 2 settings
;;     a test candidate      drop it, keep it, or negate it      3 settings
;;
;; Counting candidates as settings of a single knob would be a different and
;; much weaker thing: the search could then hold at most one of them at a time.
;;
;; Nothing here is random. "An arbitrary operator with arbitrary arguments" is
;; a deterministic walk over the whole space of fillings, so a run reproduces
;; exactly; replace the index with a random draw and nothing else changes.
;; ============================================================================

;; How many children to give an operator that takes any number of them. Two --
;; one level of structure beyond a bare primitive, which is the point.
(= (seqArity) 2)

;; How many operator-headed candidates to sample per position. The full space
;; is much larger; this is the budget.
(= (permCount) 6)

;; What each argument slot of a sampled use of $operator asks for.
(= (slotTypesOf $operator)
   (let $argTypes (argTypeOf $operator)
     (if (== (car-atom $argTypes) Seq)
         (repeat (index-atom $argTypes 1) (seqArity))
         $argTypes)))

;; What may go IN one of those slots. Primitives of the right type -- and, for
;; a test, their negations too. There is no knob inside a candidate to flip a
;; polarity later, so both polarities have to be offered up front; this is what
;; makes (OR (NOT p) q) reachable.
;; --- turning a primitive into candidates ------------------------------------
;; Most primitives are ONE leaf: `m1FoodHere` is a candidate, full stop.
;;
;; A primitive can instead be a FAMILY. `colAt` is one function standing for
;; every column of a table, so the builder adds one leaf per column -- (colAt
;; (0)), (colAt (1)), (colAt (2)) -- and neither the builder nor colAt itself
;; ever chooses between them. They are simply N candidates that happen to share
;; a definition, exactly as N per-column primitives were N candidates that did
;; not.
;;
;; A family says how big it is by defining `paramsOf`; a single leaf says
;; nothing, and there is nothing to say. The seed clause below exists only so
;; the predicate is defined: an unmatched call then FAILS and collapses to (),
;; whereas a call to a predicate with no clauses at all comes back unreduced.
(= (paramsOf noSuchPrimitive) ())

(= (instancesOf $op)
   (let $found (collapse (paramsOf $op))
     (if (== $found ())
         ((leafOf $op))
         (map-atom (car-atom $found) $slot
                   (mkTree (mkNode $op) (map-atom $slot $param (leafOf $param)))))))

;; Every candidate leaf of a type -- the flattened vocabulary.
(= (literalsOfType $type)
   (foldl-atom (primsOfType $type) () $found $symbol
               (union-atom $found (instancesOf $symbol))))

(= (fillersOfType $type)
   (let $literals (literalsOfType $type)
     (if (== $type Bool)
         (union-atom $literals (map-atom $literals $literal (negated $literal)))
         $literals)))

(= (vocabsOf $operator) (map-atom (slotTypesOf $operator) $type (fillersOfType $type)))

;; --- walking the fillings ---------------------------------------------------
;; The $index-th way of filling the slots, counted like an odometer over the
;; vocabularies: the LAST slot turns fastest, so consecutive indices vary the
;; trailing arguments while holding the leading one steady. With the first slot
;; turning fastest, a three-argument operator would repeat its last two
;; arguments for as long as the budget lasted.
;;
;; Reading the vocabularies right to left is what makes the last slot fastest;
;; the accumulator carries what is left of the index, and the picks pile up in
;; the correct order as it goes.
(= (fillAt $vocabs $index)
   (let ($leftover $args)
        (foldl-atom (reverse $vocabs) ($index ()) $acc $vocab
          (let* ((($remaining $picked) $acc)
                 ($size (size-atom $vocab))
                 ($choice (index-atom $vocab (% $remaining $size))))
            ((floor-math (/ $remaining $size)) (cons-atom $choice $picked))))
     $args))

(= (fillCount $vocabs) (foldl-atom $vocabs 1 $total $vocab (* $total (size-atom $vocab))))

;; --- which fillings are worth a knob ----------------------------------------
;; Two slots holding the same test add nothing: (OR p p) is just p, and
;; (OR p (NOT p)) is just true. So a filling is thrown away when two slots
;; share a base, polarity ignored.
(= (baseOf $subtree)
   (if (== (nodeSymOf $subtree) NOT) (car-atom (kidsOf $subtree)) $subtree))

(= (allDistinct $items) (== (size-atom $items) (size-atom (nub $items))))

;; ...and an argument is never headed by the operator it sits under. That is
;; the same rule that keeps an OR out of an OR one level up, applied one level
;; down: it is what stops (NOT (NOT p)) being offered as though it were new.
(= (usableFilling $operator $args)
   (and (allDistinct (map-atom $args $arg (baseOf $arg)))
        (not (containsIn (map-atom $args $arg (nodeSymOf $arg)) $operator))))

;; --- sampling ---------------------------------------------------------------
;; The $index-th candidate: operators taken in turn, so a small budget spends
;; itself across all of them instead of exhausting the first. Unusable fillings
;; come back as (), and are dropped below.
(= (candidateAt $operators $index)
   (let* (($count (size-atom $operators))
          ($operator (index-atom $operators (% $index $count)))
          ($args (fillAt (vocabsOf $operator) (floor-math (/ $index $count)))))
     (if (usableFilling $operator $args) (mkTree (mkNode $operator) $args) ())))

;; how far the walk has to go before every operator has run out of fillings
(= (permLimit $operators)
   (* (size-atom $operators)
      (maxOf (map-atom $operators $operator (fillCount (vocabsOf $operator))))))

;; Walk the whole space, drop the unusable, drop repeats (an operator with few
;; fillings comes round again), keep the first $budget.
;; AND, and_seq => (AND berryFresh berryWorm), (action_bool_if berryFresh berrPick berryWalk)
;; (Seq Bool)
(= (sampleCandidates $operators $budget)
   (let $walked (map-atom (rangeTo (permLimit $operators)) $index
                          (candidateAt $operators $index))
     (takeFirst $budget (nub (filter-atom $walked $candidate (!= $candidate ()))))))

;; Which operators may head a candidate for a slot of type $type sitting under
;; $parent. Not the parent's own operator -- (and_seq (and_seq ...)) says
;; nothing new, and for tests this is exactly the AND/OR alternation: the
;; candidates offered inside an AND are ORs and vice versa.
;; An operator none of whose slots can be filled is not a candidate head at all.
;; Without this the odometer walks into (% $remaining 0) inside fillAt, and that
;; is NOT a silent failure: `%` compiles to a direct goal outside reduce's catch
;; (metta.pl), so the whole run dies with a zero-divisor.
;;
;; It bites as soon as a domain has a vocabulary for one type and none for
;; another. A numeric table is exactly that: numGt is fillable from the columns
;; and lifts permLimit above zero, while AND and OR have no Bool literals to
;; draw on -- and then candidateAt reaches the unfillable one. With ONLY
;; unfillable operators permLimit is 0, rangeTo 0 is (), and candidateAt is
;; never reached, which is why this went unnoticed for so long.
(= (isFillable $operator) (> (fillCount (vocabsOf $operator)) 0))

(= (permittedOpsFor $parent $type)
   (filter-atom (opsOfType $type) $operator
                (and (isFillable $operator) (!= $operator $parent)))) ;; (AND (AND) ) => and_seq, and_seq

;; Every candidate for a slot of type $type under $parent.
(= (samplePerms $parent $type) ;; A, B, C (AND B C), (OR B C)
   (let* (($literals (literalsOfType $type))
          ($operators (permittedOpsFor $parent $type))
          ($compounds (if (== $operators ())
                          ()
                          (sampleCandidates $operators (permCount)))))
     (union-atom $literals $compounds)))

;; the boolean case is the same question asked of type Bool
(= (sampleLogicalPerms $parent) (samplePerms $parent Bool))
