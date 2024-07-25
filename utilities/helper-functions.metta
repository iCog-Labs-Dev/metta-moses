; !(import! &self list)
!(import! &self tree-ds)

(= (check-not-duplicated $list)
    (case $list
        (
            (Nil True)
            ((Cons $x $xs)
                (if (member $x $xs)
                    False
                    (check-not-duplicated $xs)
                )
            )
        )
    )
)
(= (check-not-inverse-duplicated $list)
    (case $list
        (
            (Nil True)
            ((Cons $x $xs)
                (if (member-not $x $xs)
                    False
                    (check-not-inverse-duplicated $xs)
                )
            )
        )
    )
)
(=(isEmpty $exp)
    (if (== Nil $exp) True False)
)
(:intersect (-> List List List List))
(=(intersect $list1 $list2 $accumulator)
    (if (or (== $list1 Nil) (== $list2 Nil))
        $accumulator
        (case ($list1 $list2)
            (
                (((Cons $x $xs) (Cons $y $ys))
                        (let* (
                            ($is-x-member (member $x $ys))
                            ($is-y-member (member $y $xs))
                            )(if (and (== $is-x-member True) (== $is-y-member True))
                                (if (== $x $y)
                                    (intersect $xs $ys (append $accumulator (Cons $x Nil)))
                                    (intersect $xs $ys (append $accumulator (Cons $x (Cons $y Nil))))
                                )
                                (if (and (== $is-x-member True) (== $is-y-member False))
                                    (intersect $xs $ys (append $accumulator (Cons $x Nil)))
                                    (if (and (== $is-x-member False) (== $is-y-member True))
                                        (intersect $xs $ys (append $accumulator (Cons $y Nil)))
                                        (intersect $xs $ys $accumulator)
                                    )
                                )

                            )
                        )

      
                )
            )
        )

    )
)

(:union-set (->List List List List))
(=(union-set $list1 $list2)
    (remove-duplicates (append $list1 $list2))
)


(:cdr (-> List Atom))
(=(cdr ()) Nil)
(=(cdr (Cons $x $xs)) $xs)
(:car (-> List Atom))
(=(car ()) Nil)
(=(car (Cons $x $xs)) $x)


(=(check_tree_depth $data)
    (case $data (
            (($op $exp1 $exp2)
                
                 (+ 1 (max (check_tree_depth $exp1) (check_tree_depth $exp2)))
            )
            (($op $exp1) 1)
            ($_ 0)

        )
    )
)
(=(max $first-val $second-val)
    (if (> $first-val $second-val) $first-val $second-val
    )
)



(:get-children (-> Expression List List))
(= (get-children $exp $guard-set)
    (if (==(get-metatype $exp) Symbol)
        Nil
    (if (==(get-metatype $exp) Expression)
        (case $exp (
            (($op $exp1 $exp2)
                (let* (
                    ($type1 (get-metatype $exp1))
                    ($type2 (get-metatype $exp2))
                )
                (if (and (== $type1 Symbol) (== $type2 Symbol))
                    (append (Cons $exp1 (Cons $exp2 Nil)) $guard-set)
        
                    (if (and (== $type1 Symbol) (== $type2 Expression))
                        
                        (append (Cons $exp1 Nil) (get-children $exp2 $guard-set))
                    
                        (if (and (== $type1 Expression) (== $type2 Symbol))
                            (append (Cons $exp2 Nil) (get-children $exp1 $guard-set))
                            (append (get-children $exp1 $guard-set) (get-children $exp2 $guard-set))
                            
                        )
                    )

                )
            )
            )
    
            

        ))
        (ERROR the format is invalid)
    )
    
    )
)
(:get-guard-set (-> Expression List List))
(= (get-guard-set $exp)
        (case $exp (
            (($OP $exp1 $exp2)
            (let* (
                    ($type1 (get-metatype $exp1))
                    ($type2 (get-metatype $exp2)) 
                )
                (if (and (== $type1 Expression) (== $type2 Expression)) 
                    Nil
                    (if (== $OP AND)
                        (if (and (== $type1 Symbol) (== $type2 Symbol))
                            (Cons $exp1 (Cons $exp2 Nil))
                            (if (and (== $type1 Symbol) (== $type2 Expression))
                                (Cons $exp1 Nil)
                                (Cons $exp2 Nil)
                                
                            )
                        )
                        Nil
                    )
                )
            )
            )
            (($OP $exp)(
                (if (== NOT $exp) ($OP $exp) ERROR)
            ))
            ($exp (Cons $exp Nil))

        
    )
)
)
;; (=(get-dominant-set $exp)
;;     (case $exp (
;;             (($op $exp1 $exp2)
;;                 (if (== AND $op)
                   
                    
;;                 )
;;             )


;;         )
;;     )
;; )
(=(n-ary-and $exp)
    (case $exp (
            (Nil True)
            ((Cons $x $xs)
                (if (== $x True)
                    (n-ary-and $xs)
                    False
                )
            )

        )
    )
)

