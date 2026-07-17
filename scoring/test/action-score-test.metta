!(import! &self ../../utilities/general-helpers)
;; parameters load BEFORE action-score: the scorer reads (param
;; fitness), and PeTTa gates reduction on load order.
!(import! &self ../../parameters/registry)
!(import! &self ../../parameters/defaults)
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

;; Generic action-scoring test. A deterministic test FITNESS is defined HERE
;; and bound via (set-param fitness ...) -- proving an experiment plugs
;; in through the param contract alone (the scorer's var-head ($fn $exp $i)
;; dispatch finds clauses loaded at any later time; operator/primitive
;; clauses are bare heads found by the engine's reduce dispatch) without
;; touching scoring.
;;
;; World: (mkTstWorld $n); tstInc bumps the counter and succeeds.
;; Episodes are deterministic and ORDINAL-distinguishing (even ordinal ->
;; 1.0 on success else 0.5; odd ordinal -> 0.0); every invocation is
;; RECORDED in &tstEpisodeLog so cache behavior is observable.
(= (tstInc $children (mkTstWorld $n)) (mkARes True (mkTstWorld (+ $n 1))))

!(bind! &tstEpisodeLog (new-space))
(= (tstLogCount) (size-atom (collapse (match &tstEpisodeLog $e $e))))

;; parity via the shared isEven helper (utilities/general-helpers)
(= (tstFitness $exp $i)
   (let* (($_ (add-atom &tstEpisodeLog (episodeRan $exp $i)))
          ((mkARes $v $w) (evalAction $exp (mkTstWorld 0))))
     (if (isEven $i)
         (if (== $v True) 1.0 0.5)   ;; even ordinal: 1.0 on success
         0.0)))                       ;; odd ordinal: always 0.0
;; A second, distinguishable fitness for the cache key-isolation test:
(= (tstAltFitness $exp $i)
   (let $_ (add-atom &tstEpisodeLog (altRan $exp $i)) 7.0))
(= (tstBestScore $n) $n)
;; tstGhostFitness deliberately gets NO clauses at all (misconfigured).
;; Non-Number-returning fitnesses for the get-type guard tests (section 6):
(= (tstBoolFitness $exp $i) True)
(= (tstStrFitness $exp $i) "oops")

!(set-param fitness tstFitness)
!(set-param bestScore tstBestScore)

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

;; ---- 1. Episode ordinals run 0..n-1 IN ORDER ----
;; 4 episodes -> ordinals 0,1,2,3 -> (1.0 0.0 1.0 0.0): the FIRST element is
;; episode 0's score (even -> 1.0), proving episode 0 runs first and the
;; parity pattern tracks position throughout.
!(assertEqual (scoreActionTree (tstSeqTree) 4 &actionScoreCache)
              (mkBScore (1.0 0.0 1.0 0.0)))

;; ---- 2. Cache ----
;; first call ran exactly 4 episodes
!(assertEqual (tstLogCount) 4)
;; identical args -> cache hit: same bscore, NO new episodes
!(assertEqual (scoreActionTree (tstSeqTree) 4 &actionScoreCache)
              (mkBScore (1.0 0.0 1.0 0.0)))
!(assertEqual (tstLogCount) 4)
;; different nEpisodes -> miss: 3 more episodes run
!(assertEqual (scoreActionTree (tstSeqTree) 3 &actionScoreCache)
              (mkBScore (1.0 0.0 1.0)))
!(assertEqual (tstLogCount) 7)
;; different tree -> miss: 2 more episodes
!(assertEqual (scoreActionTree (tstLeafTree) 2 &actionScoreCache)
              (mkBScore (1.0 0.0)))
!(assertEqual (tstLogCount) 9)
;; resetActionScoreCache: the same args re-run their episodes afterwards
!(resetActionScoreCache)
!(assertEqual (scoreActionTree (tstLeafTree) 2 &actionScoreCache)
              (mkBScore (1.0 0.0)))
!(assertEqual (tstLogCount) 11)
;; KEY ISOLATION: a DIFFERENT fitness symbol (resetActionScoreCache NOT
;; called) must MISS for the same tree + nEpisodes -- the fitness symbol is
;; part of the cache key, so configured fitnesses never share entries.
!(set-param fitness tstAltFitness)
!(assertEqual (scoreActionTree (tstLeafTree) 2 &actionScoreCache)
              (mkBScore (7.0 7.0)))
!(assertEqual (tstLogCount) 13)
;; ...and switching BACK serves tstFitness's still-cached entry: no re-runs.
!(set-param fitness tstFitness)
!(assertEqual (scoreActionTree (tstLeafTree) 2 &actionScoreCache)
              (mkBScore (1.0 0.0)))
!(assertEqual (tstLogCount) 13)

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
;; unregistered leaf -> 1 (actions/perceptions ARE the alphabet)
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
;; entry, so this first call re-runs its 4 episodes (13 -> 17)...
!(assertEqual (getActionCscore (tstSeqTree) (mkActionCtx 4) 4.0 &actionScoreCache)
              (mkCscore 2.0 2 0.5 0.0 1.5))
!(assertEqual (tstLogCount) 17)
;; ...and the second call hits the fresh cache entry: no new episodes.
!(assertEqual (getActionCscore (tstSeqTree) (mkActionCtx 4) 4.0 &actionScoreCache)
              (mkCscore 2.0 2 0.5 0.0 1.5))
!(assertEqual (tstLogCount) 17)

;; ---- 5. Worst path ----
;; scoreActionTree can never produce an Error bscore (missing config and
;; failing episodes are mapped to -1.0 defined-worst before mkBScore), so the
;; if-error guard in getActionCscore is exercised directly on a hand-built
;; Error, asserting it selects worstCscore.
!(assertEqual (if-error (Error (mkBScore ()) "bad bscore") (worstCscore) notTaken)
              (worstCscore))

;; ---- 6. Misconfigured fitness -> all -1.0, right length, never crash ----
;; UNSET param (the () default): every episode scores the defined-worst
!(set-param fitness ())
!(assertEqual (scoreActionTree (tstSeqTree) 3 &actionScoreCache)
              (mkBScore (-1.0 -1.0 -1.0)))
;; a fitness SYMBOL with no clauses at all
!(set-param fitness tstGhostFitness)
!(assertEqual (scoreActionTree (tstSeqTree) 2 &actionScoreCache)
              (mkBScore (-1.0 -1.0)))
;; neither ran any logged episode
!(assertEqual (tstLogCount) 17)
;; a fitness returning a NON-NUMBER: True is the classic bug (returning
;; evalAction's status instead of a score) and True IS Grounded, so only
;; the explicit (get-type ...) == Number guard keeps it out of the bscore
;; -- each episode maps to -1.0 instead of crashing sumBScore downstream
!(set-param fitness tstBoolFitness)
!(assertEqual (scoreActionTree (tstSeqTree) 2 &actionScoreCache)
              (mkBScore (-1.0 -1.0)))
;; ...same for a string result (also Grounded, also not a Number)
!(set-param fitness tstStrFitness)
!(assertEqual (scoreActionTree (tstSeqTree) 2 &actionScoreCache)
              (mkBScore (-1.0 -1.0)))
;; nEpisodes = 0 -> the empty bscore (restore the real fitness first)
!(set-param fitness tstFitness)
!(assertEqual (scoreActionTree (tstLeafTree) 0 &actionScoreCache)
              (mkBScore ()))

;; ---- 7. Remaining param-contract surface ----
!(assertEqual (let $fn (param bestScore) ($fn 4)) 4)
