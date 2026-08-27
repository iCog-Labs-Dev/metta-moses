;; ============================================================================
;; demo-grove.metta -- A NUMBER, not a subtree: the thing every other demo
;; cannot do.
;;
;;   ( ulimit -v 8000000; timeout 900 \
;;       sh /home/yab/PeTTaV1/run.sh prototypes/m1/demo-grove.metta -s )
;;
;; WORLD        a row of fruit trees, each with a RIPENESS. A picker walks the
;;              row; picking a ripe tree is worth something, picking an unripe
;;              one wastes the fruit. Two groves, two ripe trees each.
;; CONTEXT      the grove, the picker's position, and what it has picked and
;;              spoiled -- a changing world, as in demo.metta.
;; VOCABULARY   no boolean perception at all. The only condition that can be
;;              built is a numeric comparison, so nothing here can solve the
;;              problem without getting a number right.
;; SCORE        picked minus spoiled, over both groves. Best is 4.
;; THE POINT    the exemplar's STRUCTURE is already right -- look, then pick or
;;              walk on. What is wrong is a NUMBER inside it: it holds out for
;;              ripeness above 0, strips both groves bare and spoils four fruit.
;;              No rearrangement of subtrees fixes that. 8 appears nowhere in
;;              the world, the vocabulary or any declaration.
;;
;; Threshold and stride are BOTH tunable, in the same vector as the action and
;; condition knobs, and only one of them is wrong -- a search that thrashes
;; would move both.
;;
;; The control run will not solve this, and that is honest rather than a defect:
;; a number is tunable only where the program already has one, and an empty
;; program has none. What the exemplar hands over here is the number itself.
;; ============================================================================
!(import! &self prototypes/m1/all)
!(import! &self prototypes/m1/core/numeric)
!(import! &self prototypes/m1/domain/grove)

!(m1Moses grove (groveExemplar) groveScoreExp (groveBestScore))
