!(import! &self ../../utilities/general-helpers)
;; parameters load BEFORE scoring/action-score below: the scorer reads
;; (param fitness), and PeTTa gates reduction on load order.
!(import! &self ../../parameters/registry)
!(import! &self ../../parameters/defaults)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/map)
!(import! &self ../../utilities/ordered-multimap)
!(import! &self ../../utilities/nodeId)

!(import! &self ../../reduct/boolean-reduct/rte-helpers)
!(import! &self ../../reduct/boolean-reduct/cut-unnecessary-or)
!(import! &self ../../reduct/boolean-reduct/cut-unnecessary-and)
!(import! &self ../../reduct/boolean-reduct/n-ary-propagate-not)
!(import! &self ../../reduct/boolean-reduct/n-ary-gather-junctors)
!(import! &self ../../reduct/boolean-reduct/delete-inconsistent-handle)
!(import! &self ../../reduct/boolean-reduct/zero-constraint-subsumption)
!(import! &self ../../reduct/boolean-reduct/one-constraint-subsumption)
!(import! &self ../../reduct/boolean-reduct/promote-common-constraints)
!(import! &self ../../reduct/boolean-reduct/reduce-to-elegance)

!(import! &self ../../utilities/tree)
!(import! &self ../../scoring/cacheSpace)

!(import! &self ../../scoring/fitness)
!(import! &self ../../scoring/boolean-ops)
!(import! &self ../../scoring/action-registry)
!(import! &self ../../scoring/action-eval)
!(import! &self ../../scoring/action-ops)
!(import! &self ../../scoring/bscore)
!(import! &self ../../scoring/cscore)
!(import! &self ../../scoring/action-score)
!(import! &self ../../scoring/precision-bscore)

!(import! &self ../../representation/knob-representation)
!(import! &self ../../representation/lsk)
!(import! &self ../../representation/knob-mapper)
!(import! &self ../../feature-selection/feature-selection-helpers)
!(import! &self ../../representation/representation)
!(import! &self ../../representation/instance)

!(import! &self ../../scoring/complexity-based-scorer)

;; The tic-tac-toe action fitness package (shared players + world/primitives/
;; episode/registration): supplies tttActionFitness / tttActionBestScore and
;; the domain vocabulary for the ttt action asserts appended below.
!(import! &self ../../examples/tic-tac-toe/tic-tac-toe-helpers)
!(import! &self ../../examples/tic-tac-toe/moves)
!(import! &self ../../examples/tic-tac-toe/random-player)
!(import! &self ../../examples/tic-tac-toe/minimax-player)
!(import! &self ../../examples/tic-tac-toe-action/ttt-action-world)
!(import! &self ../../examples/tic-tac-toe-action/ttt-action-primitives)
!(import! &self ../../examples/tic-tac-toe-action/ttt-action-episode)
!(import! &self ../../examples/tic-tac-toe-action/ttt-action-registration)

!(import! &self ../../moses/neighborhood-sampling)

!(import! &self ../score-deme)

;; ============================================================
;; transform dispatch tests for the ACTION scoring context.
;;
;; A deterministic TEST-LOCAL fitness (sdtFitness) is defined here, after
;; the pipeline loaded, and bound via (set-param fitness ...) --
;; exactly like a real experiment. World = a plain number counter (opaque
;; to the engine); no board, no randomness.
;; ============================================================

;; ---- Test-local fitness ----
;; sdtBump: increment the counter, succeed. sdtStop: fail, world untouched.
(= (sdtBump $params $world) (mkARes True (+ $world 1)))
(= (sdtStop $params $world) (mkARes False $world))
;; The vocabulary params are part of the experiment template; quote is
;; REQUIRED at the set-param site: sdtBump/sdtStop are live bare-head
;; clauses (probe-verified: quote strips on set, the param holds the plain
;; tuple). This test's rep is hand-built below, so nothing here consults
;; the vocabulary -- the bindings keep the experiment template complete.
!(set-param actions (quote (sdtBump sdtStop)))
!(set-param perceptions ())

;; Episode-ordinal bonus (PRIVATE to the fitness -- the analog of the old
;; opponent interleave): even ordinals add 0.0, odd ordinals add 0.25.
;; (parity via the shared isEven helper, utilities/general-helpers)
(= (sdtOrdinalBonus $i) (if (isEven $i) 0.0 0.25))
;; Episode score = final counter value + the per-ordinal bonus, so both the
;; chosen action AND the ordinal sequence are visible in the bscore.
(= (sdtFitness $exp $i)
   (let (mkARes $v $w) (evalAction $exp 0)
        (+ $w (sdtOrdinalBonus $i))))
