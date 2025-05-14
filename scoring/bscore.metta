!(register-module! ../../metta-moses)
!(import! &self metta-moses:utilities:list-methods)
!(import! &self metta-moses:utilities:tree)
!(import! &self metta-moses:utilities:general-helpers)
!(import! &self metta-moses:scoring:fitness)

(: BehavioralScore Type)
(: mkBScore (-> (List Number) BehavioralScore))

;; Subtrace two behavioral scores
(: sub (-> BehavioralScore BehavioralScore BehavioralScore))
(= (sub (mkBScore $bs1) (mkBScore $bs2))
   (if (~= (List.length $bs1) (List.length $bs2))
       (Error ($bs1 $bs2) "Incompatible behavioral scores")
       (mkBScore (List.sub $bs1 $bs2))))

;; Input table
(: ITable (-> $a Type))
;; List of rows and column labels
(: mkITable (-> (List (List $a)) (List Symbol) (ITable $a)))

(: TruthTableBScore (-> $a Type))

;; Complexity coeff, Size, Table
(: mkTruthTableBScore (-> Number Number (ITable $a) (TruthTableBScore $a)))

(: createTruthTableBScore (-> Number (ITable $a) (TruthTableBScore $a)))
(= (createTruthTableBScore $complexityCoeff (mkITable $itable $labels)) (mkTruthTableBScore $complexityCoeff (List.length $itable) (mkITable $itable $labels)))

;; Return the table from truth table bscore
(: getTable (-> (TruthTableBScore $a) (ITable $a)))
(= (getTable (mkTruthTableBScore $compCoeff $size $table)) $table)

(: scoreTree (-> (ITable $a) (Tree $a) BehavioralScore))
(= (scoreTree (mkITable $table $labels) $tree)
   (chain (preOrder $tree) $expTree
   (chain (List.map (compose evaluate ((curry replaceVarsWithTruth) ($labels $expTree))) $table) $scoreList
   (chain (List.length $labels) $length
   (chain (List.flatten (List.map ((curry List.drop) (- $length 1)) $table)) $outputs
   (chain (List.zipWith compareAndScore $scoreList $outputs) $bScore
      (mkBScore $bScore)))))))

(: bestPossibleScore (-> (TruthTableBScore $a) BehavioralScore))
(= (bestPossibleScore (mkTruthTableBScore $compCoeff $size $table)) (mkBScore (List.repeat $size 0)))

(: worstPossibleScore (-> (TruthTableBScore $a) BehavioralScore))
(= (worstPossibleScore (mkTruthTableBScore $compCoeff $size $table)) (mkBScore (List.repeat $size -1)))

;; When we have a compressed tree, the min improvement 
;;  will be calculated. For now it's fixed.
(: minImprove (-> (TruthTableBScore $a) Number))
(= (minImprove $_) 0.5)

(: sumBScore (-> BehavioralScore Number))
(= (sumBScore (mkBScore $bs)) (List.sum $bs))

(: compareAndScore (-> $a $a Number))
(= (compareAndScore $a $b) (if (== $a $b) 0 -1))

(: (getComplexity (-> (Tree $a) Number)))
(= (getComplexity $tree) (treeComplexity $tree))

;; Replace every occurence of a lable inside an expression with a truth value
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

(: replaceVarsWithTruth (-> ((List Symbol) Expression) (List Bool) Expression))
(= (replaceVarsWithTruth ($lList $boolExpr) $bList)
   (let $blList (List.zip $bList $lList) (List.foldl replaceVarWithTruth $boolExpr $blList)))

;; Behavioral complexity score
(: BehavioralCScore (-> $a Type))
(: mkBCScore (-> (TruthTableBScore $a) (BehavioralCScore $a)))

(: bestPossibleScore (-> (BehavioralCScore $a) Number))
(= (bestPossibleScore (mkBCScore $truthTableBScore)) (let (mkBScore $bscore) (bestPossibleScore $truthTableBScore) (List.sum $bscore)))

(: worstPossibleScore (-> (BehavioralCScore $a) Number))
(= (worstPossibleScore (mkBCScore $truthTableBScore)) (let (mkBScore $bscore) (worstPossibleScore $truthTableBScore) (List.sum $bscore)))

;; When we have a compressed tree, the min improvement 
;;  will be calculated. For now it's fixed.
(: minImprove (-> (BehavioralCScore $a) Number))
(= (minImprove (mkBCScore $truthTableBScore) (minImprove $truthTableBScore)))

