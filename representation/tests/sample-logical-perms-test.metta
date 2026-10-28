
!(import! &self ../../utilities/lazy-random-selector)
!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../representation/sample-logical-perms)
!(import! &self ../../scoring/boolean-ops)
!(import! &self ../../scoring/bscore)
!(import! &self ../../representation/build-action)

!(py-call (random.seed 42))
;; Testcase for sample-logical-perms
!(assertEqual (length (sampleLogicalPerms AND 2 (A B))) 4)
!(assertEqual (length (sampleLogicalPerms OR 2 (A B))) 4)

;; Action-domain permutation sampling (replaces the retired game-strategy
;; permutation cases). The action vocabulary rides as an ordinary argument --
;; no set-param scaffolding. canwin/canblock are inert perception symbols.
;; With perceptions () the sampler is degenerate and returns the vocabulary
;; verbatim.
(= (tttActs) (playwin playblock playcenter playcorner playside))

;; A pair permutation is (action_bool_if <perception> <actA> <actB>) with
;; two distinct actions drawn from the vocabulary and a perception drawn from
;; the perceptions list.
(= (isActionPairPerm (action_bool_if $perception $actA $actB) $actions $perceptions)
   (all ((once (is-member $perception $perceptions))
         (once (is-member $actA $actions))
         (once (is-member $actB $actions))
         (!= $actA $actB))))

;; Degenerate guards: single action, or empty perceptions, return the
;; vocabulary unchanged.
!(assertEqual (sampleActionPerms (playwin) (canwin)) (playwin))
!(assertEqual (sampleActionPerms (tttActs) ()) (playwin playblock playcenter playcorner playside))

;; Two-action vocabulary, one perception: pairCount 2 == sampleCount, so both
;; ordered pairs are produced deterministically after the two base actions.
!(assertEqual
  (let $perms (sampleActionPerms (playwin playblock) (canwin))
    ((length $perms)
     (car-atom $perms)
     (car-atom (cdr-atom $perms))
     (and (once (is-member (action_bool_if canwin playwin playblock) $perms))
          (once (is-member (action_bool_if canwin playblock playwin) $perms)))))
  (4 playwin playblock True))

;; Five-action vocabulary, two perceptions: n defaults to 5, so the result is
;; the five base actions in order followed by five pair permutations, each a
;; well-formed action_bool_if perm.
!(assertEqual
  (let $perms (sampleActionPerms (tttActs) (canwin canblock))
    ((length $perms)
     (take 5 $perms)
     (map-atom (subtraction-atom $perms (tttActs)) $p (isActionPairPerm $p (tttActs) (canwin canblock)))))
  (10 (playwin playblock playcenter playcorner playside) (True True True True True)))
