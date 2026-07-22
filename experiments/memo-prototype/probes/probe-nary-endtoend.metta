;; Probe: full variant-P pipeline (ops-nary + rewriter-nary + UNCHANGED
;; evaluator-common/evaluator-memo) against the SAME hand-computed columns
;; common/reference-formulas.metta carries, to verify item 3's claim before
;; committing to the real correctness harness: does reusing evaluator-memo's
;; evalZipTerm VERBATIM correctly dispatch `($op $row)` to ops-nary's AND/OR/
;; NOT clauses? Formulas are written LOCALLY here via quote (reference-
;; formulas.metta itself stores them as BARE AND/OR/NOT literals, which
;; would misfire once ops-nary is in scope -- see the file's own header).
!(bind! &params (new-space))
!(import! &self ../../../parameters/registry)
!(import! &self (library lib_memo))
!(import! &self ../common/list-helpers)
!(import! &self ../common/kernel-common)
!(import! &self ../zipform/ops-nary)
!(import! &self ../zipform/evaluator-common)
!(import! &self ../zipform/evaluator-memo)
!(import! &self ../zipform/rewriter-nary)
!(import! &self ../common/truth-tables)
!(import! &self ../common/reference-formulas)

!(setZipTable (miniTable))
!(clear-memoize)
!(clear-memoize-stats)

(= (fLeafA) (quote A))
(= (fNotA) (quote (NOT (A))))
(= (fAndAB) (quote (AND (A B))))
(= (fOrAB) (quote (OR (A B))))
(= (fNested) (quote (AND ((OR (A B)) (NOT (B))))))
(= (fSingletonAnd) (quote (AND ((OR (A B))))))

!(let (quote $e) (fLeafA) (println! (P_LEAFA (evalZipTerm (rewriteTreeNaryCached $e)))))
!(let (quote $e) (fNotA) (println! (P_NOTA (evalZipTerm (rewriteTreeNaryCached $e)))))
!(let (quote $e) (fAndAB) (println! (P_ANDAB (evalZipTerm (rewriteTreeNaryCached $e)))))
!(let (quote $e) (fOrAB) (println! (P_ORAB (evalZipTerm (rewriteTreeNaryCached $e)))))
!(let (quote $e) (fNested) (println! (P_NESTED (evalZipTerm (rewriteTreeNaryCached $e)))))
!(let (quote $e) (fSingletonAnd) (println! (P_SINGLETON (evalZipTerm (rewriteTreeNaryCached $e)))))

;; expected (hand-copied from common/reference-formulas.metta comments):
;; expectedLeafA=(False False True True) expectedNotA=(True True False False)
;; expectedAndAB=(False False False True) expectedOrAB=(False True True True)
;; expectedNestedAndOrNot=(False False True False)
;; singleton AND((OR(A,B))) == OR(A,B) = (False True True True)

(= (fParity3) (quote (OR ( (AND (X1 (NOT (X2)) (NOT (X3))))
                           (AND ((NOT (X1)) X2 (NOT (X3))))
                           (AND ((NOT (X1)) (NOT (X2)) X3))
                           (AND (X1 X2 X3)) ))))
!(setZipTable (parity3Table))
!(clear-memoize)
!(clear-memoize-stats)
!(let (quote $e) (fParity3) (println! (P_PARITY3 (evalZipTerm (rewriteTreeNaryCached $e)))))
;; expected (common/reference-formulas.metta expectedParity3Formula):
;; (False True True False True False False True)
