;; ============================================================================
;; demo-from-scratch.metta -- what happens with NO starting program at all.
;;
;;   ( ulimit -v 8000000; timeout 900 \
;;       sh /home/yab/PeTTaV1/run.sh prototypes/m1/demo-from-scratch.metta -s )
;;
;; demo.metta starts from a program that is wrong but well-shaped. This one
;; starts from nothing, which is the honest test of what the machinery can and
;; cannot do on its own. It cannot do very much, and the reasons are worth
;; more than the result.
;; ============================================================================
!(import! &self prototypes/m1/all)

(= (line) "--------------------------------------------------------------")
(= (emptyProgram) (mkTree (mkNode and_seq) ()))
(= (eRep) (buildRep (emptyProgram)))

;; one round of the real loop: knob the program, search, keep the winner
(= (expandRound $tree)
   (let* (($rep (buildRep $tree))
          (($i $s) (searchBest m1ScoreExp $rep)))
     ((candidateOf $rep $i) $s)))

;; the score after each accepted move, so "how fast" is visible
(= (trajectory $rep $mults $inst $score $fuel)
   (if (<= $fuel 0)
       ($score)
       (let ($ni $ns) (climbStep m1ScoreExp $rep $mults $inst $score)
         (if (== $ns $score)
             ($score)
             (cons-atom $score (trajectory $rep $mults $ni $ns (- $fuel 1)))))))

(= (scoreTrail $rep)
   (let* (($m (multsOf $rep))
          ($d (defaultInstance $rep)))
     (trajectory $rep $m $d (m1Score $rep $d) 20)))

;; every program made only of GRAB and STEP, up to length 3
(= (m1Acts) ((mkTree (mkNode m1Grab) ()) (mkTree (mkNode m1Step) ())))
(= (m1Seqs $n)
   (if (<= $n 0) (())
       (let $tails (m1Seqs (- $n 1))
         (foldl-atom (m1Acts) () $acc $a
           (union-atom $acc (map-atom $tails $t (cons-atom $a $t)))))))
(= (blindScores)
   (let $all (union-atom (m1Seqs 1) (union-atom (m1Seqs 2) (m1Seqs 3)))
     (map-atom $all $kids (m1ScoreExp (compileTree (mkTree (mkNode and_seq) $kids))))))


!(println! "")
!(println! "==============================================================")
!(println! "  STARTING FROM NOTHING")
!(println! "")
!(println! "  Same creature, same loops of food, same 14 moves. But this")
!(println! "  time the program we begin with is empty -- it does nothing.")
!(println! "==============================================================")
!(println! (starting-program (showTree (emptyProgram))))
!(println! (it-scores (m1ScoreExp (compileTree (emptyProgram)))))

!(println! "")
!(println! (line))
!(println! "STEP 1.  What can be changed?")
!(println! (line))
!(println! (knobs (knobCountOf (eRep))))
!(println! (settings (multsOf (eRep))))
!(println! "  One knob. An empty sequence has nothing in it to adjust, so")
!(println! "  the only thing on offer is the slot for a new child -- and")
!(println! "  that slot can hold one primitive action.")
!(println! (the-three-possible-programs
   (map-atom (0 1 2) $v (showTree (candidateOf (eRep) ($v))))))
!(println! (and-their-scores
   (map-atom (0 1 2) $v (m1Score (eRep) ($v)))))

!(println! "")
!(println! (line))
!(println! "STEP 2.  Run the search.")
!(println! (line))
!(println! (result (let ($i $s) (searchBest m1ScoreExp (eRep)) $s)))
!(println! (moves-it-made (scoreTrail (eRep))))
!(println! "  It does not move. And repeating the whole round -- knob the")
!(println! "  winner, search again -- changes nothing, because the winner")
!(println! "  is the same empty program:")
!(println! (after-one-round  (let ($t $s) (expandRound (emptyProgram)) $s)))
!(println! (after-two-rounds (let ($t $s) (expandRound (emptyProgram))
                               (let ($t2 $s2) (expandRound $t) $s2))))

!(println! "")
!(println! (line))
!(println! "STEP 3.  Why it is stuck -- reason one: a valley.")
!(println! (line))
!(println! (adding-grab-alone (m1ScoreExp (quote (and_seq ((m1Grab ())))))))
!(println! (adding-step-alone (m1ScoreExp (quote (and_seq ((m1Step ())))))))
!(println! (but-both-together (m1ScoreExp (quote (and_seq ((m1Grab ()) (m1Step ())))))))
!(println! "  GRAB then STEP is worth 2 -- better than doing nothing. But")
!(println! "  getting there needs BOTH additions, and the first one on its")
!(println! "  own is worth -24: grabbing at every cell, mostly empty ones.")
!(println! "  A search that only ever accepts an improvement cannot walk")
!(println! "  through that valley.")

!(println! "")
!(println! (line))
!(println! "STEP 4.  Reason two: a ceiling it could never break anyway.")
!(println! (line))
!(println! (best-of-every-grab-step-program (maxOf (blindScores))))
!(println! "  Every program built only from GRAB and STEP is capped at 2,")
!(println! "  because none of them ever LOOKS. To beat 2, a conditional has")
!(println! "  to appear -- and nothing on offer can introduce one. The slot")
!(println! "  vocabulary holds primitives, and no arrangement of primitives")
!(println! "  is a conditional.")

!(println! "")
!(println! (line))
!(println! "STEP 5.  Give it a conditional -- even a badly wired one.")
!(println! (line))
!(println! (starting-program (showTree (m1Exemplar))))
!(println! (which-scores (m1Score (m1Rep) (defaultInstance (m1Rep)))))
!(println! (score-after-each-accepted-move (scoreTrail (m1Rep))))
!(println! "  One move. -25 to 10, the best the world allows.")

!(println! "")
!(println! "==============================================================")
!(println! "  WHAT THIS SHOWS")
!(println! "")
!(println! "  From scratch the bottleneck is not search effort -- the")
!(println! "  search had nowhere to go on its very first step. It is what")
!(println! "  the representation is able to offer. Two things are missing,")
!(println! "  and real MOSES has an answer for each:")
!(println! "")
!(println! "   * one hill climb cannot cross a valley. MOSES keeps a whole")
!(println! "     POPULATION of programs and comes back to ones that looked")
!(println! "     bad, instead of following a single path uphill.")
!(println! "")
!(println! "   * a conditional can only appear if something on offer can")
!(println! "     build one. MOSES synthesises if-then-else candidates out")
!(println! "     of the vocabulary for exactly this reason.")
!(println! "")
!(println! "  Neither is built here -- both are listed in README.md under")
!(println! "  what this prototype does not do. Seen from an empty start,")
!(println! "  they stop being omissions and start being the point.")
!(println! "==============================================================")
!(println! "")
