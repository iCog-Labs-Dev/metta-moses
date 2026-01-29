;; 3-Bit Parity: Output is True if the number of True inputs is odd. Labels: X1, X2, X3, Out
;; Example: (XOR X1 X2 X3) => (OR (AND A (NOT B) (NOT C)) (AND (NOT A) B (NOT C)) (AND (NOT A) (NOT B) C) (AND A B C))
(= (parity3) (mkITable
    (Cons (Cons False (Cons False (Cons False (Cons False Nil))))
    (Cons (Cons False (Cons False (Cons True  (Cons True  Nil))))
    (Cons (Cons False (Cons True  (Cons False (Cons True  Nil))))
    (Cons (Cons False (Cons True  (Cons True  (Cons False Nil))))
    (Cons (Cons True  (Cons False (Cons False (Cons True  Nil))))
    (Cons (Cons True  (Cons False (Cons True  (Cons False Nil))))
    (Cons (Cons True  (Cons True  (Cons False (Cons False Nil))))
    (Cons (Cons True  (Cons True  (Cons True  (Cons True  Nil)))) Nil))))))))
    
    (Cons X1 (Cons X2 (Cons X3 (Cons Out Nil))))))

;; Example: (XOR X1 X2 X3 X4) => (OR (AND A (NOT B) (NOT C) (NOT D)) (AND (NOT A) B (NOT C) (NOT D)) (AND (NOT A) (NOT B) C (NOT D)) (AND (NOT A) (NOT B) (NOT C) D) (AND (NOT A) B C D) (AND A (NOT B) C D) (AND A B (NOT C) D) (AND A B C (NOT D)))
(= (parity4) (mkITable
   (Cons (Cons False (Cons False (Cons False (Cons False (Cons False Nil)))))
   (Cons (Cons False (Cons False (Cons False (Cons True (Cons True Nil)))))
   (Cons (Cons False (Cons False (Cons True (Cons False (Cons True Nil)))))
   (Cons (Cons False (Cons False (Cons True (Cons True (Cons False Nil)))))
   (Cons (Cons False (Cons True (Cons False (Cons False (Cons True Nil)))))
   (Cons (Cons False (Cons True (Cons False (Cons True (Cons False Nil)))))
   (Cons (Cons False (Cons True (Cons True (Cons False (Cons False Nil)))))
   (Cons (Cons False (Cons True (Cons True (Cons True (Cons True Nil)))))
   (Cons (Cons True (Cons False (Cons False (Cons False (Cons True Nil)))))
   (Cons (Cons True (Cons False (Cons False (Cons True (Cons False Nil)))))
   (Cons (Cons True (Cons False (Cons True (Cons False (Cons False Nil)))))
   (Cons (Cons True (Cons False (Cons True (Cons True (Cons True Nil)))))
   (Cons (Cons True (Cons True (Cons False (Cons False (Cons False Nil)))))
   (Cons (Cons True (Cons True (Cons False (Cons True (Cons True Nil)))))
   (Cons (Cons True (Cons True (Cons True (Cons False (Cons True Nil)))))
   (Cons (Cons True (Cons True (Cons True (Cons True (Cons False Nil))))) Nil))))))))))))))))
   (Cons X1 (Cons X2 (Cons X3 (Cons X4 (Cons Out Nil)))))))

;; Logic: Output is 1 if any input is 1
;; Example: (OR X1 X2 X3)
(= (disjunction3) (mkITable
   (Cons (Cons False (Cons False (Cons False (Cons False Nil))))
   (Cons (Cons False (Cons False (Cons True  (Cons True  Nil))))
   (Cons (Cons False (Cons True  (Cons False (Cons True  Nil))))
   (Cons (Cons False (Cons True  (Cons True  (Cons True  Nil))))
   (Cons (Cons True  (Cons False (Cons False (Cons True  Nil))))
   (Cons (Cons True  (Cons False (Cons True  (Cons True  Nil))))
   (Cons (Cons True  (Cons True  (Cons False (Cons True  Nil))))
   (Cons (Cons True  (Cons True  (Cons True  (Cons True  Nil)))) Nil))))))))

   (Cons X1 (Cons X2 (Cons X3 (Cons Out Nil))))))



