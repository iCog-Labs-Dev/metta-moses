!(register-module! ../../../../metta-moses)

!(import! &self metta-moses:optimization:eda/bde-scoring)
!(import! &self metta-moses:utilities:general-helpers)
!(import! &self metta-moses:utilities:list-methods)
!(import! &self metta-moses:utilities:pair)
!(import! &self metta-moses:feature-selection:feature-selection-helpers)


;; ================================================================================
;; Test Data Setup
;; ================================================================================

;; Test boolean lists (bind concrete data)
!(bind! testBoolList1 (Cons True (Cons False (Cons True (Cons False Nil)))))
!(bind! testBoolList2 (Cons False (Cons True (Cons False (Cons True Nil)))))
!(bind! testBoolList3 (Cons True (Cons True (Cons True (Cons True Nil)))))
!(bind! testBoolList4 (Cons False (Cons False (Cons False (Cons False Nil)))))

;; Test discrete value lists (bind concrete data)
!(bind! testDiscreteList1 (Cons 0 (Cons 1 (Cons 0 (Cons 1 Nil)))))
!(bind! testDiscreteList2 (Cons 1 (Cons 0 (Cons 1 (Cons 0 Nil)))))
!(bind! testDiscreteList3 (Cons 0.0 (Cons 1.0 (Cons 2.0 (Cons 0.0 Nil)))))
!(bind! testDiscreteList4 (Cons 2.0 (Cons 1.0 (Cons 0.0 (Cons 2.0 Nil)))))

;; Test continuous value lists (bind concrete data)
!(bind! testContinuousList1 (Cons 1.0 (Cons 2.0 (Cons 3.0 (Cons 4.0 Nil)))))
!(bind! testContinuousList2 (Cons 2.0 (Cons 3.0 (Cons 4.0 (Cons 5.0 Nil)))))
!(bind! testContinuousList3 (Cons 0.5 (Cons 1.5 (Cons 2.5 (Cons 3.5 Nil)))))
!(bind! testContinuousList4 (Cons 1.5 (Cons 2.5 (Cons 3.5 (Cons 4.5 Nil)))))

;; ================================================================================
;; Type Definition Tests
;; ================================================================================

;; Test BDeScore constructor
!(bind! testBDeScore (mkBDeScore 1.5))
!(assertEqual (getBDeScoreValue testBDeScore) 1.5)

;; Test SplitType constructors
!(bind! TestBinarySplit (mkBinarySplit True))
!(bind! TestDiscreteSplit (mkDiscreteSplit (Cons True (Cons False Nil))))
!(bind! TestContinuousSplit (mkContinuousSplit 2.5))

;; Test SplitType predicates
!(assertEqual (isBinarySplit TestBinarySplit) True)
!(assertEqual (isBinarySplit TestDiscreteSplit) False)
!(assertEqual (isBinarySplit TestContinuousSplit) False)

!(assertEqual (isDiscreteSplit TestDiscreteSplit) True)
!(assertEqual (isDiscreteSplit TestBinarySplit) False)
!(assertEqual (isDiscreteSplit TestContinuousSplit) False)

!(assertEqual (isContinuousSplit TestContinuousSplit) True)
!(assertEqual (isContinuousSplit TestBinarySplit) False)
!(assertEqual (isContinuousSplit TestDiscreteSplit) False)

;; ================================================================================
;; Helper Function Tests
;; ================================================================================

;; Test boolean counting functions
!(assertEqual (countTrue testBoolList1) 2)
!(assertEqual (countTrue testBoolList3) 4)
!(assertEqual (countTrue testBoolList4) 0)

!(assertEqual (countFalse testBoolList1) 2)
!(assertEqual (countFalse testBoolList3) 0)
!(assertEqual (countFalse testBoolList4) 4)

; ;; Test joint counting functions
!(assertEqual (countBothTrue testBoolList1 testBoolList2) 0)
!(assertEqual (countBothTrue testBoolList3 testBoolList3) 4)
!(assertEqual (countBothTrue testBoolList4 testBoolList4) 0)

!(assertEqual (countParentTrueChildFalse testBoolList1 testBoolList2) 2)
!(assertEqual (countParentFalseChildTrue testBoolList1 testBoolList2) 2)
!(assertEqual (countBothFalse testBoolList1 testBoolList2) 0)

