;; ============================================================================
;; walkthrough-tape.metta -- THROWAWAY. Not part of any suite.
;;
;;   ( ulimit -v 8000000; timeout 900 \
;;       sh /home/yab/PeTTaV1/run.sh prototypes/m1/walkthrough-tape.metta -s )
;;
;; The same single-stepping as walkthrough-alarm.metta, over the ACTION domain,
;; so the two can be read side by side. Every frame number means the same thing
;; in both files.
;;
;; Three things differ, and they are the only three:
;;   FRAME 1  the context CHANGES as the program runs, so there is a world to
;;            watch rather than a fixed table row
;;   FRAME 2  the root produces Act, so buildKnobs routes it to buildNode and
;;            the knobs come back MIXED -- two-setting action knobs and
;;            three-setting test knobs in one vector
;;   FRAME 3  what the knobs offer includes whole conditionals, assembled by
;;            type before the search ever sees them
;; Everything else -- decode, neighbourhood, the climb -- is the same code
;; reached the same way.
;; ============================================================================
!(import! &self prototypes/m1/all)
!(import! &self prototypes/m1/domain/tape)

(= (line) "--------------------------------------------------------------")
(= (rep)   (m1Rep))
(= (mults) (knobMultiplicities (rep)))
(= (start) (exemplarInst (rep)))

;; ---------------------------------------------------------------------------
;; Instruments. Each calls the real function and labels what came back.
;; ---------------------------------------------------------------------------

;; Both values are let-bound BEFORE the quote. `quote` substitutes bindings and
;; strips one layer -- it does not evaluate -- so a call written inside it would
;; be printed verbatim rather than run.
(= (offerOf $inst $index)
   (let* (($kind    (kindAt (rep) $index))
          ($program (preOrderExp (getCandidate (rep) (changeAt $inst $index 1)))))
     (quote (knob $index kind $kind offers $program))))

(= (scoresOf $inst $index)
   (let $scores (map-atom (rangeTo (index-atom (mults) $index)) $setting
                          (scoreInstance m1ScoreExp (rep) (changeAt $inst $index $setting)))
     (quote (knob $index settings-0-up $scores))))

(= (bestMoveFrom $inst $score)
   (foldl-atom (rangeTo (size-atom $inst)) (noKnob noSetting $score) $best $index
     (foldl-atom (rangeTo (index-atom (mults) $index)) $best $sofar $setting
       (let* ((($bestIndex $bestSetting $bestScore) $sofar)
              ($try (scoreInstance m1ScoreExp (rep) (changeAt $inst $index $setting))))
         (if (> $try $bestScore) ($index $setting $try) $sofar)))))

;; Every world the program passes through in one episode. This is
;; m1RunEpisode's own loop with the recursion kept instead of thrown away --
;; including its stopping rule, that a pass which burns no fuel means the
;; program never acts.
(= (worldTrace $program $world $steps)
   (if (<= $steps 0)
       ()
       (let* (((mkRes $value $next) (evalProgram $program $world))
              ((mkW $cells $position $eaten $wasted $fuel) $world)
              ((mkW $cellsAfter $posAfter $eatenAfter $wastedAfter $fuelAfter) $next))
         (if (== $fuelAfter $fuel)
             ()
             (cons-atom $next (worldTrace $program $next (- $steps 1)))))))

;; score after each accepted move
(= (trajectory $inst $score $fuel)
   (if (<= $fuel 0)
       ($score)
       (let ($nextInst $nextScore) (hillClimbingStep m1ScoreExp (rep) (mults) $inst $score)
         (if (== $nextScore $score)
             ($score)
             (cons-atom $score (trajectory $nextInst $nextScore (- $fuel 1)))))))


!(println! "")
!(println! "==============================================================")
!(println! "  SINGLE-STEPPING THE SEARCH -- action domain, a world to change")
!(println! "==============================================================")

!(println! "")
!(println! (line))
!(println! "FRAME 0.  The input: one program, as a tree.")
!(println! (line))
!(println! "  Deliberately backwards -- it steps when it sees food and grabs")
!(println! "  when it does not.")
!(println! (exemplar-tree (m1Exemplar)))
!(println! (exemplar-runnable (preOrderExp (m1Exemplar))))

!(println! "")
!(println! (line))
!(println! "FRAME 1.  Running it: the context is a world, and it MOVES.")
!(println! (line))
!(println! "  (mkW <cells> <position> <eaten> <wasted> <fuel>). The program is")
!(println! "  run over and over until the fuel is gone; each line below is the")
!(println! "  world one pass produced, which is the world the next pass gets.")
!(println! "  This is what core/monad.metta threads -- and it is the only")
!(println! "  thing walkthrough-alarm.metta does not have.")
!(println! (world-0 (m1World 0)))
!(map-atom (worldTrace (preOrderExp (m1Exemplar)) (m1World 0) 20) $w (println! (world $w)))
!(println! (episode-0-scores (m1Fitness (preOrderExp (m1Exemplar)) 0)))
!(println! (episode-1-scores (m1Fitness (preOrderExp (m1Exemplar)) 1)))
!(println! (total (m1ScoreExp (preOrderExp (m1Exemplar)))))

