;; ============================================================================
;; domain/thermostat.metta -- a NUMERIC input table, and a threshold the search
;; has to tune.
;;
;; domain/alarm.metta is the boolean table: every column is True or False and the
;; search combines columns. Here the column is a NUMBER, and no combination of
;; columns can express the answer -- the answer is a comparison against a value
;; that appears nowhere in the table.
;;
;;     sound the alarm when the temperature exceeds some level
;;
;; The level is what has to be found. It is not in the vocabulary, it is not in
;; the data, and it is not written in the exemplar: the exemplar guesses 0 and is
;; wrong on half the rows. What finds it is a CONTIN KNOB -- classic MOSES's
;; mechanism for putting a real number into a discrete search, ported in
;; knobs/knob.metta.
;;
;; WHY THIS IS THE INTERESTING CASE. Every other knob in this prototype chooses a
;; SUBTREE from a list the builder enumerated. A contin knob chooses a VALUE, and
;; the value cannot be enumerated. It is reached by a walk -- Left, Right, Stop --
;; over three instance slots, each an ordinary 3-setting knob, so
;; search/hillclimb.metta never learns that a number is involved.
;;
;; THE MEAN COMES FROM THE TREE. `(numThreshold (0))` in the exemplar is the
;; walk's starting point, so an all-Stop instance decodes back to the exemplar --
;; which is what keeps `exemplarInst` an honest check rather than a coincidence.
;; ============================================================================

;; --- the problem -------------------------------------------------------------
;; Six readings. The alarm should sound above 16 degrees, but nothing here says
;; 16: the table only says which readings should and should not sound it, and any
;; level in (12, 20] reproduces it. The search has to land in that window.
;;
;; Rows are quoted for the same reason alarm's are -- a tuple whose head is
;; itself a tuple is not a shape to leave to chance.
(= (thermRows)
   (( 2 False)
           (10 False)
           (12 False)
           (20 True)
           (25 True)
           (40 True)))

(= (thermLabels) (temperature Output))

(= (thermTable) (mkITable (thermRows) (thermLabels)))

;; Deliberately NOT named rowsOf/labelsOf/outputOf/compareAndScore: those are
;; domain/alarm.metta's, and a second identical clause set would double every
;; answer if both domains were ever imported together.
(= (thermRowsOf   (mkITable $rows $labels)) $rows)
(= (thermLabelsOf (mkITable $rows $labels)) $labels)
(= (thermOutputOf $row) (lastOf $row))
(= (thermInputCount) (- (size-atom (thermLabelsOf (thermTable))) 1))

;; --- the vocabulary ----------------------------------------------------------
;; A numeric column reads its position out of the row, exactly as alarm's colAt
;; does. The only difference is the declared return type, and that difference is
;; what makes it a legal argument to a comparison instead of to an AND.
(= (numColAt ($index) $row) (mkRes (index-atom $row $index) $row))

;; A tunable constant. It ignores the row entirely -- it IS its parameter. That
;; is the whole trick: a number the search can move is a primitive whose
;; parameter happens to be continuous, so it needs no new kind of tree node.
(= (numThreshold ($n) $row) (mkRes $n $row))

;; --- trees, written with the same helpers the builder uses -------------------
;; This matters: assignKnobs recognises the exemplar's own condition by comparing
;; it against the sampled candidates, so the exemplar has to be built the way
;; instancesOf builds them or it would not be matched -- it would be dropped and
;; re-offered, and the starting instance would no longer reproduce the starting
;; program.
(= (thermCol)         (mkTree (mkNode numColAt)     ((leafOf 0))))
(= (thermThresh $n)   (mkTree (mkNode numThreshold) ((leafOf $n))))

;; --- scoring -----------------------------------------------------------------
;; classic's 0-for-right, -1-for-wrong, summed. Best score is 0.
(= (thermCompare $got $wanted) (if (== $got $wanted) 0 -1))

(= (thermRowScore $program $row)
   (let (mkRes $value $ignored) (evalProgram $program $row)
     (thermCompare $value (thermOutputOf $row))))

(= (thermScoreExp $program)
   (foldl-atom (thermRowsOf (thermTable)) 0 $total $row
               (+ $total (thermRowScore $program $row))))

(= (thermBestScore) 0)

;; --- the program we start from ----------------------------------------------
;; "Sound the alarm when the temperature is above zero" -- true of every row, so
;; it is wrong on the three that should stay quiet. The structure is already
;; right; only the number is wrong, which is what isolates the contin knob.
(= (thermExemplar)
   (mkTree (mkNode AND)
     ((mkTree (mkNode numGt) ((thermCol) (thermThresh 0))))))

(= (thermRep) (buildKnobs (thermExemplar)))

(= (thermScore $rep $inst) (scoreInstance thermScoreExp $rep $inst))


;; ============================================================================
;; Declarations.
;;
;; numColAt is an ordinary parameterised primitive: `paramsOf` names the discrete
;; set its parameter ranges over, one entry per input column.
;;
;; numThreshold answers the SAME question differently -- `continOf` says its
;; parameter is a number to tune, and gives the walk its step, expansion and
;; depth. With mean 0, step 8, expansion 2 and depth 3 the reachable values
;; include 8 (one Right), 24 (two Rights) and 16 (Right, Right, Left), which is
;; inside the (12, 20] window the table allows. Three moves, each an improvement.
;;
;; The mean written here is a fallback for a threshold the BUILDER places; the
;; exemplar's own `(numThreshold (0))` supplies the mean for the one it wrote.
;; ============================================================================
(: numColAt     (-> Params $ctx Number))
(: numThreshold (-> Params $ctx Number))

(= (paramsOf numColAt) (map-atom (rangeTo (thermInputCount)) $index ($index)))
(= (continOf numThreshold) (mkContin 0 8 2 3))
