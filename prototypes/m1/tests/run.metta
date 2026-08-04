;; ============================================================================
;; tests/run.metta -- runs everything.
;;
;;   ( ulimit -v 8000000; timeout 900 \
;;       sh /home/yab/PeTTaV1/run.sh prototypes/m1/tests/run.metta -s )
;;
;; A silent finish means every check passed; a failure prints and stops.
;; Start with t-operators: if those fail, nothing below them is trustworthy.
;; ============================================================================
!(import! &self prototypes/m1/all)

!(import! &self prototypes/m1/tests/t-operators)
!(import! &self prototypes/m1/tests/t-types)
!(import! &self prototypes/m1/tests/t-knobs)
!(import! &self prototypes/m1/tests/t-decode)
!(import! &self prototypes/m1/tests/t-domain)
!(import! &self prototypes/m1/tests/t-search)
