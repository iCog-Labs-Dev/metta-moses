;; Type definitions and functions related to beahvioral socre, behavioral complexity score and turth table behavioral score.
;; Behavioral score is a list of numbers, where each number represents the score of a particular output. 
;; For boolean expressions, the score is either 0 or -1. Therefore, this behavioral score is a list of 0s and -1s.
;; In the C++ version, floating point scores and numbers different than -1 and 0 are used as a result of table compression 
;;  and weighting options. However, we don't have that yet.

(: BehavioralScore Type)
(: mkBScore (-> (List Number) BehavioralScore))

;; Subtrace two behavioral scores
(: BScore.sub (-> BehavioralScore BehavioralScore BehavioralScore))
(= (BScore.sub (mkBScore $bs1) (mkBScore $bs2))
   (if (~= (List.length $bs1) (List.length $bs2))
       (Error ($bs1 $bs2) "Incompatible behavioral scores")
       (mkBScore (List.sub $bs1 $bs2))))

;; Sums the behavioral score to get a single number.
(: sumBScore (-> BehavioralScore Number))
(= (sumBScore (mkBScore $bs)) (List.sum $bs))

;; Input table with rows, columns and labels of the columns
;; An Input Table is just a list of lists.
(: ITable (-> $a Type))
(: mkITable (-> (List (List $a)) (List Symbol) (ITable $a)))

;; TruthTableBScore is a type that contains the complexity coefficient, size of the table and the input table itself.
;; Using this type we can get behavioral score and behavioral complexity score.
;; This table is the cTruthTableBScore in the C++. The C stands for compressed. But omitted here since the table won't be compressed during this version.
;;  It is left as future work.
(: TruthTableBScore (-> $a Type))
(: mkTruthTableBScore (-> Number Number (ITable $a) (TruthTableBScore $a)))

;; A constuctor for truthTableBScore to assign the size of the table on it's own.
;; INFO: This could have been done by overloading the mkTruthTableBScore function, but
;;  that has shown to be problematic for certain cases. Best to avoid it whenever we can.
(: createTruthTableBScore (-> Number (ITable $a) (TruthTableBScore $a)))
(= (createTruthTableBScore $complexityCoeff (mkITable $itable $labels)) (mkTruthTableBScore $complexityCoeff (List.length $itable) (mkITable $itable $labels)))

;; Return the table from truth table bscore
(: getTable (-> (TruthTableBScore $a) (ITable $a)))
(= (getTable (mkTruthTableBScore $compCoeff $size $table)) $table)

;; Function to give a behavioral score for a given tree.
;; It takes the Input table and the tree then scores the input table on each row. After which it builds the behavioral score.
;;
;; Params: $table - Input table
;;         $labels - Column labels
;;         $tree - The tree to be scored
;;
;; Returns: Beahvioral score for the given tree.
(: scoreTree (-> (ITable $a) (Tree $a) BehavioralScore))
(= (scoreTree (mkITable $table $labels) $tree)
   (chain (preOrder $tree) $expTree
   (trace! (Scoring $expTree)
   (chain (List.map (compose evaluate ((curry replaceVarsWithTruth) ($labels $expTree))) $table) $scoreList
   (chain (List.length $labels) $length
   (chain (List.flatten (List.map ((curry List.drop) (- $length 1)) $table)) $outputs
   (chain (List.zipWith compareAndScore $scoreList $outputs) $bScore
      (mkBScore $bScore))))))))

;; Return the best possible BehavioralScore given the size of the table.
;;  Altohugh the whole table is given for consistency and to distinguish 
;;  from the same function that works on BehavioralCScore, it uses only the size of the table.
(: bestPossibleScore (-> (TruthTableBScore $a) BehavioralScore))
(= (bestPossibleScore (mkTruthTableBScore $compCoeff $size $table)) (mkBScore (List.repeat $size 0)))

