;; ============================================================================
;; demo-berries.metta -- THE ANSWER IS NOT A CANDIDATE; it has to be assembled.
;;
;;   ( ulimit -v 8000000; timeout 900 \
;;       sh /home/yab/PeTTaV1/run.sh prototypes/m1/demo-berries.metta -s )
;;
;; WORLD        a patch of berries, each with a colour, a taste and a worm.
;; CONTEXT      that patch -- and the program CHANGES it. Picking takes a berry
;;              and spends fuel.
;; IT CAN DO    berryPick, berryWalk.
;; IT CAN SEE   berryRed, berrySweet, berryWormy.
;; SCORE        a good berry earns, a bad one costs, over two patches. Higher
;;              is better; 16 is the ceiling.
;; THE POINT    berries are ripe by colour OR by smell, and some ripe-looking
;;              ones are wormy, so the answer is
;;
;;                  (AND (OR berryRed berrySweet) (NOT berryWormy))
;;
;;              and (OR berryRed berrySweet) IS NOT ONE OF THE CANDIDATES. The
;;              sampler works to a budget, its odometer holds the leading
;;              argument steady longest, and berryWormy is declared first -- so
;;              every pair on offer leads with berryWormy and the one we need is
;;              never reached. No single knob can produce the answer.
;;
;;              What makes it reachable anyway is the empty OR node the builder
;;              leaves under every condition: the candidates are the letters,
;;              and that node is where words get spelled.
;;
;; It also marks the limit honestly -- both moves have to pay off on their own,
;; because a single hill climb accepts nothing else. An answer whose first half
;; is worthless without its second is still out of reach, and that is what a
;; population is for.
;;
;; NOTE: berryExemplar is currently EMPTY, so this run starts from nothing and
;; the report says NOT-SOLVED. Restore a conditional exemplar to see the
;; two-move story above.
;; ============================================================================
!(import! &self prototypes/m1/all)
!(import! &self prototypes/m1/domain/berries)

!(m1Moses berries (berryExemplar) berryScoreExp (berryBestScore))
