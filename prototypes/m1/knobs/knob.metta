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
;;     (mkASK <settings> <default>)         action_subtree_knob
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
;; contin knob wants `depth` of them, because classic spends one 3-way slot per
;; step of the walk that finds its number (field_set.cc: "One 'cooked' contin
;; field consists of contin_spec::depth raw fields").
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
(= (simpleActionSubtreeKnob $child) ($child (mkASK 2 1)))

;; The same knob for a candidate the program does NOT have yet: add it, or
;; leave it out. Starts out. (classic: action_subtree_knob)
(= (actionSubtreeKnob $candidate) ((mkNullVex ($candidate)) (mkASK 2 0)))


;; ============================================================================
;; A TUNABLE NUMBER.  (classic: contin_spec + contin_knob)
;;
;; The other two knobs choose a SUBTREE. This one chooses a VALUE, and the way
;; classic makes that fit a discrete search is worth restating, because it is
;; not obvious: the value is never stored. What is stored is a WALK.
;;
;; Start at `mean`. At each step go Left, go Right, or Stop. While every step so
;; far has gone the same way the step size GROWS by `expansion` -- that is how
;; few steps reach far from the mean. The first time the direction reverses, the
;; step is halved from then on -- that is how it lands precisely. So the walk
;; travels far AND finely, which an evenly spaced grid of the same width cannot.
;;
;;     (mkCTK <mean> <step> <expansion> <depth>)
;;
;; occupies `depth` CONSECUTIVE instance slots, each holding one trit:
;;
;;     0 = Stop      1 = Left      2 = Right
;;
;; and each of those is an ordinary 3-setting knob, so nothing in
;; search/hillclimb.metta has to learn what a number is.
;;
;; THE FIRST Stop ENDS THE WALK. Every trit after it is dead, exactly as
;; classic's decoder `break`s. Two consequences, both load-bearing:
;;   - all-Stop is the mean, so the default instance reproduces the very
;;     program that was built -- which is what keeps exemplarInst honest;
;;   - only the first trit is live at the start, so hill climbing extends the
;;     walk one step at a time, left to right. Refinement falls out of the
;;     ordinary one-knob-at-a-time neighbourhood scan.
;;
;; Not copied from classic, deliberately: canonization. classic PLANTS constants
;; (a zero coefficient per input, so tuning one away from zero switches an input
;; on) and needs ~43 arithmetic reduction rules to keep the result from
;; exploding. Here a number is tunable only where a primitive declares one.
;; ============================================================================

;; The only accessor anything needs: the mean, for a threshold the BUILDER places
;; rather than one the exemplar wrote. Everything else destructures mkContin where
;; it uses it.
(= (continMean (mkContin $mean $step $expansion $depth)) $mean)

;; A primitive says its parameter is a NUMBER TO TUNE by defining continOf; one
;; that says nothing has an ordinary parameter. The seed clause exists only so
;; the predicate is DEFINED -- an unmatched call then fails and collapses to (),
;; whereas a call to a predicate with no clauses at all comes back unreduced,
;; and collapse of THAT is a one-element list, which takes the wrong branch with
;; no error. Same pattern and same reason as paramsOf in knobs/perms.metta.
(= (continOf noSuchPrimitive) ())

(= (continSpecOf $op)
   (let $found (collapse (continOf $op)) (if (== $found ()) () (car-atom $found))))

;; --- the walk ---------------------------------------------------------------
;; classic's contin_stepper (field_set.h). `left` and `right` are mirrors: the
;; first branch is the expansion phase, the second the bisection phase, and the
;; `adjusted` step undoes the last expansion on the step that reverses.
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

;; (mkStopped $value) absorbs every later trit. classic `break`s out of its loop;
;; a fold cannot break, so a distinct shape is how the walk remembers it is over.
;; The four clauses are disjoint -- on the shape, then on the trit.
(= (continMove $expansion (mkStopped $value)      $trit) (mkStopped $value))
(= (continMove $expansion (mkWalk $v $s $l $r) 0)        (mkStopped $v))
(= (continMove $expansion (mkWalk $v $s $l $r) 1) (continLeft  $expansion (mkWalk $v $s $l $r)))
(= (continMove $expansion (mkWalk $v $s $l $r) 2) (continRight $expansion (mkWalk $v $s $l $r)))

(= (walkValue (mkStopped $value))       $value)
(= (walkValue (mkWalk $value $s $l $r)) $value)

(= (continWalk $trits $mean $step $expansion)
   (walkValue (foldl-atom $trits (mkWalk $mean $step True True) $walk $trit
                          (continMove $expansion $walk $trit))))

;; --- building one -----------------------------------------------------------
;; The MEAN COMES FROM THE TREE: whatever number is sitting in the parameter
;; slot when the representation is built is where the walk starts. The author
;; wrote it, or the builder placed the declared default -- either way the tree
;; holds it, so all-Stop decodes back to the program that was built. classic does
;; the same thing (contin_knob's spec takes `combo::get_contin(*tgt)` as its
;; mean); the fallback below is for a leaf that somehow holds no number.
(= (continKnobFor $leaf (mkContin $defaultMean $step $expansion $depth))
   (let* (($symbol (nodeSymOf $leaf))
          ($mean   (if (isGroundLiteral $symbol) $symbol $defaultMean))
          ($first  (nextIdxN $depth)))
     (mkKnob $leaf (mkCTK $mean $step $expansion $depth) $first)))
