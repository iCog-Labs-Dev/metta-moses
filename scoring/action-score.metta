;; Generic behavioral + composite scoring for action domains -- the action
;; analog of scoreStrategyTree/getCscore. NOTHING here is domain-specific:
;; a domain plugs in by contributing config clauses only (see contract below);
;; this file never names a concrete domain, opponent, or world shape.
;;
;; LOAD POSITION: after scoring/action-registry (whose sentinel clauses for
;; actionDomainRunEpisode/actionDomainOpponents/actionDomainBestScore make the
;; call sites below compile as real, dynamically-dispatched calls -- PeTTa
;; gates reduction on load order), after scoring/action-eval + action-ops
;; (actionExp / isRegisteredActionOperator), and after scoring/bscore +
;; scoring/cscore (mkBScore consumers, sumBScore, getComplexityCoef,
;; updatePenalizedScore, worstCscore).
;;
;; DOMAIN-CONFIG CONTRACT (each is one clause per domain, added by the domain
;; package at any later load time):
;;   (= (actionDomainOpponents  <domain>) (quote (<opp> ...)))   ; tuple of
;;       episode variants/opponents. The tuple SHOULD be quote-wrapped -- and
;;       MUST be when any entry names a loaded function, or the body compiles
;;       as a CALL (the standard data-site hazard) and the domain silently
;;       scores as misconfigured. Plain inert-symbol tuples remain accepted;
;;       actionDomainOpponentsSafe unwraps either form. () or (quote ()) or a
;;       missing clause = misconfigured -> the defined-worst all -1.0 score,
;;       never a crash
;;   (= (actionDomainRunEpisode <domain> $compiledExp $opp) <Number>)
;;       ; runs ONE episode of the COMPILED (actionExp) expression against
;;       ; $opp and returns its score, higher = better
;;   (= (actionDomainBestScore  <domain> $nEpisodes) <Number>)

;; ---- Behavioral-score cache ----
;; Entries: ($domain $compiledExp $nEpisodes $bscore) -- keyed by the compiled
;; expression so identical candidates share an entry (mirrors
;; &strategyScoreCache + scoreStrategyTree in
;; examples/tic-tac-toe/strategy-scoring.metta:48-57).
!(bind! &actionScoreCache (new-space))

;; Empty the action-score cache (mirrors resetSubtreeCache in
;; scoring/cacheSpace.metta): collapse the matches FIRST, then remove --
;; never mutate the space while match is iterating it.
(= (resetActionScoreCache)
   (let $entries (collapse (match &actionScoreCache $e $e))
     (map-atom $entries $e (remove-atom &actionScoreCache $e))))

;; ---- Episode loop ----

;; actionDomainOpponentsSafe: the opponents tuple, with a missing clause
;; (unregistered/misconfigured domain) mapped to () instead of a bare failure
;; -- scoring must never crash, so the no-clause case falls into the same
;; defined-worst path as an explicitly empty opponents list.
;; A quote-wrapped tuple (see contract above) is UNWRAPPED here: PeTTaV1
;; strips quote on evaluation, but runtimes where (quote (...)) survives as
;; a size-2 expression get the inner tuple back. Guarded nested ifs, not
;; `and` -- size-atom/car-atom on a non-expression would error.
(= (actionDomainOpponentsSafe $domain)
   (chain (collapse (actionDomainOpponents $domain)) $rs
     (if (== $rs ())
         ()
         (let $v (car-atom $rs)
           (if (== (get-metatype $v) Expression)
               (if (== (size-atom $v) 2)
                   (if (== (car-atom $v) quote)
                       (let ($q $inner) $v $inner)
                       $v)
                   $v)
               $v)))))

;; runActionEpisode: ONE episode's score, with a failing/missing
;; actionDomainRunEpisode clause mapped to the defined-worst -1.0.
(= (runActionEpisode $domain $exp $opp)
   (chain (collapse (actionDomainRunEpisode $domain $exp $opp)) $rs
     (if (== $rs ()) -1.0 (car-atom $rs))))

