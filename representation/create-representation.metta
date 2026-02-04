;; In our simplified approach, we're not using dynamic feature selection
;; or ignore operators. This significantly streamlines the representation
;; creation process compared to the original implementation.
;;
;; The original code handles several complex scenarios:
;; 1. Dynamic feature selection to reduce the number of features used
;; 2. Creating multiple representations with different feature sets
;; 3. Pruning exemplars based on selected features
;; 4. Enforcing specific features
;; 5. Creating ignore_ops sets for non-selected features ↠ not implemented as a separate container for ignored args rather if exemplar features are ignored, they are subtracted from args list in representation building

;; createRepresentation -- calls on the representation building procedure
;; For games: createRepresentation($nDeme, $tree)
;; For boolean: createRepresentation($nDeme, $tree, $itable, $algo, $prune, $enforced, $scorer)

;; Game strategy representation (2 parameters)
;;(: createRepresentation (-> Number (Tree $a) (List Representation)))
(= (createRepresentation $nDeme $tree)
    (eval (representation $tree $nDeme)))

;; Boolean logic representation (7 parameters)
;;(: createRepresentation (-> Number (Tree $a) (ITable $a) Symbol Bool Expression Symbol (List Representation)))
(= (createRepresentation $nDeme $tree (mkITable $table $labels) $algo $prune-exemplar $enforced-fts $scorerType)
    (eval (representation $nDeme $tree (mkITable $table $labels) $algo $prune-exemplar $enforced-fts $scorerType)))
