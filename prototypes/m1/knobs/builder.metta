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
;;
;; The literal branch wraps and knobs, and THEN goes inside for numbers.
;; `buildInner` runs after addLogicalKnobs and never before: assignKnobs matches
;; a candidate against the children the node already has, and a knob-bearing
;; child matches nothing, so knobbing first would drop the exemplar's own
;; condition and re-offer it as a placeholder -- losing the round trip. classic
;; orders it the same way (build_knobs.cc: add_logical_knobs, then
;; contin_canonize + build_contin on the predicate's argument).
(= (buildLogical $tree $parentOp)
   (if (isJunctor (nodeSymOf $tree))
       (let* (($op      (nodeSymOf $tree))
              ($knobbed (addLogicalKnobs $tree))
              ($deeper  (map-atom (kidsOf $knobbed) $child (recurseKid $child $op)))
              ($fresh   (addLogicalKnobs (mkTree (mkNode (swapAndOr $op)) ()))))
         (mkTree (mkNode $op) (union-atom $deeper ($fresh))))
       (buildInner
         (addLogicalKnobs (mkTree (mkNode (swapAndOr $parentOp)) ($tree))))))

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
;; A Bool slot gets the whole boolean treatment above. logicalCanonize always
;; hands back a junctor, so buildLogical takes its first branch and the parent
;; op is never read -- the tree's own symbol stands in for it.
(= (buildBoolSlot $child)
   (let $canonized (logicalCanonize $child)
     (buildLogical $canonized (nodeSymOf $canonized))))

;; Any other slot: a primitive child is knobbed; a compound child is gone into,
;; so its own slots get knobbed instead.
(= (addSimpleActionKnobs $child)
   (if (isPrimitive (nodeSymOf $child))
       (wrapKnob (simpleActionSubtreeKnob $child))
       (buildNode $child)))

;; A Number slot gets a knob on its VALUE. A Params slot gets NOTHING -- it is a
;; parametrised leaf's own parameter, colAt's column index, and the walk must
;; not go inside. Remove that branch and a column index becomes tunable: the
;; program stays well-formed and starts reading the wrong column. classic needs
;; no such branch because there an argument is a different vertex type from a
;; constant, so its scan cannot see one.
(= (buildSlot $type $child)
   (if (== $type Params)
       $child
       (if (== $type Bool)
           (buildBoolSlot $child)
           (if (== $type Number)
               (buildNumberSlot $child)
               (addSimpleActionKnobs $child)))))

;; A number the author wrote gets a walk attached, with itself as the mean.
;; Anything else is a subtree, walked for numbers of its own.
;;
;; isNumberLiteral, NOT isGroundLiteral: the latter is true of Bool and String
;; too, so it would make True or "8" the mean of an arithmetic walk. Literals of
;; other types are left as written -- there is no knob kind for them yet.
(= (buildNumberSlot $child)
   (if (isNumberLiteral (nodeSymOf $child))
       (continKnobFor $child)
       (buildInner $child)))

;; --- looking inside something the boolean recursion treats as opaque --------
;; m1's build_contin: a flat walk that knobs ONLY Number slots and walks through
;; every other kind. It must not send a Bool slot to buildSlot -- that would
;; re-enter the boolean machinery and double every knob already hung.
;;
;; It goes THROUGH a knob, since a controlled subtree may hold a number, and
;; stops at a PLACEHOLDER: knobSpecs reports no knobs inside a switched-off
;; candidate, so a knob there would leave a gap in the instance vector. That is
;; why a tunable number has to be one the exemplar wrote.
(= (buildInner (mkKnob $subtree $knob $index))
   (mkKnob (buildInner $subtree) $knob $index))
(= (buildInner (mkNullVex $held)) (mkNullVex $held))
(= (buildInner (mkTree (mkNode $symbol) $children))
   (if (isPrimitive $symbol)
       (mkTree (mkNode $symbol) $children)
       (mkTree (mkNode $symbol)
               (map-atom (rangeTo (size-atom $children)) $slot
                 (let $child (index-atom $children $slot)
                   (if (== (slotType $symbol $slot) Number)
                       (buildNumberSlot $child)
                       (buildInner $child)))))))

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
