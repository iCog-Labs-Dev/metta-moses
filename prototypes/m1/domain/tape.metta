;; ============================================================================
;; domain/tape.metta -- a toy world, and the ONLY file that knows what a
;; context is.
;;
;; An ant-like creature walks a circular tape of cells. Some cells hold food.
;; It has a fixed budget of actions.
;;
;;     (mkW <cells> <position> <eaten> <wasted> <fuel>)
;;
;; Two things it can DO:      grab (eat if there is food, otherwise waste a move)
;;                            step (move on one cell)
;; Two things it can SEE:     is there food here?   is there food ahead?
;;
;; ONE RULE MAKES THE WHOLE THING WORK: an action always reports success while
;; there is fuel, whether or not it found food. If grabbing an empty cell
;; reported failure, a program could learn where the food is by watching
;; whether its actions succeed -- it would be seeing without looking. Because
;; it cannot, a program that never looks behaves identically on both tapes
;; below, and that is what makes looking provably worth it.
;;
;; Seeing costs nothing and changes nothing: perceptions hand back the world
;; exactly as they found it.
;; ============================================================================

(= (m1Next $cells $position)
   (if (>= (+ $position 1) (size-atom $cells)) 0 (+ $position 1)))

(= (m1SetCell $cells $at $value)
   (map-atom (rangeTo (size-atom $cells)) $index
             (if (== $index $at) $value (index-atom $cells $index))))

;; --- actions ----------------------------------------------------------------
(= (m1Grab $params (mkW $cells $position $eaten $wasted $fuel))
   (if (<= $fuel 0)
       (mkRes False (mkW $cells $position $eaten $wasted $fuel))
       (if (== (index-atom $cells $position) F)
           (mkRes True (mkW (m1SetCell $cells $position E) $position
                            (+ $eaten 1) $wasted (- $fuel 1)))
           (mkRes True (mkW $cells $position $eaten (+ $wasted 1) (- $fuel 1))))))

(= (m1Step $params (mkW $cells $position $eaten $wasted $fuel))
   (if (<= $fuel 0)
       (mkRes False (mkW $cells $position $eaten $wasted $fuel))
       (mkRes True (mkW $cells (m1Next $cells $position) $eaten $wasted (- $fuel 1)))))

;; --- perceptions ------------------------------------------------------------
(= (m1FoodHere $params (mkW $cells $position $eaten $wasted $fuel))
   (mkRes (== (index-atom $cells $position) F)
          (mkW $cells $position $eaten $wasted $fuel)))

(= (m1FoodAhead $params (mkW $cells $position $eaten $wasted $fuel))
   (mkRes (== (index-atom $cells (m1Next $cells $position)) F)
          (mkW $cells $position $eaten $wasted $fuel)))

;; --- two tapes --------------------------------------------------------------
;; They agree at position 0 and differ EVERYWHERE else. A program that never
;; looks runs the same way on both, so whatever it gains on one it loses on the
;; other -- across the two episodes it can never score more than 2. Looking
;; scores 10. That gap is the point of the whole exercise.
(= (m1TapeA) (F F E F E F E F E))      ;; food at 0,1,3,5,7
(= (m1TapeB) (F E F E F E F E F))      ;; food at 0,2,4,6,8
(= (m1Fuel) 14)                        ;; exactly one lap if played perfectly
(= (m1World $episode) (mkW (if (== (% $episode 2) 0) (m1TapeA) (m1TapeB)) 0 0 0 (m1Fuel)))
(= (m1BestScore) 10)

;; --- running one episode ----------------------------------------------------
;; The program is run over and over until the fuel is gone. The check for "no
;; fuel was used" is what stops a program that never acts from looping forever;
;; it simply scores 0.
(= (m1RunEpisode $program (mkW $cells $position $eaten $wasted $fuel))
   (if (<= $fuel 0)
       (- $eaten $wasted)
       (let (mkRes $value $next)
            (evalProgram $program (mkW $cells $position $eaten $wasted $fuel))
         (let (mkW $cellsAfter $posAfter $eatenAfter $wastedAfter $fuelAfter) $next
           ;; no fuel used means the program never acts -- stop, or it loops
           (if (== $fuelAfter $fuel)
               (- $eatenAfter $wastedAfter)
               (m1RunEpisode $program $next))))))

(= (m1Fitness $program $episode) (m1RunEpisode $program (m1World $episode)))
(= (m1ScoreExp $program) (+ (m1Fitness $program 0) (m1Fitness $program 1)))
(= (m1FoodCount $cells) (foldl-atom $cells 0 $count $cell (if (== $cell F) (+ $count 1) $count)))

;; --- the program we start from ----------------------------------------------
;; Deliberately wrong: it steps when it sees food and grabs when it does not.
(= (m1Exemplar)
   (mkTree (mkNode and_seq)
     ((mkTree (mkNode action_bool_if)
        ((mkTree (mkNode m1FoodHere) ())
         (mkTree (mkNode m1Step) ())
         (mkTree (mkNode m1Grab) ()))))))

(= (m1Rep) (buildKnobs (m1Exemplar)))

;; the one line that connects this domain to the generic machinery
(= (m1Score $rep $inst) (scoreInstance m1ScoreExp $rep $inst))


;; ============================================================================
;; Type declarations.
;;
;; The argument part says what a thing's CHILDREN are, and that is what tells
;; the builder how to treat it:
;;     Params          no children -- a leaf that takes parameters
;;     (Seq Act)       any number of Act children
;;     (Bool Act Act)  exactly three, of those types
;;
;; The return type says what it produces, which is how the builder knows what
;; may go in a slot. Declare a new perception here and it joins the boolean
;; vocabulary automatically -- nothing else changes.
;;
;; A domain declares ONLY its own primitives. The operators they are combined
;; with -- and_seq, action_bool_if and the rest -- are declared once in
;; core/types.metta, because they belong to no domain.
;; ============================================================================
(: m1Grab      (-> Params $ctx Act))
(: m1Step      (-> Params $ctx Act))
(: m1FoodHere  (-> Params $ctx Bool))
(: m1FoodAhead (-> Params $ctx Bool))
