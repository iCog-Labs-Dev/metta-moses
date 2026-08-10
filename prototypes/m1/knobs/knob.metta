;; ============================================================================
;; knobs/knob.metta -- what a knob IS.
;;
;; A knob is a choice the search can make, attached to one position in a tree:
;;
;;     (mkKnob <what it controls> <the knob> <its index>)
;;
;; The index is the knob's slot in the instance vector -- the vector of small
;; integers the search actually moves in. Two kinds of knob, carrying the names
;; they have in the production tree and in classic MOSES:
;;
;;     (mkLSK <settings> <default>)         logical_subtree_knob
;;                                          0 = absent, 1 = present, 2 = negated
;;     (mkASK <settings> <default> <perms>) action_subtree_knob
;;                                          0 = absent, n = the (n-1)th perm
;;
;; A knob holds ONE candidate, and its settings are the ways THAT candidate can
;; be handled -- three for a test (absent, as written, negated), two for an
;; action (absent, present). The number of candidates offered at a position is
;; a different quantity entirely: it is the number of knobs there, never the
;; width of one of them.
;;
;; ONE counter hands out indices, for both kinds. Two counters is the classic
;; way to break this: the indices collide, decode reads the wrong slot, and
;; nothing reports an error -- you just get a different program than you asked
;; for. tests/t-knobs.metta pins that.
;; ============================================================================

!(bind! &knobCount (new-state 0))

(= (nextIdx)
   (let* (($index (get-state &knobCount))
          ($ignored (change-state! &knobCount (+ $index 1))))
     $index))

(= (resetIdx) (change-state! &knobCount 0))


;; ---------------------------------------------------------------------------
;; logicalSubtreeKnob -- decide what a boolean knob controls, and whether it
;; starts switched on.
;;
;; $children is what the node already has; $candidate is one thing on offer.
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
(= (logicalSubtreeKnob $children $candidate)
   (if (containsIn $children $candidate)
       ($candidate (mkLSK 3 1))
       (let $negatedCandidate (negated $candidate)
         (if (containsIn $children $negatedCandidate)
             ($negatedCandidate (mkLSK 3 1))
             ((mkNullVex ($candidate)) (mkLSK 3 0))))))

;; An action-side knob over something the program ALREADY has: keep it, or drop
;; it. Two settings, whatever the subtree is. (classic: simple_action_subtree_knob)
(= (simpleActionSubtreeKnob $child) ($child (mkASK 2 1 ($child))))

;; The same knob for a candidate the program does NOT have yet: add it, or
;; leave it out. Starts out. (classic: action_subtree_knob)
(= (actionSubtreeKnob $candidate) ((mkNullVex ($candidate)) (mkASK 2 0 ($candidate))))
