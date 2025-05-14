!(register-module! ../../metta-moses)
!(import! &self metta-moses:utilities:general-helpers)
!(import! &self metta-moses:utilities:list-methods)
!(import! &self metta-moses:utilities:tree)

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
   (let*
      (
        ($expTree (preOrder $tree))
      )
      ()))

;; Replace every occurence of a lable inside an expression with a truth value
(: replaceVarWithTruth (-> (Bool Atom) Atom Atom))
(= (replaceVarWithTruth ($b $l) $boolExpr)
   (trace! (Getting BoolExpr: $boolExpr)
   (if (or (== (get-metatype $boolExpr) Symbol) (== (get-metatype $boolExpr) Grounded))
       (if (== $boolExpr $l) $b $boolExpr)
       (let ($h $t) (decons-atom $boolExpr)
            (if (== $t ())
                (replaceVarWithTruth ($b $l) $h)
                (let $t' (map-atom $t $ts (replaceVarWithTruth ($b $l) $ts))
                  (if (== $h $l)
                      (cons-atom $b $t')
                      (cons-atom $h $t'))))))))

(: replaceVarsWithTruth (-> (List Bool) (List Atom) Expression Expression))
(= (replaceVarsWithTruth Nil Nil $boolExpr) $boolExpr)
(= (replaceVarsWithTruth (Cons $b $bs) (Cons $l $ls) $boolExpr )
   (let $boolExpr' (replaceVarWithTruth ($b $l) $boolExpr) (trace! (GotBoolExpr: $boolExpr') (replaceVarsWithTruth $bs $ls $boolExpr'))))

;; !(replaceVarWithTruth (True A) (AND A B (OR A B (NOT A)))) ;; (AND True B (OR True B (NOT True)))
;; !(replaceVarWithTruth (False B) (AND A B (OR A B (NOT A)))) ;; (AND A False (OR A False (NOT False)))
;; !(replaceVarsWithTruth (Cons True (Cons False Nil)) (Cons A (Cons B Nil)) (AND A B (OR A B (NOT A))))
!(List.foldl replaceVarWithTruth (AND A B (OR A B (NOT A))) (Cons (True A) (Cons (False B) Nil)))

;; !(let $a (mkBScore (Cons 1 (Cons 0 (Cons 2 Nil)))) (get-type $a)) ;; BehavioralScore
;; !(let $a (mkITable (Cons (Cons 1 (Cons 0 (Cons 2 Nil))) Nil) (Cons A (Cons B (Cons C Nil)))) (get-type $a)) ;; (ITable Number)
;; !(let $a (mkTruthTableBScore 1 0.2 (mkITable (Cons (Cons 1 (Cons 0 (Cons 2 Nil))) Nil) (Cons A (Cons B (Cons C Nil))))) (get-type $a)) ;; (TruthTableBScore Number)
;; !(let $a (createTruthTableBScore 0.2 (mkITable (Cons (Cons 1 (Cons 0 (Cons 2 Nil))) Nil) (Cons A (Cons B (Cons C Nil))))) (get-type $a)) ;; (TruthTableBScore Number)
;; !(createTruthTableBScore 0.2 (mkITable (Cons (Cons 1 (Cons 0 (Cons 2 Nil))) Nil) (Cons A (Cons B (Cons C Nil))))) ;; (mkTruthTableBScore 0.2 1 (mkITable (Cons (Cons 1 (Cons 0 (Cons 2 Nil))) Nil)))
;; !(sub (mkBScore (Cons 1 (Cons 0 (Cons 2 Nil)))) (mkBScore (Cons 1 (Cons 0 (Cons 2 Nil))))) ;; (mkBScore (Cons 0 (Cons 0 (Cons 0 Nil))))
;; !(getTable (mkTruthTableBScore 1 0.2 (mkITable (Cons (Cons 1 (Cons 0 (Cons 2 Nil))) Nil) (Cons A (Cons B (Cons C Nil)))))) ;; (mkITable (Cons (Cons 1 (Cons 0 (Cons 2 Nil))) Nil))

