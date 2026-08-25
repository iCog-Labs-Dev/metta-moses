;; ============================================================================
;; demo-grove.metta -- THE MIXED CASE: actions and numbers in one program.
;;
;;   ( ulimit -v 8000000; timeout 900 \
;;       sh /home/yab/PeTTaV1/run.sh prototypes/m1/demo-grove.metta -s )
;;
;; WORLD        a row of cells, each holding a RIPENESS -- a number, with 0
;;              meaning bare ground. Cells 1 and 3 hold the only two berries
;;              worth eating, and both are ODD.
;; CONTEXT      that grove -- and the program CHANGES it. Picking clears a cell,
;;              striding moves, both spend fuel.
;; IT CAN DO    grovePick. groveStepN, whose STRIDE is a tuned number.
;; IT CAN SEE   groveRipeHere -- a NUMERIC perception: how ripe this cell is.
;;              groveThresh IS its parameter, a second tuned number.
;; SCORE        a ripe berry +2, an unripe one -3. Higher is better; 4 is the
;;              ceiling -- both good berries, nothing wasted.
;; THE POINT    demo.metta is actions over boolean perceptions.
;;              demo-thermostat is a boolean program over a numeric table.
;;              This is BOTH AT ONCE, in a single tree:
;;
;;                (and_seq ((action_bool_if
;;                   ((numGt ((groveRipeHere ()) (groveThresh (0))))
;;                    (grovePick ())
;;                    (groveStepN (2))))))
;;                 ^Act        ^Act    ^Bool     ^Number    ^Act, tuned count
;;
;;              Four types in one program, and ASK, LSK and CTK knobs in ONE
;;              instance vector that the search cannot tell apart.
;;
;;              TWO NUMBERS IN TWO ROLES, found by two different routes through
;;              the builder: the threshold by scanning inside a boolean
;;              candidate, the magnitude by scanning an action primitive's own
;;              parameter. Neither is a special case of the other.
;;
;; Both numbers start wrong, deliberately. A threshold of 0 means every berry
;; looks worth eating, and a stride of 2 from an even start never lands on an
;; odd cell -- so the exemplar picks the unripe ones and never reaches the good
;; ones at all.
;; ============================================================================
!(import! &self prototypes/m1/all)
!(import! &self prototypes/m1/domain/grove)

!(m1Moses grove (groveExemplar) groveScoreExp (groveBestScore))
