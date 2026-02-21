
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
!(assertEqual (sampleStrategyPerms PRIORITIZED-OR 1 (playcenter playcorner playblock playside playwin)) (PRIORITIZED-OR playcenter))

!(assertEqual (sampleStrategyPerms PRIORITIZED-OR 2 (playcenter playcorner playblock playside playwin)) ((PRIORITIZED-OR playwin playside playcorner) (PRIORITIZED-OR playwin playside playcenter)))

!(assertEqual (sampleStrategyPerms PRIORITIZED-OR 3 (playcenter playcorner playblock playside playwin)) ((PRIORITIZED-OR playside playwin playcenter) (PRIORITIZED-OR playside playwin playcorner) (PRIORITIZED-OR playwin playblock playcenter)))