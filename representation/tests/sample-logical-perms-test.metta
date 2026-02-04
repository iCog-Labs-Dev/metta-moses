
!(import! &self ../../utilities/lazy-random-selector)
!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../representation/sample-logical-perms)
!(import! &self ../../scoring/bscore)

!(py-call (random.seed 42))
;; Testcase for sample-logical-perms
!(assertEqual (length (sampleLogicalPerms AND 2 (A B))) 4)
!(assertEqual (length (sampleLogicalPerms OR 2 (A B))) 4)

;; Testcase for sample-strategy-perms
!(assertEqual (sampleStrategyPerms PRIORITIZED-OR 1 (playcenter)) (PRIORITIZED-OR playcenter))

!(assertEqual (sampleStrategyPerms PRIORITIZED-OR 2 (playcenter playcorner)) 
              ((PRIORITIZED-OR playcenter playcorner) (PRIORITIZED-OR playcorner playcenter) playcenter playcorner))

!(assertEqual (sampleStrategyPerms PRIORITIZED-OR 3 (playcenter playcorner playblock))
              ((PRIORITIZED-OR playcenter playblock) (PRIORITIZED-OR playcorner playcenter) (PRIORITIZED-OR playblock playcenter) playcenter playcorner playblock))
;; check that original moves are included
!(assertEqual (let $result (sampleStrategyPerms PRIORITIZED-OR 2 (playcenter playcorner))
    (and (is-member playcenter $result) (is-member playcorner $result))) True)
;; check that PRIORITIZED-OR combinations are included
!(assertEqual (let $result (sampleStrategyPerms PRIORITIZED-OR 2 (playcenter playcorner))
    (or (is-member (PRIORITIZED-OR playcenter playcorner) $result)
        (is-member (PRIORITIZED-OR playcorner playcenter) $result))) True)