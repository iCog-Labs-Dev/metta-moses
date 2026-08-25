;; ============================================================================
;; demo-alarm.metta -- NO WORLD AT ALL: the classic boolean path.
;;
;;   ( ulimit -v 8000000; timeout 900 \
;;       sh /home/yab/PeTTaV1/run.sh prototypes/m1/demo-alarm.metta -s )
;;
;; WORLD        NONE. There is no creature and nothing to change. This is an
;;              input TABLE in the shape the production tree uses -- eight rows
;;              of True/False with the answer as the last column. Two motion
;;              sensors and a maintenance switch; the alarm should sound when
;;              either sensor fires, unless the building is being serviced. All
;;              eight rows are present, so the table IS the specification.
;; CONTEXT      a ROW. The program reads it and never alters it -- so the
;;              machinery that exists to thread a CHANGING world threads an
;;              unchanging one, and not a line of it notices. That is the thing
;;              this demo is really testing.
;; VOCABULARY   one primitive, colAt, parametrised by column index, so the
;;              vocabulary is (colAt (0)) (colAt (1)) (colAt (2)) -- generated
;;              from the table's width rather than written out. Widen the table
;;              and the vocabulary widens on its own; nothing here names a
;;              column.
;; SCORE        0 for a row got right, -1 for one got wrong, summed. So the BEST
;;              score is 0 and everything else is negative -- the opposite of
;;              the action worlds, and the same as classic MOSES.
;; THE POINT    no single column reproduces the table, so the answer has to
;;              combine them. Same buildKnobs, same getCandidate, same
;;              hillClimbing as every action world above.
;;
;; The exemplar guesses "sound the alarm when the front sensor fires" -- column
;; 0 alone, wrong on three of the eight rows.
;; ============================================================================
!(import! &self prototypes/m1/all)
!(import! &self prototypes/m1/domain/alarm)

!(m1Moses alarm (alarmExemplar) alarmScoreExp (alarmBestScore))
