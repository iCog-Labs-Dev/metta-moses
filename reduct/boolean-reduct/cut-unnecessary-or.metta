;; A function to remove an unnecessary OR and its child.
;; Preconditions: The point of application (POA) has only one child.
;; Action: If the preconditions are met, the function adds the POA's
;;            grandChildren to the POA's parent and removes the POA
;;            from parent. It then returns the updated parent, an
;;            empty atom and a boolean value of true. If conditions 
;;            are not met, it returns the state unchanged.
;; Example: input: POA ==> (OR (AND (NOT D))), parent => (AND B (OR (AND (NOT D))))
;;          output: ((AND B (NOT D)) () True)
; (: orCut (-> Expression Expression (Expression Expression Bool)))
(= (orCut $parent $current)
   ;; (let*
   ;;   (
   ;;    ;; ($log (println! (==== Inside OrCut ====)))
   ;;    ;; ($log' (println! (Parameters ==> Parent: $parent Current: $current)))
   ;;   )
     ;; guarded if-chain: shape checks with == never bind label vars
     (if (and (== (get-metatype $current) Expression) (not (== $current ())))
         (let ($h $t) (decons-atom $current)
           (if (== $h OR)
               (if (== $t ())
                   ($parent $current False)                  ;; (OR) — no child
                   (if (== (cdr-atom $t) ())                 ;; exactly one child
                       (let $x (car-atom $t)
                         (if (isLeaf $x)
                             ((addLiterals (subAll $parent ($current)) ($x)) () True)
                             (if (== (car-atom $x) NOT)
                                 ((addLiterals (subAll $parent ($current)) ($x)) () True)
                                 ((addChildren (subAll $parent ($current)) (getSubExpression $x)) () True))))
                       ($parent $current False)))            ;; multiple children
               ($parent $current False)))                    ;; not an OR node
         ($parent $current False))                           ;; leaf / () POA
   ;; )
)

;; A function to return the literals and children of any given node.
;; It is used for cases where we need all the subExpressions of AND & OR nodes.
;;    Expressions like (NOT A) doesn't have any subExpression and are treated as a literal.
; (: getSubExpression (-> Expression Expression))
(= (getSubExpression $exp)
   ;; (NOT $a) is considered as a literal hence has no subExpression.
   (if (isNotHeaded $exp)
       ()
       (let*
         (
           ($literals (getLiterals $exp))
           ($children (getChildrenExp $exp))
         )
         (concatTuple $literals $children)
       )
   )
)

;; A helper function used to apply orCut function in the until function.
;; This function keeps the state of the until function updated for a single function application.
; (: applyOrCut (-> (Expression Bool (Expression Expression)) (Expression Bool (Expression Expression))))
(= (applyOrCut ($parent $bool ($child $remainingChildren)))
      (let*
        (
          (($updatedParent $updatedChild $appliedOrCut) (orCut $parent $child))
          ($nextChild (if (~= $remainingChildren ()) (car-atom $remainingChildren) ()))
          ($restChildren (if (~= $remainingChildren ()) (cdr-atom $remainingChildren) ()))
        )
        ($updatedParent (or $appliedOrCut $bool) ($nextChild $restChildren))
      )
)

