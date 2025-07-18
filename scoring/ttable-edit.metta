(= (adjustTruthTable $candidateArgs (mkITable $dataRows $labels))
    (chain (argsFromTableHeader $labels) $totalArgs ;; use List.listToExpr instead of defining a new function for the same purpose
        (chain (subtraction-atom $totalArgs $candidateArgs) $diff ;; find the differing args list -- currently subtraction-atom in mettalog appears to maintain the order of atoms in the first tuple when computing the difference -- if this behaviour changes this will not work
            (chain (map-getIndexOf $diff $labels) $indices ;; 
                (chain (map-dropAt $dataRows $indices) $newDataRows
                    (chain (List.dropAt $labels $indices) $newLabels
                        (mkITable $newDataRows $newLabels)))))))
        
;; the output lable is the last one, so collect everyting except the last label
;; error in the logic -- not necessary to drop the output label -- jsut keep it as well
(: argsFromTableHeader (-> (List $a) Expression))
(= (argsFromTableHeader (Cons $x $xs))
    (unify $xs Nil () ;; means we have reached the end of the list including the output label
            (chain (argsFromTableHeader $xs) $res ;; else keep on collecting args from the list and append them
                (cons-atom $x $res))))

(: map-getIndexOf (-> Expression (List $a) Expression))
(= (map-getIndexOf $diff $labels) ;; get indices of those features in the truth table but not in the tree
    (if-decons-expr $diff $h $t
        (chain (map-getIndexOf $t $labels) $res
            (chain (List.getIndexOf $h $labels) $h-mapped
                (if-error $h-mapped $h-mapped 
                    (cons-atom $h-mapped $res))))
                ()))

;; return the index of a symbol in the list        
(: List.getIndexOf (-> $a (List $a) Number))        
(= (List.getIndexOf $el $list)
    (unify $list Nil
        (Error $el "Not found in label list/Empty list")
        (unify $list (Cons $x $xs)
            (if (== $x $el)
                0
                (chain (List.getIndexOf $el $xs) $res 
                    (if-error $res $res (+ 1 $res))))
            (Empty))))

;; apply the drop function over range of indices given as tuple of numbers
(: List.dropAt (-> (List $a) Expression (List $a)))
(= (List.dropAt $list $indices)
   (if-decons-expr $indices $h $t
        (unify $list Nil 
            Nil
            (unify $list (Cons $x $xs)
                (if (== $h 0)
                    (chain (map dec $t) $updated-indices ;; after each removal the remaining indices must be upadated by decrementing 1 from each
                        (List.dropAt $xs $updated-indices))
                    (chain (map dec $indices) $updated-indices ;; if no removal occured update the whole indices tuple
                        (chain (List.dropAt $xs $updated-indices) $res
                            (Cons $x $res))))
                    ())) ;; is there anything to fix here?? what to do instead of leaving it () ?? 🤔
        $list))

;; mapping List.dropAt it over all the rows
;; now map-dropAt takes tuple of indices instead of jsut an index
(: map-dropAt (-> (List (List $a)) Expression (List (List $a))))
(= (map-dropAt $dataRows $indices)
   (unify $dataRows Nil
        Nil
        (unify $dataRows (Cons $x $xs)
            (chain (List.dropAt $x $indices) $first-row-modified
                (chain (map-dropAt $xs $indices) $rest-adjusted 
                    (Cons $first-row-modified $rest-adjusted)))
                ())))                

(: map (-> (-> $a $a) Expression Expression))     
(= (map $f $expr)
    (if-decons-expr $expr $h $t
        (chain ($f $h) $h-mapped
            (chain (map $f $t) $t-mapped
                (cons-atom $h-mapped $t-mapped)))
            ()))

;; decrement operator
(: dec (-> Number Number))            
(= (dec $n) (- $n 1)) 