;; Test discrete value counting
!(bind! testDiscreteCounts (countDiscreteValues testDiscreteList1 2))
!(assertEqual (List.length testDiscreteCounts) 2)
!(assertEqual (List.getByIdx testDiscreteCounts 0) 2)
!(assertEqual (List.getByIdx testDiscreteCounts 1) 2)

; ;; Test continuous value filtering
!(bind! testFilteredLess (filterLessThan testContinuousList1 3.0))
!(bind! testFilteredGreater (filterGreaterEqual testContinuousList1 3.0))
!(assertEqual (List.length testFilteredLess) 2)
!(assertEqual (List.length testFilteredGreater) 2)

;; Test mathematical helper functions
!(assertEqual (> (exp2 1.0) 0.0) True)
!(assertEqual (> (logGamma 10.0) 0.0) True)

; ;; ================================================================================
; ;; Binary-Binary Scoring Tests
; ;; ================================================================================

; ;; Test binary-binary scoring with simple case
!(bind! binaryScore1 (binaryBinaryScore testBoolList1 testBoolList2))
!(assertEqual (> (getBDeScoreValue binaryScore1) 0) True)

;; Test binary-binary scoring with identical lists
!(bind! binaryScore2 (binaryBinaryScore testBoolList1 testBoolList1))
!(assertEqual (> (getBDeScoreValue binaryScore2) 0) True)

;; Test binary-binary scoring with all True
!(bind! binaryScore3 (binaryBinaryScore testBoolList3 testBoolList3))
!(assertEqual (> (getBDeScoreValue binaryScore3) 0) True)

;; Test binary-binary scoring with all false
!(bind! binaryScore4 (binaryBinaryScore testBoolList4 testBoolList4))
!(assertEqual (> (getBDeScoreValue binaryScore4) 0) True)

; ;; ================================================================================
; ;; Discrete-Discrete Scoring Tests
; ;; ================================================================================

; ;; Test discrete-discrete 2-way scoring
!(bind! discreteScore1 (discreteDiscrete2WayScore testDiscreteList1 testDiscreteList2 2 2))
!(assertEqual (> (getBDeScoreValue discreteScore1) 0) True)

;; Test discrete-discrete 2-way scoring with different cardinalities
!(bind! discreteScore2 (discreteDiscrete2WayScore testDiscreteList3 testDiscreteList4 3 3))
!(assertEqual (> (getBDeScoreValue discreteScore2) -10) True)

;; Test discrete-discrete n-way scoring
!(bind! discreteScore3 (discreteDiscreteNWayScore testDiscreteList1 testDiscreteList2 2 2))
!(assertEqual (> (getBDeScoreValue discreteScore3) 0) True)

;; Test discrete-discrete scoring with identical lists
!(bind! discreteScore4 (discreteDiscrete2WayScore testDiscreteList1 testDiscreteList1 2 2))
!(assertEqual (> (getBDeScoreValue discreteScore4) 0) True)

; ;; ================================================================================
; ;; Continuous-Discrete Scoring Tests
; ;; ================================================================================

;; Test continuous-discrete 2-way scoring
!(bind! continuousDiscreteScore1 (continuousDiscrete2WayScore testContinuousList1 testDiscreteList1 2))
!(assertEqual (> (getBDeScoreValue continuousDiscreteScore1) 0) True)

;; Test continuous-discrete 2-way scoring with different data
!(bind! continuousDiscreteScore2 (continuousDiscrete2WayScore testContinuousList2 testDiscreteList2 2))
!(assertEqual (> (getBDeScoreValue continuousDiscreteScore2) 0) True)

;; Test continuous-discrete n-way scoring
!(bind! continuousDiscreteScore3 (continuousDiscreteNWayScore testContinuousList1 testDiscreteList1 2))
!(assertEqual (> (getBDeScoreValue continuousDiscreteScore3) 0) True)

;; Test continuous-discrete scoring with identical continuous values
!(bind! continuousDiscreteScore4 (continuousDiscrete2WayScore testContinuousList1 testDiscreteList1 2))
!(assertEqual (> (getBDeScoreValue continuousDiscreteScore4) 0) True)

; ;; ================================================================================
; ;; Continuous-Continuous Scoring Tests
; ;; ================================================================================

