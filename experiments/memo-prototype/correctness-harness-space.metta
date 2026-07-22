;; ---------------------------------------------------------------------------
;; Correctness harness for variant S (kernel-space.metta / hand-rolled
;; &protoSubtreeCache). Runs on BOTH runtimes -- no lib_memo import.
;;
;; Run:  /home/yab/PeTTa-pr165/run.sh <abs-path-to-this-file>
;;   sh  /home/yab/PeTTaV1/run.sh    experiments/memo-prototype/correctness-harness-space.metta -s
;;
;; Assertions use the native `test` translator construct (same one used by
;; correctness-harness-memo.metta; verified present and identical on both
;; runtimes -- src/translator.pl HV==test clause). It prints
;; "is X, should Y. <✅|❌>" and halts(1) on the first failed comparison, so
;; a clean run to the end means every assertion below passed.
;; ---------------------------------------------------------------------------

!(bind! &params (new-space))
!(import! &self ../../parameters/registry)
!(import! &self kernel-space)
!(import! &self common/truth-tables)
!(import! &self common/reference-formulas)

;; === Reference-formula correctness (tiny 4-row miniTable) ===================
!(setProtoTable (miniTable))
!(resetProtoCache)

!(println! (RESULT formulaLeafA (evalColCached (formulaLeafA))))
!(test (evalColCached (formulaLeafA)) (expectedLeafA))

!(println! (RESULT formulaNotA (evalColCached (formulaNotA))))
!(test (evalColCached (formulaNotA)) (expectedNotA))

!(println! (RESULT formulaAndAB (evalColCached (formulaAndAB))))
!(test (evalColCached (formulaAndAB)) (expectedAndAB))

!(println! (RESULT formulaOrAB (evalColCached (formulaOrAB))))
!(test (evalColCached (formulaOrAB)) (expectedOrAB))

!(println! (RESULT formulaNestedAndOrNot (evalColCached (formulaNestedAndOrNot))))
!(test (evalColCached (formulaNestedAndOrNot)) (expectedNestedAndOrNot))

;; === Full parity3 formula correctness (8-row parity3Table) =================
!(setProtoTable (parity3Table))
!(resetProtoCache)

!(println! (RESULT parity3Formula (evalColCached (parity3Formula))))
!(test (evalColCached (parity3Formula)) (expectedParity3Formula))

;; === Cache-behavior check =====================================================
;; Evaluate the full parity3 formula twice; the first pass above already
;; populated &protoSubtreeCache, so this repeat must be pure hits.
!(println! (STATS after-first-pass (getSpaceStats)))
!(evalColCached (parity3Formula))
!(println! (STATS after-second-pass-expect-pure-hits (getSpaceStats)))

;; === Table-switch check =======================================================
;; (AND (A B)) is a valid formula against BOTH miniTable (4 rows) and
;; majority3Table (8 rows) since both tables have labels A and B -- but the
;; two tables carry different A/B data and different row counts, so a stale
;; cached column is trivially observable (wrong length, wrong values).
!(setProtoTable (miniTable))
!(resetProtoCache)
!(println! (RESULT-miniTable formulaAndAB (evalColCached (formulaAndAB))))
;; populates &protoSubtreeCache for the ground key (subtree (AND (A B)) ...)
;; against miniTable

!(setProtoTable (majority3Table))
;; NO resetProtoCache here -- deliberately demonstrate staleness.
!(println! (STALE-WITHOUT-RESET formulaAndAB (evalColCached (formulaAndAB))))
;; Expected (miniTable-era, WRONG for majority3Table): (False False False True)
;; &protoSubtreeCache replays the stale 4-row miniTable column verbatim: the
;; cache is keyed purely by the ground expression, with no knowledge that
;; setProtoTable silently changed the backing state -- the same staleness
;; hazard as variant M's lib_memo path.

!(resetProtoCache)
!(println! (CORRECT-AFTER-RESET formulaAndAB (evalColCached (formulaAndAB))))
;; Hand-computed majority3Table A/B columns:
;;   A = (False False False False True  True  True  True )
;;   B = (False False True  True  False False True  True )
;;   AND(A,B) row-by-row: F,F,F,F,F,F,T,T
!(test (evalColCached (formulaAndAB)) (False False False False False False True True))
