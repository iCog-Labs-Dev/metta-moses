;; ============================================================================
;; search/moses.metta -- THE TOP-LEVEL CALL.
;;
;; Everything under core/, knobs/ and search/ is a piece. This is the one place
;; they are assembled, and it is the analogue of `moses` / `moses-run` in the
;; production tree (moses/demo-problems.metta): a single entry point that takes
;; a problem and runs it end to end.
;;
;;     (m1Moses <name> <exemplar> <scorer> <best>)
;;
;;     name       what to call the run
;;     exemplar   the program to start from, as a tree
;;     scorer     a function from a runnable program to a number, higher better
;;     best       the score that would mean "solved", for reporting only
;;
;; Nothing else. No domain is named in this file, and nothing here knows whether
;; a context is a world, a board or a table row -- that is entirely the domain
;; file's business, and it is why the same call runs all six.
;;
;; THE PIPELINE, WHICH IS THE WHOLE PROTOTYPE IN ORDER:
;;
;;     buildKnobs      one program      -> a space of programs
;;     exemplarInst    that space       -> the point the exemplar sits at
;;     hillClimbing    that point       -> a better point
;;     getCandidate    a point          -> a program again
;;     preOrderExp     a program tree   -> the term the evaluator runs
;;     <scorer>        that term        -> a number
;;
;; EVERY RUN ALSO REPORTS ITS CONTROL. A result means much less if the exemplar
;; already contained the structure the knobs were supposed to discover, so the
;; same search runs a second time from an EMPTY program of the same root type,
;; and both are printed. Where the two agree the exemplar was not doing the
;; work; where they differ it was, and `verdict` says which rather than leaving
;; it to be noticed.
;;
;; ON `quote` IN THIS FILE: every printed line is a quoted shape holding only
;; VARIABLES. quote blocks the whole shape including inner calls, so a line
;; written as (quote (knobs (knobCountOf $rep))) would print the call rather
;; than the number. Everything is computed into a let* binding first, and the
;; quote only ever substitutes.
;; ============================================================================

;; An empty program of the same kind as the exemplar -- an action root stays an
;; action root, a boolean root stays boolean, so buildKnobs routes it the same
;; way and the control is comparing like with like.
(= (emptyLike $exemplar) (mkTree (mkNode (nodeSymOf $exemplar)) ()))

;; The score after each accepted move. hillClimbing returns only the end point,
;; so this walks the same hillClimbingStep to show the path it took.
(= (mosesTrail $scorer $rep $mults $inst $score $fuel)
   (if (<= $fuel 0)
       ($score)
       (let ($nextInst $nextScore) (hillClimbingStep $scorer $rep $mults $inst $score)
         (if (== $nextScore $score)
             ($score)
             (cons-atom $score (mosesTrail $scorer $rep $mults $nextInst $nextScore (- $fuel 1)))))))

;; How many knobs of each kind, so a mixed representation reads at a glance
;; instead of as a long vector.
(= (kindTally $rep)
   (let $kinds (map-atom (rangeTo (knobCountOf $rep)) $i (kindAt $rep $i))
     (map-atom (nub $kinds) $kind
               ($kind (size-atom (filter-atom $kinds $k (== $k $kind)))))))

;; --- one run ----------------------------------------------------------------
;; mkRun is an inert constructor, like mkRes and mkTree: it has no clause, so a
;; run can be passed around and destructured without reducing.
(= (mosesRun $scorer $tree)
   (let* (($rep     (buildKnobs $tree))
          ($start   (exemplarInst $rep))
          ($mults   (knobMultiplicities $rep))
          ($from    (scoreInstance $scorer $rep $start))
          ($trail   (mosesTrail $scorer $rep $mults $start $from 40))
          (($inst $score) (hillClimbing $scorer $rep))
          ($program (preOrderExp (getCandidate $rep $inst))))
     (mkRun (knobCountOf $rep) (kindTally $rep) $start $from $trail $score $program)))

;; What the two runs together are entitled to claim.
(= (mosesVerdict $real $empty $best)
   (if (== $empty $best)
       SOLVED-FROM-NOTHING
       (if (== $real $best)
           SOLVED-ONLY-WITH-THE-EXEMPLAR
           NOT-SOLVED)))

;; --- the entry point --------------------------------------------------------
(= (m1Moses $name $exemplar $scorer $best)
   (let* (((mkRun $rKnobs $rKinds $rStart $rFrom $rTrail $rScore $rProgram)
           (mosesRun $scorer $exemplar))
          ((mkRun $eKnobs $eKinds $eStart $eFrom $eTrail $eScore $eProgram)
           (mosesRun $scorer (emptyLike $exemplar)))
          ($startProgram (preOrderExp $exemplar))
          ($verdict      (mosesVerdict $rScore $eScore $best))
          ($lines
            ("=============================================================="
             (quote (moses $name))
             "=============================================================="
             ""
             "  FROM THE EXEMPLAR"
             (quote (start-program $startProgram))
             (quote (knobs $rKnobs $rKinds))
             (quote (start-instance $rStart scores $rFrom))
             (quote (trail $rTrail))
             (quote (found $rProgram))
             (quote (score $rScore of-best $best))
             ""
             "  FROM AN EMPTY PROGRAM -- the control: same call, nothing given"
             (quote (knobs $eKnobs $eKinds))
             (quote (start-instance $eStart scores $eFrom))
             (quote (trail $eTrail))
             (quote (found $eProgram))
             (quote (score $eScore of-best $best))
             ""
             (quote (verdict $verdict))
             "==============================================================")))
     (map-atom $lines $line (println! $line))))
