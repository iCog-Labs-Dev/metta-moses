;; ============================================================================
;; tests/run-contin.metta -- the tunable-number machinery, with no domain.
;;
;;   ( ulimit -v 8000000; timeout 900 \
;;       sh /home/yab/PeTTaV1/run.sh prototypes/m1/tests/run-contin.metta -s ) | grep -c ✅
;;
;; Compare that count against `grep -c '^!(test' prototypes/m1/tests/t-contin.metta`.
;;
;; NO DOMAIN IS LOADED. The walk and the Params guard are answers about
;; declarations, not about any world, so nothing here needs one -- and keeping
;; a domain out is what lets this suite exist without moving the tick count of
;; any suite that was passing before.
;;
;; Absence of failures is NOT enough. `test` calls halt(1) on mismatch, so a
;; short count WITH a ❌ means the run stopped there, while a short count with
;; NO ❌ means checks vanished silently.
;; ============================================================================
!(import! &self prototypes/m1/all)
!(import! &self prototypes/m1/core/numeric)

!(import! &self prototypes/m1/tests/t-contin)
