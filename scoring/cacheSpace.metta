!(bind! &treeSpace (new-space))
;; Retained only for signature compatibility: scoreTree still accepts a cache
;; space argument, but scoring is now memoized entirely in &subtreeCache below.
;; &bscoreCache is no longer read or written.
!(bind! &bscoreCache (new-space))
;; Subtree-level (columnar) score cache: (subtree <canonicalExpr> <bool-vector>)
;; entries for operator nodes AND label leaves. Keyed by the symbolic
;; expression, so identical subtrees across candidates share an entry. Every
;; subtree — including each tree's root — is memoized here, making this the
;; sole score memo. Persists for the whole run (a run scores one fixed table);
;; it is NOT cleared per generation, mirroring the old &bscoreCache lifetime.
!(bind! &subtreeCache (new-space))

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

;; Remove every candidate-cache entry supplied by the reset traversal.
(= (removeCandidateScoreEntries ()) True)
(= (removeCandidateScoreEntries (cons $entry $rest))
   (let $_removed (remove-atom &candidateScoreCache $entry)
     (removeCandidateScoreEntries $rest)))

;; Always return a Boolean, including when the cache is already empty, so this
;; reset can be safely sequenced at the beginning of every shared MOSES run.
(= (resetCandidateScoreCache)
   (let $entries
        (collapse (match &candidateScoreCache $entry $entry))
     (removeCandidateScoreEntries $entries)))

;; Empty the subtree cache. A run scores ONE fixed table, and every entry is
;; valid only for that table -- call this before scoring against a DIFFERENT
;; table in the same process (e.g. a test file exercising two tables).
(= (resetSubtreeCache)
   (let $entries (collapse (match &subtreeCache $e $e))
     (map-atom $entries $e (remove-atom &subtreeCache $e))))
