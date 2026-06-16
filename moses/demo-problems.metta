;; 3-Bit Parity: Output is True if the number of True inputs is odd. Labels: X1, X2, X3, Out
;; Example: (XOR X1 X2 X3) => (OR (AND A (NOT B) (NOT C)) (AND (NOT A) B (NOT C)) (AND (NOT A) (NOT B) C) (AND A B C))
(= (parity3) (mkITable
    (cons (cons False (cons False (cons False (cons False ()))))
    (cons (cons False (cons False (cons True  (cons True  ()))))
    (cons (cons False (cons True  (cons False (cons True  ()))))
    (cons (cons False (cons True  (cons True  (cons False ()))))
    (cons (cons True  (cons False (cons False (cons True  ()))))
    (cons (cons True  (cons False (cons True  (cons False ()))))
    (cons (cons True  (cons True  (cons False (cons False ()))))
    (cons (cons True  (cons True  (cons True  (cons True  ())))) ()))))))))
    
    (cons X1 (cons X2 (cons X3 (cons Out ()))))))

;; Example: (XOR X1 X2 X3 X4) => (OR (AND A (NOT B) (NOT C) (NOT D)) (AND (NOT A) B (NOT C) (NOT D)) (AND (NOT A) (NOT B) C (NOT D)) (AND (NOT A) (NOT B) (NOT C) D) (AND (NOT A) B C D) (AND A (NOT B) C D) (AND A B (NOT C) D) (AND A B C (NOT D)))
(= (parity4) (mkITable
   (cons (cons False (cons False (cons False (cons False (cons False ())))))
   (cons (cons False (cons False (cons False (cons True (cons True ())))))
   (cons (cons False (cons False (cons True (cons False (cons True ())))))
   (cons (cons False (cons False (cons True (cons True (cons False ())))))
   (cons (cons False (cons True (cons False (cons False (cons True ())))))
   (cons (cons False (cons True (cons False (cons True (cons False ())))))
   (cons (cons False (cons True (cons True (cons False (cons False ())))))
   (cons (cons False (cons True (cons True (cons True (cons True ())))))
   (cons (cons True (cons False (cons False (cons False (cons True ())))))
   (cons (cons True (cons False (cons False (cons True (cons False ())))))
   (cons (cons True (cons False (cons True (cons False (cons False ())))))
   (cons (cons True (cons False (cons True (cons True (cons True ())))))
   (cons (cons True (cons True (cons False (cons False (cons False ())))))
   (cons (cons True (cons True (cons False (cons True (cons True ())))))
   (cons (cons True (cons True (cons True (cons False (cons True ())))))
   (cons (cons True (cons True (cons True (cons True (cons False ()))))) ()))))))))))))))))
   (cons X1 (cons X2 (cons X3 (cons X4 (cons Out ())))))))

;; Logic: Output is 1 if any input is 1
;; Example: (OR X1 X2 X3)
(= (disjunction3) (mkITable
   (cons (cons False (cons False (cons False (cons False ()))))
   (cons (cons False (cons False (cons True  (cons True  ()))))
   (cons (cons False (cons True  (cons False (cons True  ()))))
   (cons (cons False (cons True  (cons True  (cons True  ()))))
   (cons (cons True  (cons False (cons False (cons True  ()))))
   (cons (cons True  (cons False (cons True  (cons True  ()))))
   (cons (cons True  (cons True  (cons False (cons True  ()))))
   (cons (cons True  (cons True  (cons True  (cons True  ())))) ()))))))))

   (cons X1 (cons X2 (cons X3 (cons Out ()))))))



;; 3-Bit Majority: Output is True if more than half (2 or 3) inputs are True. Labels: A, B, C, Out
;; Example: (OR (AND A B) (AND A C) (AND B C))
(= (majority3) (mkITable
    (cons (cons False (cons False (cons False (cons False ()))))
    (cons (cons False (cons False (cons True  (cons False ()))))
    (cons (cons False (cons True  (cons False (cons False ()))))
    (cons (cons False (cons True  (cons True  (cons True  ()))))
    (cons (cons True  (cons False (cons False (cons False ()))))
    (cons (cons True  (cons False (cons True  (cons True  ()))))
    (cons (cons True  (cons True  (cons False (cons True  ()))))
    (cons (cons True  (cons True  (cons True  (cons True  ())))) ()))))))))
    
    (cons A (cons B (cons C (cons Out ()))))))

