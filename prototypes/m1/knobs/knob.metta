;; ============================================================================
;; knobs/knob.metta -- what a knob IS.
;;
;; A knob is a choice the search can make, attached to one position in a tree:
;;
;;     (mkKnob <what it controls> <the knob> <its index>)
;;
;; The index is the knob's slot in the instance vector -- the vector of small
;; integers the search actually moves in. Two kinds of knob:
;;
;;     (mkLSK <settings> <default>)         0 = absent, 1 = present, 2 = negated
;;     (mkASK <settings> <default> <perms>) 0 = absent, n = the (n-1)th perm
;;
;; ONE counter hands out indices, for both kinds. Two counters is the classic
;; way to break this: the indices collide, decode reads the wrong slot, and
;; nothing reports an error -- you just get a different program than you asked
;; for. tests/t-knobs.metta pins that.
;; ============================================================================

!(bind! &knobCount (new-state 0))

(= (nextIdx)
   (let* (($i (get-state &knobCount))
          ($_ (change-state! &knobCount (+ $i 1))))
     $i))

(= (resetIdx) (change-state! &knobCount 0))


;; ---------------------------------------------------------------------------
;; logicalSubtreeKnob -- decide what a boolean knob controls, and whether it
;; starts switched on.
;;
;; $children is what the node already has; $perm is a candidate subtree.
;;
;;   the candidate is already there            -> control it, start ON
;;   its NEGATION is already there             -> control that, start ON
;;   neither                                   -> control a placeholder, OFF
;;
;; The middle case is the one that matters. It means an exemplar whose
;; condition is (NOT p) is preserved: the knob for p controls the (NOT p)
;; that is already present. Deciding this by looking at the candidate's head
;; symbol instead would quietly throw such an exemplar away -- which would
;; break feeding an evolved program back in as the next starting point, the
;; very thing that lets conditions get more elaborate over time.
;;
;; Polarity is still fully reachable: setting 2 negates whatever is
;; controlled, so a controlled (NOT p) at setting 2 gives (NOT (NOT p)),
;; which is p once reduction tidies it up.
;; ---------------------------------------------------------------------------
(= (logicalSubtreeKnob $children $perm)
   (if (containsIn $children $perm)
       ($perm (mkLSK 3 1))
       (let $neg (negated $perm)
         (if (containsIn $children $neg)
             ($neg (mkLSK 3 1))
             ((mkNullVex ($perm)) (mkLSK 3 0))))))

;; an action-side knob: keep this subtree, or drop it
(= (subtreeKnob $child) ($child (mkASK 2 1 ($child))))
