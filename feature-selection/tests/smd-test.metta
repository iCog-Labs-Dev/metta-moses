; !(register-module! ../../../metta-moses)
!(import! &self ../../../metta-moses/feature-selection/feature-selection-helpers)
!(import! &self ../../../metta-moses/feature-selection/smd)
!(import! &self ../../../metta-moses/utilities/general-helpers)
!(import! &self ../../../metta-moses/utilities/list-methods)

(= (ttable) (mkITable  
            (Cons (Cons True (Cons True (Cons False (Cons True (Cons True Nil)))))
            (Cons (Cons True (Cons False (Cons False (Cons True (Cons True Nil)))))
            (Cons (Cons False (Cons True (Cons False (Cons True (Cons False Nil)))))
            (Cons (Cons False (Cons False (Cons False (Cons True (Cons False Nil))))) Nil))))
            
            (Cons A (Cons B (Cons C (Cons D (Cons Output Nil)))))))

(= (dataRows) 
            (Cons (Cons False (Cons False (Cons False (Cons True (Cons True Nil)))))
            (Cons (Cons True (Cons False (Cons False (Cons True (Cons True Nil)))))
            (Cons (Cons False (Cons True (Cons False (Cons True (Cons False Nil)))))
            (Cons (Cons False (Cons False (Cons False (Cons True (Cons False Nil))))) Nil)))))

!(assertEqual (let $res (stochasticMaxDependency 0 3 3 (ttable) mi ()) (size-atom $res)) 3)
!(assertEqual (let $res (stochasticMaxDependency 0 1 3 (ttable) mi ()) (size-atom $res)) 3)
!(assertEqual (let $res (stochasticMaxDependency 0 1 2 (ttable) mi ()) (size-atom $res)) 2)
