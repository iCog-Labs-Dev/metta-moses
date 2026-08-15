;; ============================================================================
;; domain/alarm.metta -- the classic MOSES boolean problem: an input table.
;;
;; Everything else under domain/ hand-writes a world and gives the creature
;; named senses to look at it. This one does not have a world at all. It has a
;; TABLE, in the shape the production tree uses (scoring/bscore.metta):
;;
;;     (mkITable <rows> <labels>)
;;
;; every row is a tuple of input values with the target as its LAST column, and
;; the labels name the columns, the last one being Output. That is the whole
;; problem statement -- there is no code anywhere describing the answer, only
;; eight rows saying what it should have said.
;;
;; A CONTEXT IS A ROW. Nothing ever changes it, so the monad that exists to
;; thread a changing world threads an unchanging one and every file above it is
;; unaffected.
;;
;; ONE PRIMITIVE, NOT ONE PER COLUMN. `colAt` takes a column index as its
;; parameter and reads that position out of the row, so the vocabulary is
;;
;;     (colAt (0))  (colAt (1))  (colAt (2))
;;
;; generated from the table's width rather than written out. Point a different
;; table at this file and the vocabulary follows it -- nothing here names a
;; column, and nothing would have to be added for a table with fifty of them.
;;
;; That is what `Params` was always for. core/types.metta calls isPrimitive
;; "classic's is_argument, generalised past 'is it a column of the input
;; table'", and classic MOSES arguments are positional too -- combo writes $1,
;; $2, and the labels are for humans. `(colAt (0))` is that, spelled out.
;;
;; SCORING FOLLOWS THE PRODUCTION TREE TOO. compareAndScore gives 0 for a row
;; the program got right and -1 for one it got wrong, and the behavioural score
;; is their sum. So the BEST score is 0 and everything else is negative, which
;; is the opposite of the action domains and the same as classic MOSES.
;; ============================================================================

;; --- the problem -------------------------------------------------------------
;; A building has two motion sensors and a maintenance switch. The alarm should
;; sound when either sensor fires, unless the building is being serviced. All
;; eight rows are present, so the table IS the specification and a program is
;; either right or provably not.
;;
;; The rows are quoted because a tuple whose head is itself a tuple is not a
;; shape to leave to chance. The labels no longer need quoting -- they are
;; headings for humans now, not operator symbols.
(= (alarmRows)
   (quote ((False False False   False)
           (False False True    False)
           (False True  False   True)
           (False True  True    False)
           (True  False False   True)
           (True  False True    False)
           (True  True  False   True)
           (True  True  True    False))))

(= (alarmLabels) (sensorFront sensorRear inMaintenance Output))

(= (alarmTable) (mkITable (alarmRows) (alarmLabels)))

(= (rowsOf   (mkITable $rows $labels)) $rows)
(= (labelsOf (mkITable $rows $labels)) $labels)

;; the target column, read the way scoring/bscore.metta reads it: the last one
(= (outputOf $row) (lastOf $row))

;; every column except the target
(= (inputCount) (- (size-atom (labelsOf (alarmTable))) 1))

;; --- the one primitive -------------------------------------------------------
;; Reads a column and hands the row back untouched -- the same shape a
;; perception has in domain/tape.metta, because a perception was always a thing
;; that looks without changing anything. The index arrives in the node's
;; parameter slot, which every primitive has always been handed.
(= (colAt ($index) $row) (mkRes (index-atom $row $index) $row))

;; A tree for one column, so exemplars and tests can say (col 0).
(= (col $index) (mkTree (mkNode colAt) ((leafOf $index))))

;; --- scoring -----------------------------------------------------------------
;; classic: compareAndScore, then sumBScore over the whole table.
(= (compareAndScore $got $wanted) (if (== $got $wanted) 0 -1))

(= (alarmRowScore $program $row)
   (let (mkRes $value $ignored) (evalProgram $program $row)
     (compareAndScore $value (outputOf $row))))

(= (alarmScoreExp $program)
   (foldl-atom (rowsOf (alarmTable)) 0 $total $row
               (+ $total (alarmRowScore $program $row))))

;; every row right, which is what a behavioural score of all zeroes sums to
(= (alarmBestScore) 0)

;; --- the program we start from ----------------------------------------------
;; "Sound the alarm when the front sensor fires" -- column 0 alone. The obvious
;; first guess, and wrong twice over: it ignores the rear sensor, and it ignores
;; maintenance. It gets three of the eight rows wrong.
(= (alarmExemplar)
   (mkTree (mkNode AND) ((col 0))))

(= (alarmRep) (buildKnobs (alarmExemplar)))

;; the one line that connects this domain to the generic machinery -- the same
;; line every other domain has
(= (alarmScore $rep $inst) (scoreInstance alarmScoreExp $rep $inst))


;; ============================================================================
;; The vocabulary, GENERATED FROM THE TABLE.
;;
;; One declaration, forever, for any table: colAt produces a Bool from a
;; parameter. Then one parameter slot per input column, computed from the
;; heading list -- so a wider table widens the vocabulary and nothing here
;; changes.
;;
;; One declaration, forever, for any table -- and one line saying colAt is a
;; FAMILY of that many leaves. The builder then adds (colAt (0)), (colAt (1)),
;; (colAt (2)) the way it would add three separately declared perceptions;
;; nothing selects between them and colAt itself decides nothing.
;;
;; The count is read off the table, so a wider table widens the vocabulary with
;; no edit here at all.
;; ============================================================================
(: colAt (-> Params $ctx Bool))

(= (paramsOf colAt) (map-atom (rangeTo (inputCount)) $index ($index)))