!(println! "")
!(println! (line))
!(println! "FRAME 2.  buildKnobs: one program becomes a space of programs.")
!(println! (line))
!(println! "  The root is and_seq, which produces Act, so the root goes to")
!(println! "  buildNode -- and the vector comes back MIXED. Compare the")
!(println! "  all-LSK vector in walkthrough-alarm.metta: same function, and")
!(println! "  the difference is entirely the root's declared return type.")
!(println! (knob-count (knobCountOf (rep))))
!(println! (multiplicities (mults)))
!(println! (kinds (map-atom (rangeTo (knobCountOf (rep))) $i (kindAt (rep) $i))))
!(println! "")
!(println! "  ASK = action knob, two settings: drop it or keep it.")
!(println! "  LSK = test knob, three: absent, as written, negated.")
!(println! (start-instance (start)))

!(println! "")
!(println! (line))
!(println! "FRAME 3.  What each knob is FOR.")
!(println! (line))
!(println! "  Knob i moved to 1, everything else left alone. The growth knobs")
!(println! "  take the low indices, and several of them offer a COMPLETE")
!(println! "  conditional -- test and both branches, filled in by type before")
!(println! "  the search saw it. That is why one move can be enough.")
!(map-atom (rangeTo (knobCountOf (rep))) $i (println! (offerOf (start) $i)))

!(println! "")
!(println! (line))
!(println! "FRAME 4.  Decoding, in the three stages it really has.")
!(println! (line))
!(println! (stage-1-raw-tree (getCandidateRec (start) (rep))))
!(println! "")
!(println! (stage-2-cleaned (getCandidate (rep) (start))))
!(println! "")
!(println! (stage-3-runnable (preOrderExp (getCandidate (rep) (start)))))
!(println! (and-it-scores (scoreInstance m1ScoreExp (rep) (start))))

!(println! "")
!(println! (line))
!(println! "FRAME 5.  Hill-climbing step 1: the whole neighbourhood.")
!(println! (line))
!(println! "  Every knob with the score of each of its settings, in setting")
!(println! "  order. Scanning these for the largest number is exactly what")
!(println! "  hillClimbingStep does.")
!(map-atom (rangeTo (knobCountOf (rep))) $i
           (println! (scoresOf (start) $i)))
!(println! "")
!(println! (best-knob-setting-score (bestMoveFrom (start) (scoreInstance m1ScoreExp (rep) (start)))))

(= (afterStep1)
   (let ($inst $score)
        (hillClimbingStep m1ScoreExp (rep) (mults) (start) (scoreInstance m1ScoreExp (rep) (start)))
     $inst))

!(println! (instance-now (afterStep1)))
!(println! (program-now  (preOrderExp (getCandidate (rep) (afterStep1)))))
!(println! (score-now    (scoreInstance m1ScoreExp (rep) (afterStep1))))

!(println! "")
!(println! (line))
!(println! "FRAME 6.  And from there.")
!(println! (line))
!(map-atom (rangeTo (knobCountOf (rep))) $i
           (println! (scoresOf (afterStep1) $i)))
!(println! "")
!(println! (best-knob-setting-score
             (bestMoveFrom (afterStep1) (scoreInstance m1ScoreExp (rep) (afterStep1)))))

!(println! "")
!(println! (line))
!(println! "FRAME 7.  The score after every accepted move.")
!(println! (line))
!(println! (trail (trajectory (start) (scoreInstance m1ScoreExp (rep) (start)) 20)))

!(println! "")
!(println! (line))
!(println! "FRAME 8.  The same thing, run by the real function.")
!(println! (line))
!(println! (hillClimbing-inst  (let ($i $s) (hillClimbing m1ScoreExp (rep)) $i)))
!(println! (hillClimbing-score (let ($i $s) (hillClimbing m1ScoreExp (rep)) $s)))
!(println! (hillClimbing-found (let ($i $s) (hillClimbing m1ScoreExp (rep))
                                 (preOrderExp (getCandidate (rep) $i)))))
!(println! (the-best-this-world-allows (m1BestScore)))

!(println! "")
!(println! (line))
!(println! "FRAME 9.  The winner's episode, world by world.")
!(println! (line))
!(println! "  Compare with FRAME 1: same fuel, same tape, and the eaten")
!(println! "  count climbs instead of the wasted count.")
(= (found) (let ($i $s) (hillClimbing m1ScoreExp (rep)) (preOrderExp (getCandidate (rep) $i))))
!(println! (world-0 (m1World 0)))
!(map-atom (worldTrace (found) (m1World 0) 20) $w (println! (world $w)))
!(println! (total (m1ScoreExp (found))))

!(println! "")
!(println! "==============================================================")
!(println! "  Same nine frames as walkthrough-alarm.metta, same functions")
!(println! "  in the same order. The domain supplies a context and a score;")
!(println! "  everything between buildKnobs and hillClimbing is indifferent")
!(println! "  to which domain it was.")
!(println! "==============================================================")
!(println! "")
