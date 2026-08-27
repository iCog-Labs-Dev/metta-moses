;; ============================================================================
;; tests/run-grove.metta -- the mixed world: actions, a condition, and numbers.
;;
;;   ( ulimit -v 8000000; timeout 900 \
;;       sh /home/yab/PeTTaV1/run.sh prototypes/m1/tests/run-grove.metta -s ) | grep -c ✅
;;
;; Compare that count against `grep -c '^!(test' prototypes/m1/tests/t-grove.metta`.
;;
;; core/numeric is imported HERE rather than by all.metta. numGt returns Bool,
;; so loading it everywhere would put it in opsOfType Bool for every domain and
;; move candidate lists, knob counts and scores in all four worlds that have no
;; numbers. It goes after all and before the domain: a call to a function that
;; has not been imported yet compiles as data.
;;
;; Absence of failures is NOT enough -- count the ticks and compare. `test`
;; calls halt(1), so a short count WITH a ❌ means the run stopped there, and a
;; short count with NO ❌ means checks vanished silently.
;; ============================================================================
!(import! &self prototypes/m1/all)
!(import! &self prototypes/m1/core/numeric)
!(import! &self prototypes/m1/domain/grove)

!(import! &self prototypes/m1/tests/t-grove)
