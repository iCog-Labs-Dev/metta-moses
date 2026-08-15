;; ============================================================================
;; tests/run-alarm.metta -- the boolean domain.
;;
;;   ( ulimit -v 8000000; timeout 900 \
;;       sh /home/yab/PeTTaV1/run.sh prototypes/m1/tests/run-alarm.metta -s )
;;
;; A separate run because a domain is loaded per suite: two domains in one
;; space would merge their vocabularies and every candidate list would change.
;;
;; Absence of failures is NOT enough -- count the ticks and compare:
;;
;;   ...run-alarm.metta -s ) | grep -c ✅
;;   grep -c '^!(test' prototypes/m1/tests/t-alarm.metta
;; ============================================================================
!(import! &self prototypes/m1/all)
!(import! &self prototypes/m1/domain/alarm)

!(import! &self prototypes/m1/tests/t-alarm)
