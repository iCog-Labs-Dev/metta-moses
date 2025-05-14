!(register-module! ../../metta-moses)
!(import! &self metta-moses:utilities:general-helpers)
!(import! &self metta-moses:utilities:list-methods)

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
(: mkITable (-> (List (List $a)) (ITable $a)))

(: TruthTableBScore (-> $a Type))

;; Complexity coeff, Size, Table
(: mkTruthTableBScore (-> Number Number (ITable $a) (TruthTableBScore $a)))

(: createTruthTableBScore (-> Number (ITable $a) (TruthTableBScore $a)))
(= (createTruthTableBScore $complexityCoeff (mkITable $itable)) (mkTruthTableBScore $complexityCoeff (List.length $itable) (mkITable $itable)))

;; Return the table from truth table bscore
(: getTable (-> (TruthTableBScore $a) (ITable $a)))
(= (getTable (mkTruthTableBScore $compCoeff $size $table)) $table)

;; !(let $a (mkBScore (Cons 1 (Cons 0 (Cons 2 Nil)))) (get-type $a)) ;; BehavioralScore
;; !(let $a (mkITable (Cons (Cons 1 (Cons 0 (Cons 2 Nil))) Nil)) (get-type $a)) ;; (ITable Number)
;; !(let $a (mkTruthTableBScore 1 0.2 (mkITable (Cons (Cons 1 (Cons 0 (Cons 2 Nil))) Nil))) (get-type $a)) ;; (TruthTableBScore Number)
;; !(let $a (createTruthTableBScore 0.2 (mkITable (Cons (Cons 1 (Cons 0 (Cons 2 Nil))) Nil))) (get-type $a)) ;; (TruthTableBScore Number)
;; !(createTruthTableBScore 0.2 (mkITable (Cons (Cons 1 (Cons 0 (Cons 2 Nil))) Nil))) ;; (mkTruthTableBScore 0.2 1 (mkITable (Cons (Cons 1 (Cons 0 (Cons 2 Nil))) Nil)))
;; !(sub (mkBScore (Cons 1 (Cons 0 (Cons 2 Nil)))) (mkBScore (Cons 1 (Cons 0 (Cons 2 Nil))))) ;; (mkBScore (Cons 0 (Cons 0 (Cons 0 Nil))))
;; !(getTable (mkTruthTableBScore 1 0.2 (mkITable (Cons (Cons 1 (Cons 0 (Cons 2 Nil))) Nil)))) ;; (mkITable (Cons (Cons 1 (Cons 0 (Cons 2 Nil))) Nil))

