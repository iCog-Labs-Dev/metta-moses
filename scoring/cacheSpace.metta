!(bind! &treeSpace (new-space))
;; Retained only for signature compatibility: scoreTree still accepts a cache
;; space argument, but scoring is memoized through lib_memo (evalSubtree in
;; scoring/fitness). &bscoreCache is no longer read or written.
!(bind! &bscoreCache (new-space))

;; Complete candidate scores are cached separately from Boolean subtree values
;; so actual-evaluation accounting can distinguish a new scorer call from reuse
;; of an already scored program. The scoring context is part of the key because
;; one tree can score differently for another table, horizon, or ratio.
!(bind! &candidateScoreCache (new-space))

;; Return a cached complete-program score for this context, or () on a miss.
(= (cachedCandidateScore $context $tree)
   (let $matches
        (collapse
          (match &candidateScoreCache
                 (candidateScore $context $tree $score)
                 $score))
     (if (== $matches ()) () (car-atom $matches))))

;; Store a complete-program score only when the context/tree key is new.
(= (cacheCandidateScore $context $tree $score)
   (if (== (cachedCandidateScore $context $tree) ())
       (add-atom &candidateScoreCache
                 (candidateScore $context $tree $score))
       True))

;; Remove every atom from a cache space. Collapse the matches first, then
;; remove: never change the space while match iterates it. (clearSpace in
;; general-helpers removes inside get-atoms, so it is not used here.)
(= (emptySpace $space)
   (let $entries (collapse (match $space $e $e))
     (map-atom $entries $e (remove-atom $space $e))))

;; Empty the candidate-score cache. Callers ignore the result.
(= (resetCandidateScoreCache) (emptySpace &candidateScoreCache))
