;; ============================================================================
;; demo-thermostat.metta -- TUNING A NUMBER, not choosing a subtree.
;;
;;   ( ulimit -v 8000000; timeout 900 \
;;       sh /home/yab/PeTTaV1/run.sh prototypes/m1/demo-thermostat.metta -s )
;;
;; WORLD        NONE -- an input table again, but the column is a NUMBER. Six
;;              temperature readings and whether the alarm should have sounded.
;; CONTEXT      a ROW, unchanged by the program, exactly as in demo-alarm.
;; VOCABULARY   numColAt reads the column. numThreshold IS its parameter -- a
;;              constant the search can move. numGt compares two Numbers and is
;;              what turns them into the Bool a condition needs.
;; SCORE        0 for a reading got right, -1 for one got wrong. Best is 0.
;; THE POINT    every other knob in this prototype chooses a SUBTREE from a list
;;              the builder enumerated. Here the answer is a VALUE, and a value
;;              cannot be enumerated: any level in (12, 20] reproduces the
;;              table, and no such number appears in the table, the vocabulary
;;              or the exemplar.
;;
;;              A CONTIN KNOB reaches it by a WALK -- Left, Right or Stop over
;;              three ordinary 3-setting slots -- so search/hillclimb.metta
;;              never learns that a number is involved at all. All-Stop means
;;              "the number the exemplar was built with", which is what makes
;;              the starting instance decode back to the starting program.
;;
;;              Watch the trail: 0 -> 8 -> 24 -> 16. It OVERSHOOTS in the
;;              expansion phase and bisects back. Nothing asked it to do that;
;;              it is what one-knob-at-a-time hill climbing does to a walk
;;              encoding, and it is classic MOSES's contin_stepper arithmetic.
;;
;; The exemplar guesses "sound the alarm above zero degrees", which is true of
;; every reading. The STRUCTURE is already right and only the number is wrong,
;; which is what isolates the contin knob.
;; ============================================================================
!(import! &self prototypes/m1/all)
!(import! &self prototypes/m1/domain/thermostat)

!(m1Moses thermostat (thermExemplar) thermScoreExp (thermBestScore))
