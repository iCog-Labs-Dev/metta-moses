;; ---------------------------------------------------------------------------
;; Correctness harness for variant M (kernel-memo.metta / lib_memo).
;; PR-165 PeTTa ONLY -- kernel-memo.metta imports (library lib_memo), which
;; does not exist on PeTTaV1. See correctness-harness-space.metta for the
;; twin harness that runs on both runtimes.
;;
;; Run:  /home/yab/PeTTa-pr165/run.sh <abs-path-to-this-file>
;;
;; Assertions use the native `test` translator construct (verified present
;; and identical -- src/translator.pl HV==test clause -- on both PeTTaV1 and
;; PeTTa-pr165); it prints "is X, should Y. <✅|❌>" and halts(1) on the
;; first failed comparison, so a clean run to the end means every assertion
;; below passed.
;; ---------------------------------------------------------------------------

!(bind! &params (new-space))
!(import! &self ../../parameters/registry)
!(import! &self kernel-memo)
!(import! &self common/truth-tables)
!(import! &self common/reference-formulas)

;; === Reference-formula correctness (tiny 4-row miniTable) ===================
!(setMemoTable (miniTable))
!(clear-memoize)
!(clear-memoize-stats)

!(println! (RESULT formulaLeafA (evalCol (formulaLeafA))))
!(test (evalCol (formulaLeafA)) (expectedLeafA))

!(println! (RESULT formulaNotA (evalCol (formulaNotA))))
!(test (evalCol (formulaNotA)) (expectedNotA))

!(println! (RESULT formulaAndAB (evalCol (formulaAndAB))))
!(test (evalCol (formulaAndAB)) (expectedAndAB))

!(println! (RESULT formulaOrAB (evalCol (formulaOrAB))))
!(test (evalCol (formulaOrAB)) (expectedOrAB))

!(println! (RESULT formulaNestedAndOrNot (evalCol (formulaNestedAndOrNot))))
!(test (evalCol (formulaNestedAndOrNot)) (expectedNestedAndOrNot))

;; === Full parity3 formula correctness (8-row parity3Table) =================
!(setMemoTable (parity3Table))
!(clear-memoize)
!(clear-memoize-stats)

!(println! (RESULT parity3Formula (evalCol (parity3Formula))))
!(test (evalCol (parity3Formula)) (expectedParity3Formula))

;; === Cache-behavior check =====================================================
;; Evaluate the full parity3 formula (11 distinct subtree nodes/leaves: 1 OR
;; root, 4 AND terms, 6 NOT leaves, X1/X2/X3 leaves reused across terms)
;; twice. The first pass above already populated the memo, so this repeat
;; must be pure hits -- report both stats snapshots.
!(println! (STATS after-first-pass (get-memoize-stats)))
!(evalCol (parity3Formula))
!(println! (STATS after-second-pass-expect-pure-hits (get-memoize-stats)))

;; === Table-switch check =======================================================
;; (AND (A B)) is a valid formula against BOTH miniTable (4 rows) and
;; majority3Table (8 rows) since both tables have labels A and B -- but the
;; two tables carry different A/B data and different row counts, so a stale
;; memoized column is trivially observable (wrong length, wrong values).
!(setMemoTable (miniTable))
!(clear-memoize)
!(clear-memoize-stats)
!(println! (RESULT-miniTable formulaAndAB (evalCol (formulaAndAB))))
;; populates the lib_memo cache for the ground key (AND (A B)) against miniTable

!(setMemoTable (majority3Table))
;; NO clear-memoize here -- deliberately demonstrate staleness.
!(println! (STALE-WITHOUT-CLEAR formulaAndAB (evalCol (formulaAndAB))))
;; Expected (miniTable-era, WRONG for majority3Table): (False False False True)
;; lib_memo replays the stale 4-row miniTable column verbatim: it has no
;; way to know setMemoTable silently changed the backing state, matching
;; the "memoized functions reading state serve STALE results after state
;; mutation" warning from the verified PR-165 probes.

!(clear-memoize)
!(println! (CORRECT-AFTER-CLEAR formulaAndAB (evalCol (formulaAndAB))))
;; Hand-computed majority3Table A/B columns:
;;   A = (False False False False True  True  True  True )
;;   B = (False False True  True  False False True  True )
;;   AND(A,B) row-by-row: F,F,F,F,F,F,T,T
!(test (evalCol (formulaAndAB)) (False False False False False False True True))