;; 3-Bit Majority: Output is True if more than half (2 or 3) inputs are True. Labels: A, B, C, Out
;; Example: (OR (AND A B) (AND A C) (AND B C))
(= (majority3) (mkITable
    (Cons (Cons False (Cons False (Cons False (Cons False Nil))))
    (Cons (Cons False (Cons False (Cons True  (Cons False Nil))))
    (Cons (Cons False (Cons True  (Cons False (Cons False Nil))))
    (Cons (Cons False (Cons True  (Cons True  (Cons True  Nil))))
    (Cons (Cons True  (Cons False (Cons False (Cons False Nil))))
    (Cons (Cons True  (Cons False (Cons True  (Cons True  Nil))))
    (Cons (Cons True  (Cons True  (Cons False (Cons True  Nil))))
    (Cons (Cons True  (Cons True  (Cons True  (Cons True  Nil)))) Nil))))))))
    
    (Cons A (Cons B (Cons C (Cons Out Nil))))))

;;Example: (OR (AND X1 X2 X3) (AND X1 X2 X4) (AND X1 X2 X5) (AND X1 X3 X4) (AND X1 X3 X5) (AND X1 X4 X5) (AND X2 X3 X4) (AND X2 X3 X5) (AND X2 X4 X5) (AND X3 X4 X5))
(= (majority5) (mkITable
   (Cons (Cons False (Cons False (Cons False (Cons False (Cons False (Cons False Nil))))))
   (Cons (Cons False (Cons False (Cons False (Cons False (Cons True (Cons False Nil))))))
   (Cons (Cons False (Cons False (Cons False (Cons True (Cons False (Cons False Nil))))))
   (Cons (Cons False (Cons False (Cons False (Cons True (Cons True (Cons False Nil))))))
   (Cons (Cons False (Cons False (Cons True (Cons False (Cons False (Cons False Nil))))))
   (Cons (Cons False (Cons False (Cons True (Cons False (Cons True (Cons False Nil))))))
   (Cons (Cons False (Cons False (Cons True (Cons True (Cons False (Cons False Nil))))))
   (Cons (Cons False (Cons False (Cons True (Cons True (Cons True (Cons True Nil))))))
   (Cons (Cons False (Cons True (Cons False (Cons False (Cons False (Cons False Nil))))))
   (Cons (Cons False (Cons True (Cons False (Cons False (Cons True (Cons False Nil))))))
   (Cons (Cons False (Cons True (Cons False (Cons True (Cons False (Cons False Nil))))))
   (Cons (Cons False (Cons True (Cons False (Cons True (Cons True (Cons True Nil))))))
   (Cons (Cons False (Cons True (Cons True (Cons False (Cons False (Cons False Nil))))))
   (Cons (Cons False (Cons True (Cons True (Cons False (Cons True (Cons True Nil))))))
   (Cons (Cons False (Cons True (Cons True (Cons True (Cons False (Cons True Nil))))))
   (Cons (Cons False (Cons True (Cons True (Cons True (Cons True (Cons True Nil))))))
   (Cons (Cons True (Cons False (Cons False (Cons False (Cons False (Cons False Nil))))))
   (Cons (Cons True (Cons False (Cons False (Cons False (Cons True (Cons False Nil))))))
   (Cons (Cons True (Cons False (Cons False (Cons True (Cons False (Cons False Nil))))))
   (Cons (Cons True (Cons False (Cons False (Cons True (Cons True (Cons True Nil))))))
   (Cons (Cons True (Cons False (Cons True (Cons False (Cons False (Cons False Nil))))))
   (Cons (Cons True (Cons False (Cons True (Cons False (Cons True (Cons True Nil))))))
   (Cons (Cons True (Cons False (Cons True (Cons True (Cons False (Cons True Nil))))))
   (Cons (Cons True (Cons False (Cons True (Cons True (Cons True (Cons True Nil))))))
   (Cons (Cons True (Cons True (Cons False (Cons False (Cons False (Cons False Nil))))))
   (Cons (Cons True (Cons True (Cons False (Cons False (Cons True (Cons True Nil))))))
   (Cons (Cons True (Cons True (Cons False (Cons True (Cons False (Cons True Nil))))))
   (Cons (Cons True (Cons True (Cons False (Cons True (Cons True (Cons True Nil))))))
   (Cons (Cons True (Cons True (Cons True (Cons False (Cons False (Cons True Nil))))))
   (Cons (Cons True (Cons True (Cons True (Cons False (Cons True (Cons True Nil))))))
   (Cons (Cons True (Cons True (Cons True (Cons True (Cons False (Cons True Nil))))))
   (Cons (Cons True (Cons True (Cons True (Cons True (Cons True (Cons True Nil)))))) Nil))))))))))))))))))))))))))))))))
   (Cons X1 (Cons X2 (Cons X3 (Cons X4 (Cons X5 (Cons Out Nil))))))))

