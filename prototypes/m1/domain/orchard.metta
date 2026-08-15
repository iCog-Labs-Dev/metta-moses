;; ============================================================================
;; domain/orchard.metta -- a world where half the fruit has gone bad.
;;
;; A creature walks a ring of cells. Each cell holds one of three things:
;;
;;     FS   fresh fruit        FX   spoiled fruit        E   nothing
;;
;;     (mkOrchard <cells> <position> <eaten> <wasted> <fuel>)
;;
;; Two things it can DO:    orchPick   eat what is here -- and eating the bad
;;                                     fruit costs more than eating nothing
;;                          orchWalk   move on one cell
;;
;; TWO SENSES, AND EACH IS BLIND TO WHAT THE OTHER SEES:
;;
;;     orchFruitHere   SIGHT. There is something in this cell. Fresh and
;;                     spoiled fruit look alike, so this is true at FS and FX.
;;     orchNoRotHere   SMELL. Nothing here smells of rot. True at FS -- and
;;                     also at E, because bare ground does not smell of rot
;;                     either.
;;
;; So sight cannot tell good fruit from bad, and smell cannot tell fruit from
;; bare ground. That is the point of the world, and it is why NEITHER SENSE IS
;; WORTH ANYTHING ON ITS OWN:
;;   - pick whenever you see something, and you eat the spoiled fruit too
;;   - pick whenever you smell no rot, and you pick at empty cells -- and
;;     picking at an empty cell leaves it empty, so you never move again
;;
;; Only "I can see something AND I cannot smell rot" is fresh fruit, and a
;; conjunction is a thing the search has to BUILD: it is not any single sense,
;; nor any single sense negated. domain/tape.metta asks whether looking is
;; worth it; this one asks whether using two senses at once is.
;;
;; Same rule as domain/tape.metta, and for the same reason: an action reports
;; success while there is fuel, whatever it found. Were a wasted pick to report
;; failure, a program could tell fresh from spoiled by watching whether its
;; actions succeeded -- seeing without looking -- and the conjunction would stop
;; being necessary. Seeing costs nothing and changes nothing: a perception hands
;; the world back exactly as it found it.
;; ============================================================================

(= (orchNext $cells $position)
   (if (>= (+ $position 1) (size-atom $cells)) 0 (+ $position 1)))

(= (orchSetCell $cells $at $value)
   (map-atom (rangeTo (size-atom $cells)) $index
             (if (== $index $at) $value (index-atom $cells $index))))

;; --- actions ----------------------------------------------------------------
;; Picking always costs a move. What it is worth depends on what was there, and
;; the creature is never told which of the three happened.
;;     FS  +2 eaten,   the cell is emptied
;;     FX  +3 wasted,  the cell is emptied -- you throw the bad fruit away
;;     E   +1 wasted,  nothing changes, so the creature has not moved either
(= (orchPick $params (mkOrchard $cells $position $eaten $wasted $fuel))
   (if (<= $fuel 0)
       (mkRes False (mkOrchard $cells $position $eaten $wasted $fuel))
       (let* (($cell    (index-atom $cells $position))
              ($emptied (orchSetCell $cells $position E)))
         (if (== $cell FS)
             (mkRes True (mkOrchard $emptied $position (+ $eaten 2) $wasted (- $fuel 1)))
             (if (== $cell FX)
                 (mkRes True (mkOrchard $emptied $position $eaten (+ $wasted 3) (- $fuel 1)))
                 (mkRes True (mkOrchard $cells $position $eaten (+ $wasted 1) (- $fuel 1))))))))

(= (orchWalk $params (mkOrchard $cells $position $eaten $wasted $fuel))
   (if (<= $fuel 0)
       (mkRes False (mkOrchard $cells $position $eaten $wasted $fuel))
       (mkRes True (mkOrchard $cells (orchNext $cells $position)
                              $eaten $wasted (- $fuel 1)))))

