;; ====================================================================
;; Weighted Table Pipeline & ProblemContext Verification Test
;;
;; This test verifies the end-to-end pipeline integration for weighted
;; table compression (CTable) and sample weighting, mirroring classic
;; C++ MOSES behavior:
;;   1. CLI / Parameter handling: (param score-weight)
;;   2. problemContext assembly:
;;      - Compresses raw table with sample weights into (mkCTable ...)
;;      - Strips the weight column from input table via delete_column
;;        so representation knobs and deme expansion ignore weights
;;      - Computes dynamic bestPossibleScore via bestPossibleScore
;;      - Computes dynamic hcScoreImprovedThreshold via minImprove
;;   3. Downstream behavioral scoring: scoreTree & getCscore over CTable
;;   4. Downstream deme transformation & scoring over CTable
;;   5. End-to-end evolutionary pipeline execution via (moses)
;;
;; Classic C++ References:
;;   - moses/moses/main/table-problems.cc#L79-L85, L125-L130
;;   - moses/moses/moses_main.cc#L79-L101
;;   - moses/scoring/bscores.cc#L276-L425
;; ====================================================================

!(import! &self ../../deme/demeSpaceName.py)
!(import! &self ../../moses-imports)

;; --------------------------------------------------------------------
;; Section 1: problemContext Assembly with Weighted Table
;; --------------------------------------------------------------------

!(println! ("--- Verifying problemContext on weightedParity3 ---"))

!(set-param problem weightedParity3)
!(set-param score-weight Weight)
!(set-param complexityRatio 0.2)
!(set-param fsAlgo None)

;; 1.1: Verify the weight column was stripped from the input table
!(let* (
        (($scoringCtx $metaPop $bestPossibleScore) (problemContext))
        (($flag $fsAlgo $ttBScore $cleanTable) $scoringCtx)
        ((mkITable $cleanCols $cleanLabels) $cleanTable)
       )
   (assertEqual $cleanLabels (X1 X2 X3 Out)))

;; 1.2: Verify input table has 4 columns (X1, X2, X3, Out) and no Weight column
!(let* (
        (($scoringCtx $metaPop $bestPossibleScore) (problemContext))
        (($flag $fsAlgo $ttBScore $cleanTable) $scoringCtx)
        ((mkITable $cleanCols $cleanLabels) $cleanTable)
       )
   (assertEqual (List.length $cleanLabels) 4))

;; 1.3: Verify the scoring table is an (mkCTable ...) holding the compressed patterns
!(let* (
        (($scoringCtx $metaPop $bestPossibleScore) (problemContext))
        (($flag $fsAlgo $ttBScore $cleanTable) $scoringCtx)
        ((mkTruthTableBScore $cpxPen $size $scoringTable) $ttBScore)
       )
   (assertEqual (getCTableLabels $scoringTable) (X1 X2 X3 Out)))

!(let* (
        (($scoringCtx $metaPop $bestPossibleScore) (problemContext))
        (($flag $fsAlgo $ttBScore $cleanTable) $scoringCtx)
        ((mkTruthTableBScore $cpxPen $size $scoringTable) $ttBScore)
       )
   (assertEqual (getCTableTotalWeight $scoringTable) 12.0))

;; 1.4: Verify the table size matches 8 unique patterns
!(let* (
        (($scoringCtx $metaPop $bestPossibleScore) (problemContext))
        (($flag $fsAlgo $ttBScore $cleanTable) $scoringCtx)
        ((mkTruthTableBScore $cpxPen $size $scoringTable) $ttBScore)
       )
   (assertEqual $size 8))

;; 1.5: Verify bestPossibleScore is dynamically computed (0 for clean parity)
!(let* (
        (($scoringCtx $metaPop $bestPossibleScore) (problemContext))
       )
   (assertEqual $bestPossibleScore 0))

;; 1.6: Verify hcScoreImprovedThreshold was dynamically set from minImprove (0.5 * 1.0 = 0.5)
!(assertEqual (param hcScoreImprovedThreshold) 0.5)

;; --------------------------------------------------------------------
;; Section 2: Tree Behavioral Scoring over CTable
;; --------------------------------------------------------------------

!(println! ("--- Verifying scoreTree and getCscore over CTable ---"))

