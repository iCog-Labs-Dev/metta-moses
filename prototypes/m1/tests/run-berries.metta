;; ============================================================================
;; tests/run-berries.metta -- the checks for domain/berries.
;;
;;   ( ulimit -v 8000000; timeout 900 \
;;       sh /home/yab/PeTTaV1/run.sh prototypes/m1/tests/run-berries.metta -s ) | grep -c ✅
;;
;; Compare that count against `grep -c '^!(test' prototypes/m1/tests/t-berries.metta`.
;; A check whose expected value is an unquoted program is a call, yields no
;; answer, and never runs -- printing neither a pass nor a failure.
;;
;; One domain per run: two would merge their vocabularies.
;; ============================================================================
!(import! &self prototypes/m1/all)
!(import! &self prototypes/m1/domain/berries)

!(import! &self prototypes/m1/tests/t-berries)
