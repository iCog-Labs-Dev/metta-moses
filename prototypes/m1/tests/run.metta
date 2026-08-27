;; ============================================================================
;; tests/run.metta -- runs everything.
;;
;;   ( ulimit -v 8000000; timeout 900 \
;;       sh /home/yab/PeTTaV1/run.sh prototypes/m1/tests/run.metta -s )
;;
;; A failure prints and stops. But absence of failures is NOT enough: count the
;; ticks and compare them against the number of checks written down.
;;
;;   ...run.metta -s ) | grep -c ✅              -> must be 147
;;   cat prototypes/m1/tests/t-{operators,types,knobs,decode,domain,search}.metta \
;;       | grep -c '^!(test'
;;
;; The brace list, not t-*.metta: the other suites in this directory belong to
;; domains this runner does not load, and sweeping them in gives a number that
;; matches nothing.
;;
;; A check whose expected value is a program written out longhand is a CALL. If
;; it is not wrapped in `quote` it yields no answer and the whole check quietly
;; does not run -- no pass, no fail, no output.
;;
;; Start with t-operators: if those fail, nothing below them is trustworthy.
;; ============================================================================
!(import! &self prototypes/m1/all)
!(import! &self prototypes/m1/domain/tape)

!(import! &self prototypes/m1/tests/t-operators)
!(import! &self prototypes/m1/tests/t-types)
!(import! &self prototypes/m1/tests/t-knobs)
!(import! &self prototypes/m1/tests/t-decode)
!(import! &self prototypes/m1/tests/t-domain)
!(import! &self prototypes/m1/tests/t-search)