(= (sdtBestScore $n) (* 1.0 $n))
!(set-param fitness sdtFitness)
!(set-param bestScore sdtBestScore)

;; ---- Hand-built action representation: one embedded mkASK knob under an
;;      and_seq root (shape mirrors representation/tests/build-action-test
;;      lines 161-173); instance (0) -> absent, (1) -> sdtBump, (2) -> sdtStop.
(= (sdtBumpTree) (mkTree (mkNode sdtBump) ()))
(= (sdtStopTree) (mkTree (mkNode sdtStop) ()))
(= (sdtPerms) ((sdtBumpTree) (sdtStopTree)))
(= (sdtAsk) (mkASK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()) (sdtPerms)))
(= (sdtRep)
   (mkRep (mkKbMap (mkDscMp (((mkDiscSpec 0) (sdtAsk)))))
          (mkTree (mkNode and_seq) ((mkKnob (mkNullVex (sdtPerms)) (sdtAsk) 0)))))

;; ---- (a) applyActionBasedScore ----
;; empty instance list -> empty scored list (the scorer maps over instances)
!(assertEqual (applyActionBasedScore (sdtRep) (mkDemeId "sdtA") () 2 3.5 ()) ())

;; instance (1) picks sdtBump: candidate (and_seq (sdtBump)).
;; 2 episodes, ordinals 0,1 -> bonuses 0.0,0.25 -> bscore (1.0 1.25),
;; raw = 2.25 (exact in binary); complexity = 1 (and_seq costs 0).
!(assertEqual
  (let* (($scored (applyActionBasedScore (sdtRep) (mkDemeId "sdtA")
                     ((mkInst (1))) 2 3.5 ()))
         (((mkSInst (mkPair $inst (mkCscore $raw $cpx $pen $u $penScore)))) $scored))
    ($inst $raw $cpx))
  ((mkInst (1)) 2.25 1))

;; ---- (b) transform routes the tagged action context to applyActionBasedScore ----
;; instance (2) picks sdtStop: tree fails every episode, counter stays 0 ->
;; bscore (0.0 0.25), raw 0.25, complexity 1.
!(assertEqual
  (let* (($result (transform
                    (mkSInstSet ((mkSInst (mkPair (mkInst (2)) -1.0e308))))
                    (sdtRep)
                    (mkDemeId "sdtB")
                    (mkActionCtx 2)
                    3.5))
         ((mkSInstSet ((mkSInst (mkPair $inst (mkCscore $raw $cpx $pen $u $penScore))))) $result))
    ($inst $raw $cpx))
  ((mkInst (2)) 0.25 1))

;; penalized score consistency on the action arm: pen = cpx * coef(3.5),
;; penScore = raw - pen (both sides computed by the same code path).
!(assertEqual
  (let* (($result (transform
                    (mkSInstSet ((mkSInst (mkPair (mkInst (1)) -1.0e308))))
                    (mkRep (mkKbMap (mkDscMp (((mkDiscSpec 0) (sdtAsk)))))
                           (mkTree (mkNode and_seq) ((mkKnob (mkNullVex (sdtPerms)) (sdtAsk) 0))))
                    (mkDemeId "sdtC")
                    (mkActionCtx 2)
                    3.5))
         ((mkSInstSet ((mkSInst (mkPair $inst (mkCscore $raw $cpx $pen $u $penScore))))) $result))
    (isApproxEq $penScore (- $raw $pen)))
  True)

;; ---- (c) case-order regression guards: the looser arms still win their
;;      own shapes AFTER the action arm was prepended ----

;; boolean arm: fixtures copied verbatim from score-deme-test.metta
(= (tree1)
        (mkTree (mkNode AND)
          (cons (mkKnob (mkTree (mkNode A) ()) (lsk3) 2)
          (cons (mkTree (mkNode OR)
                  (cons (mkTree (mkNode B) ())
                  (cons (mkTree (mkNode C) ())
                  (cons (mkKnob (mkNullVex
                          (cons (mkTree (mkNode D) ()) ())) (lsk1) 0) ()))))
          (cons (mkKnob (mkNullVex
                  (cons (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) ())) ())) (lsk2) 1) ())))))
(= (lsk1) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())))
(= (lsk2) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())))
(= (lsk3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ())))
(= (knobMapObj) (mkKbMap (mkDscMp (((mkDiscSpec 1) (lsk1)) ((mkDiscSpec 0) (lsk2)) ((mkDiscSpec 1) (lsk3))))))
(= (ttable2) (mkITable
                    (cons (cons True (cons True (cons True (cons True ()))))
                    (cons (cons True (cons False (cons False (cons False ()))))
                    (cons (cons False (cons True (cons False (cons False ()))))
                    (cons (cons False (cons False (cons False (cons False ())))) ()))))
                    (cons A (cons B (cons C (cons output ()))))))

