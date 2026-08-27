;; ============================================================================
;; domain/grove.metta -- actions and numbers in the same program.
;;
;; A picker walks a row of fruit trees, each carrying a RIPENESS. It can pick
;; the tree it is standing at, or walk on. Picking a ripe one is worth
;; something; picking an unripe one wastes the fruit.
;;
;;     (mkG <ripeness per tree> <position> <picked> <spoiled> <fuel>)
;;
;; Two things it can DO:    pick (worth it only if ripe enough)
;;                          walk on by some number of trees
;; Two things it can SEE:   how ripe is this tree?  how ripe is the next one?
;;
;; Every other domain is discrete: the search only chooses WHICH perceptions a
;; condition is built from. Here the decisive part is a NUMBER -- the ripeness
;; the picker holds out for -- and it appears nowhere in the world, vocabulary
;; or declarations. `groveRipeEnough` is undeclared, so it never joins the
;; vocabulary and no program can read it; the value comes out of fitness alone.
;;
;; The mixture is the point: one instance vector holds ASK, LSK and CTK knobs,
;; reached by three different routes -- the threshold by descending into a
;; comparison inside a condition, the stride through an ordinary Act slot.
;;
;; As in domain/tape.metta, an action reports success while there is fuel
;; whatever the fruit was like. Otherwise a program could read ripeness by
;; watching its actions succeed -- seeing without looking.
;; ============================================================================

(= (groveNext $trees $position)
   (if (>= (+ $position 1) (size-atom $trees)) 0 (+ $position 1)))

;; Walking on by $steps is $steps single steps. Written as a fold over
;; groveNext rather than with `%` on purpose: `%` compiles to a direct goal
;; outside reduce's catch, so a stride that arrived as a fraction would take the
;; whole run down instead of scoring badly.
(= (groveAhead $trees $position $steps)
   (foldl-atom (rangeTo $steps) $position $at $ignored (groveNext $trees $at)))

(= (grovePicked $trees $at)
   (map-atom (rangeTo (size-atom $trees)) $index
             (if (== $index $at) 0 (index-atom $trees $index))))

;; The world's own truth, and deliberately NOT declared: with no (: ...) it
;; joins no vocabulary, so `8` is a number the search must find rather than one
;; it can name.
(= (groveRipeEnough) 8)

;; A tuned number arrives as a contin walk, so it can be fractional or negative.
;; Rounding down and clamping to one keeps a stride a stride; classic pushes the
;; same problem into the domain too, keeping contin_t as a double everywhere and
;; letting the operator decide what a fraction of an action means.
(= (groveStepsOf $value)
   (let $whole (floor-math $value) (if (<= $whole 0) 1 $whole)))

;; --- what it can DO ---------------------------------------------------------
;; A primitive: takes parameters and a context, hands back an mkRes.
(= (grovePick $params (mkG $trees $position $picked $spoiled $fuel))
   (if (<= $fuel 0)
       (mkRes False (mkG $trees $position $picked $spoiled $fuel))
       (if (> (index-atom $trees $position) (groveRipeEnough))
           (mkRes True (mkG (grovePicked $trees $position) $position
                            (+ $picked 1) $spoiled (- $fuel 1)))
           (mkRes True (mkG (grovePicked $trees $position) $position
                            $picked (+ $spoiled 1) (- $fuel 1))))))

;; An OPERATOR, not a primitive, and the rule forces it: a tunable stride means
;; the slot must be declared Number, and Number rather than Params is what makes
;; isPrimitive false. So it is called context-free and reaches the world through
;; getCtx/putCtx -- only possible because core/monad.metta made the context
;; ambient.
;;
;; The price: addSimpleActionKnobs knobs only PRIMITIVE children, so this
;; action's stride is tunable and the action itself cannot be switched off.
(= (groveWalkBy ($n))
   (let* (((mkG $trees $position $picked $spoiled $fuel) (getCtx))
          ($steps   (groveStepsOf (evalTerm $n)))
          ($moved   (if (<= $fuel 0)
                        (mkG $trees $position $picked $spoiled $fuel)
                        (mkG $trees (groveAhead $trees $position $steps)
                             $picked $spoiled (- $fuel 1))))
          ($ignored (putCtx $moved)))
     (> $fuel 0)))