;; 2.1: Candidate (AND X1 X2 X3) scored against CTable
!(let* (
        (($scoringCtx $metaPop $bestPossibleScore) (problemContext))
        (($flag $fsAlgo $ttBScore $cleanTable) $scoringCtx)
        ((mkTruthTableBScore $cpxPen $size $ctable) $ttBScore)
        ($_ (resetSubtreeCache))
        ($tree (buildTree (quote (AND X1 X2 X3))))
        ($bScore (scoreTree $ctable $tree &bscoreCache))
       )
   (assertEqual (let (mkBScore $bs) $bScore (List.length $bs)) 8))

!(let* (
        (($scoringCtx $metaPop $bestPossibleScore) (problemContext))
        (($flag $fsAlgo $ttBScore $cleanTable) $scoringCtx)
        ((mkTruthTableBScore $cpxPen $size $ctable) $ttBScore)
        ($_ (resetSubtreeCache))
        ($tree (buildTree (quote (AND X1 X2 X3))))
        ($bScore (scoreTree $ctable $tree &bscoreCache))
       )
   (assertEqual (sumBScore $bScore) -4.0))

;; 2.2: Verify getCscore over CTable
!(let* (
        (($scoringCtx $metaPop $bestPossibleScore) (problemContext))
        (($flag $fsAlgo $ttBScore $cleanTable) $scoringCtx)
        ((mkTruthTableBScore $cpxPen $size $ctable) $ttBScore)
        ($_ (resetSubtreeCache))
        ($tree (buildTree (quote (AND X1 X2 X3))))
        ($cScore (getCscore $ctable $tree $cpxPen &bscoreCache))
        ((mkCscore $score $cpx $cpxP $divP $cScoreVal) $cScore)
       )
   (assertEqual $score -4.0))

;; --------------------------------------------------------------------
;; Section 3: Downstream Deme Scoring with CTable
;; --------------------------------------------------------------------

!(println! ("--- Verifying Deme Scoring over CTable ---"))

;; Verify applyComplexityBasedScore correctly handles (mkCTable ...)
!(let* (
        (($scoringCtx $metaPop $bestPossibleScore) (problemContext))
        (($flag $fsAlgo $ttBScore $cleanTable) $scoringCtx)
        ((mkTruthTableBScore $cpxPen $size $ctable) $ttBScore)
        ($rep (mkRep (mkKbMap (mkDscMp ())) (buildTree (quote (AND X1 X2 X3)))))
        ($inst (mkInst ()))
        ($scored (applyComplexityBasedScore $rep (mkDemeId "1") (cons $inst ()) $ctable $cpxPen))
        ((mkSInst (mkPair $resInst (mkCscore $s $c $cp $dp $cs))) (car-atom $scored))
       )
   (assertEqual $s -4.0))

;; --------------------------------------------------------------------
;; Section 4: End-to-End MOSES Pipeline Run on Weighted Table
;; --------------------------------------------------------------------

!(println! ("--- Verifying End-to-End (moses) on weightedParity3 ---"))

!(set-param seed 0)
!(set-param maxGen 2)
!(set-param nEval 50)
!(set-param nDeme 1)
!(set-param complexityRatio 3.5)
!(set-param fsAlgo None)
!(set-param optAlgo hc)

;; 4.1: Run moses end-to-end and extract the top evolved candidate program and returned score
;; 4.2: Independently recompute the candidate's score against the CTable and assert exact match
!(let* (
        ((($flag $fsAlgo $ttBScore $cleanTable) $metaPop $bestPossibleScore) (problemContext))
        ((mkTruthTableBScore $cpxPen $size $ctable) $ttBScore)
        ($result (moses))
        ($topCandidate (index-atom (second $result) 0))
        ($progExpr (car-atom $topCandidate))
        ($_ (println! ("returned program was: " $progExpr)))
        ($returnedScore (second $topCandidate))
        ($_ (resetSubtreeCache))
        ($tree (buildTree $progExpr))
        ($recomputedBScore (scoreTree $ctable $tree &bscoreCache))
        ($recomputedSum (sumBScore $recomputedBScore))
       )
   (assertEqual $returnedScore $recomputedSum))

!(println! ("All weighted table pipeline tests completed successfully!"))
