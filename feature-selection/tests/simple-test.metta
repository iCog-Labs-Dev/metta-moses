; !(register-module! ../../../metta-moses)
!(import! &self ../../../metta-moses/feature-selection/feature-selection-helpers)
!(import! &self ../../../metta-moses/feature-selection/simple)
!(import! &self ../../../metta-moses/utilities/general-helpers)
!(import! &self ../../../metta-moses/utilities/list-methods)

(= (ttable) (mkITable  
            (Cons (Cons True (Cons True (Cons False (Cons True (Cons True Nil)))))
            (Cons (Cons True (Cons False (Cons False (Cons True (Cons True Nil)))))
            (Cons (Cons False (Cons True (Cons False (Cons True (Cons False Nil)))))
            (Cons (Cons False (Cons False (Cons False (Cons True (Cons False Nil))))) Nil))))
            
            (Cons A (Cons B (Cons C (Cons D (Cons Output Nil)))))))

; ;; MI threshold 0.0
!(assertEqual (simpleFeatureSelector 0.0 2 False (ttable) ()) ((0 (0 1))))
!(assertEqual (simpleFeatureSelector 0.0 3 False (ttable) ()) ((0 (0 1 2))))
!(assertEqual (simpleFeatureSelector 0.0 1 False (ttable) ()) ((0 (0))))

;; MI threshold 0.5
!(assertEqual (simpleFeatureSelector 0.5 2 False (ttable) ()) ((0 (0))))

;; MI threshold 1.1
!(assertEqual (simpleFeatureSelector 1.1 3 False (ttable) ()) ((0 ())))

;; 0 as target size -- return all feature sets 
!(assertEqual (simpleFeatureSelector 0.0 0 False (ttable) ()) ((0 (A B C D))))
; Recommended-- more tests by more and varied tables