;; --- what it can SEE --------------------------------------------------------
;; Numbers, not booleans -- which is the only reason a Number slot has anything
;; to draw on. Seeing costs nothing and changes nothing.
(= (groveRipeHere $params (mkG $trees $position $picked $spoiled $fuel))
   (mkRes (index-atom $trees $position)
          (mkG $trees $position $picked $spoiled $fuel)))

(= (groveRipeAhead $params (mkG $trees $position $picked $spoiled $fuel))
   (mkRes (index-atom $trees (groveNext $trees $position))
          (mkG $trees $position $picked $spoiled $fuel)))

;; --- two groves -------------------------------------------------------------
;; Two, for the reason domain/tape.metta has two tapes: one grove alone can be
;; solved by a program that memorises positions rather than one that reads
;; ripeness. Both hold exactly two trees worth picking, in different places.
(= (groveA) (2 5 12 3 10 7))    ;; worth picking at 2 and 4
(= (groveB) (11 4 6 9 1 3))     ;; worth picking at 0 and 3
(= (groveFuel) 12)
(= (groveWorld $episode)
   (mkG (if (== (% $episode 2) 0) (groveA) (groveB)) 0 0 0 (groveFuel)))

;; Two ripe trees per grove, nothing spoiled.
(= (groveBestScore) 4)

;; --- running one episode ----------------------------------------------------
;; Exactly domain/tape.metta's loop: run the program over and over until the
;; fuel is gone, and stop early if a pass used none, so a program that never
;; acts scores instead of looping forever.
(= (groveRunEpisode $program (mkG $trees $position $picked $spoiled $fuel))
   (if (<= $fuel 0)
       (- $picked $spoiled)
       (let (mkRes $value $next)
            (evalProgram $program (mkG $trees $position $picked $spoiled $fuel))
         (let (mkG $treesAfter $posAfter $pickedAfter $spoiledAfter $fuelAfter) $next
           (if (== $fuelAfter $fuel)
               (- $pickedAfter $spoiledAfter)
               (groveRunEpisode $program $next))))))

(= (groveFitness $program $episode) (groveRunEpisode $program (groveWorld $episode)))
(= (groveScoreExp $program) (+ (groveFitness $program 0) (groveFitness $program 1)))

;; --- the program we start from ----------------------------------------------
;; The structure is right and the NUMBER is wrong: hold out for ripeness above
;; 0, which is every tree that has not been picked yet, so it strips both groves
;; bare and spoils four fruit doing it. The stride beside it is already correct.
;;
;; That pairing is deliberate. A run where every number is wrong cannot show
;; whether the search is tuning or thrashing; here one number must move and one
;; must be left exactly where it is.
(= (groveExemplar)
   (mkTree (mkNode and_seq)
     ((mkTree (mkNode action_bool_if)
        ((mkTree (mkNode numGt) ((mkTree (mkNode groveRipeHere) ()) (leafOf 0)))
         (mkTree (mkNode grovePick) ())
         (mkTree (mkNode groveWalkBy) ((leafOf 1))))))))

(= (groveRep) (buildKnobs (groveExemplar)))

;; the one line that connects this domain to the generic machinery -- the same
;; line every other domain has
(= (groveScore $rep $inst) (scoreInstance groveScoreExp $rep $inst))


;; ============================================================================
;; Type declarations.
;;
;; Read the argument parts as the answer to "what may the builder do here?":
;;
;;     Params      a leaf that takes parameters -- NEVER looked inside, so a
;;                 number sitting in one is safe from tuning
;;     (Number)    one child which is a number -- tunable if it is written out,
;;                 or a subtree that produces a number
;;
;; No Bool primitive here, on purpose: every condition must come through numGt,
;; so nothing can solve this without touching a number. It also means isFillable
;; drops action_bool_if (its Bool slot has no literals), so the empty control
;; run cannot invent a conditional -- the honest result, not a defect.
;; ============================================================================
(: grovePick      (-> Params   $ctx Act))
(: groveWalkBy    (-> (Number) $ctx Act))
(: groveRipeHere  (-> Params   $ctx Number))
(: groveRipeAhead (-> Params   $ctx Number))
