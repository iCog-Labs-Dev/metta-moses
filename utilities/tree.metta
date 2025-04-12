(: Tree (-> $a Type))
(: mkTree (-> (Node $a) (List (Tree $a)) (Tree $a)))

(: Node (-> $a Type))
(: mkNode (-> $a (Node $a)))

(: NullVertex (Tree $a))
(: mkNullVex (-> (List (Tree $a)) (Tree $a)))

(: preOrder (-> (Tree $a) $a))
(= (preOrder (mkTree (mkNode $r) Nil)) $r)
(= (preOrder (mkNullVex $knobs)) ())
(= (preOrder (mkTree (mkNode $r) (Cons $x $xs)))
     (let*
         (
           ($lc  (List.map preOrder (Cons $x $xs)))
           ($lc' (List.filter (. not isUnit) $lc))
           ($lcE (List.listToExpr $lc'))
           ;; (()   (println! (Root: $r Children: $lc Children': $lc' Expression: $lcE)))
           ($exp (cons-atom $r $lcE))
         )
         $exp)
)

(: buildTree (-> $a (Tree $a)))
(= (buildTree $expr)
        (if (== (get-metatype $expr) Expression)
            (let ($head $tail) (decons-atom $expr)
                (mkTree (mkNode $head) (exprToList (map buildTree $tail))))
            (mkTree (mkNode $expr) Nil))
            )