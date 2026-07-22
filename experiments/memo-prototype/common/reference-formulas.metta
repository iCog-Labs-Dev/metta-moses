;; ---------------------------------------------------------------------------
;; Hand-written reference formulas (wrapped node shape: (AND (c1 .. ck)) /
;; (OR (c1 .. ck)) / (NOT (c))) and hand-computed expected output columns.
;; Every expected column below was worked out BY HAND from the truth tables
;; in common/truth-tables.metta and the tiny inline 4-row table defined here
;; -- none of them were produced by running the kernel. AND/OR/NOT are never
;; defined as functions anywhere in this prototype, so these data literals
;; stay inert and can be fed to either kernel unquoted.
;; ---------------------------------------------------------------------------

;; --- Tiny 4-row, 2-variable reference table -------------------------------
;; Labels (A B Out); Out is unused by these formulas (they only reference A/B)
;; but is included so the table shape matches the production convention
;; (target column last).
;;   row0: A=False B=False Out=False
;;   row1: A=False B=True  Out=True
;;   row2: A=True  B=False Out=True
;;   row3: A=True  B=True  Out=False
(= (miniTable)
   (mkITable
     ((False False False) (False True True) (True False True) (True True False))
     (A B Out)))

;; A column = (False False True True)
;; B column = (False True False True)

;; --- Formula 1: single label leaf (bare symbol, no wrapping) --------------
(= (formulaLeafA) A)
(= (expectedLeafA) (False False True True))

;; --- Formula 2: (NOT (A)) --------------------------------------------------
;; not(False False True True) = (True True False False)
(= (formulaNotA) (NOT (A)))
(= (expectedNotA) (True True False False))

;; --- Formula 3: (AND (A B)) -------------------------------------------------
;; and((F F T T),(F T F T)) row-by-row: F&F=F, F&T=F, T&F=F, T&T=T
(= (formulaAndAB) (AND (A B)))
(= (expectedAndAB) (False False False True))

;; --- Formula 4: (OR (A B)) --------------------------------------------------
;; or((F F T T),(F T F T)) row-by-row: F|F=F, F|T=T, T|F=T, T|T=T
(= (formulaOrAB) (OR (A B)))
(= (expectedOrAB) (False True True True))

;; --- Formula 5: nested (AND ((OR (A B)) (NOT (B)))) -------------------------
;; OR(A B)  = (False True  True True)
;; NOT(B)   = (True  False True False)
;; AND of the two, row-by-row: F&T=F, T&F=F, T&T=T, T&F=F
(= (formulaNestedAndOrNot) (AND ((OR (A B)) (NOT (B)))))
(= (expectedNestedAndOrNot) (False False True False))

;; --- Formula 6: full parity3 formula (XOR expansion over X1..X3) -----------
;; Per the comment in moses/demo-problems.metta:
;;   (XOR X1 X2 X3) => (OR (AND X1 (NOT X2) (NOT X3))
;;                         (AND (NOT X1) X2 (NOT X3))
;;                         (AND (NOT X1) (NOT X2) X3)
;;                         (AND X1 X2 X3))
;; expressed in the wrapped node shape used by these kernels. Hand-evaluated
;; against every row of parity3Table (common/truth-tables.metta):
;;   row (F F F): all four AND terms are False -> OR = False
;;   row (F F T): term3 (NOT X1)&(NOT X2)&X3 = T&T&T = True -> OR = True
;;   row (F T F): term2 (NOT X1)&X2&(NOT X3) = T&T&T = True -> OR = True
;;   row (F T T): all four AND terms False -> OR = False
;;   row (T F F): term1 X1&(NOT X2)&(NOT X3) = T&T&T = True -> OR = True
;;   row (T F T): all four AND terms False -> OR = False
;;   row (T T F): all four AND terms False -> OR = False
;;   row (T T T): term4 X1&X2&X3 = True -> OR = True
;; This reproduces parity3Table's Out column exactly (odd-parity XOR).
(= (parity3Formula)
   (OR ( (AND (X1 (NOT (X2)) (NOT (X3))))
         (AND ((NOT (X1)) X2 (NOT (X3))))
         (AND ((NOT (X1)) (NOT (X2)) X3))
         (AND (X1 X2 X3)) )))
(= (expectedParity3Formula)
   (False True True False True False False True))
