!(import! &self ../../../metta-moses/utilities/general-helpers)
!(import! &self ../../../metta-moses/utilities/list-methods)
!(import! &self ../../../metta-moses/feature-selection/feature-selection-helpers)
!(import! &self ../../../metta-moses/feature-selection/smd)
!(import! &self ../../../metta-moses/feature-selection/incremental-feature-selection)
!(import! &self ../../../metta-moses/feature-selection/stochasitc-maximum-dependency)
!(import! &self ../../../metta-moses/moses/demo-problems)

(= (clear-lru)
   (let $r1 (collapse (match &self (lru-entry $k $v $t) (remove-atom &self (lru-entry $k $v $t))))
        (let $r2 (collapse (match &self (lru-tick $t) (remove-atom &self (lru-tick $t))))
             (let $r3 (collapse (match &self (lru-capacity $c) (remove-atom &self (lru-capacity $c))))
                  True))))

!(clear-lru)
!(lru-init 128)

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

;; setting seed for the random-float function
; !(random-seed 42)
!(py-call (random.seed 42))

!(clear-lru)
!(lru-init 128)

!(test (smd-feature-selection (mux6) 2 0.0 5 ())  ((0.09436093777043375 (1 3)) (0.09436093777043375 (2 3)) (0.09436093777043375 (0 3)) (0.09436093777043375 (3 5)) (0.09436093777043375 (3 4))))
!(test (smd-feature-selection (mux6) 5 0.0 5 ()) ((0.75 (0 1 3 4 5)) (0.75 (0 1 2 3 5)) (0.75 (0 1 2 3 4)) (0.5 (0 2 3 4 5))))

;; clear cache before trying it with another table
!(clear-lru)
!(lru-init 128)

!(test (smd-feature-selection (majority5) 2 0.0 5 ()) ((0.22821777840020196 (0 1)) (0.22821777840020196 (0 2)) (0.22821777840020196 (1 2)) (0.22821777840020152 (0 4)) (0.22821777840020152 (0 3))))

; (smd-select-feature-sets $Table $target-size $threshold $top-size $init-features)

!(test (smd-feature-selection (majority5) 3 0.0 5 (0 2)) ((0.3915414066556506 (0 2 4)) (0.3915414066556506 (0 2 3)) (0.3915414066556506 (0 1 2))))
