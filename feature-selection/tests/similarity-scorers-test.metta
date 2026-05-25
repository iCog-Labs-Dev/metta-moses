!(import! &self ../../../metta-moses/utilities/general-helpers)
!(import! &self ../../../metta-moses/utilities/list-methods)
!(import! &self ../../../metta-moses/feature-selection/feature-selection-helpers)
!(import! &self ../../../metta-moses/feature-selection/similarity-scorers)

(= (ttable) 
    (mkITable 
        (cons (cons False (cons False (cons True (cons True (cons True ())))))
        (cons (cons True (cons False (cons False (cons True (cons True ())))))
        (cons (cons False (cons True (cons False (cons True (cons False ())))))
        (cons (cons False (cons False (cons False (cons True (cons False ()))))) ()))))
        
        (cons A (cons B (cons C (cons D (cons Output ())))))))

; Test 
!(assertEqual (jaccardIndex (A) (B)) 0) 
!(assertEqual (jaccardIndex (A B) (B)) 0.5) 
!(assertEqual (jaccardIndex (A B) (B A)) 1) 

!(assertEqual (py-call ("round" (mi (1) (0 3) 0 (ttable)) 3)) 0.065)
!(assertEqual (py-call ("round" (mi (0 1) (0 3) 0 (ttable)) 3)) 0.236)
!(assertEqual (mi (0 1) (0 3) 1 (ttable)) 0.815)
