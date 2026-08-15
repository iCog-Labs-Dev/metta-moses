;; ============================================================================
;; domain/berries.metta -- a world whose answer is NOT on the menu.
;;
;; A creature walks a ring of berries. Each cell holds one of:
;;
;;     RC  ripe by colour, sound      RW  ripe by colour, WORMY
;;     RS  ripe by smell,  sound      U   unripe          E  nothing left
;;
;;     (mkPatch <cells> <position> <eaten> <wasted> <fuel>)
;;
;; Two things it can DO:    berryPick   take what is here
;;                          berryWalk   move on one cell
;; Three things it can SEE: berryWormy  is this one wormy?
;;                          berryRed    does it look ripe?   (RC and RW)
;;                          berrySweet  does it smell ripe?  (RS)
;;
;; Picking is worth +2 on a sound ripe berry, -3 on a wormy one, -2 on an
;; unripe one, and -1 on a cell already emptied -- and an empty pick does not
;; move you, so a program that picks at nothing stands still until the fuel is
;; gone.
;;
;; THE POINT OF THIS WORLD. The berries worth taking are exactly
;;
;;     (AND (OR berryRed berrySweet) (NOT berryWormy))
;;
;; and `(OR berryRed berrySweet)` is NOT one of the candidates offered at the
;; condition. The sampler walks operator-headed candidates in order and the
;; budget runs out before it reaches that pair -- what it does offer is
;; (OR berryWormy berryRed), (OR berryWormy berrySweet) and so on, because
;; berryWormy is the first perception declared and the odometer holds the
;; leading slot steady longest.
;;
;; So the disjunction cannot be switched on. It has to be BUILT, one perception
;; at a time, inside the OR node the builder leaves under the condition -- which
;; is what that node is for. domain/orchard.metta needs a conjunction and gets
;; handed it in one move; this one needs a shape nothing hands over.
;;
;; Same invariant as the other two worlds: an action reports success while
;; there is fuel, whatever it found, so success never leaks what the cell was.
;; ============================================================================

(= (berryNext $cells $position)
   (if (>= (+ $position 1) (size-atom $cells)) 0 (+ $position 1)))

(= (berrySetCell $cells $at $value)
   (map-atom (rangeTo (size-atom $cells)) $index
             (if (== $index $at) $value (index-atom $cells $index))))

;; what taking the berry in this cell is worth
(= (berryWorth $cell)
   (if (== $cell RC) 2
   (if (== $cell RS) 2
   (if (== $cell RW) -3
   (if (== $cell U)  -2
                     -1)))))

;; --- actions ----------------------------------------------------------------
;; Picking empties the cell -- unless there was nothing there, in which case
;; nothing changes and the creature has not moved either.
(= (berryPick $params (mkPatch $cells $position $eaten $wasted $fuel))
   (if (<= $fuel 0)
       (mkRes False (mkPatch $cells $position $eaten $wasted $fuel))
       (let* (($cell  (index-atom $cells $position))
              ($worth (berryWorth $cell))
              ($after (if (== $cell E) $cells (berrySetCell $cells $position E))))
         (if (> $worth 0)
             (mkRes True (mkPatch $after $position (+ $eaten $worth) $wasted (- $fuel 1)))
             (mkRes True (mkPatch $after $position $eaten (- $wasted $worth) (- $fuel 1)))))))

(= (berryWalk $params (mkPatch $cells $position $eaten $wasted $fuel))
   (if (<= $fuel 0)
       (mkRes False (mkPatch $cells $position $eaten $wasted $fuel))
       (mkRes True (mkPatch $cells (berryNext $cells $position)
                            $eaten $wasted (- $fuel 1)))))

;; --- perceptions ------------------------------------------------------------
;;             RC      RW      RS      U       E
;; wormy       False   True    False   False   False
;; red         True    True    False   False   False
;; sweet       False   False   True    False   False
(= (berryWormy $params (mkPatch $cells $position $eaten $wasted $fuel))
   (mkRes (== (index-atom $cells $position) RW)
          (mkPatch $cells $position $eaten $wasted $fuel)))

(= (berryRed $params (mkPatch $cells $position $eaten $wasted $fuel))
   (let $cell (index-atom $cells $position)
     (mkRes (or (== $cell RC) (== $cell RW))
            (mkPatch $cells $position $eaten $wasted $fuel))))

(= (berrySweet $params (mkPatch $cells $position $eaten $wasted $fuel))
   (mkRes (== (index-atom $cells $position) RS)
          (mkPatch $cells $position $eaten $wasted $fuel)))

;; --- two rings --------------------------------------------------------------
;; Same four sound berries and same two wormy ones on each, in a different
;; order, so no fixed walking rhythm carries from one to the other.
(= (berryRingA) (RC RW RS U RC RW RS U))
(= (berryRingB) (RS U RC RW RS U RC RW))
(= (berryFuel) 14)
(= (berryWorld $episode)
   (mkPatch (if (== (% $episode 2) 0) (berryRingA) (berryRingB)) 0 0 0 (berryFuel)))
(= (berryBestScore) 16)

;; --- running one episode ----------------------------------------------------
(= (berryRunEpisode $program (mkPatch $cells $position $eaten $wasted $fuel))
   (if (<= $fuel 0)
       (- $eaten $wasted)
       (let (mkRes $value $next)
            (evalProgram $program (mkPatch $cells $position $eaten $wasted $fuel))
         (let (mkPatch $cellsAfter $posAfter $eatenAfter $wastedAfter $fuelAfter) $next
           ;; no fuel used means the program never acts -- stop, or it loops
           (if (== $fuelAfter $fuel)
               (- $eatenAfter $wastedAfter)
               (berryRunEpisode $program $next))))))

(= (berryFitness $program $episode) (berryRunEpisode $program (berryWorld $episode)))
(= (berryScoreExp $program) (+ (berryFitness $program 0) (berryFitness $program 1)))

;; --- the program we start from ----------------------------------------------
;; "Take the ones that look ripe." Reasonable, and wrong twice over: it takes
;; the wormy ones, which also look ripe, and it walks past the ones that are
;; ripe by smell alone.
(= (berryExemplar)
   (mkTree (mkNode and_seq)
     ()))

(= (berryRep) (buildKnobs (berryExemplar)))

;; the one line that connects this domain to the generic machinery
(= (berryScore $rep $inst) (scoreInstance berryScoreExp $rep $inst))


;; ============================================================================
;; Type declarations. Only this domain's own primitives -- the operators they
;; get combined with are declared once, in core/types.metta.
;;
;; THE ORDER MATTERS HERE, which is worth saying out loud. primsOfType hands
;; back the perceptions in declaration order, the sampler fills its leading
;; argument slot from that list first, and the budget runs out before the
;; leading slot has moved past the first perception. Declaring berryWormy first
;; is therefore what keeps (OR berryRed berrySweet) off the menu.
;; ============================================================================
(: berryPick  (-> Params $ctx Act))
(: berryWalk  (-> Params $ctx Act))
(: berryWormy (-> Params $ctx Bool))
(: berryRed   (-> Params $ctx Bool))
(: berrySweet (-> Params $ctx Bool))