;; runActionEpisodes: $n episode scores of a compiled expression, opponents
;; interleaved deterministically by episode index -- episode i (0-based) gets
;; opponent (i mod len). No mod-math in this runtime (probe-verified), so the
;; cycle is structural: walk a working copy of the opponents tuple, refill
;; from the original when it empties. INVARIANT: the loop is only entered
;; with a non-() full opponents list ($all), so the refill branch can never
;; spin -- the () case was already routed to the defined-worst path above.
;; Scores come back cons-listed in episode
;; order -- exactly the (mkBScore (list of Numbers)) contents sumBScore /
;; BScore.sub consume (scoring/bscore.metta), same shape strategy-scoring
;; builds.
(= (runActionEpisodes $domain $exp $n)
   (let $opps (actionDomainOpponentsSafe $domain)
     (if (== $opps ())
         (List.repeat $n -1.0)     ;; misconfigured domain -> defined-worst
         (runActionEpisodesLoop $domain $exp $n $opps $opps))))
(= (runActionEpisodesLoop $domain $exp $n $remaining $all)
   (if (<= $n 0)
       ()
       (if (== $remaining ())
           (runActionEpisodesLoop $domain $exp $n $all $all)
           (let* ((($opp $rest) (decons-atom $remaining))
                  ($score (runActionEpisode $domain $exp $opp)))
             (cons $score (runActionEpisodesLoop $domain $exp (- $n 1) $rest $all))))))

;; ---- Behavioral score (cached) ----
;; scoreActionTree: candidate Tree -> mkBScore over $nEpisodes episodes.
;; The tree is compiled ONCE via actionExp; the compiled expression is the
;; cache key, so structurally identical candidates never re-run episodes.
;; Cache miss -> run episodes, memoize, return; hit -> cached value.
;; NOTE: misconfigured-domain results (the all -1.0 bscore) are cached too --
;; if the domain package is configured/loaded only AFTERWARDS, call
;; (resetActionScoreCache) or the stale worst scores keep being served.
;(: scoreActionTree (-> Symbol (Tree $a) Number $space BehavioralScore))
(= (scoreActionTree $domain $tree $nEpisodes $scoreSpace)
   (let* (($exp (actionExp $tree))
          ($cached (collapse (match $scoreSpace ($domain $exp $nEpisodes $bscore) $bscore))))
     (if (== $cached ())
         (let* (($bs (mkBScore (runActionEpisodes $domain $exp $nEpisodes)))
                ($_ (add-atom $scoreSpace ($domain $exp $nEpisodes $bs))))
           $bs)
         (car-atom $cached))))

;; ---- Complexity ----
;; actionTreeComplexity: number of domain-action/perception leaves in a
;; candidate Tree; registered structural combinators cost 0 (they are the
;; action analog of AND/OR/NOT). Deliberately SEPARATE from treeComplexity in
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
           1     ;; domain actions/perceptions ARE the alphabet
           (+ 1 (List.sum (List.map actionTreeComplexity $children))))))

;; ---- Composite score ----
;; getActionCscore: behavioral score + complexity penalty -> mkCscore.
;; DISTINCT name (not a getCscore overload): the existing 4-arg getCscore
;; boolean/strategy clauses (scoring/cscore.metta:23-28) already overlap
;; ambiguously, and (mkActionCtx ($domain $nGames)) keys the dispatch anyway.
;; The penalty math duplicates ~6 lines of getCscore's 3-arg core
;; (scoring/cscore.metta:6-20) -- ACCEPTED duplication: that core calls
;; treeComplexity internally, and action candidates need
;; actionTreeComplexity, so it cannot be funneled through.
;(: getActionCscore (-> (Tree $a) ActionCtx Number $space Cscore))
(= (getActionCscore $tree (mkActionCtx ($domain $nGames)) $complexityRatio $scoreSpace)
   (let $bs (scoreActionTree $domain $tree $nGames $scoreSpace)
     (if-error $bs   ;; parity with getCscore; scoreActionTree never errors
        (worstCscore)
        (let* (($bsum (sumBScore $bs))
               ($cpxy (actionTreeComplexity $tree))
               ($cCoef (getComplexityCoef $complexityRatio)))
          (updatePenalizedScore
            (mkCscore $bsum $cpxy (* $cpxy $cCoef) 0.0 (* -1 (pow-math 10 308)))
            False)))))
