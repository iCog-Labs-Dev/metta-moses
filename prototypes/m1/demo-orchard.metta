;; ============================================================================
;; demo-orchard.metta -- a world where ONE test is not enough.
;;
;;   ( ulimit -v 8000000; timeout 900 \
;;       sh /home/yab/PeTTaV1/run.sh prototypes/m1/demo-orchard.metta -s )
;;
;; demo.metta has a creature that only has to decide whether to look. Here it
;; has to look at two things and put them together, which is the case the
;; boolean half of the machinery exists for.
;; ============================================================================
!(import! &self prototypes/m1/all)
!(import! &self prototypes/m1/domain/orchard)

(= (line) "--------------------------------------------------------------")
(= (start) (exemplarInst (orchRep)))

;; every conditional you can write from one perception, in either polarity and
;; with the branches either way round
(= (oneTestPrograms)
   (let* (($tests (fillersOfType Bool))
          ($pick  (leafOf orchPick))
          ($walk  (leafOf orchWalk)))
     (union-atom
       (map-atom $tests $test (mkTree (mkNode action_bool_if) ($test $pick $walk)))
       (map-atom $tests $test (mkTree (mkNode action_bool_if) ($test $walk $pick))))))

(= (oneTestScores)
   (map-atom (oneTestPrograms) $program
     (orchScoreExp (preOrderExp (mkTree (mkNode and_seq) ($program))))))

;; the program the search is looking for, written by hand for comparison
(= (theConjunction)
   (mkTree (mkNode and_seq)
     ((mkTree (mkNode action_bool_if)
        ((mkTree (mkNode AND) ((leafOf orchFruitHere) (leafOf orchNoRotHere)))
         (leafOf orchPick)
         (leafOf orchWalk))))))

(= (simpleSolution)
   (mkTree (mkNode and_seq)
     ((mkTree (mkNode action_bool_if)
        ((leafOf orchNoRotHere)
         (leafOf orchPick)
         (leafOf orchWalk))))))

!(println! "")
!(println! "==============================================================")
!(println! "  AN ORCHARD WHERE HALF THE FRUIT HAS GONE BAD")
!(println! "")
!(println! "  Same shape of creature as demo.metta, walking a ring of")
!(println! "  cells. But now a cell holds FS (fresh fruit), FX (spoiled")
!(println! "  fruit) or E (nothing), and PICKING matters:")
!(println! "")
!(println! "      fresh fruit    +2      spoiled fruit   -3     nothing  -1")
!(println! "")
!(println! "  It has two senses, and each is blind to what the other sees:")
!(println! "      orchFruitHere   SIGHT.  Something is here -- but fresh and")
!(println! "                              spoiled fruit look alike.")
!(println! "      orchNoRotHere   SMELL.  Nothing here smells of rot -- but")
!(println! "                              bare ground does not either.")
!(println! "==============================================================")
!(println! (the-two-rings (orchRingA) (orchRingB)))
!(println! (moves-allowed (orchFuel)))
!(println! (best-possible-score (orchBestScore)))

!(println! "")
!(println! (line))
!(println! "STEP 1.  The obvious program -- and it is not good enough.")
!(println! (line))
!(println! (program (preOrderExp (orchExemplar))))
!(println! "  'If there is fruit here, pick it.' Perfectly sensible, and")
!(println! "  it eats every spoiled fruit on the ring.")
!(println! (it-scores (orchScoreExp (preOrderExp (orchExemplar)))))

!(println! "")
!(println! (line))
!(println! "STEP 2.  No single test can fix it.")
!(println! (line))
!(println! "  Every conditional you can build from ONE perception -- both")
!(println! "  of them, negated or not, branches either way round:")
!(println! (their-scores (oneTestScores)))
!(println! (best-of-them (maxOf (oneTestScores))))
!(println! (doing-nothing (orchScoreExp (preOrderExp (mkTree (mkNode and_seq) ())))))
!(println! "  Not one of them beats doing nothing. Half a condition is")
!(println! "  worse than no condition here: picking whenever nothing is")
!(println! "  spoiled means picking at empty cells, and picking at an empty")
!(println! "  cell does not move you -- so the creature stands still and")
!(println! "  burns every remaining move on one square.")

!(println! "")
!(println! (line))
!(println! "STEP 3.  What is needed is a CONJUNCTION.")
!(println! (line))
!(println! (program (preOrderExp (theConjunction))))
!(println! (it-scores (orchScoreExp (preOrderExp (theConjunction)))))
!(println! "  Fresh fruit is the one cell where both tests hold at once.")
!(println! "  This is a program no arrangement of single tests reaches --")
!(println! "  it has to be BUILT out of two of them.")

!(println! "")
!(println! "  The obvious shortcut -- 'pick whenever you smell no rot' --")
!(println! "  does not work, and it is worth seeing how badly. Bare ground")
!(println! "  smells of nothing too, so the creature picks at an empty cell,")
!(println! "  which leaves the cell empty and the creature where it stood:")
!(println! (smell-alone (preOrderExp (simpleSolution))))
!(println! (it-scores (orchScoreExp (preOrderExp (simpleSolution)))))

!(println! "")
!(println! (line))
!(println! "STEP 4.  Which is exactly what the boolean knobs are for.")
!(println! (line))
!(println! "  The exemplar's condition sits in a Bool slot, so the builder")
!(println! "  puts a knob on every candidate test that could join it:")
!(println! (candidates-at-the-condition
              (map-atom (sampleLogicalPerms AND) $p (preOrderExp $p))))
!(println! (knobs-in-total (knobCountOf (orchRep))))
!(println! (starting-settings (start)))
!(println! (which-is (preOrderExp (getCandidate (orchRep) (start)))))
!(println! (scoring (orchScore (orchRep) (start))))

!(println! "")
!(println! (line))
!(println! "STEP 5.  The search.")
!(println! (line))
!(println! (found (let ($i $s) (hillClimbing orchScoreExp (orchRep))
                    (preOrderExp (getCandidate (orchRep) $i)))))
!(println! (score (let ($i $s) (hillClimbing orchScoreExp (orchRep)) $s)))
!(println! (knob-settings-that-changed
              (let ($i $s) (hillClimbing orchScoreExp (orchRep))
                (size-atom (filter-atom (rangeTo (knobCountOf (orchRep))) $k
                             (!= (index-atom $i $k) (index-atom (start) $k)))))))
!(println! "  One knob. The second candidate at the condition position is")
!(println! "  orchNoRotHere, and switching it on puts it alongside the test")
!(println! "  that was already there -- which is what an AND node means.")

!(println! "")
!(println! "==============================================================")
!(println! "  WHAT THIS ONE ADDS")
!(println! "")
!(println! "  demo.metta shows a program learning to LOOK. This one shows")
!(println! "  it learning to look at two things and combine them, which is")
!(println! "  a different ability and needs a different piece of the")
!(println! "  machinery: candidates at a Bool slot, and a knob per")
!(println! "  candidate so more than one can be switched on at a time.")
!(println! "")
!(println! "  Nothing in core/, knobs/ or search/ knows this world exists.")
!(println! "  domain/orchard.metta declares four primitives and says what")
!(println! "  a program is worth; everything else is the same code that")
!(println! "  ran demo.metta.")
!(println! "==============================================================")
!(println! "")
