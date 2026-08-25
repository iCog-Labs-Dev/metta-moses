;; ============================================================================
;; tests/run-grove.metta -- the mixed domain: an action program, a boolean
;; condition, numeric operands, and two tuned numbers.
;;
;;   ( ulimit -v 8000000; timeout 900 \
;;       sh /home/yab/PeTTaV1/run.sh prototypes/m1/tests/run-grove.metta -s )
;;
;; A separate run because a domain is loaded per suite: two domains in one space
;; would merge their vocabularies and every candidate list would change.
;;
;; Absence of failures is NOT enough -- count the ticks and compare:
;;
;;   ...run-grove.metta -s ) | grep -c ✅
;;   grep -c '^!(test' prototypes/m1/tests/t-grove.metta
;;
;; A short count with no failure means checks vanished (an expected side that
;; yields nothing prints neither pass nor fail). A short count WITH a failure
;; means the run stopped there -- PeTTa's `test` calls halt/1 on mismatch.
;; ============================================================================
!(import! &self prototypes/m1/all)
!(import! &self prototypes/m1/domain/grove)

!(import! &self prototypes/m1/tests/t-grove)
