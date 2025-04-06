;; Ordered set type definition
(: OS (-> $a Type))
(: NilOS (OS $a))
(: ConsOS (-> $a (OS $a) (OS $a)))

;; Insert an element into an ordered set
;; Takes a comparison comparator 
;;      -- restriction on the comparison comparator here is that the 
;;      -- comparator has to return the result of the comparison comparator in terms of symbol atoms as decribed below
;;      G -- strictly greater than, E -- equal to, L -- strictly lower than
(: OS.insert (-> (-> $a $a Atom) $a (OS $a) (OS $a)))
(= (OS.insert $comparator $x NilOS) (ConsOS $x NilOS))
(= (OS.insert $comparator $new (ConsOS $x $xs))
    
    (case ($comparator $new $x)
        ((G (ConsOS $new (ConsOS $x $xs)))
         (E (ConsOS $x $xs))
         (L (ConsOS $x (OS.insert $comparator $new $xs))))))

;; Exemplar comparator
(: cmprXmplr (-> Xmplr Xmplr Atom))
(= (cmprXmplr 
        (mkXmplr $tree1 (mkDemeId $id1) (mkCscore (mkScoreT $s1) (mkComplexity $cs1) (mkScoreT $cp1) (mkScoreT $up1)) (mkBscore $bs1))
        (mkXmplr $tree2 (mkDemeId $id2) (mkCscore (mkScoreT $s2) (mkComplexity $cs2) (mkScoreT $cp2) (mkScoreT $up2)) (mkBscore $bs2)))
    
    (let ($p1 $p2) ((- (- $s1 $cp1) $up1) (- (- $s2 $cp2) $up2))
        (case ((> $p1 $p2) (== $p1 $p2) (< $cs1 $cs2) (== $cs1 $cs2))
            
            (((True $t $u $v) G)
            ((False True True $v) G)
            ((False True False True) E)
            ((False True False False) L)
            ((False False $u $v) L) ))))

;; Number compartor
(: cmprNum (-> Number Number Atom))
(= (cmprNum $num1 $num2)
    (case ((> $num1 $num2) (== $num1 $num2))
        (((True $t) G)
         ((False True) E)
         ((False False) L))))

;; Length of an OS
(: OS.length (-> (OS $a) Number))
(= (OS.length NilOS) 0)
(= (OS.length (ConsOS $x $xs)) (+ 1 (OS.length $xs)))

;; Get by index
! (bind! INDEX_ERROR "empty set/index out of range")

;; OS.getByIndx -- get by index
(: OS.getByIdx (-> Number (OS $a) $a)) 
(= (OS.getByIdx $idx NilOS) (Error $idx INDEX_ERROR))
(= (OS.getByIdx $idx (ConsOS $x $xs)) 
    (if (== $idx 0)
        $x
        (OS.getByIdx (- $idx 1) $xs)))

;; Cull dominated exemplars from the ordered set of exemplars
;; OS.removen -- removes number of exemplars from the end of the ordered set
(: OS.removen (-> Number (OS $a) (OS $a)))
(= (OS.removen $n NilOS) (Error $n INDEX_ERROR))
(= (OS.removen $n (ConsOS $x $xs))
    (let $l (OS.length (ConsOS $x $xs))
        (if (== $l $n)
            NilOS
            (ConsOS $x (OS.removen $n $xs)))))