;; (mkITable ...) context still hits the boolean arm (expected values are the
;; ones score-deme-test pins for the same inputs)
!(assertEqual
   (transform
   (mkSInstSet (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 2 ())))) -1.0000000000000001e308)) (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 1 ())))) -1.0000000000000001e308)) ())))
   (mkRep (knobMapObj) (tree1))
   (mkDemeId "1")
   (ttable2)
   2.0)
   (mkSInstSet (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 2 ())))) (mkCscore -2 3 1.5 0.0 -3.5))) (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 1 ())))) (mkCscore 0 3 1.5 0.0 -1.5))) ()))))

;; ============================================================
;; Real action-domain scoring: the converted strategy asserts (was:
;; score-deme-test @192-204, the applyStrategyBasedScore / transform pins for
;; the PRIORITIZED-OR playcenter/playcorner strategy). Here the candidate is
;; scored through the generic action stack against tttActionFitness. The ttt
;; params are bound AFTER the sdt/boolean asserts above so those keep running
;; under their own fitness.
;;
;; Hand-built action rep: an or_seq root with two embedded mkASK knobs
;; (shape mirrors the sdtRep above / representation/tests/build-action-test);
;; instance (0) -> knob absent, (1) -> its primitive. Instance (1 1) selects
;; both -> candidate (or_seq (tttCenter tttCorner)).
(= (tttCenterTree) (mkTree (mkNode tttCenter) ()))
(= (tttCornerTree) (mkTree (mkNode tttCorner) ()))
(= (tttAsk1) (mkASK (mkDiscKnob (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) ()) ((tttCenterTree))))
(= (tttAsk2) (mkASK (mkDiscKnob (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) ()) ((tttCornerTree))))
(= (tttActionRep)
   (mkRep (mkKbMap (mkDscMp (((mkDiscSpec 0) (tttAsk1)) ((mkDiscSpec 1) (tttAsk2)))))
          (mkTree (mkNode or_seq)
            ((mkKnob (mkNullVex ((tttCenterTree))) (tttAsk1) 0)
             (mkKnob (mkNullVex ((tttCornerTree))) (tttAsk2) 1)))))

;; Bind the ttt experiment template (quote at the vocabulary set-param sites:
;; the primitives are live bare-head clauses -- see ttt-action-registration).
!(set-param fitness tttActionFitness)
!(set-param bestScore tttActionBestScore)
!(set-param actions (quote (tttWin tttBlock tttCenter tttCorner tttSide)))
!(set-param perceptions (quote (tttCanWin tttCanBlock tttCenterFree)))

;; (a) empty instance list -> empty scored list (was: applyStrategyBasedScore
;; ... () 1 3.5 () -> ()).
!(assertEqual (applyActionBasedScore (tttActionRep) (mkDemeId "ttt0") () 1 3.5 ()) ())

;; (b) instance (1 1) -> candidate (or_seq tttCenter tttCorner). n=1, ordinal 0
;; -> minimax (deterministic): the two-action tree runs out of moves and
;; forfeits -> raw -1.0; complexity 2; pen = 2 * coef(3.5) = 0.5714285714...
;; (was: applyStrategyBasedScore instance (1 1) -> the same -1.0/2 cscore).
!(assertEqual (applyActionBasedScore (tttActionRep) (mkDemeId "ttt1")
                     (cons (mkInst (cons 1 (cons 1 ()))) ()) 1 3.5 ())
              ((mkSInst (mkPair (mkInst (1 1)) (mkCscore -1.0 2 0.5714285714285714 0.0 -1.5714285714285714)))))

;; (c) transform of an empty instance set through the tagged action context
;; (was: transform (mkSInstSet ()) ... (1) 3.5 -> (mkSInstSet ())).
!(assertEqual
   (transform (mkSInstSet ()) (tttActionRep) (mkDemeId "ttt2") (mkActionCtx 1) 3.5)
   (mkSInstSet ()))

;; (d) transform of a worst-score sentinel: instance (1 1) rescored to the same
;; cscore as (b). Same (fitness exp n) triple -> &actionScoreCache hit, so no
;; re-run (was: the transform-rescore strategy assert).
!(assertEqual (transform
   (mkSInstSet (cons (mkSInst (mkPair (mkInst (cons 1 (cons 1 ()))) -1.0e308)) ()))
   (tttActionRep) (mkDemeId "ttt3") (mkActionCtx 1) 3.5)
   (mkSInstSet ((mkSInst (mkPair (mkInst (1 1)) (mkCscore -1.0 2 0.5714285714285714 0.0 -1.5714285714285714))))))
