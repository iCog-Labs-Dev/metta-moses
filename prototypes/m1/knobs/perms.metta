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
(= (fillersOfType $type)
   (let $literals (map-atom (primsOfType $type) $symbol (leafOf $symbol))
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
(= (sampleCandidates $operators $budget)
   (let $walked (map-atom (rangeTo (permLimit $operators)) $index
                          (candidateAt $operators $index))
     (takeFirst $budget (nub (filter-atom $walked $candidate (!= $candidate ()))))))

;; Which operators may head a candidate for a slot of type $type sitting under
;; $parent. Not the parent's own operator -- (and_seq (and_seq ...)) says
;; nothing new, and for tests this is exactly the AND/OR alternation: the
;; candidates offered inside an AND are ORs and vice versa.
(= (permittedOpsFor $parent $type)
   (filter-atom (opsOfType $type) $operator (!= $operator $parent)))

;; Every candidate for a slot of type $type under $parent.
(= (samplePerms $parent $type)
   (let* (($literals (map-atom (primsOfType $type) $symbol (leafOf $symbol)))
          ($operators (permittedOpsFor $parent $type))
          ($compounds (if (== $operators ())
                          ()
                          (sampleCandidates $operators (permCount)))))
     (union-atom $literals $compounds)))

;; the boolean case is the same question asked of type Bool
(= (sampleLogicalPerms $parent) (samplePerms $parent Bool))