;; Return the worst possible BehavioralScore given the size of the table.
;;  Altohugh the whole table is given for consistency and to distinguish 
;;  from the same function that works on BehavioralCScore, it uses only the size of the table.
(: worstPossibleScore (-> (TruthTableBScore $a) BehavioralScore))
(= (worstPossibleScore (mkTruthTableBScore $compCoeff $size $table)) (mkBScore (List.repeat $size -1)))

;; When we have a compressed tree, the min improvement 
;;  will be calculated. For now it's fixed.
(: minImprove (-> (TruthTableBScore $a) Number))
(= (minImprove $_) 0.5)

;; Score tree helepr function that compares two values and returns a number instead of a bool.
;; It returns 0 if the values are equal, -1 they're not equal.
(: compareAndScore (-> $a $a Number))
(= (compareAndScore $a $b) (if (== $a $b) 0 -1))

;; A wrapper function to return the complexity a tree.
(: (getComplexity (-> (Tree $a) Number)))
(= (getComplexity $tree) (treeComplexity $tree))

;; Replace every occurence of a lable inside an expression with a truth value.
;;
;; Params: $boolExpr - The expression to be modified
;;         $b - The truth value to replace with
;;         $l - The variable to be replaced
;;
;; Returns: Modified version of the boolean expression.
(: replaceVarWithTruth (-> (Bool Symbol) $a $a))
(= (replaceVarWithTruth ($b $l) $boolExpr)
   (if (== (get-metatype $boolExpr) Expression) ;; If symbol or Grounded
       (let ($h $t) (decons-atom $boolExpr)
            (if (== $t ())
                (replaceVarWithTruth ($b $l) $h)
                (let $t' (map-atom $t $ts (replaceVarWithTruth ($b $l) $ts))
                  (if (== $h $l)
                      (cons-atom $b $t')
                      (cons-atom $h $t')))))
       (if (== $boolExpr $l) $b $boolExpr)))

;; Replace ever occurence of all labels (boolean variables) 
;;  inside an expression with their corresponding truth values.
;;
;; Params: $boolExpr - The expression to be modified
;;         $lList - list of variables to be replaced
;;         $bList - list of the corresponding truth values to replace the variables with
;;
;; Returns: Modified version of the boolean expression.
(: replaceVarsWithTruth (-> ((List Symbol) Expression) (List Bool) Expression))
(= (replaceVarsWithTruth ($lList $boolExpr) $bList)
   (let $blList (List.zip $bList $lList) (List.foldl replaceVarWithTruth $boolExpr $blList)))

;; Behavioral complexity score. Although this type adds no additional atttributes to the truth table bscore,
;;  It is used to distinguish between the two types. The behavioral complexity score is treated differently than the latter one.
;;  Instead of a list of scores in the BehavioralScore this type deals with a single score values.
(: BehavioralCScore (-> $a Type))
(: mkBCScore (-> (TruthTableBScore $a) (BehavioralCScore $a)))

;; Return the best possible Behavioral composite score given the table. 
;;  Although the whole table is given for consistency and to distinguish 
;;  from the same function that works on BehavioralScore, it only needs the size of the table.
(: bestPossibleScore (-> (BehavioralCScore $a) Number))
(= (bestPossibleScore (mkBCScore $truthTableBScore)) (let (mkBScore $bscore) (bestPossibleScore $truthTableBScore) (List.sum $bscore)))

;; Return the worst possible Behavioral composite score given the table.
;;  Although the whole table is given for consistency and to distinguish
;;  from the same function that works on BehavioralScore, it only needs the size of the table.
(: worstPossibleScore (-> (BehavioralCScore $a) Number))
(= (worstPossibleScore (mkBCScore $truthTableBScore)) (let (mkBScore $bscore) (worstPossibleScore $truthTableBScore) (List.sum $bscore)))

;; When we have a compressed tree, the min improvement
;;  will be calculated. For now it's fixed.
(: minImprove (-> (BehavioralCScore $a) Number))
(= (minImprove (mkBCScore $truthTableBScore) (minImprove $truthTableBScore)))