;;Example: (OR (AND X1 X2 X3) (AND X1 X2 X4) (AND X1 X2 X5) (AND X1 X3 X4) (AND X1 X3 X5) (AND X1 X4 X5) (AND X2 X3 X4) (AND X2 X3 X5) (AND X2 X4 X5) (AND X3 X4 X5))
(= (majority5) (mkITable
   (cons (cons False (cons False (cons False (cons False (cons False (cons False ()))))))
   (cons (cons False (cons False (cons False (cons False (cons True (cons False ()))))))
   (cons (cons False (cons False (cons False (cons True (cons False (cons False ()))))))
   (cons (cons False (cons False (cons False (cons True (cons True (cons False ()))))))
   (cons (cons False (cons False (cons True (cons False (cons False (cons False ()))))))
   (cons (cons False (cons False (cons True (cons False (cons True (cons False ()))))))
   (cons (cons False (cons False (cons True (cons True (cons False (cons False ()))))))
   (cons (cons False (cons False (cons True (cons True (cons True (cons True ()))))))
   (cons (cons False (cons True (cons False (cons False (cons False (cons False ()))))))
   (cons (cons False (cons True (cons False (cons False (cons True (cons False ()))))))
   (cons (cons False (cons True (cons False (cons True (cons False (cons False ()))))))
   (cons (cons False (cons True (cons False (cons True (cons True (cons True ()))))))
   (cons (cons False (cons True (cons True (cons False (cons False (cons False ()))))))
   (cons (cons False (cons True (cons True (cons False (cons True (cons True ()))))))
   (cons (cons False (cons True (cons True (cons True (cons False (cons True ()))))))
   (cons (cons False (cons True (cons True (cons True (cons True (cons True ()))))))
   (cons (cons True (cons False (cons False (cons False (cons False (cons False ()))))))
   (cons (cons True (cons False (cons False (cons False (cons True (cons False ()))))))
   (cons (cons True (cons False (cons False (cons True (cons False (cons False ()))))))
   (cons (cons True (cons False (cons False (cons True (cons True (cons True ()))))))
   (cons (cons True (cons False (cons True (cons False (cons False (cons False ()))))))
   (cons (cons True (cons False (cons True (cons False (cons True (cons True ()))))))
   (cons (cons True (cons False (cons True (cons True (cons False (cons True ()))))))
   (cons (cons True (cons False (cons True (cons True (cons True (cons True ()))))))
   (cons (cons True (cons True (cons False (cons False (cons False (cons False ()))))))
   (cons (cons True (cons True (cons False (cons False (cons True (cons True ()))))))
   (cons (cons True (cons True (cons False (cons True (cons False (cons True ()))))))
   (cons (cons True (cons True (cons False (cons True (cons True (cons True ()))))))
   (cons (cons True (cons True (cons True (cons False (cons False (cons True ()))))))
   (cons (cons True (cons True (cons True (cons False (cons True (cons True ()))))))
   (cons (cons True (cons True (cons True (cons True (cons False (cons True ()))))))
   (cons (cons True (cons True (cons True (cons True (cons True (cons True ())))))) ()))))))))))))))))))))))))))))))))
   (cons X1 (cons X2 (cons X3 (cons X4 (cons X5 (cons Out ()))))))))

;; 3-Bit Multiplexer: - Input 1 is Address (Addr)
;;                    - Input 2 is Data 0 (D0)
;;                    - Input 3 is Data 1 (D1)
;;                  If Addr is False, Output is D0. If Addr is True, Output is D1.
;; Example: (OR (AND (NOT Addr) D0)  ;; The "Else" case (Address is 0)
;;              (AND Addr D1))        ; The "Then" case (Address is 1)
(= (mux3) (mkITable
    (cons (cons False (cons False (cons False (cons False ()))))  ; A=0, D0=0 -> 0
    (cons (cons False (cons False (cons True  (cons False ()))))  ; A=0, D0=0 -> 0
    (cons (cons False (cons True  (cons False (cons True  ()))))  ; A=0, D0=1 -> 1
    (cons (cons False (cons True  (cons True  (cons True  ()))))  ; A=0, D0=1 -> 1
    (cons (cons True  (cons False (cons False (cons False ()))))  ; A=1, D1=0 -> 0
    (cons (cons True  (cons False (cons True  (cons True  ()))))  ; A=1, D1=1 -> 1
    (cons (cons True  (cons True  (cons False (cons False ()))))  ; A=1, D1=0 -> 0
    (cons (cons True  (cons True  (cons True  (cons True  ())))) ()))))))))

    (cons Addr (cons D0 (cons D1 (cons Out ()))))))

