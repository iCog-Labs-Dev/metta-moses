;; Candidate reconstruction: builds the program tree for one instance of a
;; representation (getCandidate and its helpers).
;;
;; These functions are in their own file, apart from the representation
;; constructor, because of the import order. hill-climbing-helpers calls them,
;; and the representation constructor calls featureSelector, whose hc selector
;; calls hillClimbing. So moses.metta loads this file before the optimizer and
;; representation.metta after it.

;; Helper function to extract tree from representation
(= (getRepTree (mkRep $knobMapObj $tree)) $tree)

;; Universal getCandidate that works for both boolean and action domains.
;; Candidate finalization keeps strategy trees untouched. Action programs use
;; static action reduction; all other candidates use boolean reduction.
(= (candidateRootSymbol $tree)
   (let $rootValue (getNodeValue $tree)
      (if (== (get-metatype $rootValue) Expression)
          (car-atom (cdr-atom $rootValue))
          $rootValue)))

(= (finalizeCandidateTree $rootSymbol $candidate)
   (if (isActionOperator $rootSymbol)
       (cleanActionTree $candidate)
       (cleanTree $candidate)))

;; Builds the program tree for one instance and caches it in &treeSpace by ($id $inst).
(= (getCandidate $repObj $id $inst)
   (case (match &treeSpace ($id $inst $tree) $tree)
             (($tree $tree)
             (Empty
                (let*
                    ( 
                      ((mkRep $kmo $tr) $repObj)
                      ;; ($_ (println! (Tree: (preOrder $tr))))
                      ;; ($_ (println! (GetCandidateHelper: $inst $tr)))
                      ($candidate (getCandidateHelper $inst $tr))
                      ;; ($_ (println! (Found candidate: (preOrder $candidate))))
                      ($rootNode (getRepTree $repObj))
                      ($rootSymbol (candidateRootSymbol $rootNode))
                      ($finalTree (finalizeCandidateTree $rootSymbol $candidate))

                      ($_ (add-atom &treeSpace ($id $inst $finalTree)))
                      ;; ($_ (println! (Cleaned Tree: $cleanedTree)))
                    )
                    $finalTree)))))

;; getCandidateHelper builds the program tree of an instance from the knob tree.
;; ASK knob: setting 0 drops it. Default 0 selects perm (setting - 1);
;; default 1 keeps the controlled subtree.
(= (getCandidateHelper (mkInst $inst) (mkKnob $controlledSubtree (mkASK $discKnob $perms) $i))
   (let*
      (
         ($ask (mkASK $discKnob $perms))
         ((mkDiscSpec $defaultSetting) (getKnobDefault $ask))
         ($setting (if (!= (getDisallowedSpecs $ask) ())
                     (mapEffectiveDiscSpec $ask (index-atom $inst $i))
                     (index-atom $inst $i)))
      )
      (if (== $setting 0)
         ()
         (if (== $defaultSetting 0)
             (getCandidateHelper (mkInst $inst) (List.getByIdx $perms (- $setting 1)))
             (getCandidateHelper (mkInst $inst) $controlledSubtree)))))

;; Null-vertex unwrapping for LSK knobs only.
;; mkASK knobs go only to the ASK clause above. A generic pattern here
;; gave two solutions for (mkKnob (mkNullVex ...) (mkASK ...) $i).
(= (getCandidateHelper $inst (mkKnob (mkNullVex ($child)) (mkLSK $discKnob) $i))
   (getCandidateHelper $inst (mkKnob $child (mkLSK $discKnob) $i)))

;; LSK knob: setting 0 drops the subtree, 1 keeps it, 2 negates it.
;; With an empty disallowed list the effective setting is the actual setting.
(= (getCandidateHelper (mkInst $inst) (mkKnob (mkTree $node $children) (mkLSK (mkDiscKnob $m $c $d $disAllowed)) $i))
   (let*
     (
       ($setting (if (!= $disAllowed ())
                     (mapEffectiveDiscSpec (mkLSK (mkDiscKnob $m $c $d $disAllowed)) (index-atom $inst $i))
                     (index-atom $inst $i)))
     )
     (if (== $setting 0)
         ()
         (let $newChildren (filter-atom (map-atom $children $ch (getCandidateHelper (mkInst $inst) $ch)) (!= ()))
              (case $setting
                 (
                   (1 (mkTree $node $newChildren))
                   (2 (mkTree (mkNode NOT) ((mkTree $node $newChildren))))))))))

(= (getCandidateHelper $inst (mkTree $node $children))
   (let $newChildren (map-atom $children $ch (getCandidateHelper $inst $ch))
        (mkTree $node (filter-atom $newChildren (!= ())))))
