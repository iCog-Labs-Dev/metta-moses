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
;; Route by CONFIGURATION: an ACTION run is configured iff (param
;; fitness) is non-empty (set via --fitness=<fn> or an in-script
;; set-param); a TABLE run is configured iff a demo `problem` symbol or a
;; CSV `inputFile` was supplied. Exactly one of the two must hold:
;;   both    -> loud error + help (no silent precedence)
;;   neither -> help
;;   action  -> (moses-run-action)   table -> (moses-run)
(= (moses)
   (let* (($actionConfigured (not (== (param fitness) ())))
          ($tableConfigured  (not (and (== (param problem)   ())
                                       (== (param inputFile) "")))))
     (if (and $actionConfigured $tableConfigured)
         (both-configured-error-and-exit)
         (if $actionConfigured
             (moses-run-action)
             (if $tableConfigured
                 (moses-run)
                 (no-problem-help-and-exit))))))

;; Shown when BOTH an action fitness and a table problem are configured:
;; there is no meaningful precedence between them, so the run refuses loudly
;; instead of silently picking one.
(= (both-configured-error-and-exit)
   (let*
      (
        ($_ (println! ""))
        ($_ (println! "Error: both an action fitness and a table problem are configured; unset one."))
        ($_ (println! "  action route: --fitness=<fn>   (or !(set-param fitness <fn>))"))
        ($_ (println! "  table route:  --problem=<name> / --inputFile=<csv>"))
        ($_ (print-help-and-exit))
      )
      ()))

;; Shown when (moses) is invoked with neither a table problem (--problem= /
;; --inputFile=) nor an action fitness (--fitness=). Falls through to
;; the standard --help dump so the user sees every knob and value.
(= (no-problem-help-and-exit)
   (let*
      (
        ($_ (println! ""))
        ($_ (println! "No problem specified."))
        ($_ (println! "For a boolean table run, pass --problem=<name>, e.g.:"))
        ($_ (println! "    sh run.sh moses.metta -s --problem=parity3"))
        ($_ (println! "or programmatically:  !(set-param problem parity3)"))
        ($_ (println! "For an action run, bind a fitness function instead:"))
        ($_ (println! "    --fitness=tttActionFitness  (or !(set-param fitness <fn>))"))
        ($_ (println! "plus the vocabulary params -- see parameters/defaults.metta."))
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
        ;; Termination target: (getBestPossibleScore)'s hardcoded 0 (a
        ;; clean table classified perfectly) unless (param bestScore)
        ;; carries an explicit NUMBER override -- the table-run half of
        ;; the bestScore contract (the action runner below treats the
        ;; same param as a function symbol; see parameters/defaults.metta).
        ($bsParam (param bestScore))
        ($bestPosssibleScore (if (== (get-type $bsParam) Number)
                                 $bsParam
                                 (getBestPossibleScore)))
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

;; Action runner, modeled on moses-run above. The experiment's fitness
;; arrives through the global params ((param fitness) consumed inside
;; scoring/action-score; (param bestScore) consumed here). The metapop
;; seed is the empty and_seq exemplar (the action analog of moses-run's
;; `true` tree) at the defined-worst score: every one of the $nTrials
;; episodes forfeits at -1.0 (see the empty-exemplar loophole note in the
;; episode runner), so raw score = complexity-penalized score = -1.0*nTrials.
(= (moses-run-action)
   (let*
      (
        ;; Refuse loudly when the knob vocabulary is missing: with an empty
        ;; actions every deme is knobless, so the run would print its
        ;; generations and silently produce no result. perceptions MAY
        ;; legitimately be (): an experiment with no perceptions builds
        ;; action-only knobs (sampleActionPerms returns the bare action
        ;; list, representation/build-action.metta:18-21), so only
        ;; actions is mandatory. The error path halts the process.
        ($_vocabGuard (if (== (param actions) ())
                          (missing-action-vocab-error-and-exit)
                          ()))
        ($seed     (param seed))
        ($maxGen   (param maxGen))
        ($nDeme    (param nDeme))
        ($optAlgo  (param optAlgo))
        ($optimizer (optimizer-for $optAlgo))

        ($srp (py-call (random.seed $seed)))
        ;; genCount feeds the cap-size formula inside resizeMetapop (same
        ;; seeding as moses-run).
        ($_  (set-param genCount $maxGen))
        ($cpxPen (param complexityRatio))
        ($nTrials (param nTrials))
        ;; Best reachable raw score is experiment knowledge: the fitness
        ;; package declares it as (param bestScore), a function symbol
        ;; called ($bsFn $nTrials). Collapse-guarded: unset ((), a symbol
        ;; with no clause, a failing call, or a non-Number result -- the
        ;; termination compare needs arithmetic, and e.g. True is Grounded
        ;; but not a Number, so the test is (get-type ...) == Number) ->
        ;; a never-reached target ((pow-math 10 308)), so the run
        ;; terminates via maxGen instead.
        ($bsFn (param bestScore))
        ($bsRs (collapse ($bsFn $nTrials)))
        ($bestPossibleScore
           (if (== $bsRs ())
               (pow-math 10 308)
               (let $bsV (car-atom $bsRs)
                 (if (== (get-type $bsV) Number) $bsV (pow-math 10 308)))))
        ($_ (println! (BestPossibleScore: $bestPossibleScore)))
        ($worst (* -1.0 $nTrials))
        ($metaPop ((mkExemplar (mkTree (mkNode and_seq) ()) (mkDemeId "1") (mkCscore $worst 0 $cpxPen 0 $worst) (mkBScore (List.repeat $nTrials -1.0)))))
        ($result (runMoses $maxGen $bestPossibleScore $metaPop 0 $nDeme
              (mkActionCtx $nTrials $cpxPen)
              $optimizer))
        ($newR (mapG cleanedExemplar $result))
        ($_ (cut)) ;; INFO: Mirrors moses-run; commits choice points before returning.
      )
      (FinalResult $newR)))

;; Shown when an action run is configured (fitness set) but the knob
;; vocabulary is not: same loud-refusal style as
;; both-configured-error-and-exit -- no silent knobless run.
(= (missing-action-vocab-error-and-exit)
   (let*
      (
        ($_ (println! ""))
        ($_ (println! "Error: fitness is configured but actions is unset."))
        ($_ (println! "Without an action vocabulary every deme is knobless and the run produces nothing."))
        ($_ (println! "Bind it in-script before !(moses), quote-wrapped:"))
        ($_ (println! "    !(set-param actions (quote (act1 act2 ...)))"))
        ($_ (println! "(perceptions may stay () -- that builds action-only knobs.)"))
        ($_ (print-help-and-exit))
      )
      ()))

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

