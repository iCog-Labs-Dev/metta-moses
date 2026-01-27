
!(import! &self ../../utilities/lazy-random-selector)
!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../representation/sample-logical-perms)
!(import! &self ../../scoring/bscore)

;; Testcase for sample-logical-perms
!(assertEqual (length (sampleLogicalPerms AND 2 (A B))) 4)
!(assertEqual (length (sampleLogicalPerms OR 2 (A B))) 4)

;; Testcase for sample-strategy-perms

;; Test with single move (edge case)
!(assertEqual (length (sampleStrategyPerms PRIORITIZED-OR 1 (play-center))) 2)
!(assertEqual (length (sampleStrategyPerms PRIORITIZED-OR 2 (play-center play-corner))) 4)
!(assertEqual (length (sampleStrategyPerms PRIORITIZED-OR 3 (play-center play-corner play-block))) 6)
;; Test with 4 moves
!(assertEqual (length (sampleStrategyPerms PRIORITIZED-OR 4 (play-center play-corner play-block play-fork))) 8)

;; check that original moves are included
!(assertEqual (let $result (sampleStrategyPerms PRIORITIZED-OR 2 (play-center play-corner))
    (and (is-member play-center $result) (is-member play-corner $result))) True)

;; check that PRIORITIZED-OR combinations are included
!(assertEqual (let $result (sampleStrategyPerms PRIORITIZED-OR 2 (play-center play-corner))
    (or (is-member (PRIORITIZED-OR play-center play-corner) $result)
        (is-member (PRIORITIZED-OR play-corner play-center) $result))) True)