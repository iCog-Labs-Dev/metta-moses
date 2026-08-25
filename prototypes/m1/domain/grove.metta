;; ============================================================================
;; domain/grove.metta -- THE MIXED CASE. One program, three worlds' worth of
;; machinery, and two tuned numbers.
;;
;; domain/tape.metta is an action program over boolean perceptions.
;; domain/thermostat.metta is a boolean program over a numeric table.
;; This is both at once, in a single tree:
;;
;;     (and_seq ((action_bool_if ((numGt ((groveRipeHere ()) (groveThresh (0))))
;;                                (grovePick ())
;;                                (groveStepN (2))))))
;;      ^Act        ^Act              ^Bool     ^Number         ^Act, tuned count
;;
;; An ACTION root, whose condition is a BOOLEAN comparison, whose operands are
;; NUMBERS, one of which is a constant the search tunes -- and whose else-branch
;; is an action whose MAGNITUDE the search also tunes. Every layer of the
;; prototype is carrying a different type at the same time.
;;
;; TWO CONTIN KNOBS, TWO ROLES. This is the point of the file:
;;
;;   groveThresh   a threshold in a CONDITION -- how ripe is ripe enough
;;   groveStepN    a magnitude in a PROGRAM   -- how far to walk in one go
;;
;; Both are the same mechanism (a primitive whose parameter is declared
;; continuous), reached by two different routes in the builder: the threshold is
;; found by scanning inside a boolean candidate, the magnitude by scanning an
;; action primitive's own parameter. Neither is a special case of the other.
;;
;; BOTH START WRONG, DELIBERATELY. The exemplar guesses "pick anything at all"
;; and "walk two cells at a time"; the good berries sit on cells a two-stride
;; walk never lands on. Neither number is in the data and neither is derivable
;; from the structure -- the search has to find both.
;; ============================================================================

;; --- the world ---------------------------------------------------------------
;; A row of cells, each holding a RIPENESS. 0 is bare ground. A berry is worth
;; eating only above 8; eating an unripe one costs more than eating nothing, so a
;; creature that picks indiscriminately does worse than one that never picks.
;; mkGrove is an inert constructor -- no clause, like mkW and mkRes. A clause
;; here would be self-referential and loop.
(= (groveRipeFloor) 8)
(= (groveCells)     (5 9 0 12 0 5))
(= (groveFuel)      6)
(= (groveWorld)     (mkGrove (groveCells) 0 0 0 (groveFuel)))

;; Reading past the end is bare ground rather than an error: a program that walks
;; off the row wastes its remaining fuel, which is a bad score and not a crash.
(= (groveRipeAt $cells $position)
   (if (< $position (size-atom $cells)) (index-atom $cells $position) 0))

(= (groveClearAt $cells $position)
   (map-atom (rangeTo (size-atom $cells)) $i
             (if (== $i $position) 0 (index-atom $cells $i))))

;; --- what it can see ---------------------------------------------------------
;; A NUMERIC perception. Structurally identical to tape's m1FoodHere -- looks
;; without changing anything -- and different only in its declared return type,
;; which is what makes it a legal operand of a comparison instead of a condition
;; in its own right.
(= (groveRipeHere $params (mkGrove $cells $position $eaten $wasted $fuel))
   (mkRes (groveRipeAt $cells $position)
          (mkGrove $cells $position $eaten $wasted $fuel)))

;; A tunable constant: it ignores the world and IS its parameter.
(= (groveThresh ($n) (mkGrove $cells $position $eaten $wasted $fuel))
   (mkRes $n (mkGrove $cells $position $eaten $wasted $fuel)))