(=(n-ary-or $exp)
    (case $exp (
            (Nil False)
            ((Cons $x $xs)
                (if (== $x True)
                    True
                    (n-ary-or $xs)
                    
                )
            )

        )
    )
)
(=(is-subset $list1 $list2)
    (let* (
            ($min-list (if (> (length $list1) (length $list2)) $list2 $list1
                        ))

            ($max-list (if (> (length $list1) (length $list2)) $list1 $list2
                        ) )

        )(is-subset-ordered $min-list $max-list)
    )
   
)
(=(is-subset-ordered $min-list $max-list)
    (if (== $min-list Nil)
        True
        (case $min-list (
            ((Cons $x $xs)
                (if (member $x $max-list)
                    (is-subset-ordered $xs $max-list)
                    False
                )
            )


            )
        )
    )

)

;; !(is-subset (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil)))) (Cons 1 (Cons 2 (Cons 3  Nil))))
;;!(union-set (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil)))) (Cons 5 (Cons 6 (Cons 7 (Cons 1 Nil)))) )
;;!(intersect (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil)))) (Cons 5 (Cons 6 (Cons 7 (Cons 1 Nil)))) Nil)
;; !(n-ary-or (Cons False (Cons True (Cons False (Cons True Nil)))))
;; !(n-ary-and (Cons True (Cons True (Cons False (Cons True Nil)))))

;; main = print $ mergeSort [3, 6, 2, 7, 1, 5, 4]
;; !(quickSort (Cons 2 (Cons 1 (Cons 3 Nil))))
;; !(quickSort (Cons 3 (Cons 6 (Cons 2 (Cons 7 (Cons 1 (Cons 5 (Cons 4 Nil))))))))
;;!(intersection (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil)))) (Cons 1 (Cons 4 (Cons 5 (Cons 6 Nil)))) Nil)
;;!(get-type True)
;; !(cdr (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil)))))
;; !(get-children (AND (OR x1 x2) (AND x3 x4)) Nil)
;;!(get-guard-set (AND (OR x1 x2) (AND x3 x4)))
;;!(intersect (Cons a (Cons b (Cons c Nil))) (Cons c (Cons d (Cons e (Cons f Nil)))) Nil)
;;!(check_tree_depth (AND (OR x1 x2) (AND x3 x4)))
;;!(member 1 Nil)
;;!(add-three 1 2 3)
;;!(append (Cons a (Cons b (Cons c Nil))) (Cons c Nil))


; !(get-type LITERAL)

(: has-terminal-node (-> Tree Bool))
(= (has-terminal-node NilNode) False)
(= (has-terminal-node $node) (
    case $node (
        ( (TreeNode (Value $value $truthValue AND) NilNode NilNode $guardSet NilList) (
            unify $guardSet (ConsTree $singleNode NilList) True False
        ) )
        ( (TreeNode $nodeValue $left $right $guardSet $children) ( or (has-terminal-node $left) (has-terminal-node $right)) )
    )
    
))



!(has-terminal-node (TreeNode (Value Nil False OR) (TreeNode (Value Nil True AND) NilNode NilNode NilList NilList) (TreeNode (Value Nil False AND) NilNode (TreeNode (Value Nil False AND) NilNode NilNode (ConsTree (TreeNode (Value x True LITERAL) NilNode NilNode NilList NilList ) (ConsTree (TreeNode (Value x True LITERAL) NilNode NilNode NilList NilList ) NilList)) NilList) NilList NilList) NilList NilList) )














(: contains-terminal-node (-> TreeList Bool ))
(= (contains-terminal-node NilList) False)
(= (contains-terminal-node $treeList) (
    case $treeList (
        ( (ConsTree $t $ts) (or (has-terminal-node $t) (trace! (evaluating $ts ) (contains-terminal-node $ts))) )
        ; ($else (Invalid Expression--- $else))
    )
))


; !(buildTree (OR a (AND b c)))

