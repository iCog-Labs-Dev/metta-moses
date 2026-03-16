
!(import! &self ../../utilities/lazy-random-selector)
!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../representation/sample-logical-perms)
!(import! &self ../../scoring/bscore)

;; Testcase for sample-logical-perms
!(assertEqual (length (sampleLogicalPerms AND 2 (A B))) 4)
!(assertEqual (length (sampleLogicalPerms OR 2 (A B))) 4)