;; --- what it can do ----------------------------------------------------------
;; Same rule as tape and orchard, and for the same reason: an action reports
;; success while there is fuel, whatever it found. A wasted pick that reported
;; failure would let the search read the answer off the return value instead of
;; out of the score.
(= (grovePick $params (mkGrove $cells $position $eaten $wasted $fuel))
   (let $ripeness (groveRipeAt $cells $position)
     (if (> $ripeness (groveRipeFloor))
         (mkRes True (mkGrove (groveClearAt $cells $position) $position
                              (+ $eaten 2) $wasted (- $fuel 1)))
         (mkRes True (mkGrove (groveClearAt $cells $position) $position
                              $eaten (+ $wasted 3) (- $fuel 1))))))

;; Walk $n cells for one fuel. The count is TUNED, and it is rounded here rather
;; than in the knob: classic keeps contin values as doubles throughout, so a
;; domain that needs a whole number rounds at the point of use. (classic scopes
;; its contin knobs to exactly this kind of structural literal -- a repeat count.)
(= (groveStepN ($n) (mkGrove $cells $position $eaten $wasted $fuel))
   (mkRes True (mkGrove $cells (+ $position (round-math $n))
                        $eaten $wasted (- $fuel 1))))

;; --- an episode --------------------------------------------------------------
;; Same shape as tape's m1RunEpisode, including the guard: a program that uses no
;; fuel never acts, so stop rather than loop forever.
(= (groveRunEpisode $program (mkGrove $cells $position $eaten $wasted $fuel))
   (if (<= $fuel 0)
       (- $eaten $wasted)
       (let (mkRes $value $next)
            (evalProgram $program (mkGrove $cells $position $eaten $wasted $fuel))
         (let (mkGrove $cellsAfter $posAfter $eatenAfter $wastedAfter $fuelAfter) $next
           (if (== $fuelAfter $fuel)
               (- $eatenAfter $wastedAfter)
               (groveRunEpisode $program $next))))))

(= (groveScoreExp $program) (groveRunEpisode $program (groveWorld)))

;; Two ripe berries at +2, nothing wasted. Reaching it needs BOTH numbers right:
;; the threshold to leave the unripe ones alone, and the stride to land on the
;; ripe ones at all.
(= (groveBestScore) 4)

;; --- the program we start from ----------------------------------------------
;; "Pick whatever is here, otherwise stride two cells." Wrong twice over: the
;; threshold of 0 means every berry looks worth eating, and a stride of 2 only
;; ever lands on even cells, where the good berries are not.
(= (groveThreshTree $n) (mkTree (mkNode groveThresh) ((leafOf $n))))
(= (groveRipeTree)      (mkTree (mkNode groveRipeHere) ()))

(= (groveExemplar)
   (mkTree (mkNode and_seq)
     ((mkTree (mkNode action_bool_if)
        ((mkTree (mkNode numGt) ((groveRipeTree) (groveThreshTree 0)))
         (mkTree (mkNode grovePick) ())
         (mkTree (mkNode groveStepN) ((leafOf 2))))))))

(= (groveRep) (buildKnobs (groveExemplar)))

(= (groveScore $rep $inst) (scoreInstance groveScoreExp $rep $inst))


;; ============================================================================
;; Declarations.
;;
;; Two primitives declare a CONTINUOUS parameter, and their specs differ because
;; what they measure differs -- which is the argument for continOf being
;; per-primitive rather than one global step/expansion/depth the way classic does
;; it.
;;
;;   groveThresh  mean 0, step 8, depth 1 -> reachable 0, 8, -8.  8 is the answer.
;;   groveStepN   mean 2, step 1, depth 1 -> reachable 2, 1, 3.   1 is the answer.
;;
;; Depth 1 keeps both walks to a single trit, so each number is one knob and the
;; test can read the trits directly. thermostat exercises a deeper walk.
;; ============================================================================
(: groveRipeHere (-> Params $ctx Number))
(: groveThresh   (-> Params $ctx Number))
(: grovePick     (-> Params $ctx Act))
(: groveStepN    (-> Params $ctx Act))

(= (continOf groveThresh) (mkContin 0 8 2 1))
(= (continOf groveStepN)  (mkContin 2 1 2 1))
