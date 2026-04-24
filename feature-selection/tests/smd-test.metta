!(import! &self ../../../metta-moses/utilities/general-helpers)
!(import! &self ../../../metta-moses/utilities/list-methods)
!(import! &self ../../../metta-moses/feature-selection/feature-selection-helpers)
!(import! &self ../../../metta-moses/feature-selection/smd)

(= (ttable) (mkITable  
            (cons (cons True (cons True (cons False (cons True (cons True ())))))
            (cons (cons True (cons False (cons False (cons True (cons True ())))))
            (cons (cons False (cons True (cons False (cons True (cons False ())))))
            (cons (cons False (cons False (cons False (cons True (cons False ()))))) ()))))
            
            (cons A (cons B (cons C (cons D (cons Output ())))))))

(= (dataRows) 
            (cons (cons False (cons False (cons False (cons True (cons True ())))))
            (cons (cons True (cons False (cons False (cons True (cons True ())))))
            (cons (cons False (cons True (cons False (cons True (cons False ())))))
            (cons (cons False (cons False (cons False (cons True (cons False ()))))) ())))))

!(assertEqual (let $res (stochasticMaxDependency 0 3 3 (ttable) mi ()) (size-atom $res)) 3)
!(assertEqual (let $res (stochasticMaxDependency 0 1 3 (ttable) mi ()) (size-atom $res)) 3)
!(assertEqual (let $res (stochasticMaxDependency 0 1 2 (ttable) mi ()) (size-atom $res)) 2)
