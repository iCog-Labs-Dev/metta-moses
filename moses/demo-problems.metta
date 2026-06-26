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


;; Matches classic MOSES: best_possible_score() for `logical_bscore`/clean
;; boolean truth tables is just 0 (sum of zeros, one zero per row -- no
;; misclassifications). The complexity-penalty business is per-candidate,
;; not part of the termination target. CSV input takes the same code
;; path; if the table is noisy (duplicate input rows with conflicting
;; targets), 0 will be unreachable and the algorithm will instead
;; terminate via `maxGen`.
(= (getBestPossibleScore) 0)

;; Return the ITable to evolve against. If --inputFile is set, load it from
;; a CSV via the Python helper; otherwise dispatch to the demo problem
;; function whose name is in (param problem).
(= (resolve-itable)
   (if (== (param inputFile) "")
       (let $p (param problem) ($p))
       (let $sexpr (py-call (csv_helper.load_boolean_table (param inputFile) (param targetFeature)))
            (parse $sexpr))))

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
;;  Zero-argument entry point:
;;
;;      !(moses)
;;
;;  Override any knob from the command line:
;;
;;      sh run.sh moses.metta -s \
;;          --problem=parity3 --maxGen=20 --nDeme=2 \
;;          --fsAlgo=smd --optAlgo=hc --capCoef=80
;;
;;  Inspect every recognized knob:
;;
;;      sh run.sh moses.metta -s --help
;; ============================================================
;; Run unless the user supplied neither a demo `problem` symbol nor a CSV
;; `inputFile`. Either is enough to know what to evolve against.
(= (moses)
   (if (and (== (param problem)   ())
            (== (param inputFile) ""))
       (no-problem-help-and-exit)
       (moses-run)))

;; Shown when (moses) is invoked without --problem= on the command line
;; and without an in-script (set-param problem ...). Falls through to the
;; standard --help dump so the user sees every knob and value.
(= (no-problem-help-and-exit)
   (let*
      (
        ($_ (println! ""))
        ($_ (println! "No problem specified."))
        ($_ (println! "Pass --problem=<name> on the command line, e.g.:"))
        ($_ (println! "    sh run.sh moses.metta -s --problem=parity3"))
        ($_ (println! "or programmatically:  !(set-param problem parity3)"))
        ($_ (print-help-and-exit))
      )
      ()))

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
        ;; Resolve the input table once: a CSV the user passed via
        ;; --inputFile, otherwise the demo problem named by `problem`.
        ($itable (resolve-itable))
        ($truthTableBScore (createTruthTableBScore $cpxPen $itable))
        (($ctor $worstPossibleBScore) (worstPossibleScore $truthTableBScore))
        ($worstPossibleScore (List.sum $worstPossibleBScore))
        ($bestPosssibleScore (getBestPossibleScore))
        ($_ (println! (BestPossibleScore: $bestPosssibleScore)))
        ($metaPop ((mkExemplar (mkTree (mkNode true) ()) (mkDemeId "1") (mkCscore $worstPossibleScore 0 $cpxPen 0 $worstPossibleScore) ($ctor $worstPossibleBScore))))
        ($result (runMoses $maxGen $bestPosssibleScore $metaPop 0 $nDeme
              (False $fsAlgo $truthTableBScore $itable)
              $optimizer))
        ;; ($_ (println! (Result: $result)))
        ($newR (mapG cleanedExemplar $result))
        ($_ (cut)) ;; INFO: This gives few extra seconds performance gain. Do not remove.
      )
      (FinalResult $newR)))

;; Maps the optAlgo symbol to the concrete optimizer function used by
;; runMoses. Only hill climbing is integration-tested today; the SA and
;; univariate implementations under optimization/ exist but have never
;; been wired into the deme-expansion path. Add a clause here when a new
;; algorithm becomes ready.
(= (optimizer-for hc)
     (case $optimizer
          (
            (hc hillClimbing)
            ;; (sa simulated-annealing)
            ($other (let*
                      (
                        ($_ (println! ""))
                        ($_ (println! (Error: unsupported optAlgo $other)))
                        ($_ (println! "Recognized optAlgo values: hc"))
                        ($_ (println! "(simulated annealing and univariate exist in the tree but are not integration-tested.)"))
                        ($_ (callPredicate (Predicate (halt 1))))
                      )
                      ())))))

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

