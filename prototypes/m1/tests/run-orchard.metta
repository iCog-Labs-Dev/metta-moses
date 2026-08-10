;; ============================================================================
;; tests/run-orchard.metta -- the orchard world's checks.
;;
;;   ( ulimit -v 8000000; timeout 900 \
;;       sh /home/yab/PeTTaV1/run.sh prototypes/m1/tests/run-orchard.metta -s )
;;
;; Its own runner, not part of tests/run.metta: a domain brings its own
;; operator vocabulary, and loading two of them at once would merge the two
;; vocabularies and duplicate the shared declarations, doubling every answer
;; that goes through sigOf.
;;
;; Absence of failures is NOT enough. Count the ticks and compare:
;;
;;   ...run-orchard.metta -s ) | grep -c ✅
;;   grep -c '^!(test' prototypes/m1/tests/t-orchard.metta
;;
;; A check whose expected side is a program written out longhand is a CALL. If
;; it is not wrapped in `quote` it yields no answer and the check quietly does
;; not run -- no pass, no fail, no output at all.
;; ============================================================================
!(import! &self prototypes/m1/all)
!(import! &self prototypes/m1/domain/orchard)

!(import! &self prototypes/m1/tests/t-orchard)
