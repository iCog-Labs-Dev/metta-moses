!(import! &self ../../../metta-moses/utilities/list-methods)
!(import! &self ../../../metta-moses/utilities/general-helpers)
!(import! &self ../../../metta-moses/feature-selection/feature-selection-helpers)
!(import! &self ../../../metta-moses/feature-selection/simple)

(= (ttable) (mkITable  
            (cons (cons True (cons True (cons False (cons True (cons True ())))))
            (cons (cons True (cons False (cons False (cons True (cons True ())))))
            (cons (cons False (cons True (cons False (cons True (cons False ())))))
            (cons (cons False (cons False (cons False (cons True (cons False ()))))) ()))))
            
            (cons A (cons B (cons C (cons D (cons Output ())))))))

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
