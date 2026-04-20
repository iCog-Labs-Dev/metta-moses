!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/list-methods)
!(import! &self ../feature-selection-helpers)
!(import! &self ../random-feature-selection)

!(py-call (random.seed 42))

(= (table1) (mkITable 
    (cons (cons True (cons True (cons False (cons True (cons True ())))))
    (cons (cons True (cons False (cons False (cons True (cons True ())))))
    (cons (cons False (cons True (cons False (cons True (cons False ())))))
    (cons (cons False (cons False (cons False (cons True (cons False ()))))) ()))))
    (cons A (cons B (cons C (cons D (cons Output ())))))))

(= (table_xor) (mkITable
    (cons (cons True  (cons True  (cons False ())))
    (cons (cons True  (cons False (cons True  ())))
    (cons (cons False (cons True  (cons True  ())))
    (cons (cons False (cons False (cons False ()))) ()))))
    (cons A (cons B (cons Output ())))))

(= (table3) (mkITable 
    (cons (cons False (cons True (cons True (cons False (cons True ())))))
    (cons (cons True (cons True (cons False (cons False (cons False ())))))
    (cons (cons True (cons False (cons True (cons True (cons True ())))))
    (cons (cons False (cons False (cons True (cons True (cons False ()))))) ()))))
    (cons X1 (cons X2 (cons X3 (cons X4 (cons Result ())))))))

(= (table4) (mkITable 
    (cons (cons True (cons True (cons False (cons True (cons False (cons True (cons True ())))))))
    (cons (cons False (cons True (cons True (cons False (cons True (cons False (cons False ()))))))) ()))
    (cons A (cons B (cons C (cons D (cons E (cons F (cons Output ())))))))))

;; TESTS FOR randomFeatureSelection
 ;; Test zero and negative target sizes - should return empty
!(assertEqual (randomFeatureSelection (table1) 0) ((0 ())))
!(assertEqual (randomFeatureSelection (table1) -1) ((0 ())))
!(assertEqual (randomFeatureSelection (table1) -5) ((0 ())))

; Test normal Features
!(assertEqual (randomFeatureSelection (table_xor) 1) ((0 (0))))
!(assertEqual (randomFeatureSelection (table1) 2) ((0 (2 0))))
!(assertEqual (randomFeatureSelection (table3) 3) ((0 (3 0 1))))

 ;; Test target size >= number of features - should return all indices
!(assertEqual (randomFeatureSelection (table1) 4) ((0 (0 1 2 3)))) ;; exactly all features
!(assertEqual (randomFeatureSelection (table1) 5) ((0 (0 1 2 3)))) ;; more than available
!(assertEqual (randomFeatureSelection (table1) 10) ((0 (0 1 2 3)))) ;; much more than available

!(assertEqual (randomFeatureSelection (table4) 6) ((0 (0 1 2 3 4 5)))) ;; exactly all features
!(assertEqual (randomFeatureSelection (table4) 8) ((0 (0 1 2 3 4 5)))) ;; more than available
