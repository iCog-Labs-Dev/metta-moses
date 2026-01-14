; !(register-module! ../../../metta-moses)
!(import! &self ../../../metta-moses/feature-selection/similarity-scorers)
!(import! &self ../../../metta-moses/feature-selection/feature-selection-helpers)
!(import! &self ../../../metta-moses/utilities/general-helpers)
!(import! &self ../../../metta-moses/utilities/list-methods)

(= (ttable) 
    (mkITable 
        (Cons (Cons False (Cons False (Cons True (Cons True (Cons True Nil)))))
        (Cons (Cons True (Cons False (Cons False (Cons True (Cons True Nil)))))
        (Cons (Cons False (Cons True (Cons False (Cons True (Cons False Nil)))))
        (Cons (Cons False (Cons False (Cons False (Cons True (Cons False Nil))))) Nil))))
        
        (Cons A (Cons B (Cons C (Cons D (Cons Output Nil)))))))

; Test 
!(assertEqual (jaccardIndex (A) (B)) 0) 
!(assertEqual (jaccardIndex (A B) (B)) 0.5) 
!(assertEqual (jaccardIndex (A B) (B A)) 1) 

!(assertEqual (py-call ("round" (mi (1) (0 3) 0 (ttable)) 3)) 0.065)
!(assertEqual (py-call ("round" (mi (0 1) (0 3) 0 (ttable)) 3)) 0.236)
!(assertEqual (mi (0 1) (0 3) 1 (ttable)) 0.815)