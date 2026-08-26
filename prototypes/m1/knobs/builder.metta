;; ============================================================================
;; knobs/builder.metta -- turning one program into a space of programs.
;;
;; NO OPERATOR IS NAMED IN THIS FILE. Every decision is a question about types:
;; what does this slot want, and what can produce that? Add an operator with a
;; Bool slot anywhere and it gets an evolved condition, with no change here.
;;
;; Every walk below is a map. That is safe because map-atom applies its body
;; strictly left to right, and handing out knob indices is a side effect --
;; tests/t-knobs.metta pins the resulting order, so a runtime that reordered
;; the walk would be caught rather than silently producing a shuffled vector.
;; ============================================================================

;; --- attaching knobs to one boolean node ------------------------------------
;; Every candidate gets a knob. A candidate that MATCHES something already in
;; the node takes it over (and starts switched on); the rest become
;; switched-off placeholders. Children nothing matched are left alone.
(= (wrapKnob ($subtree $knob)) (let $index (nextIdx) (mkKnob $subtree $knob $index)))

(= (wrapKnobs $knobPairs) (map-atom $knobPairs $pair (wrapKnob $pair)))

;; Each existing child may be taken over by at most ONE candidate, so the walk
;; carries what has already been claimed. Two candidates really can match the
;; same child -- a child (NOT p) matches the candidate (NOT p) outright and the
;; candidate p through the negation rule -- and letting both take it would
;; switch it on twice and decode it twice. First candidate offered wins.
(= (assignKnobs $children $candidates)
   (foldl-atom $candidates (() ()) $acc $candidate
     (let* ((($claimed $pairs) $acc)
            ($pair (logicalSubtreeKnob (without $children $claimed) $candidate))
            ($controls (car-atom $pair)))
       (if (containsIn $children $controls)
           ((union-atom $claimed ($controls)) (union-atom $pairs ($pair)))
           ($claimed (union-atom $pairs ($pair)))))))

(= (addLogicalKnobs (mkTree (mkNode $op) $children))
   (let* (($candidates (sampleLogicalPerms $op))
          (($takenOver $knobPairs) (assignKnobs $children $candidates))
          ($knobbed   (wrapKnobs $knobPairs))
          ($untouched (without $children $takenOver)))
     (mkTree (mkNode $op) (union-atom $untouched $knobbed))))

;; --- the boolean recursion --------------------------------------------------
;; At a junctor:  knob here, go into the children, then APPEND an empty node
;;                of the opposite kind and knob that too -- an empty slot the
;;                search can grow into.
;; At a literal:  wrap it in the opposite kind and knob that, so a lone `p`
;;                can become `(OR p q)`.
;;
;; Between them these give one full AND-over-ORs-over-literals alternation per
;; build. Deeper structure accumulates when an evolved program is fed back in
;; as the next starting point.
(= (buildLogical $tree $parentOp)
   (if (isJunctor (nodeSymOf $tree))
       (buildJunctor $tree)
       (addLogicalKnobs (mkTree (mkNode (swapAndOr $parentOp)) ($tree)))))

(= (buildJunctor (mkTree (mkNode $op) $children))
   (let* (($knobbed (addLogicalKnobs (mkTree (mkNode $op) $children)))
          ($deeper  (recurseKids (kidsOf $knobbed) $op))
          ($fresh   (addLogicalKnobs (mkTree (mkNode (swapAndOr $op)) ()))))
     (mkTree (mkNode $op) (union-atom $deeper ($fresh)))))

(= (recurseKids $children $parentOp)
   (map-atom $children $child (recurseKid $child $parentOp)))

;; a knob holding a real subtree is gone into; a placeholder is not, because
;; there is nothing there yet
(= (recurseKid (mkKnob $subtree $knob $index) $parentOp)
   (if (isNullVex $subtree)
       (mkKnob $subtree $knob $index)
       (mkKnob (buildLogical $subtree $parentOp) $knob $index)))
(= (recurseKid (mkTree $node $children) $parentOp)
   (buildLogical (mkTree $node $children) $parentOp))

;; a lone literal becomes a one-element conjunction, so the recursion above
;; always starts at a junctor
(= (logicalCanonize $tree)
   (if (isJunctor (nodeSymOf $tree)) $tree (mkTree (mkNode AND) ($tree))))

;; --- slots ------------------------------------------------------------------
;; A Bool slot gets the whole boolean treatment above.
(= (buildBoolSlot $child) (buildJunctor (logicalCanonize $child)))

;; Any other slot: a primitive child is knobbed; a compound child is gone into,
;; so its own slots get knobbed instead.
(= (addSimpleActionKnobs $child)
   (if (isPrimitive (nodeSymOf $child))
       (wrapKnob (simpleActionSubtreeKnob $child))
       (buildNode $child)))

(= (buildSlot $type $child)
   (if (== $type Bool) (buildBoolSlot $child) (addSimpleActionKnobs $child)))

;; Each child is built against the type ITS OWN position asks for, so the walk
;; is over the positions rather than over the children.
(= (buildSlots $children $op)
   (map-atom (rangeTo (size-atom $children)) $slot
             (buildSlot (slotType $op $slot) (index-atom $children $slot))))

;; A node that takes any number of children can GROW: every candidate of the
;; right type gets its own switched-off knob, and switching one on adds that
;; child. This is how the search builds a program up rather than only editing
;; what is already there.
;;
;; ONE KNOB PER CANDIDATE, each with two settings -- drop it or keep it. Not
;; one knob whose settings are the candidates: that would let the node hold at
;; most one new child ever, so (and_seq GRAB STEP) could never be built, and
;; a conditional could never sit alongside anything else.
;;
;; `slotType` answers for any position of a variadic operator, so the element
;; type is one type query rather than a hand-taken-apart signature.
(= (extraSlot $op)
   (if (isVariadic $op) ;; Op nary
       (wrapKnobs (map-atom (samplePerms $op (slotType $op 0)) $candidate
                            (actionSubtreeKnob $candidate)))
       ()))

;; The growth knobs are bound FIRST, so they take the low indices; the demos
;; and tests read those positions by number.
(= (buildNode (mkTree (mkNode $op) $children))
   (let* (($grown (extraSlot $op)) ;; New Knobs
          ($built (buildSlots $children $op))) ;; Building children
     (mkTree (mkNode $op) (union-atom $built $grown))))

;; The root is built against the type IT produces, exactly as every other
;; position is built against the type its slot asks for. An action-rooted
;; exemplar reaches buildNode as before; a BOOLEAN-rooted one -- a program that
;; is nothing but a condition -- reaches buildBoolSlot instead, and so gets
;; three-setting test knobs and the AND/OR alternation rather than the
;; two-setting action knobs buildNode would have hung on it.
;;
;; Routing on the type here is the only thing that had to change for a purely
;; boolean problem to run through this machinery; see domain/alarm.metta.
(= (buildKnobs $tree)
   (let $ignored (resetIdx) (buildSlot (retTypeOf (nodeSymOf $tree)) $tree)))