;; Two bits (A0, A1) decide which of the four data bits (D0..D3) passes through.
;; Example: (OR
;;              (AND (NOT A0) (AND (NOT A1) D0))  ;; Address 00 -> D0
;;              (AND (NOT A0) A1 D1)              ;; Address 01 -> D1
;;              (AND A0 (NOT A1) D2)              ;; Address 10 -> D2
;;              (AND A0 A1 D3))                   ;; Address 11 -> D3
(= (mux6) (mkITable
   (cons (cons False (cons False (cons False (cons False (cons False (cons False (cons False ())))))))
   (cons (cons False (cons False (cons False (cons False (cons False (cons True (cons False ())))))))
   (cons (cons False (cons False (cons False (cons False (cons True (cons False (cons False ())))))))
   (cons (cons False (cons False (cons False (cons False (cons True (cons True (cons False ())))))))
   (cons (cons False (cons False (cons False (cons True (cons False (cons False (cons False ())))))))
   (cons (cons False (cons False (cons False (cons True (cons False (cons True (cons False ())))))))
   (cons (cons False (cons False (cons False (cons True (cons True (cons False (cons False ())))))))
   (cons (cons False (cons False (cons False (cons True (cons True (cons True (cons False ())))))))
   (cons (cons False (cons False (cons True (cons False (cons False (cons False (cons True ())))))))
   (cons (cons False (cons False (cons True (cons False (cons False (cons True (cons True ())))))))
   (cons (cons False (cons False (cons True (cons False (cons True (cons False (cons True ())))))))
   (cons (cons False (cons False (cons True (cons False (cons True (cons True (cons True ())))))))
   (cons (cons False (cons False (cons True (cons True (cons False (cons False (cons True ())))))))
   (cons (cons False (cons False (cons True (cons True (cons False (cons True (cons True ())))))))
   (cons (cons False (cons False (cons True (cons True (cons True (cons False (cons True ())))))))
   (cons (cons False (cons False (cons True (cons True (cons True (cons True (cons True ())))))))
   (cons (cons False (cons True (cons False (cons False (cons False (cons False (cons False ())))))))
   (cons (cons False (cons True (cons False (cons False (cons False (cons True (cons False ())))))))
   (cons (cons False (cons True (cons False (cons False (cons True (cons False (cons False ())))))))
   (cons (cons False (cons True (cons False (cons False (cons True (cons True (cons False ())))))))
   (cons (cons False (cons True (cons False (cons True (cons False (cons False (cons True ())))))))
   (cons (cons False (cons True (cons False (cons True (cons False (cons True (cons True ())))))))
   (cons (cons False (cons True (cons False (cons True (cons True (cons False (cons True ())))))))
   (cons (cons False (cons True (cons False (cons True (cons True (cons True (cons True ())))))))
   (cons (cons False (cons True (cons True (cons False (cons False (cons False (cons False ())))))))
   (cons (cons False (cons True (cons True (cons False (cons False (cons True (cons False ())))))))
   (cons (cons False (cons True (cons True (cons False (cons True (cons False (cons False ())))))))
   (cons (cons False (cons True (cons True (cons False (cons True (cons True (cons False ())))))))
   (cons (cons False (cons True (cons True (cons True (cons False (cons False (cons True ())))))))
   (cons (cons False (cons True (cons True (cons True (cons False (cons True (cons True ())))))))
   (cons (cons False (cons True (cons True (cons True (cons True (cons False (cons True ())))))))
   (cons (cons False (cons True (cons True (cons True (cons True (cons True (cons True ())))))))
   (cons (cons True (cons False (cons False (cons False (cons False (cons False (cons False ())))))))
   (cons (cons True (cons False (cons False (cons False (cons False (cons True (cons False ())))))))
   (cons (cons True (cons False (cons False (cons False (cons True (cons False (cons True ())))))))
   (cons (cons True (cons False (cons False (cons False (cons True (cons True (cons True ())))))))
   (cons (cons True (cons False (cons False (cons True (cons False (cons False (cons False ())))))))
   (cons (cons True (cons False (cons False (cons True (cons False (cons True (cons False ())))))))
   (cons (cons True (cons False (cons False (cons True (cons True (cons False (cons True ())))))))
   (cons (cons True (cons False (cons False (cons True (cons True (cons True (cons True ())))))))
   (cons (cons True (cons False (cons True (cons False (cons False (cons False (cons False ())))))))
   (cons (cons True (cons False (cons True (cons False (cons False (cons True (cons False ())))))))
   (cons (cons True (cons False (cons True (cons False (cons True (cons False (cons True ())))))))
   (cons (cons True (cons False (cons True (cons False (cons True (cons True (cons True ())))))))
   (cons (cons True (cons False (cons True (cons True (cons False (cons False (cons False ())))))))
   (cons (cons True (cons False (cons True (cons True (cons False (cons True (cons False ())))))))
   (cons (cons True (cons False (cons True (cons True (cons True (cons False (cons True ())))))))
   (cons (cons True (cons False (cons True (cons True (cons True (cons True (cons True ())))))))
   (cons (cons True (cons True (cons False (cons False (cons False (cons False (cons False ())))))))
   (cons (cons True (cons True (cons False (cons False (cons False (cons True (cons True ())))))))
   (cons (cons True (cons True (cons False (cons False (cons True (cons False (cons False ())))))))
   (cons (cons True (cons True (cons False (cons False (cons True (cons True (cons True ())))))))
   (cons (cons True (cons True (cons False (cons True (cons False (cons False (cons False ())))))))
   (cons (cons True (cons True (cons False (cons True (cons False (cons True (cons True ())))))))
   (cons (cons True (cons True (cons False (cons True (cons True (cons False (cons False ())))))))
   (cons (cons True (cons True (cons False (cons True (cons True (cons True (cons True ())))))))
   (cons (cons True (cons True (cons True (cons False (cons False (cons False (cons False ())))))))
   (cons (cons True (cons True (cons True (cons False (cons False (cons True (cons True ())))))))
   (cons (cons True (cons True (cons True (cons False (cons True (cons False (cons False ())))))))
   (cons (cons True (cons True (cons True (cons False (cons True (cons True (cons True ())))))))
   (cons (cons True (cons True (cons True (cons True (cons False (cons False (cons False ())))))))
   (cons (cons True (cons True (cons True (cons True (cons False (cons True (cons True ())))))))
   (cons (cons True (cons True (cons True (cons True (cons True (cons False (cons False ())))))))
   (cons (cons True (cons True (cons True (cons True (cons True (cons True (cons True ()))))))) ()))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
   (cons A0 (cons A1 (cons D0 (cons D1 (cons D2 (cons D3 (cons Out ())))))))))


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
      (updatePenalizedScore (mkCscore 0 $bestCpx (* (getComplexityCoef $cpxPen) $bestCpx) 0.0 (* -1 (pow-math 10 308))) False))
   )

;; runMoses (after the hyperparameter-registry migration) takes:
;;   $maxGen $maxScore $metaPop $nExpansion $nDeme $context $optimize
;; All other knobs (maxCandOutput, nEval, maxCandPerDeme, minPoolSize,
;; complexityTemperature, nToKeep, capCoef, genCount) are read from
;; &params via (param ...). Seed them via (set-param ...) or via
;; --name=value flags handled by parameters/cli.metta.
;;     ($result (runMoses 20 (mkCscore -0.1 2 0.1 0.1 3) 10 (metaPop2) 0 2
;;                   False    ;; the new arguments for prune-exemplar -- we are saying dont prune the exemplar
;;                   smd      ;; the new arguments for feature selection algo
;;                   (createTruthTableBScore 2 (xortable))
;;                   hillClimbing
;;                   100 10 20 2
;;                   (xortable)
;;                   10 0.004 1000))
;; ============================================================
;;  Top-level MOSES entry point.
;;
;;  After the hyperparameter-registry migration, everything that
;;  used to be a positional argument is sourced from &params. The
;;  user-facing entry point is therefore zero-argument:
;;
;;      !(moses)
;;
;;  Override any knob from the command line:
;;
;;      sh run.sh runner.metta -s \
;;          --problem=parity3 --maxGen=20 --nDeme=2 \
;;          --fsAlgo=smd --optAlgo=hc --capCoef=80
;;
;;  Inspect every recognized knob:
;;
;;      sh run.sh runner.metta -s --help
;; ============================================================
(= (moses)
   (if (== (param problem) ())
       (no-problem-help-and-exit)
       (moses-run)))

;; Shown when (moses) is invoked without --problem= on the command line
;; and without an in-script (set-param problem ...). Falls through to the
;; standard --help dump so the user sees every knob and value.
(= (no-problem-help-and-exit)
   (let*
      (
        ($_   (println! ""))
        ($__  (println! "No problem specified."))
        ($___ (println! "Pass --problem=<name> on the command line, e.g.:"))
        ($____ (println! "    sh run.sh runner.metta -s --problem=parity3"))
        ($_____ (println! "or programmatically:  !(set-param problem parity3)"))
        ($______ (print-help-and-exit))
      )
      halt-not-reached))

(= (moses-run)
   (let*
      (
        ;; Pull every input from the registry up-front so the body
        ;; reads like the historical runDemoProblem.
        ($seed     (param seed))
        ($maxGen   (param maxGen))
        ($nDeme    (param nDeme))
        ($fsAlgo   (param fsAlgo))
        ($optAlgo  (param optAlgo))
        ($problem  (param problem))
        ($optimizer (optimizer-for $optAlgo))

        ($srp (py-call (random.seed $seed)))
        ;; genCount feeds the cap-size formula inside resizeMetapop; it
        ;; is conceptually the initial $maxGen and stays constant across
        ;; the recursion, so we seed it once here.
        ($_  (set-param genCount $maxGen))
        ($cpxPen (param complexityRatio))
        ($truthTableBScore (createTruthTableBScore $cpxPen ($problem)))
        (($ctor $worstPossibleBScore) (worstPossibleScore $truthTableBScore))
        ($worstPossibleScore (List.sum $worstPossibleBScore))
        ($bestPosssibleCscore (getBestPossibleCscore $cpxPen $problem))
        ($__ (println! (BestPossibleScore: $bestPosssibleCscore)))
        ($metaPop ((mkExemplar (mkTree (mkNode true) ()) (mkDemeId "1") (mkCscore $worstPossibleScore 0 $cpxPen 0 $worstPossibleScore) ($ctor $worstPossibleBScore))))
        ($result (runMoses $maxGen $bestPosssibleCscore $metaPop 0 $nDeme
              (False $fsAlgo $truthTableBScore ($problem))
              $optimizer))
        ($___ (println! (Result: $result)))
        ($newR (mapG cleanedExemplar $result))
        ($____ (cut)) ;; INFO: This gives few extra seconds performance gain. Do not remove.
      )
      (FinalResult $newR)))

;; Maps the optAlgo symbol to the concrete optimizer function used by
;; runMoses. Only hill climbing is integration-tested today; the SA and
;; univariate implementations under optimization/ exist but have never
;; been wired into the deme-expansion path. Add a clause here when a new
;; algorithm becomes ready.
(= (optimizer-for hc) hillClimbing)
(= (optimizer-for $other)
   (let*
      (
        ($_   (println! ""))
        ($__  (println! (Error: unsupported optAlgo $other)))
        ($___ (println! "Recognized optAlgo values: hc"))
        ($____ (println! "(simulated annealing and univariate exist in the tree but are not integration-tested.)"))
        ($_____ (callPredicate (Predicate (halt 1))))
      )
      halt-not-reached))

;; Backward-compat shim. Existing test_moses.py templates substitute
;; placeholders into a (runDemoProblem $seed $maxGen $nDeme $fsAlgo $problem)
;; call; we keep that signature working by writing the arguments into
;; &params and then dispatching to (moses).
(= (runDemoProblem $seed $maxGen $nDeme $fsAlgo $problem)
   (let*
      (
        ($_1 (set-param seed    $seed))
        ($_2 (set-param maxGen  $maxGen))
        ($_3 (set-param nDeme   $nDeme))
        ($_4 (set-param fsAlgo  $fsAlgo))
        ($_5 (set-param problem $problem))
      )
      (moses)))

