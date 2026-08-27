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

;; Claim $count CONSECUTIVE slots and answer the first. Most knobs want one; a
;; tunable number wants `depth` of them, because classic spends one 3-way slot
;; per step of the walk that finds its number (field_set.cc: "One 'cooked'
;; contin field consists of contin_spec::depth raw fields").
(= (nextIdxN $count)
   (let* (($index (get-state &knobCount))
          ($ignored (change-state! &knobCount (+ $index $count))))
     $index))

(= (nextIdx) (nextIdxN 1))

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


;; ============================================================================
;; A TUNABLE NUMBER.  (classic: contin_spec + contin_stepper + contin_knob)
;;
;; The other two knobs choose a SUBTREE. This one chooses a VALUE, and the way
;; classic makes that fit a discrete search is worth restating, because it is
;; not obvious: THE VALUE IS NEVER STORED. What is stored is a WALK.
;;
;; Start at `mean`. At each step go Left, go Right, or Stop. While every step so
;; far has gone the same way the step size GROWS by `expansion` -- that is how
;; few steps reach far from the mean. The first time the direction reverses, the
;; step is halved from then on -- that is how it lands precisely. So the walk
;; travels far AND finely, which an evenly spaced grid of the same width cannot.
;;
;; Classic splits this in two -- a contin_knob holds a location and a spec,
;; while field_set owns the trit encoding. m1 has no field set, so mkCTK is both.
;;
;; Classic's canonization is deliberately NOT copied: it PLANTS constants
;; (contin_canonize, append_linear_combination's *(0 $i) per argument) so that
;; tuning a coefficient off zero switches an input on. That is the
;; symbolic-regression half and the reason it needs ~43 reduction rules. Here a
;; number is tunable only where the declared slot type says Number -- see
;; knobs/builder.metta.
;; ============================================================================

;; Step, expansion and depth. No mean: the mean is whatever number sits in the
;; slot when the representation is built, never something declared.
;;
;; ONE spec for the whole run, as in classic, where these are build_knobs
;; members with no per-position override -- the adaptive version is #if 0'd out
;; in representation.cc for slowing the search down.
(= (continDefaults) (mkContin 8 2 3))

;; --- the walk ---------------------------------------------------------------
;; classic's contin_stepper (field_set.h). `left` and `right` are mirrors: the
;; first branch is the expansion phase, the second the bisection phase, and the
;; `adjusted` step undoes the last expansion on the step that reverses.
;;
;; Note that a Left clears only allRight -- so a second Left is STILL in the
;; expansion phase. Clearing both would turn (1 1) from -3 into -1.5.
(= (continLeft $expansion (mkWalk $value $step $allLeft $allRight))
   (if $allLeft
       (mkWalk (- $value $step) (* $step $expansion) True False)
       (let $adjusted (if $allRight (/ $step (* $expansion 2)) $step)
         (mkWalk (- $value $adjusted) (/ $adjusted 2) False False))))

(= (continRight $expansion (mkWalk $value $step $allLeft $allRight))
   (if $allRight
       (mkWalk (+ $value $step) (* $step $expansion) False True)
       (let $adjusted (if $allLeft (/ $step (* $expansion 2)) $step)
         (mkWalk (+ $value $adjusted) (/ $adjusted 2) False False))))

;; (mkStopped $value) absorbs every later trit -- classic `break`s, and a fold
;; cannot, so a distinct shape is how the walk remembers it is over. The four
;; clauses are disjoint, first on shape then on trit; an overlapping one would
;; multiply solutions silently rather than erroring.
(= (continMove $expansion (mkStopped $value)   $trit) (mkStopped $value))
(= (continMove $expansion (mkWalk $v $s $l $r) 0)     (mkStopped $v))
(= (continMove $expansion (mkWalk $v $s $l $r) 1) (continLeft  $expansion (mkWalk $v $s $l $r)))
(= (continMove $expansion (mkWalk $v $s $l $r) 2) (continRight $expansion (mkWalk $v $s $l $r)))

(= (walkValue (mkStopped $value))       $value)
(= (walkValue (mkWalk $value $s $l $r)) $value)

;; Both flags start True, so the very first move is an expansion whichever way
;; it goes.
(= (continWalk $trits $mean $step $expansion)
   (walkValue (foldl-atom $trits (mkWalk $mean $step True True) $walk $trit
                          (continMove $expansion $walk $trit))))

;; --- building one -----------------------------------------------------------
;; THE MEAN COMES FROM THE TREE -- whatever number sits in the slot when the
;; representation is built, so all-Stop decodes back to the program that was
;; built. classic does the same (contin_knob's spec takes get_contin(*tgt)).
;; There is deliberately no way to DECLARE a mean: a number nobody wrote is a
;; number nobody can tune.
(= (continKnobFor $leaf)
   (let* (((mkContin $step $expansion $depth) (continDefaults))
          ($first (nextIdxN $depth)))
     (mkKnob $leaf (mkCTK (nodeSymOf $leaf) $step $expansion $depth) $first)))
