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
;; (: createRepresentation (-> Number (Tree $a) (ITable $a) Symbol Bool Expression Symbol Representation))
;; For games: createRepresentation($nDeme, $tree)
;; For boolean: createRepresentation($nDeme, $tree, $itable, $algo, $prune, $enforced, $scorer)

;; Game strategy representation (2 parameters)
;;(: createRepresentation (-> Number (Tree $a) (List Representation)))
(= (createRepresentation $nDeme $tree)
    (representation $tree $nDeme))

;; Boolean logic representation (7 parameters)
;; The eighth arg to `representation` is `$disable-discprobe`, so we negate
;; the user-facing `discProbe` knob (True == enabled) when forwarding.
(= (createRepresentation $nDeme $tree (mkITable $table $labels) $algo $prune-exemplar $enforced-fts $scorerType)
    (let ((mkRep (mkKbMap (mkDscMp $dscKbMp)) $updatedTree)) (representation $nDeme $tree (mkITable $table $labels) $algo $prune-exemplar $enforced-fts $scorerType (not (param discProbe))) ((mkRep (mkKbMap (mkDscMp $dscKbMp)) $updatedTree))))

;; Action representation (4 parameters): the experiment's action/perception
;; vocabularies arrive as ARGUMENTS -- arity alone routes here (the boolean
;; clause is 7-ary, the game clause 2-ary), and this layer stays a pure
;; function of its inputs: the one (param actions)/(param perceptions) read
;; happens at the deme boundary (expand-deme.metta's action overload), where
;; moses-run-action's loud missing-vocab guard has already validated them.
;; Threads the vocabularies into the action-capable 10-arg `representation`
;; overload (representation.metta:145-162). That overload builds exactly ONE
;; rep per call (its $nDeme slot is unused), so the per-deme loop lives HERE
;; -- the action analog of the loop the 2-arg game clause delegates to
;; representation.metta:40-51. Knob sampling inside buildAction is
;; randomized, so demes get distinct representations.
;; The (mkITable () ()) is a placeholder: the action path of buildKnobs
;; (build-knobs.metta:20-31) never consults the itable / fs-algo / scorer
;; slots. Each element is (mkRep (mkKbMap (mkDscMp $mmp)) $tree) -- the
;; 1-field KnobMap shape loopCreateDeme / expandDemeHelper destructure.
(= (createRepresentation $nDeme $tree $actions $perceptions)
   (let $demeNumbers (range 0 1 $nDeme)
     (map-atom $demeNumbers $x
       (let ($rep) (representation 1 $tree (mkITable () ()) None False () mi True $actions $perceptions)
         $rep))))
