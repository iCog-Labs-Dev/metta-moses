;; ============================================================================
;; walkthrough-alarm.metta -- THROWAWAY. Not part of any suite.
;;
;;   ( ulimit -v 8000000; timeout 900 \
;;       sh /home/yab/PeTTaV1/run.sh prototypes/m1/walkthrough-alarm.metta -s )
;;
;; The demo-*.metta files argue a point. This one does not argue anything: it
;; single-steps the actual execution and prints the real intermediate values,
;; the way you would if you put a breakpoint on every function in the pipeline
;; and printed its arguments and its result.
;;
;; Nothing below is a special printing path. Every value shown is produced by
;; the same function the search itself calls -- buildKnobs, exemplarInst,
;; getCandidateRec, cleanTree, preOrderExp, scoreInstance, hillClimbingStep --
;; called here one at a time instead of in a loop.
;;
;; The domain is domain/alarm.metta: the classic MOSES boolean problem. An
;; input table, columns for a vocabulary, and a behavioural score of 0 per row
;; right and -1 per row wrong -- so 0 is the best possible and everything else
;; is negative. It is the same pipeline the action domains use.
;; ============================================================================
!(import! &self prototypes/m1/all)
!(import! &self prototypes/m1/domain/alarm)

(= (line) "--------------------------------------------------------------")
(= (rep)   (alarmRep))
(= (mults) (knobMultiplicities (rep)))
(= (start) (exemplarInst (rep)))

;; ---------------------------------------------------------------------------
;; Instruments. Each one calls the real function and labels what came back.
;; ---------------------------------------------------------------------------

;; the program knob $index gives when moved to setting 1, everything else left
;; where it is -- i.e. what that knob OFFERS
(= (offerOf $inst $index)
   (let $program (preOrderExp (getCandidate (rep) (changeAt $inst $index 1)))
     (quote (knob $index offers $program))))

;; every setting of knob $index, scored, from the instance $inst
(= (scoresOf $inst $index)
   (let $scores (map-atom (rangeTo (index-atom (mults) $index)) $setting
                          (scoreInstance alarmScoreExp (rep) (changeAt $inst $index $setting)))
     (quote (knob $index settings-0-up $scores))))

;; the single best (knob, setting, score) anywhere in the neighbourhood
(= (bestMoveFrom $inst $score)
   (foldl-atom (rangeTo (size-atom $inst)) (noKnob noSetting $score) $best $index
     (foldl-atom (rangeTo (index-atom (mults) $index)) $best $sofar $setting
       (let* ((($bestIndex $bestSetting $bestScore) $sofar)
              ($try (scoreInstance alarmScoreExp (rep) (changeAt $inst $index $setting))))
         (if (> $try $bestScore) ($index $setting $try) $sofar)))))

;; one row of the table: what the program said, what the column wanted, and the
;; 0/-1 that scoring/bscore.metta's compareAndScore turns that into
(= (rowLine $program $row)
   (let* (($value (resValOf (evalProgram $program $row)))
          ($want  (outputOf $row))
          ($score (compareAndScore $value $want)))
     (quote (row $row said $value wanted $want scores $score))))


!(println! "")
!(println! "==============================================================")
!(println! "  SINGLE-STEPPING THE SEARCH -- an input table, no actions")
!(println! "==============================================================")

!(println! "")
!(println! (line))
!(println! "FRAME 0.  The problem, which is a TABLE.")
!(println! (line))
!(println! "  Rows of inputs with the target as the last column, and headings")
!(println! "  naming each one -- the shape scoring/bscore.metta uses. There is")
!(println! "  no code anywhere saying what the answer is; these eight rows ARE")
!(println! "  the specification.")
!(println! (headings (labelsOf (alarmTable))))
!(map-atom (rowsOf (alarmTable)) $row (println! (row $row)))
!(println! "")
!(println! "  ONE PRIMITIVE, NOT ONE PER COLUMN. `colAt` takes a column index")
!(println! "  in its parameter slot, and the slots are computed from the")
!(println! "  table's width -- so the vocabulary IS the table. Widen the")
!(println! "  table and every line below follows on its own.")
!(println! (input-columns (inputCount)))
!(println! (colAt-is-a-family-of (paramsOf colAt)))
!(println! (vocabulary (map-atom (literalsOfType Bool) $l (preOrderExp $l))))

