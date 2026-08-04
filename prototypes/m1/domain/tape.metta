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

(= (m1Next $cells $pos) (if (>= (+ $pos 1) (size-atom $cells)) 0 (+ $pos 1)))

(= (m1SetCell $cells $i $v)
   (let $idxs (rangeTo (size-atom $cells))
     (map-atom $idxs $k (if (== $k $i) $v (index-atom $cells $k)))))

;; --- actions ----------------------------------------------------------------
(= (m1Grab $params (mkW $c $p $e $pen $f))
   (if (<= $f 0)
       (mkRes False (mkW $c $p $e $pen $f))
       (if (== (index-atom $c $p) F)
           (mkRes True (mkW (m1SetCell $c $p E) $p (+ $e 1) $pen (- $f 1)))
           (mkRes True (mkW $c $p $e (+ $pen 1) (- $f 1))))))

(= (m1Step $params (mkW $c $p $e $pen $f))
   (if (<= $f 0)
       (mkRes False (mkW $c $p $e $pen $f))
       (mkRes True (mkW $c (m1Next $c $p) $e $pen (- $f 1)))))

;; --- perceptions ------------------------------------------------------------
(= (m1FoodHere $params (mkW $c $p $e $pen $f))
   (mkRes (== (index-atom $c $p) F) (mkW $c $p $e $pen $f)))

(= (m1FoodAhead $params (mkW $c $p $e $pen $f))
   (mkRes (== (index-atom $c (m1Next $c $p)) F) (mkW $c $p $e $pen $f)))

;; --- two tapes --------------------------------------------------------------
;; They agree at position 0 and differ EVERYWHERE else. A program that never
;; looks runs the same way on both, so whatever it gains on one it loses on the
;; other -- across the two episodes it can never score more than 2. Looking
;; scores 10. That gap is the point of the whole exercise.
(= (m1TapeA) (F F E F E F E F E))      ;; food at 0,1,3,5,7
(= (m1TapeB) (F E F E F E F E F))      ;; food at 0,2,4,6,8
(= (m1Fuel) 14)                        ;; exactly one lap if played perfectly
(= (m1World $i) (mkW (if (== (% $i 2) 0) (m1TapeA) (m1TapeB)) 0 0 0 (m1Fuel)))
(= (m1BestScore) 10)

;; --- running one episode ----------------------------------------------------
;; The program is run over and over until the fuel is gone. The check for "no
;; fuel was used" is what stops a program that never acts from looping forever;
;; it simply scores 0.
(= (m1RunEpisode $exp (mkW $c $p $e $pen $f))
   (if (<= $f 0)
       (- $e $pen)
       (let (mkRes $v (mkW $c2 $p2 $e2 $pen2 $f2))
            (evalProgram $exp (mkW $c $p $e $pen $f))
         (if (== $f2 $f)
             (- $e2 $pen2)
             (m1RunEpisode $exp (mkW $c2 $p2 $e2 $pen2 $f2))))))

(= (m1Fitness $exp $i) (m1RunEpisode $exp (m1World $i)))
(= (m1ScoreExp $exp) (+ (m1Fitness $exp 0) (m1Fitness $exp 1)))
(= (m1FoodCount $cells) (foldl-atom $cells 0 $a $x (if (== $x F) (+ $a 1) $a)))

;; --- the program we start from ----------------------------------------------
;; Deliberately wrong: it steps when it sees food and grabs when it does not.
(= (m1Exemplar)
   (mkTree (mkNode and_seq)
     ((mkTree (mkNode action_bool_if)
        ((mkTree (mkNode m1FoodHere) ())
         (mkTree (mkNode m1Step) ())
         (mkTree (mkNode m1Grab) ()))))))

(= (m1Rep) (buildRep (m1Exemplar)))

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
;; AND, OR and NOT are absent on purpose: a declaration applies to a symbol no
;; matter how many arguments a use of it has, and those three deliberately have
;; two forms. core/types.metta carries their signatures instead.
;; ============================================================================
(: Act Type)
(: Params Type)

(: m1Grab      (-> Params $ctx Act))
(: m1Step      (-> Params $ctx Act))
(: m1FoodHere  (-> Params $ctx Bool))
(: m1FoodAhead (-> Params $ctx Bool))

(: action_bool_if (-> (Bool Act Act) $ctx Act))
(: and_seq        (-> (Seq Act) $ctx Act))
(: or_seq         (-> (Seq Act) $ctx Act))
(: action_not     (-> (Act) $ctx Act))
