;;;;;;;;;;;;;;;;; LSK Constructor ;;;;;;;;;;;;;;;;;;;;;;;;

;; Creates a Logical Subtree Knob (LSK) for a subtree under a parent tree.
;; Params:
;;  (mkTree $node $children): The parent tree that gets the knob.
;;  $subtree: The subtree that the knob controls.
;; Returns: ($controlledSubtree $lsk). The default setting is 1 when the
;;  subtree (or its negation) is already a child, else 0 and a null vertex.
(= (logicalSubtreeKnob (mkTree $node $children ) $subtree)
   (let*
     (
       ($negatedSubtree (insertAbove $subtree (mkNode NOT)))
       ;; ($_ (println! (NegatedSubtree----------------- : $negatedSubtree)))
       ($reducedSubtree (cleanTree $negatedSubtree)  )
       ;; ($_ (println! (ReducedSubtree---------------: $reducedSubtree))) 
     )
     ;; TODO: Replace this with a robust check for subtree, one that is in accordance to the way the classic checks for subtrees.
     (if (List.contains $subtree $children)
         ($subtree (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ())))
         (if (List.contains $reducedSubtree $children)
             ($reducedSubtree (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ())))
             ((mkNullVex ($subtree)) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())))))))

;; Action subtree knobs store all selectable action permutations in the knob.
(= (actionSubtreeKnob $perms)
   ((mkNullVex $perms)
    (mkASK (mkDiscKnob (mkMultip (+ (length $perms) 1))
                       (mkDiscSpec 0)
                       (mkDiscSpec 0)
                       ())
           $perms)))

(= (simpleActionSubtreeKnob $subtree)
   ($subtree
    (mkASK (mkDiscKnob (mkMultip 2)
                       (mkDiscSpec 1)
                       (mkDiscSpec 1)
                       ())
           ($subtree))))