!(println! "")
!(println! (line))
!(println! "FRAME 1.  The starting program, and running it row by row.")
!(println! (line))
!(println! (exemplar-tree (alarmExemplar)))
!(println! "  preOrderExp turns any tree into the form the evaluator")
!(println! "  dispatches on -- every node becomes (op (children)), leaves")
!(println! "  included, as (op ()):")
!(println! (exemplar-runnable (preOrderExp (alarmExemplar))))
!(println! "")
!(println! "  Each row IS the context -- the thing core/monad.metta threads.")
!(println! "  Here nothing ever changes it, so the same row goes in and comes")
!(println! "  out; that is the only way this domain differs from tape.metta.")
!(map-atom (rowsOf (alarmTable)) $row (println! (rowLine (preOrderExp (alarmExemplar)) $row)))
!(println! (total (alarmScoreExp (preOrderExp (alarmExemplar)))))

!(println! "")
!(println! (line))
!(println! "FRAME 2.  buildKnobs: one program becomes a space of programs.")
!(println! (line))
!(println! "  The root is an AND, which produces Bool, so knobs/builder.metta")
!(println! "  routes it to buildBoolSlot. Every knob that comes back is an")
!(println! "  LSK -- three settings: absent, as written, negated.")
!(println! (knob-count (knobCountOf (rep))))
!(println! (multiplicities (mults)))
!(println! (kinds (nub (map-atom (rangeTo (knobCountOf (rep))) $i (kindAt (rep) $i)))))
!(println! "")
!(println! "  exemplarInst is the vector that reproduces what we started")
!(println! "  from: every knob at its default.")
!(println! (start-instance (start)))

!(println! "")
!(println! (line))
!(println! "FRAME 3.  What each of the 27 knobs is FOR.")
!(println! (line))
!(println! "  Knob i moved to 1, everything else left alone. Knobs 0-8 sit")
!(println! "  at the root AND; 9-17 inside the OR that took over column 0;")
!(println! "  18-26 in an empty OR the builder appended to grow into.")
!(map-atom (rangeTo (knobCountOf (rep))) $i (println! (offerOf (start) $i)))

!(println! "")
!(println! (line))
!(println! "FRAME 4.  Decoding, in the three stages it really has.")
!(println! (line))
!(println! "  getCandidateRec reads each knob's own index out of the vector")
!(println! "  and rebuilds a tree. Note the empty (OR ()) -- that is the")
!(println! "  grow-into slot, switched off:")
!(println! (stage-1-raw-tree (getCandidateRec (start) (rep))))
!(println! "")
!(println! "  cleanTree drops empty junctors that sit inside another boolean")
!(println! "  node. Scaffolding out:")
!(println! (stage-2-cleaned (getCandidate (rep) (start))))
!(println! "")
!(println! "  preOrderExp makes it runnable. THIS is the term evalProgram")
!(println! "  receives -- there is no second, prettier rendering anywhere:")
!(println! (stage-3-runnable (preOrderExp (getCandidate (rep) (start)))))
!(println! (and-it-scores (scoreInstance alarmScoreExp (rep) (start))))