;; --- perceptions ------------------------------------------------------------
;; Between them these two split the three cells into overlapping halves. Neither
;; half is the answer; their INTERSECTION is, and it is the only cell worth
;; picking.
;;              FS      FX      E
;; fruitHere    True    True    False     <- sight: something is there
;; noRotHere    True    False   True      <- smell: nothing rotten
;;              ^^^^ only FS is both
(= (orchFruitHere $params (mkOrchard $cells $position $eaten $wasted $fuel))
   (let $cell (index-atom $cells $position)
     (mkRes (or (== $cell FS) (== $cell FX))
            (mkOrchard $cells $position $eaten $wasted $fuel))))

(= (orchNoRotHere $params (mkOrchard $cells $position $eaten $wasted $fuel))
   (let $cell (index-atom $cells $position)
     (mkRes (or (== $cell FS) (== $cell E))
            (mkOrchard $cells $position $eaten $wasted $fuel))))

;; --- two rings --------------------------------------------------------------
;; Both hold three fresh fruits, at 0, 3 and 6. They differ in where the
;; spoiled fruit sits: ring A puts it just after each fresh one, ring B just
;; before. So a program that cannot tell FX from FS pays for that mistake on
;; both rings, and no walking pattern learned from one carries to the other.
;;
;; Three fresh fruits at 2 each is 6, and wasted can never go below 0, so 6 per
;; ring -- 12 over the two episodes -- is an upper bound no program can pass.
(= (orchRingA) (FS FX E FS FX E FS FX E))
(= (orchRingB) (FS E FX FS E FX FS E FX))
(= (orchFuel) 14)
(= (orchWorld $episode)
   (mkOrchard (if (== (% $episode 2) 0) (orchRingA) (orchRingB)) 0 0 0 (orchFuel)))
(= (orchBestScore) 12)

(= (orchFreshCount $cells)
   (foldl-atom $cells 0 $count $cell (if (== $cell FS) (+ $count 1) $count)))
(= (orchSpoiledCount $cells)
   (foldl-atom $cells 0 $count $cell (if (== $cell FX) (+ $count 1) $count)))

;; --- running one episode ----------------------------------------------------
;; Run the program over and over until the fuel is gone. The "no fuel was used"
;; check is what stops a program that never acts from looping forever; it simply
;; scores 0.
(= (orchRunEpisode $program (mkOrchard $cells $position $eaten $wasted $fuel))
   (if (<= $fuel 0)
       (- $eaten $wasted)
       (let (mkRes $value $next)
            (evalProgram $program (mkOrchard $cells $position $eaten $wasted $fuel))
         (let (mkOrchard $cellsAfter $posAfter $eatenAfter $wastedAfter $fuelAfter) $next
           ;; no fuel used means the program never acts -- stop, or it loops
           (if (== $fuelAfter $fuel)
               (- $eatenAfter $wastedAfter)
               (orchRunEpisode $program $next))))))

(= (orchFitness $program $episode) (orchRunEpisode $program (orchWorld $episode)))
(= (orchScoreExp $program) (+ (orchFitness $program 0) (orchFitness $program 1)))

;; --- the program we start from ----------------------------------------------
;; Not backwards, the way domain/tape.metta's exemplar is -- just naive. "If
;; there is fruit here, pick it" is the obvious thing to write, and it is wrong
;; only because half the fruit is bad.
(= (orchExemplar)
   (mkTree (mkNode and_seq)
     ((mkTree (mkNode action_bool_if)
        ((mkTree (mkNode orchFruitHere) ())
         (mkTree (mkNode orchPick) ())
         (mkTree (mkNode orchWalk) ()))))))

(= (orchRep) (buildKnobs (orchExemplar)))

;; the one line that connects this domain to the generic machinery
(= (orchScore $rep $inst) (scoreInstance orchScoreExp $rep $inst))


;; ============================================================================
;; Type declarations. Only this domain's own four primitives: the operators
;; they get combined with are declared once, in core/types.metta.
;; ============================================================================
(: orchPick      (-> Params $ctx Act))
(: orchWalk      (-> Params $ctx Act))
(: orchFruitHere (-> Params $ctx Bool))
(: orchNoRotHere (-> Params $ctx Bool))