;; !(let $a (mkBScore (Cons 1 (Cons 0 (Cons 2 Nil)))) (get-type $a)) ;; BehavioralScore
;; !(let $a (mkITable (Cons (Cons 1 (Cons 0 (Cons 2 Nil))) Nil) (Cons A (Cons B (Cons C Nil)))) (get-type $a)) ;; (ITable Number)
;; !(let $a (mkTruthTableBScore 1 0.2 (mkITable (Cons (Cons 1 (Cons 0 (Cons 2 Nil))) Nil) (Cons A (Cons B (Cons C Nil))))) (get-type $a)) ;; (TruthTableBScore Number)
;; !(let $a (createTruthTableBScore 0.2 (mkITable (Cons (Cons 1 (Cons 0 (Cons 2 Nil))) Nil) (Cons A (Cons B (Cons C Nil))))) (get-type $a)) ;; (TruthTableBScore Number)
;; !(createTruthTableBScore 0.2 (mkITable (Cons (Cons 1 (Cons 0 (Cons 2 Nil))) Nil) (Cons A (Cons B (Cons C Nil))))) ;; (mkTruthTableBScore 0.2 1 (mkITable (Cons (Cons 1 (Cons 0 (Cons 2 Nil))) Nil)))
;; !(sub (mkBScore (Cons 1 (Cons 0 (Cons 2 Nil)))) (mkBScore (Cons 1 (Cons 0 (Cons 2 Nil))))) ;; (mkBScore (Cons 0 (Cons 0 (Cons 0 Nil))))
;; !(getTable (mkTruthTableBScore 1 0.2 (mkITable (Cons (Cons 1 (Cons 0 (Cons 2 Nil))) Nil) (Cons A (Cons B (Cons C Nil)))))) ;; (mkITable (Cons (Cons 1 (Cons 0 (Cons 2 Nil))) Nil))

;; !(replaceVarWithTruth (True A) (AND A B (OR A B (NOT A)))) ;; (AND True B (OR True B (NOT True)))
;; !(replaceVarWithTruth (False B) (AND A B (OR A B (NOT A)))) ;; (AND A False (OR A False (NOT False)))
;; !(replaceVarsWithTruth (Cons True (Cons False Nil)) (Cons A (Cons B Nil)) (AND A B (OR A B (NOT A))))
;; !(replaceVarsWithTruth (Cons True (Cons False Nil)) (Cons A (Cons B Nil)) (AND A B (OR A B (NOT A))))

;; !(scoreTree (mkITable (Cons (Cons True (Cons False (Cons False Nil))) (Cons (Cons True (Cons True (Cons True Nil))) Nil) ) (Cons A (Cons B (Cons O Nil)))) (buildTree (OR A B))) ;; (mkBScore (Cons -1 (Cons 0 Nil)))
;; !(scoreTree (mkITable (Cons (Cons True (Cons False (Cons False Nil))) (Cons (Cons True (Cons True (Cons True Nil))) Nil) ) (Cons A (Cons B (Cons O Nil)))) (buildTree (AND A B))) ;; (mkBScore (Cons 0 (Cons 0 Nil)))

;; !(sumBScore (mkBScore (Cons 1 (Cons 2 (Cons 0 (Cons 1 Nil)))))) ;; 4

;; !(treeComplexity (buildTree (AND (NOT A) (OR A B)))) ;; 3
;; !(treeComplexity (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) Nil)) Nil))) ;; 0
;; !(treeComplexity (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) Nil)) Nil))) ;; 1


;; !(bestPossibleScore (mkTruthTableBScore 0.2 1 (mkITable (Cons (Cons 1 (Cons 0 (Cons 2 Nil))) Nil) (Cons A (Cons B (Cons C Nil)))))) ;; (Cons 0 Nil)
;; !(worstPossibleScore (mkTruthTableBScore 0.2 1 (mkITable (Cons (Cons 1 (Cons 0 (Cons 2 Nil))) Nil) (Cons A (Cons B (Cons C Nil)))))) ;; (Cons -1 Nil)
;; !(minImprove (mkTruthTableBScore 0.2 1 (mkITable (Cons (Cons 1 (Cons 0 (Cons 2 Nil))) Nil) (Cons A (Cons B (Cons C Nil)))))) ;; 0.5

;; !(bestPossibleScore (mkBCScore (mkTruthTableBScore 0.2 2 (mkITable (Cons (Cons 1 (Cons 0 (Cons 2 Nil))) (Cons (Cons 0 (Cons 0 (Cons 1 Nil))) Nil)) (Cons A (Cons B (Cons C Nil))))))) ;; 0
;; !(worstPossibleScore (mkBCScore (mkTruthTableBScore 0.2 2 (mkITable (Cons (Cons 1 (Cons 0 (Cons 2 Nil))) (Cons (Cons 0 (Cons 0 (Cons 1 Nil))) Nil)) (Cons A (Cons B (Cons C Nil))))))) ;; -2
;; !(minImprove (mkBCScore (mkTruthTableBScore 0.2 2 (mkITable (Cons (Cons 1 (Cons 0 (Cons 2 Nil))) (Cons (Cons 0 (Cons 0 (Cons 1 Nil))) Nil)) (Cons A (Cons B (Cons C Nil))))))) ;; 0.5

;; !(compareAndScore A B) ;; -1
;; !(compareAndScore A A) ;; 0

;; !(getComplexity (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) Nil)) Nil))) ;; 1