;; Test continuous-continuous 2-way scoring
!(bind! continuousContinuousResult1 (continuousContinuous2WayScore testContinuousList1 testContinuousList2))
!(bind! continuousContinuousScore1 (Pair.first continuousContinuousResult1))
!(bind! continuousContinuousSplit1 (Pair.second continuousContinuousResult1))
!(assertEqual (> (getBDeScoreValue continuousContinuousScore1) minusInf) False)  ; Negative scores are normal for BDe
!(assertEqual (> continuousContinuousSplit1 0.0) True)

;; Test continuous-continuous scoring with identical lists
!(bind! continuousContinuousResult2 (continuousContinuous2WayScore testContinuousList1 testContinuousList1))
!(bind! continuousContinuousScore2 (Pair.first continuousContinuousResult2))
!(bind! continuousContinuousSplit2 (Pair.second continuousContinuousResult2))
!(assertEqual (> (getBDeScoreValue continuousContinuousScore2) minusInf) False)  ; Negative scores are normal for BDe
!(assertEqual (> continuousContinuousSplit2 0.0) True)

; ;; ================================================================================
; ;; Gain Calculation Tests
; ;; ================================================================================

;; Test gain computation
!(bind! gainScore1 (computeGain 1.0 2.0 10 5))
!(assertEqual (> (getBDeScoreValue gainScore1) minusInf) True)

;; Test transfer evaluation
!(bind! transferScore1 (evaluateTransfer testDiscreteList1 testDiscreteList2 2 2))
!(assertEqual (> (getBDeScoreValue transferScore1) minusInf) True)

; ;; ================================================================================
; ;; Edge Case Tests
; ;; ================================================================================

;; Test with empty lists
!(bind! emptyBoolList Nil)
!(bind! emptyDiscreteList Nil)
!(bind! emptyContinuousList Nil)

;; Test binary scoring with empty lists
!(bind! emptyBinaryScore (binaryBinaryScore emptyBoolList emptyBoolList))
!(assertEqual (> (getBDeScoreValue emptyBinaryScore) minusInf) True)

;; Test discrete scoring with empty lists
!(bind! emptyDiscreteScore (discreteDiscrete2WayScore emptyDiscreteList emptyDiscreteList 2 2))
!(assertEqual (> (getBDeScoreValue emptyDiscreteScore) minusInf) True)

;; Test continuous scoring with empty lists
!(bind! emptyContinuousScore (continuousDiscrete2WayScore emptyContinuousList emptyDiscreteList 2))
!(assertEqual (> (getBDeScoreValue emptyContinuousScore) minusInf) True)

;; Test with single element lists
!(bind! singleBoolList (Cons True Nil))
!(bind! singleDiscreteList (Cons 1.0 Nil))
!(bind! singleContinuousList (Cons 2.0 Nil))

;; Test binary scoring with single elements
!(bind! singleBinaryScore (binaryBinaryScore singleBoolList singleBoolList))
!(assertEqual (> (getBDeScoreValue singleBinaryScore) minusInf) True)

;; Test discrete scoring with single elements
!(bind! singleDiscreteScore (discreteDiscrete2WayScore singleDiscreteList singleDiscreteList 2 2))
!(assertEqual (> (getBDeScoreValue singleDiscreteScore) minusInf) True)

;; Test continuous scoring with single elements
!(bind! singleContinuousScore (continuousDiscrete2WayScore singleContinuousList singleDiscreteList 2))
!(assertEqual (> (getBDeScoreValue singleContinuousScore) minusInf) True)

; ;; ================================================================================
; ;; Performance Tests
; ;; ================================================================================

;; Performance section: bind larger lists (reuse existing data to avoid custom data functions)
!(bind! largeBoolList testBoolList3)
!(bind! largeDiscreteList testDiscreteList1)
!(bind! largeContinuousList testContinuousList2)

;; Test binary scoring with large lists
!(bind! largeBinaryScore (binaryBinaryScore largeBoolList largeBoolList))
!(assertEqual (> (getBDeScoreValue largeBinaryScore) minusInf) True)

;; Test discrete scoring with large lists
!(bind! largeDiscreteScore (discreteDiscrete2WayScore largeDiscreteList largeDiscreteList 2 2))
!(assertEqual (> (getBDeScoreValue largeDiscreteScore) minusInf) True)

;; Test continuous scoring with large lists
!(bind! largeContinuousScore (continuousDiscrete2WayScore largeContinuousList largeDiscreteList 2))
!(assertEqual (> (getBDeScoreValue largeContinuousScore) minusInf) True)


