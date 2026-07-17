!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/tree)

!(import! &self ../cacheSpace)
!(import! &self ../fitness)
!(import! &self ../boolean-ops)
!(import! &self ../bscore)
!(import! &self ../cscore)

!(import! &self ../action-registry)
!(import! &self ../action-eval)
!(import! &self ../action-ops)
!(import! &self ../action-score)

;; Generic action-scoring test. A deterministic test domain is defined HERE,
;; after the scoring layer loaded -- proving a domain plugs in through config
;; clauses alone (the registry's sentinel clauses make action-score's
;; actionDomain* call sites dispatch dynamically; operator/primitive clauses
;; are bare heads found by the engine's reduce dispatch) without touching
;; scoring.
;;
;; World: (mkTstWorld $n); tstInc bumps the counter and succeeds.
;; Episodes are deterministic and opponent-distinguishing (oppA -> 1.0,
;; oppB -> 0.0, given a succeeding tree); every invocation is RECORDED in
;; &tstEpisodeLog so cache behavior is observable.
(= (tstInc $children (mkTstWorld $n)) (mkARes True (mkTstWorld (+ $n 1))))

!(bind! &tstEpisodeLog (new-space))
(= (tstLogCount) (size-atom (collapse (match &tstEpisodeLog $e $e))))

(= (actionDomainOpponents tstDomain) (oppA oppB))
(= (actionDomainRunEpisode tstDomain $exp $opp)
   (let* (($_ (add-atom &tstEpisodeLog (episodeRan $exp $opp)))
          ((mkARes $v $w) (evalAction $exp (mkTstWorld 0))))
     (if (== $opp oppA)
         (if (== $v True) 1.0 0.5)   ;; oppA: 1.0 on success
         0.0)))                       ;; oppB: always 0.0
(= (actionDomainBestScore tstDomain $n) $n)
;; A domain that explicitly declares NO opponents (edge case 6):
(= (actionDomainOpponents tstNilDomain) ())
;; tstGhostDomain deliberately gets NO clauses at all (misconfigured).

;; ---- Hand-built candidate trees ----
(= (tstLeafTree) (mkTree (mkNode tstInc) ()))
(= (tstSeqTree)
   (mkTree (mkNode and_seq)
     (cons (mkTree (mkNode tstInc) ())
           (cons (mkTree (mkNode tstInc) ()) ()))))
;; (and_seq (tstInc) (action_bool_if tstPer tstInc tstInc))
(= (tstNestedTree)
   (mkTree (mkNode and_seq)
     (cons (mkTree (mkNode tstInc) ())
           (cons (mkTree (mkNode action_bool_if)
                   (cons (mkTree (mkNode tstPer) ())
                         (cons (mkTree (mkNode tstInc) ())
                               (cons (mkTree (mkNode tstInc) ()) ()))))
                 ()))))

;; ---- 1. Episode interleave: episode i gets opponent (i mod len) ----
;; 4 episodes over (oppA oppB): oppA oppB oppA oppB -> (1.0 0.0 1.0 0.0),
;; stable episode order (episodes 2-3 prove the wraparound refill).
!(assertEqual (scoreActionTree tstDomain (tstSeqTree) 4 &actionScoreCache)
              (mkBScore (1.0 0.0 1.0 0.0)))

;; ---- 2. Cache ----
;; first call ran exactly 4 episodes
!(assertEqual (tstLogCount) 4)
;; identical args -> cache hit: same bscore, NO new episodes
!(assertEqual (scoreActionTree tstDomain (tstSeqTree) 4 &actionScoreCache)
              (mkBScore (1.0 0.0 1.0 0.0)))
!(assertEqual (tstLogCount) 4)
;; different nEpisodes -> miss: 3 more episodes run (odd count also re-proves
;; the mod-len wrap: episode 2 refills back to oppA)
!(assertEqual (scoreActionTree tstDomain (tstSeqTree) 3 &actionScoreCache)
              (mkBScore (1.0 0.0 1.0)))
!(assertEqual (tstLogCount) 7)
;; different tree -> miss: 2 more episodes
!(assertEqual (scoreActionTree tstDomain (tstLeafTree) 2 &actionScoreCache)
              (mkBScore (1.0 0.0)))
!(assertEqual (tstLogCount) 9)
;; resetActionScoreCache: the same args re-run their episodes afterwards
!(resetActionScoreCache)
!(assertEqual (scoreActionTree tstDomain (tstLeafTree) 2 &actionScoreCache)
              (mkBScore (1.0 0.0)))
!(assertEqual (tstLogCount) 11)

;; ---- 3. actionTreeComplexity ----
;; structural op with 2 action leaves -> 2
!(assertEqual (actionTreeComplexity (tstSeqTree)) 2)
;; empty and_seq -> 0 (registered structural ops cost nothing)
!(assertEqual (actionTreeComplexity (mkTree (mkNode and_seq) ())) 0)
;; nested: and_seq[tstInc, action_bool_if[tstPer,tstInc,tstInc]] -> 4 leaves
!(assertEqual (actionTreeComplexity (tstNestedTree)) 4)
;; mkKnob passthrough recurses on the inner tree
!(assertEqual (actionTreeComplexity (mkKnob (tstSeqTree) $lsk 0)) 2)
;; null vertex -> 0
!(assertEqual (actionTreeComplexity (mkNullVex (tstSeqTree))) 0)
;; unregistered leaf -> 1 (domain actions/perceptions ARE the alphabet)
!(assertEqual (actionTreeComplexity (mkTree (mkNode noSuchLeaf) ())) 1)
;; unregistered interior node -> 1 + children
!(assertEqual (actionTreeComplexity
                (mkTree (mkNode weirdOp)
                        (cons (mkTree (mkNode tstInc) ()) ())))
              2)

;; ---- 4. getActionCscore: full hand-computed composite ----
;; bscore (1.0 0.0 1.0 0.0) -> sum 2.0; complexity 2; ratio 4.0 -> coef 0.25
;; (exact in binary, so float equality is safe); penalty 2*0.25=0.5;
;; penalized 2.0-0.5-0.0=1.5. The reset above erased the tstSeqTree/4 cache
;; entry, so this first call re-runs its 4 episodes (11 -> 15)...
!(assertEqual (getActionCscore (tstSeqTree) (mkActionCtx (tstDomain 4)) 4.0 &actionScoreCache)
              (mkCscore 2.0 2 0.5 0.0 1.5))
!(assertEqual (tstLogCount) 15)
;; ...and the second call hits the fresh cache entry: no new episodes.
!(assertEqual (getActionCscore (tstSeqTree) (mkActionCtx (tstDomain 4)) 4.0 &actionScoreCache)
              (mkCscore 2.0 2 0.5 0.0 1.5))
!(assertEqual (tstLogCount) 15)

;; ---- 5. Worst path ----
;; scoreActionTree can never produce an Error bscore (missing config and
;; failing episodes are mapped to -1.0 defined-worst before mkBScore), so the
;; if-error guard in getActionCscore is exercised directly on a hand-built
;; Error, asserting it selects worstCscore.
!(assertEqual (if-error (Error (mkBScore ()) "bad bscore") (worstCscore) notTaken)
              (worstCscore))

;; ---- 6. Misconfigured domains -> all -1.0, right length, never crash ----
;; explicitly empty opponents list
!(assertEqual (scoreActionTree tstNilDomain (tstSeqTree) 3 &actionScoreCache)
              (mkBScore (-1.0 -1.0 -1.0)))
;; no config clauses at all
!(assertEqual (scoreActionTree tstGhostDomain (tstSeqTree) 2 &actionScoreCache)
              (mkBScore (-1.0 -1.0)))
;; neither ran any episode
!(assertEqual (tstLogCount) 15)

;; ---- 7. Remaining domain-config contract surface ----
!(assertEqual (actionDomainBestScore tstDomain 4) 4)
