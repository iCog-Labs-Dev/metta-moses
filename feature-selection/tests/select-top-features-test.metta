!(import! &self ../../../metta-moses/utilities/general-helpers)
!(import! &self ../../../metta-moses/utilities/list-methods)
!(import! &self ../../../metta-moses/scoring/cscore)
!(import! &self ../../../metta-moses/feature-selection/feature-selection-helpers)
!(import! &self ../../../metta-moses/feature-selection/similarity-scorers)
!(import! &self ../../../metta-moses/feature-selection/select-top-features)

(= (ttable) 
    (mkITable 
        (cons (cons False (cons False (cons True (cons True (cons True ())))))
        (cons (cons True (cons False (cons False (cons True (cons True ())))))
        (cons (cons False (cons True (cons False (cons True (cons False ())))))
        (cons (cons False (cons False (cons False (cons True (cons False ()))))) ()))))
        (cons A (cons B (cons C (cons D (cons Output ())))))))

;; Tests
!(assertEqual (rankFtSet 0 (ttable) 2 -1 False ja ((1 (0 2)) (0.4 (3 1)) (0.3 (1 2 3))) ()) ((0 2) (3 1) (1 2 3)))     
!(assertEqual (rankFtSet 0 (ttable) 2 -1 False mi ((1 (0 2)) (0.4 (3 1)) (0.3 (1 2 3))) ()) ((0 2) (3 1) (1 2 3)))    

!(assertEqual (selectTopFts (ttable) -2 -1 False ja ((1 (0 2)) (0.4 (3 1)) (0.3 (1 2 3))) 2) ((0 2) (3 1)))
!(assertEqual (selectTopFts (ttable) 2 -1 False mi ((1 (0 2)) (0.4 (3 1)) (0.3 (1 2 3))) 2) ((0 2) (3 1)))
!(assertEqual (selectTopFts (ttable) 2 -1 False ja ((1 (0 2)) (0.8 (0 1)) (0.4 (3 1)) (0.3 (1 2 3))) 2) ((0 2) (3 1)))