;; 3-Bit Multiplexer: - Input 1 is Address (Addr)
;;                    - Input 2 is Data 0 (D0)
;;                    - Input 3 is Data 1 (D1)
;;                  If Addr is False, Output is D0. If Addr is True, Output is D1.
;; Example: (OR (AND (NOT Addr) D0)  ;; The "Else" case (Address is 0)
;;              (AND Addr D1))        ; The "Then" case (Address is 1)
(= (mux3) (mkITable
    (Cons (Cons False (Cons False (Cons False (Cons False Nil))))  ; A=0, D0=0 -> 0
    (Cons (Cons False (Cons False (Cons True  (Cons False Nil))))  ; A=0, D0=0 -> 0
    (Cons (Cons False (Cons True  (Cons False (Cons True  Nil))))  ; A=0, D0=1 -> 1
    (Cons (Cons False (Cons True  (Cons True  (Cons True  Nil))))  ; A=0, D0=1 -> 1
    (Cons (Cons True  (Cons False (Cons False (Cons False Nil))))  ; A=1, D1=0 -> 0
    (Cons (Cons True  (Cons False (Cons True  (Cons True  Nil))))  ; A=1, D1=1 -> 1
    (Cons (Cons True  (Cons True  (Cons False (Cons False Nil))))  ; A=1, D1=0 -> 0
    (Cons (Cons True  (Cons True  (Cons True  (Cons True  Nil)))) Nil))))))))

    (Cons Addr (Cons D0 (Cons D1 (Cons Out Nil))))))

