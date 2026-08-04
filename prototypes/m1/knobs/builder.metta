;; ============================================================================
;; knobs/builder.metta -- turning one program into a space of programs.
;;
;; NO OPERATOR IS NAMED IN THIS FILE. Every decision is a question about types:
;; what does this slot want, and what can produce that? Add an operator with a
;; Bool slot anywhere and it gets an evolved condition, with no change here.
;; ============================================================================

;; --- attaching knobs to one boolean node ------------------------------------
;; Every candidate gets a knob. A candidate that MATCHES something already in
;; the node takes it over (and starts switched on); the rest become
;; switched-off placeholders. Children nothing matched are left alone.
(= (wrapKnob ($sub $k)) (let $i (nextIdx) (mkKnob $sub $k $i)))

(= (wrapKnobs ()) ())
(= (wrapKnobs (cons $q $rest))
   (let* (($k (wrapKnob $q))
          ($r (wrapKnobs $rest)))
     (cons-atom $k $r)))

(= (addLogicalKnobs (mkTree (mkNode $op) $children) $labels)
   (let* (($perms (logicalPerms $op $labels))
          ($pairs (map-atom $perms $p (logicalSubtreeKnob $children $p)))
          ($taken (map-atom $pairs $q (car-atom $q)))
          ($knobbed (wrapKnobs $pairs))
          ($kept (without $children $taken)))
     (mkTree (mkNode $op) (union-atom $kept $knobbed))))

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
(= (buildLogical $tree $parentOp $labels)
   (if (isJunctor (nodeSymOf $tree))
       (buildJunctor $tree $labels)
       (addLogicalKnobs (mkTree (mkNode (flipJunctor $parentOp)) ($tree)) $labels)))

(= (buildJunctor (mkTree (mkNode $op) $children) $labels)
   (let* (($knobbed (addLogicalKnobs (mkTree (mkNode $op) $children) $labels))
          ($deeper (recurseKids (kidsOf $knobbed) $op $labels))
          ($fresh (addLogicalKnobs (mkTree (mkNode (flipJunctor $op)) ()) $labels)))
     (mkTree (mkNode $op) (union-atom $deeper ($fresh)))))

(= (recurseKids () $op $labels) ())
(= (recurseKids (cons $c $rest) $op $labels)
   (let* (($b (recurseKid $c $op $labels))
          ($r (recurseKids $rest $op $labels)))
     (cons-atom $b $r)))

;; a knob holding a real subtree is gone into; a placeholder is not, because
;; there is nothing there yet
(= (recurseKid (mkKnob $sub $k $i) $op $labels)
   (if (isNullVex $sub)
       (mkKnob $sub $k $i)
       (mkKnob (buildLogical $sub $op $labels) $k $i)))
(= (recurseKid (mkTree $node $kids) $op $labels)
   (buildLogical (mkTree $node $kids) $op $labels))

;; a lone literal becomes a one-element conjunction, so the recursion above
;; always starts at a junctor
(= (logicalCanonize $t)
   (if (isJunctor (nodeSymOf $t)) $t (mkTree (mkNode AND) ($t))))

;; --- slots ------------------------------------------------------------------
;; A Bool slot gets the whole boolean treatment above, over the Bool vocabulary.
(= (buildBoolSlot $child)
   (buildJunctor (logicalCanonize $child) (primsOfType Bool)))

;; Any other slot: a primitive child is knobbed; a compound child is gone into,
;; so its own slots get knobbed instead.
(= (buildSubKnob $child)
   (if (isPrimitive (nodeSymOf $child))
       (wrapKnob (subtreeKnob $child))
       (buildNode $child)))

(= (buildSlot $t $child)
   (if (== $t Bool) (buildBoolSlot $child) (buildSubKnob $child)))

;; walked with explicit recursion rather than map-atom, so indices are handed
;; out strictly left to right
(= (buildSlots () $op $i) ())
(= (buildSlots (cons $c $rest) $op $i)
   (let* (($b (buildSlot (slotType $op $i) $c))
          ($r (buildSlots $rest $op (+ $i 1))))
     (cons-atom $b $r)))

;; A node that takes any number of children gets one extra, knobbed over that
;; type's vocabulary -- this is how the search GROWS a program rather than only
;; editing what is already there.
(= (extraSlot $op)
   (if (isVariadic $op)
       (let* (($t (index-atom (argTypeOf $op) 1))
              ($i (nextIdx))
              ($perms (map-atom (primsOfType $t) $s (leafOf $s))))
         ((mkKnob (mkNullVex ()) (mkASK (+ 1 (size-atom $perms)) 0 $perms) $i)))
       ()))

(= (buildNode (mkTree (mkNode $op) $children))
   (let* (($extra (extraSlot $op))
          ($built (buildSlots $children $op 0)))
     (mkTree (mkNode $op) (union-atom $built $extra))))

(= (buildRep $tree) (let $_ (resetIdx) (buildNode $tree)))