; !(has-terminal-node (= tree1
;   (TreeNode
;     (Value Nil False AND)
;     (TreeNode
;       (Value x False LITERAL)
;       NilNode
;       NilNode
;       NilList
;       NilList
;     )
;     (TreeNode
;       (Value Nil False AND)
;       NilNode
;       NilNode
;       (ConsTree
;         (TreeNode
;           (Value b False LITERAL)
;           NilNode
;           NilNode
;           NilList
;           NilList
;         )
;         NilList
;       )
;       NilList
;     )
;     NilList
;   )
; )
;  )
; !(has-terminal-node (TreeNode (Value Nil False AND) (TreeNode (Value x False LITERAL) NilNode NilNode NilList NilList) (TreeNode (Value Nil False AND) (TreeNode (Value NilNode False OR) NilNode NilNode (ConsTree (TreeNode (Value x False LITERAL) NilNode NilNode NilList NilList) NilList ) NilList) (TreeNode (Value NilNode False AND) NilNode NilNode NilList NilList) NilList NilList) NilList NilList) ) 
; !(has-terminal-node (TreeNode (Value Nil False AND)
;     (TreeNode (Value x False LITERAL) NilNode NilNode NilList NilList)
;     (TreeNode (Value Nil False AND)
;         (TreeNode (Value NilNode False OR) NilNode NilNode (ConsTree (TreeNode (Value x False LITERAL) NilNode NilNode NilList NilList) NilList ) NilList)
;         (TreeNode (Value NilNode False AND) 
;             (TreeNode (Value Nil False AND)
;             (TreeNode (Value NilNode False AND) NilNode NilNode (ConsTree (TreeNode (Value x False LITERAL) NilNode NilNode NilList NilList) NilList ) NilList)
;             (TreeNode (Value NilNode False AND) NilNode NilNode NilList NilList)
;                 NilList
;                 NilList
;             ) 
;             NilNode NilList NilList)
;         NilList
;         NilList
;     )
;     NilList
;     NilList
; )
; )


; (ConsTree 
; (TreeNode (Value Nil False AND) (TreeNode (Value x False LITERAL) NilNode NilNode NilList NilList) (TreeNode (Value Nil False AND) (TreeNode (Value NilNode False OR) NilNode NilNode (ConsTree (TreeNode (Value x False LITERAL) NilNode NilNode NilList NilList) NilList ) NilList) (TreeNode (Value NilNode False AND) NilNode NilNode NilList NilList) NilList NilList) NilList NilList) NilList)


; !(contains-terminal-node
; (ConsTree 
;     (TreeNode (Value Nil False AND) (TreeNode (Value x False LITERAL) NilNode NilNode NilList NilList) (TreeNode (Value Nil False AND) (TreeNode (Value NilNode False AND) NilNode NilNode (ConsTree (TreeNode (Value x False LITERAL) NilNode NilNode NilList NilList) NilList ) NilList) (TreeNode (Value NilNode False AND) NilNode NilNode NilList NilList) NilList NilList) NilList NilList) 
;     (ConsTree (TreeNode (Value Nil False AND)
;     (TreeNode (Value x False LITERAL) NilNode NilNode NilList NilList)
;     (TreeNode (Value Nil False AND)
;         (TreeNode (Value NilNode False OR) NilNode NilNode (ConsTree (TreeNode (Value x False LITERAL) NilNode NilNode NilList NilList) NilList ) NilList)
;         (TreeNode (Value NilNode False AND) 
;             (TreeNode (Value Nil False AND)
;             (TreeNode (Value NilNode False AND) NilNode NilNode (ConsTree (TreeNode (Value x False LITERAL) NilNode NilNode NilList NilList) NilList ) NilList) ;this node fulfills the condition
;             (TreeNode (Value NilNode False AND) NilNode NilNode NilList NilList)
;                 NilList
;                 NilList
;             ) 
;             NilNode NilList NilList)
;         NilList
;         NilList
;     )
;     NilList
;     NilList
; ) NilList)
;     )
;  )

; !(has-terminal-node (TreeNode
;   (Value Nil False AND)
;   (TreeNode
;     (Value x False LITERAL)
;     NilNode
;     NilNode
;     NilList
;     NilList
;   )
;   (TreeNode
;     (Value Nil False AND)
;     NilNode
;     NilNode
;     (ConsTree
;       (TreeNode
;         (Value b False LITERAL)
;         NilNode
;         NilNode
;         NilList
;         NilList
;       )
;       NilList
;     )
;     NilList
;   )
;   NilList
; )
; )












(: update-guardSet (-> Tree TreeList Tree) )
(= (update-guardSet $node $new-guardSet) (
    let ($value $left $right $guardSet $children) $node  (TreeNode $value $left $right $new-guardSet $children)
))
(: update-tree (-> Tree NodeValue Tree))
(= (update-tree $tree $newValue)(
    let ($value $left $right $guardSet $children) $node  (TreeNode $newValue $left $right $new-guardSet $children)
))

(: changeTree (-> Tree Tree Tree))
(= (changeTree $tree $newTree)
    (case $newTree  (
            ((TreeNode $newValue $newLeft $newRight $newGuardSet $newChildren)
                $newTree
            )
            (NilNode NilNode)
            ($_ Error)

        )
    )
)