;; Two bits (A0, A1) decide which of the four data bits (D0..D3) passes through.
;; Example: (OR
;;              (AND (NOT A0) (AND (NOT A1) D0))  ;; Address 00 -> D0
;;              (AND (NOT A0) A1 D1)              ;; Address 01 -> D1
;;              (AND A0 (NOT A1) D2)              ;; Address 10 -> D2
;;              (AND A0 A1 D3))                   ;; Address 11 -> D3
(= (mux6) (mkITable
   (Cons (Cons False (Cons False (Cons False (Cons False (Cons False (Cons False (Cons False Nil)))))))
   (Cons (Cons False (Cons False (Cons False (Cons False (Cons False (Cons True (Cons False Nil)))))))
   (Cons (Cons False (Cons False (Cons False (Cons False (Cons True (Cons False (Cons False Nil)))))))
   (Cons (Cons False (Cons False (Cons False (Cons False (Cons True (Cons True (Cons False Nil)))))))
   (Cons (Cons False (Cons False (Cons False (Cons True (Cons False (Cons False (Cons False Nil)))))))
   (Cons (Cons False (Cons False (Cons False (Cons True (Cons False (Cons True (Cons False Nil)))))))
   (Cons (Cons False (Cons False (Cons False (Cons True (Cons True (Cons False (Cons False Nil)))))))
   (Cons (Cons False (Cons False (Cons False (Cons True (Cons True (Cons True (Cons False Nil)))))))
   (Cons (Cons False (Cons False (Cons True (Cons False (Cons False (Cons False (Cons True Nil)))))))
   (Cons (Cons False (Cons False (Cons True (Cons False (Cons False (Cons True (Cons True Nil)))))))
   (Cons (Cons False (Cons False (Cons True (Cons False (Cons True (Cons False (Cons True Nil)))))))
   (Cons (Cons False (Cons False (Cons True (Cons False (Cons True (Cons True (Cons True Nil)))))))
   (Cons (Cons False (Cons False (Cons True (Cons True (Cons False (Cons False (Cons True Nil)))))))
   (Cons (Cons False (Cons False (Cons True (Cons True (Cons False (Cons True (Cons True Nil)))))))
   (Cons (Cons False (Cons False (Cons True (Cons True (Cons True (Cons False (Cons True Nil)))))))
   (Cons (Cons False (Cons False (Cons True (Cons True (Cons True (Cons True (Cons True Nil)))))))
   (Cons (Cons False (Cons True (Cons False (Cons False (Cons False (Cons False (Cons False Nil)))))))
   (Cons (Cons False (Cons True (Cons False (Cons False (Cons False (Cons True (Cons False Nil)))))))
   (Cons (Cons False (Cons True (Cons False (Cons False (Cons True (Cons False (Cons False Nil)))))))
   (Cons (Cons False (Cons True (Cons False (Cons False (Cons True (Cons True (Cons False Nil)))))))
   (Cons (Cons False (Cons True (Cons False (Cons True (Cons False (Cons False (Cons True Nil)))))))
   (Cons (Cons False (Cons True (Cons False (Cons True (Cons False (Cons True (Cons True Nil)))))))
   (Cons (Cons False (Cons True (Cons False (Cons True (Cons True (Cons False (Cons True Nil)))))))
   (Cons (Cons False (Cons True (Cons False (Cons True (Cons True (Cons True (Cons True Nil)))))))
   (Cons (Cons False (Cons True (Cons True (Cons False (Cons False (Cons False (Cons False Nil)))))))
   (Cons (Cons False (Cons True (Cons True (Cons False (Cons False (Cons True (Cons False Nil)))))))
   (Cons (Cons False (Cons True (Cons True (Cons False (Cons True (Cons False (Cons False Nil)))))))
   (Cons (Cons False (Cons True (Cons True (Cons False (Cons True (Cons True (Cons False Nil)))))))
   (Cons (Cons False (Cons True (Cons True (Cons True (Cons False (Cons False (Cons True Nil)))))))
   (Cons (Cons False (Cons True (Cons True (Cons True (Cons False (Cons True (Cons True Nil)))))))
   (Cons (Cons False (Cons True (Cons True (Cons True (Cons True (Cons False (Cons True Nil)))))))
   (Cons (Cons False (Cons True (Cons True (Cons True (Cons True (Cons True (Cons True Nil)))))))
   (Cons (Cons True (Cons False (Cons False (Cons False (Cons False (Cons False (Cons False Nil)))))))
   (Cons (Cons True (Cons False (Cons False (Cons False (Cons False (Cons True (Cons False Nil)))))))
   (Cons (Cons True (Cons False (Cons False (Cons False (Cons True (Cons False (Cons True Nil)))))))
   (Cons (Cons True (Cons False (Cons False (Cons False (Cons True (Cons True (Cons True Nil)))))))
   (Cons (Cons True (Cons False (Cons False (Cons True (Cons False (Cons False (Cons False Nil)))))))
   (Cons (Cons True (Cons False (Cons False (Cons True (Cons False (Cons True (Cons False Nil)))))))
   (Cons (Cons True (Cons False (Cons False (Cons True (Cons True (Cons False (Cons True Nil)))))))
   (Cons (Cons True (Cons False (Cons False (Cons True (Cons True (Cons True (Cons True Nil)))))))
   (Cons (Cons True (Cons False (Cons True (Cons False (Cons False (Cons False (Cons False Nil)))))))
   (Cons (Cons True (Cons False (Cons True (Cons False (Cons False (Cons True (Cons False Nil)))))))
   (Cons (Cons True (Cons False (Cons True (Cons False (Cons True (Cons False (Cons True Nil)))))))
   (Cons (Cons True (Cons False (Cons True (Cons False (Cons True (Cons True (Cons True Nil)))))))
   (Cons (Cons True (Cons False (Cons True (Cons True (Cons False (Cons False (Cons False Nil)))))))
   (Cons (Cons True (Cons False (Cons True (Cons True (Cons False (Cons True (Cons False Nil)))))))
   (Cons (Cons True (Cons False (Cons True (Cons True (Cons True (Cons False (Cons True Nil)))))))
   (Cons (Cons True (Cons False (Cons True (Cons True (Cons True (Cons True (Cons True Nil)))))))
   (Cons (Cons True (Cons True (Cons False (Cons False (Cons False (Cons False (Cons False Nil)))))))
   (Cons (Cons True (Cons True (Cons False (Cons False (Cons False (Cons True (Cons True Nil)))))))
   (Cons (Cons True (Cons True (Cons False (Cons False (Cons True (Cons False (Cons False Nil)))))))
   (Cons (Cons True (Cons True (Cons False (Cons False (Cons True (Cons True (Cons True Nil)))))))
   (Cons (Cons True (Cons True (Cons False (Cons True (Cons False (Cons False (Cons False Nil)))))))
   (Cons (Cons True (Cons True (Cons False (Cons True (Cons False (Cons True (Cons True Nil)))))))
   (Cons (Cons True (Cons True (Cons False (Cons True (Cons True (Cons False (Cons False Nil)))))))
   (Cons (Cons True (Cons True (Cons False (Cons True (Cons True (Cons True (Cons True Nil)))))))
   (Cons (Cons True (Cons True (Cons True (Cons False (Cons False (Cons False (Cons False Nil)))))))
   (Cons (Cons True (Cons True (Cons True (Cons False (Cons False (Cons True (Cons True Nil)))))))
   (Cons (Cons True (Cons True (Cons True (Cons False (Cons True (Cons False (Cons False Nil)))))))
   (Cons (Cons True (Cons True (Cons True (Cons False (Cons True (Cons True (Cons True Nil)))))))
   (Cons (Cons True (Cons True (Cons True (Cons True (Cons False (Cons False (Cons False Nil)))))))
   (Cons (Cons True (Cons True (Cons True (Cons True (Cons False (Cons True (Cons True Nil)))))))
   (Cons (Cons True (Cons True (Cons True (Cons True (Cons True (Cons False (Cons False Nil)))))))
   (Cons (Cons True (Cons True (Cons True (Cons True (Cons True (Cons True (Cons True Nil))))))) Nil))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
   (Cons A0 (Cons A1 (Cons D0 (Cons D1 (Cons D2 (Cons D3 (Cons Out Nil)))))))))


(= (getBestPossibleCscore $cpxPen $problem)
   (let $bestCpx
      (case $problem
          (
            (parity3     12) ;; (OR (AND A (NOT B) (NOT C)) (AND (NOT A) B (NOT C)) (AND (NOT A) (NOT B) C) (AND A B C))
            (parity4     32) ;; (OR (AND A (NOT B) (NOT C) (NOT D)) (AND (NOT A) B (NOT C) (NOT D)) (AND (NOT A) (NOT B) C (NOT D)) (AND (NOT A) (NOT B) (NOT C) D) (AND (NOT A) B C D) (AND A (NOT B) C D) (AND A B (NOT C) D) (AND A B C (NOT D)))
            (disjunction3 3) ;; (OR X1 X2 X3)
            (majority3    6) ;; (OR (AND A B) (AND A C) (AND B C))
            (majority5   30) ;; (OR (AND X1 X2 X3) (AND X1 X2 X4) (AND X1 X2 X5) (AND X1 X3 X4) (AND X1 X3 X5) (AND X1 X4 X5) (AND X2 X3 X4) (AND X2 X3 X5) (AND X2 X4 X5) (AND X3 X4 X5))
            (mux3         4) ;; (OR (AND (NOT Addr) D0) (AND Addr D1))
            (mux6        12) ;; (OR (AND (NOT A0) (AND (NOT A1) D0)) (AND (NOT A0) A1 D1) (AND A0 (NOT A1) D2) (AND A0 A1 D3))
          )
      )
      (eval (updatePenalizedScore (mkCscore 0 $bestCpx $cpxPen (* $cpxPen $bestCpx) 0) False)))
   )

;;$maxGen $maxScore $maxCandOutput $metaPop $nExpansion $nDeme $prune-exemplar $fs-algo $truthTableBScore $optimize $nEval $maxCandsPerDeme $minPoolSize $complexityTemperature $itable $nToKeep $capCoef $genCount
;;     ($result (runMoses 20 (mkCscore -0.1 2 0.1 0.1 3) 10 (metaPop2) 0 2
;;                   False    ;; the new arguments for prune-exemplar -- we are saying dont prune the exemplar
;;                   smd      ;; the new arguments for feature selection algo
;;                   (eval (createTruthTableBScore 2 (xortable)))
;;                   hillClimbing
;;                   100 10 20 2
;;                   (xortable)
;;                   10 0.004 1000))
(= (runDemoProblem $seed $maxGen $nDeme $fsAlgo $problem)
   (let*
      (
        ($srp (py-call (random.seed $seed)))
        ($cpxPen 0.004)
        ($truthTableBScore (eval (createTruthTableBScore 2 ($problem))))
        ($worstPossibleScore (worstPossibleScore $truthTableBScore))
        ($bestPosssibleCscore (getBestPossibleCscore $cpxPen $problem))
        ($metaPop (ConsOS (mkExemplar (mkTree (mkNode AND) Nil) (mkDemeId "1") $bestPosssibleCscore $worstPossibleScore) NilOS))
        ($result (runMoses $maxGen (mkCscore -0.1 2 0.1 0.1 3) 3 $metaPop 0 $nDeme
              False    ;; the new arguments for prune-exemplar -- we are saying dont prune the exemplar
              $fsAlgo      ;; the new arguments for feature selection algo
              $truthTableBScore
              hillClimbing
              100 10 20 2
              ($problem)
              10 $cpxPen 1000))
        ($_ (println! (Result: $result)))
        ($newR (eval (osToExpression (mapG cleanedExemplar $result) ())))
      )
      (FinalResult $newR)))


