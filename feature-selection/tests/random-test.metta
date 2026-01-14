; !(register-module! ../../../metta-moses)
!(import! &self ../random-feature-selection)
!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/list-methods)
!(import! &self ../feature-selection-helpers)

!(py-call (random.seed 42))

(= (table1) (mkITable 
    (Cons (Cons True (Cons True (Cons False (Cons True (Cons True Nil)))))
    (Cons (Cons True (Cons False (Cons False (Cons True (Cons True Nil)))))
    (Cons (Cons False (Cons True (Cons False (Cons True (Cons False Nil)))))
    (Cons (Cons False (Cons False (Cons False (Cons True (Cons False Nil))))) Nil))))
    (Cons A (Cons B (Cons C (Cons D (Cons Output Nil)))))))

(= (table_xor) (mkITable
    (Cons (Cons True  (Cons True  (Cons False Nil)))
    (Cons (Cons True  (Cons False (Cons True  Nil)))
    (Cons (Cons False (Cons True  (Cons True  Nil)))
    (Cons (Cons False (Cons False (Cons False Nil))) Nil))))
    (Cons A (Cons B (Cons Output Nil)))))

(= (table3) (mkITable 
    (Cons (Cons False (Cons True (Cons True (Cons False (Cons True Nil)))))
    (Cons (Cons True (Cons True (Cons False (Cons False (Cons False Nil)))))
    (Cons (Cons True (Cons False (Cons True (Cons True (Cons True Nil)))))
    (Cons (Cons False (Cons False (Cons True (Cons True (Cons False Nil))))) Nil))))
    (Cons X1 (Cons X2 (Cons X3 (Cons X4 (Cons Result Nil)))))))

(= (table4) (mkITable 
    (Cons (Cons True (Cons True (Cons False (Cons True (Cons False (Cons True (Cons True Nil)))))))
    (Cons (Cons False (Cons True (Cons True (Cons False (Cons True (Cons False (Cons False Nil))))))) Nil))
    (Cons A (Cons B (Cons C (Cons D (Cons E (Cons F (Cons Output Nil)))))))))

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
