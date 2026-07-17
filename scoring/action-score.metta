;; Generic behavioral + composite scoring for action programs -- the action
;; analog of scoreStrategyTree/getCscore. NOTHING here is experiment-specific:
;; this file never names a concrete fitness, opponent, or world shape.
;;
;; THE PARAM CONTRACT (how a fitness attaches -- see parameters/defaults.metta
;; for the defaults and the quote rule):
;;   fitness   -- a function SYMBOL $fn. The scorer calls ($fn $exp $i)
;;       once per episode: $exp is the COMPILED wrapped expression (actionExp
;;       output), $i the episode ordinal 0..n-1, IN ORDER. It must return a
;;       Number, higher = better. Whether ordinals map to opponents, trails,
;;       start worlds, or nothing at all is PRIVATE to that function -- the
;;       framework only hands it the ordinal.
;;   bestScore -- a function SYMBOL, ($fn $n) -> Number, the raw-score
;;       termination target for n episodes (consumed by moses-run-action).
;;   actions / perceptions -- tuples of primitive symbols, the
;;       knob vocabulary (consumed by representation/create-representation).
;; Unset fitness, a fitness symbol with no matching clause, a failing
;; call, or a non-Number episode result (e.g. a fitness that returns True
;; or a string) all map to the defined-worst -1.0 for that episode -- the
;; bscore only ever holds Numbers, never a crash (see runActionEpisode's
;; get-type guard).
;;
;; LOAD POSITION: after parameters/registry+defaults ((param ...) must have a
;; clause -- PeTTa gates reduction on load order), after scoring/action-eval +
;; action-ops (actionExp / isRegisteredActionOperator), and after
;; scoring/bscore + scoring/cscore (mkBScore consumers, sumBScore,
;; getComplexityCoef, updatePenalizedScore, worstCscore).

;; ---- Behavioral-score cache ----
;; Entries: ($fitnessSymbol $compiledExp $nEpisodes $bscore) -- keyed by the
;; compiled expression so identical candidates share an entry (mirrors
;; &strategyScoreCache + scoreStrategyTree in
;; examples/tic-tac-toe/strategy-scoring.metta:48-57). The configured fitness
;; SYMBOL is part of the key: two different fitnesses must never share
;; entries for the same tree.
!(bind! &actionScoreCache (new-space))

;; Empty the action-score cache (mirrors resetSubtreeCache in
;; scoring/cacheSpace.metta): collapse the matches FIRST, then remove --
;; never mutate the space while match is iterating it.
(= (resetActionScoreCache)
   (let $entries (collapse (match &actionScoreCache $e $e))
     (map-atom $entries $e (remove-atom &actionScoreCache $e))))

;; ---- Episode loop ----

