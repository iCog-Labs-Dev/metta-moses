!(import! &self ../../utilities/general-helpers)
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
!(import! &self ../../scoring/strategy-score-cache)

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

!(import! &self ../../moses/neighborhood-sampling)

!(import! &self ../score-deme)

;; ============================================================
;; transform dispatch tests for the ACTION scoring context.
;;
;; A deterministic TEST-LOCAL action domain (sdtDomain) is defined here,
;; after the pipeline loaded -- config clauses + registration only, exactly
;; like a real domain package. World = a plain number counter (opaque to the
;; engine); no board, no randomness.
;; ============================================================

;; ---- Test-local domain ----
;; sdtBump: increment the counter, succeed. sdtStop: fail, world untouched.
(= (sdtBump $children $world) (mkARes True (+ $world 1)))
(= (sdtStop $children $world) (mkARes False $world))
;; Vocabulary lives in the config clauses (single source since the M0
;; registry slimming; the per-primitive register API was deleted). quote is
;; REQUIRED: sdtBump/sdtStop are live bare-head clauses. This test's rep is
;; hand-built below, so nothing here consults the vocabulary -- the clauses
;; keep the domain-package template complete.
(= (actionDomainActions sdtDomain) (quote (sdtBump sdtStop)))
(= (actionDomainPerceptions sdtDomain) ())

;; Opponents are inert symbols (never head a clause), so no quote is needed.
(= (actionDomainOpponents sdtDomain) (oppA oppB))
(= (sdtOppBonus oppA) 0.0)
(= (sdtOppBonus oppB) 0.25)
;; Episode score = final counter value + a per-opponent bonus, so both the
;; chosen action AND the opponent interleave are visible in the bscore.
(= (actionDomainRunEpisode sdtDomain $exp $opp)
   (let (mkARes $v $w) (evalAction $exp 0)
        (+ $w (sdtOppBonus $opp))))
(= (actionDomainBestScore sdtDomain $n) (* 1.0 $n))
!(registerActionDomain sdtDomain)

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
;; empty instance list -> empty scored list (mirrors the strategy helper test)
!(assertEqual (applyActionBasedScore (sdtRep) (mkDemeId "sdtA") () sdtDomain 2 3.5 ()) ())

;; instance (1) picks sdtBump: candidate (and_seq (sdtBump)).
;; 2 episodes, opponents interleaved oppA,oppB -> bscore (1.0 1.25),
;; raw = 2.25 (exact in binary); complexity = 1 (and_seq costs 0).
!(assertEqual
  (let* (($scored (applyActionBasedScore (sdtRep) (mkDemeId "sdtA")
                     ((mkInst (1))) sdtDomain 2 3.5 ()))
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
                    (mkActionCtx (sdtDomain 2))
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
                    (mkActionCtx (sdtDomain 2))
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

;; strategy arm: a bare ($n) context still routes to applyStrategyBasedScore
;; (fixture from score-deme-test; empty instance set keeps it deterministic)
(= (StrategyRep)
   (mkRep
     (mkKbMap
       (mkDscKbMp (cons ((mkNodeId (1)) 0) (cons ((mkNodeId (2)) 1) ())))
       (mkDscMp
         (cons ((mkDiscSpec 2) (mkSSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 1) (mkDiscSpec 1) ())))
         (cons ((mkDiscSpec 2) (mkSSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 2) (mkDiscSpec 1) (mkDiscSpec 1) ())))
         ()))))
     (mkTree (mkNode PRIORITIZED-OR)
       (cons (mkTree (mkNode playcenter) ())
             (cons (mkTree (mkNode playcorner) ()) ())))))

!(assertEqual
   (transform (mkSInstSet ()) (StrategyRep) (mkDemeId "1") (1) 3.5)
   (mkSInstSet ()))
