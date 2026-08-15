;; ============================================================================
;; demo-berries.metta -- when the answer is not on the menu.
;;
;;   ( ulimit -v 8000000; timeout 900 \
;;       sh /home/yab/PeTTaV1/run.sh prototypes/m1/demo-berries.metta -s )
;;
;; demo-orchard.metta needs a compound condition and is handed it in one move,
;; because the missing half was sitting in the candidate list. Here the shape
;; the answer needs is not offered at all, and the search has to assemble it.
;; ============================================================================
!(import! &self prototypes/m1/all)
!(import! &self prototypes/m1/domain/berries)

(= (line) "--------------------------------------------------------------")
(= (start) (exemplarInst (berryRep)))

;; the score after each accepted move, so the climb is visible step by step
(= (trajectory $inst $score $fuel)
   (if (<= $fuel 0)
       ($score)
       (let ($nextInst $nextScore)
            (hillClimbingStep berryScoreExp (berryRep)
                              (knobMultiplicities (berryRep)) $inst $score)
         (if (== $nextScore $score)
             ($score)
             (cons-atom $score (trajectory $nextInst $nextScore (- $fuel 1)))))))

(= (scoreTrail) (trajectory (start) (berryScore (berryRep) (start)) 20))

;; the program after each accepted move
(= (programTrail $inst $score $fuel)
   (if (<= $fuel 0)
       ()
       (let ($nextInst $nextScore)
            (hillClimbingStep berryScoreExp (berryRep)
                              (knobMultiplicities (berryRep)) $inst $score)
         (if (== $nextScore $score)
             ()
             (cons-atom (preOrderExp (getCandidate (berryRep) $nextInst))
                        (programTrail $nextInst $nextScore (- $fuel 1)))))))

(= (theAnswer)
   (quote (and_seq ((action_bool_if
                      ((AND (
                              (OR (
                                    (berryRed ())
                                    (berrySweet ())
                                  ))
                              (NOT ((berryWormy ())))))
                       (berryPick ())
                       (berryWalk ()))))))) 

(= (bestNeighbour)
   (maxOf (map-atom (generateAllInNeighborhood (knobMultiplicities (berryRep)) (start))
                    $n (berryScore (berryRep) $n))))


!(println! "")
!(println! "==============================================================")
!(println! "  A BERRY PATCH, AND AN ANSWER THAT IS NOT ON THE MENU")
!(println! "")
!(println! "  A ring of berries. Each one is ripe by COLOUR (RC), ripe by")
!(println! "  SMELL (RS), ripe by colour but WORMY (RW), or unripe (U).")
!(println! "  Picking is worth +2 for a sound ripe berry, -3 for a wormy")
!(println! "  one, -2 for an unripe one, and -1 for a cell already picked")
!(println! "  -- and an empty pick does not move you.")
!(println! "")
!(println! "  Three things it can see: is it wormy, does it look ripe,")
!(println! "  does it smell ripe.")
!(println! "==============================================================")
!(println! (the-two-rings (berryRingA) (berryRingB)))
!(println! (moves-allowed (berryFuel)))
!(println! (best-possible-score (berryBestScore)))

!(println! "")
!(println! (line))
!(println! "STEP 1.  The program we start from.")
!(println! (line))
!(println! (program (preOrderExp (berryExemplar))))
!(println! "  'Take the ones that look ripe.' Wrong twice: the wormy ones")
!(println! "  look ripe too, and the ones that are only ripe by smell get")
!(println! "  walked past.")
!(println! (it-scores (berryScoreExp (preOrderExp (berryExemplar)))))
!(println! "  Worse than doing nothing, which scores 0.")

!(println! "")
!(println! (line))
!(println! "STEP 2.  What the answer has to be.")
!(println! (line))
!(println! (program (theAnswer)))
!(println! (it-scores (berryScoreExp (theAnswer))))
!(println! "  Both halves are needed. Each on its own gets only part way:")
!(println! (stop-the-wormy-ones-only (berryScoreExp (quote (and_seq ((action_bool_if
              ((AND ((berryRed ()) (NOT ((berryWormy ()))))) (berryPick ()) (berryWalk ())))))))))
!(println! (use-both-ripeness-cues-only (berryScoreExp (quote (and_seq ((action_bool_if
              ((OR ((berryRed ()) (berrySweet ()))) (berryPick ()) (berryWalk ())))))))))

!(println! "")
!(println! (line))
!(println! "STEP 3.  And here is the catch.")
!(println! (line))
!(println! "  These are the candidates offered at the condition:")
!(println! (candidates (map-atom (sampleLogicalPerms AND) $c (preOrderExp $c))))
!(println! "")
!(println! (is-the-disjunction-we-need-among-them
   (containsIn (sampleLogicalPerms AND)
               (mkTree (mkNode OR) ((mkTree (mkNode berryRed) ())
                                    (mkTree (mkNode berrySweet) ()))))))
!(println! "  It is not. Every pair on offer leads with berryWormy, because")
!(println! "  that is the first perception declared and the sampler's")
!(println! "  odometer holds the leading argument steady longest -- the")
!(println! "  budget runs out before it ever reaches (OR red sweet).")
!(println! "")
!(println! "  So no single knob can produce the answer. The best that any")
!(println! "  one setting reaches from here:")
!(println! (best-single-move (bestNeighbour)))
!(println! (out-of (berryBestScore)))

!(println! "")
!(println! (line))
!(println! "STEP 4.  So it gets built instead.")
!(println! (line))
!(println! (score-after-each-accepted-move (scoreTrail)))
!(println! (program-after-each-accepted-move (programTrail (start)
                                               (berryScore (berryRep) (start)) 20)))
!(println! "  Two moves. The first stops the wormy ones -- that candidate")
!(println! "  WAS on the menu. The second adds berrySweet inside the OR the")
!(println! "  builder leaves under the condition, next to the berryRed that")
!(println! "  was already there. The disjunction is assembled one perception")
!(println! "  at a time, out of parts that are on the menu.")

!(println! "")
!(println! (line))
!(println! "STEP 5.  Where it ended up.")
!(println! (line))
!(println! (found (let ($i $s) (hillClimbing berryScoreExp (berryRep))
                    (preOrderExp (getCandidate (berryRep) $i)))))
!(println! (score (let ($i $s) (hillClimbing berryScoreExp (berryRep)) $s)))

!(println! "")
!(println! "==============================================================")
!(println! "  WHAT THIS ONE ADDS")
!(println! "")
!(println! "  The other two worlds are solved by SELECTING: the winning")
!(println! "  program is sitting in the candidate list and the search says")
!(println! "  yes to it. Here it is not, and cannot be -- the sampler works")
!(println! "  to a budget, and a budget always leaves something out.")
!(println! "")
!(println! "  What saves it is the empty OR node the builder leaves under")
!(println! "  every condition. That node is the reason a shape nobody")
!(println! "  offered can still be reached: the candidates are the letters,")
!(println! "  and the node is where words get spelled.")
!(println! "")
!(println! "  It also shows the limit honestly. Both moves had to pay off")
!(println! "  on their own -- a single hill climb accepts nothing else. An")
!(println! "  answer whose first half is worthless without its second is")
!(println! "  still out of reach, and that is what a population is for.")
!(println! "==============================================================")
!(println! "")