!(println! "")
!(println! (line))
!(println! "FRAME 5.  Hill-climbing step 1: the whole neighbourhood.")
!(println! (line))
!(println! "  generateAllInNeighborhood varies ONE knob at a time. Below is")
!(println! "  every knob with the score of each of its settings, in setting")
!(println! "  order 0/1/2, against a current score of -3. Scanning these for")
!(println! "  the largest number is exactly what hillClimbingStep does --")
!(println! "  and larger means closer to 0, which is every row right.")
!(map-atom (rangeTo (knobCountOf (rep))) $i (println! (scoresOf (start) $i)))
!(println! "")
!(println! (best-knob-setting-score (bestMoveFrom (start) -3)))
!(println! "  Knob 2 is the candidate for column 2, and setting 2 means")
!(println! "  NEGATED -- so one move adds (NOT (colAt (2))) as a second")
!(println! "  conjunct. Several other knobs reach -1 by the same formula")
!(println! "  spelled differently; the fold keeps the first it met.")

(= (afterStep1) (let ($inst $score) (hillClimbingStep alarmScoreExp (rep) (mults) (start) -3) $inst))

!(println! (instance-now (afterStep1)))
!(println! (program-now  (preOrderExp (getCandidate (rep) (afterStep1)))))
!(println! (score-now    (scoreInstance alarmScoreExp (rep) (afterStep1))))

!(println! "")
!(println! (line))
!(println! "FRAME 6.  Hill-climbing step 2, from there.")
!(println! (line))
!(map-atom (rangeTo (knobCountOf (rep))) $i (println! (scoresOf (afterStep1) $i)))
!(println! "")
!(println! (best-knob-setting-score (bestMoveFrom (afterStep1) -1)))
!(println! "  Knob 10 is INSIDE the conjunct that was already there -- it")
!(println! "  widens (OR (colAt (0))) to (OR (colAt (0)) (colAt (1))). The")
!(println! "  first move added a conjunct at the root; this one reaches into")
!(println! "  one. A representation offering only root-level choices could")
!(println! "  make the first move and never the second.")

(= (afterStep2) (let ($inst $score) (hillClimbingStep alarmScoreExp (rep) (mults) (afterStep1) -1) $inst))

!(println! (instance-now (afterStep2)))
!(println! (program-now  (preOrderExp (getCandidate (rep) (afterStep2)))))
!(println! (score-now    (scoreInstance alarmScoreExp (rep) (afterStep2))))

!(println! "")
!(println! (line))
!(println! "FRAME 7.  Step 3: nothing improves, so the loop stops.")
!(println! (line))
!(println! (best-knob-setting-score (bestMoveFrom (afterStep2) 0)))
!(println! "  noKnob/noSetting means no neighbour beat 0, and 0 is the best")
!(println! "  the table allows. hillClimbingLoop sees the score come back")
!(println! "  equal and returns.")

!(println! "")
!(println! (line))
!(println! "FRAME 8.  The same thing, run by the real function.")
!(println! (line))
!(println! (hillClimbing-inst  (let ($i $s) (hillClimbing alarmScoreExp (rep)) $i)))
!(println! (hillClimbing-score (let ($i $s) (hillClimbing alarmScoreExp (rep)) $s)))
!(println! (hillClimbing-found (let ($i $s) (hillClimbing alarmScoreExp (rep))
                                 (preOrderExp (getCandidate (rep) $i)))))
!(println! (best-the-table-allows (alarmBestScore)))

!(println! "")
!(println! (line))
!(println! "FRAME 9.  The winner, row by row -- compare with FRAME 1.")
!(println! (line))
(= (found) (let ($i $s) (hillClimbing alarmScoreExp (rep)) (preOrderExp (getCandidate (rep) $i))))
!(map-atom (rowsOf (alarmTable)) $row (println! (rowLine (found) $row)))
!(println! (total (alarmScoreExp (found))))

!(println! "")
!(println! "==============================================================")
!(println! "  Every row right. The formula behind the table, found by the")
!(println! "  same buildKnobs / getCandidate / hillClimbingStep the action")
!(println! "  domains use -- with columns for a vocabulary and a row for a")
!(println! "  context, which is the classic MOSES boolean path.")
!(println! "==============================================================")
!(println! "")