;; runActionEpisode: ONE episode's score -- the var-head application
;; ($fn $exp $i) (repo idiom: dynamic dispatch on a symbol-valued variable).
;; The collapse-guard maps every misconfiguration to the defined-worst -1.0:
;; a failing call collapses to (); an UNSET param (() head) or a symbol with
;; no matching clause does NOT collapse to () -- the unreduced term itself
;; comes back (probe-verified) -- and a buggy fitness may return a
;; non-numeric value outright (True is the classic case: evalAction yields
;; (mkARes True $world), and True IS Grounded, so a metatype test would
;; leak it into the bscore and crash sumBScore's arithmetic downstream).
;; ONLY a Number may enter the bscore, so the guard tests
;; (get-type $v) == Number explicitly (probe-verified: ints/floats,
;; negatives, and 0/0.0 all type as Number and pass through untouched;
;; True -> Bool, "x" -> String, symbols/expressions -> %Undefined%, all
;; mapped to -1.0).
(= (runActionEpisode $fn $exp $i)
   (chain (collapse ($fn $exp $i)) $rs
     (if (== $rs ())
         -1.0
         (let $v (car-atom $rs)
           (if (== (get-type $v) Number) $v -1.0)))))

;; runActionEpisodes: episode scores for ordinals $i .. $n-1, IN ORDER
;; (episode 0 first). Scores come back cons-listed -- exactly the
;; (mkBScore (list of Numbers)) contents sumBScore / BScore.sub consume
;; (scoring/bscore.metta), same shape strategy-scoring builds.
(= (runActionEpisodes $fn $exp $n $i)
   (if (>= $i $n)
       ()
       (cons (runActionEpisode $fn $exp $i)
             (runActionEpisodes $fn $exp $n (+ $i 1)))))

;; ---- Behavioral score (cached) ----
;; scoreActionTree: candidate Tree -> mkBScore over $nEpisodes episodes of
;; the CONFIGURED fitness ((param fitness)). The tree is compiled ONCE
;; via actionExp; ($fn $exp $nEpisodes) is the cache key, so structurally
;; identical candidates never re-run episodes -- and switching the fitness
;; param can never serve another fitness's entries.
;; Cache miss -> run episodes, memoize, return; hit -> cached value.
;; NOTE: misconfigured results (the all -1.0 bscore of an unset fitness) are
;; cached too, keyed under () -- if fitness is configured only
;; AFTERWARDS the new symbol keys fresh entries, but re-binding the SAME
;; symbol to new behavior needs (resetActionScoreCache) or the stale scores
;; keep being served.
;(: scoreActionTree (-> (Tree $a) Number $space BehavioralScore))
(= (scoreActionTree $tree $nEpisodes $scoreSpace)
   (let* (($exp (actionExp $tree))
          ($fn (param fitness))
          ($cached (collapse (match $scoreSpace ($fn $exp $nEpisodes $bscore) $bscore))))
     (if (== $cached ())
         (let* (($bs (mkBScore (runActionEpisodes $fn $exp $nEpisodes 0)))
                ($_ (add-atom $scoreSpace ($fn $exp $nEpisodes $bs))))
           $bs)
         (car-atom $cached))))

;; ---- Complexity ----
;; actionTreeComplexity: number of action/perception leaves in a candidate
;; Tree; registered structural combinators cost 0 (they are the action
;; analog of AND/OR/NOT). Deliberately SEPARATE from treeComplexity in
;; utilities/tree.metta:312-319 -- that one hard-codes the boolean operator
;; list (AND OR NOT PRIORITIZED-OR) and loads before the scoring layer, so it
;; cannot consult &actionRegistry; keeping this here leaves boolean complexity
;; behavior untouched.
;(: actionTreeComplexity (-> (Tree $a) Number))
(= (actionTreeComplexity (mkNullVex $x)) 0)
(= (actionTreeComplexity (mkKnob $inner $lsk $i)) (actionTreeComplexity $inner))
(= (actionTreeComplexity (mkTree (mkNode $a) $children))
   (if (isRegisteredActionOperator $a)
       (List.sum (List.map actionTreeComplexity $children))
       (if (== $children ())
           1     ;; actions/perceptions ARE the alphabet
           (+ 1 (List.sum (List.map actionTreeComplexity $children))))))

;; ---- Composite score ----
;; getActionCscore: behavioral score + complexity penalty -> mkCscore.
;; DISTINCT name (not a getCscore overload): the existing 4-arg getCscore
;; boolean/strategy clauses (scoring/cscore.metta:23-28) already overlap
;; ambiguously, and (mkActionCtx $nGames) keys the dispatch anyway.
;; The penalty math duplicates ~6 lines of getCscore's 3-arg core
;; (scoring/cscore.metta:6-20) -- ACCEPTED duplication: that core calls
;; treeComplexity internally, and action candidates need
;; actionTreeComplexity, so it cannot be funneled through.
;(: getActionCscore (-> (Tree $a) ActionCtx Number $space Cscore))
(= (getActionCscore $tree (mkActionCtx $nGames) $complexityRatio $scoreSpace)
   (let $bs (scoreActionTree $tree $nGames $scoreSpace)
     (if-error $bs   ;; parity with getCscore; scoreActionTree never errors
        (worstCscore)
        (let* (($bsum (sumBScore $bs))
               ($cpxy (actionTreeComplexity $tree))
               ($cCoef (getComplexityCoef $complexityRatio)))
          (updatePenalizedScore
            (mkCscore $bsum $cpxy (* $cpxy $cCoef) 0.0 (* -1 (pow-math 10 308)))
            False)))))
