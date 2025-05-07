!(register-module! ../../metta-moses)

! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:utilities:list-methods)

(: uniqueAtom (-> Expression Expression))
(= (uniqueAtom $expr) (unique-atom $expr))

;; helper function to generate list of numbers ranging from 0 to n
(: genList (-> Number Expression))
(= (genList $u) (genList 0 $u))

(: genList (-> Number Number Expression))
(= (genList $l $u)
    (if (< $u $l)
        ()
        (let $res (genList $l (- $u 1))
            (cons-atom $u $res) )
    )
)

(: varyNKnobs (-> Multiplicity Instance Number  (List Instance)))
(= (varyNKnobs (mkMultip $m) (mkInst (Cons $x $xs)) $dist) ;; 0 0 0 0
    (if (== $dist 0)
        (Cons (mkInst (Cons $x $xs)) Nil)
        (let $multips (genList 1 (- $m 1))
        (let $instExp (collapse (vary1Knobs $multips (Cons $x $xs)))
        (let $instExp' (unique-atom $instExp)
        (let $accInst (collapse (let
                                   $nextCenterInst (superpose $instExp')
                                   (varyNKnobs (mkMultip $m) (mkInst $nextCenterInst) (- $dist 1))))
        (let $accInst' (collapse (let $a (superpose $accInst) (List.remove (mkInst (Cons $x $xs)) $a))) ;; 
        (let () (println! (Finished generating neighborhood of (mkInst (Cons $x $xs)) at distance: $dist)) 
          (foldl-atom $accInst' Nil $acc $i (List.extend $i $acc))))))))
        ; (let*
        ;    (
        ;      ($multips (genList 1 (- $m 1)))
        ;      ($instExp (collapse (vary1Knobs $multips (Cons $x $xs))))
        ;      ($instExp' (unique-atom $instExp))
        ;      ($accInst (collapse (let
        ;                     $nextCenterInst (superpose $instExp')
        ;                     (varyNKnobs (mkMultip $m) (mkInst $nextCenterInst) (- $dist 1)))))
        ;      ($accInst' (collapse (let $a (superpose $accInst) (List.remove (mkInst (Cons $x $xs)) $a)))) ;; Neighborhood shouldn't contain the center instance
        ;      (() (println! (Finished generating neighborhood of (mkInst (Cons $x $xs)) at distance: $dist)))
        ;    )
        ;     (foldl-atom $accInst' Nil $acc $i (List.extend $i $acc))) ;; Flattening the expression to list of lists
    ))

(: vary1Knobs (-> Expression (List Number) (List Number)))
(= (vary1Knobs $multips Nil) (empty))
(= (vary1Knobs $multips (Cons $x $xs))
   (let $i (superpose $multips) (superpose ((Cons (if (== $i $x) 0 $i) $xs) (Cons $x (vary1Knobs $multips $xs))))))

;; !(println! (let $a (collapse (vary1Knobs (1 2) (Cons 1 (Cons 0 (Cons 2 (Cons 0 Nil)))))) (let $b (uniqueAtom $a) (superpose $b))))
;; !(println! "")
;; !(println! (let $a (collapse (vary1Knobs (1 2) (Cons 0 (Cons 0 (Cons 0 (Cons 0 Nil)))))) (let $b (uniqueAtom $a) (superpose $b))))

(: distance (-> Instance Instance Number) )
(= (distance (mkInst $inst1) (mkInst $inst2))
      (let $expr1 (List.listToExpr $inst1)
      (let $expr2 (List.listToExpr $inst2)
        (if (== (size-atom $expr1) (size-atom $expr2))
            (let $diff (subtraction-atom $expr1 $expr2) (size-atom $diff))
            (Error ($expr1 $expr2) InvalidLengthOfExpressions)))))

;; !(List.map ((curry distance) (mkInst (Cons 0 (Cons 0 (Cons 0 (Cons 0 Nil)))))) (varyNKnobs (mkMultip 3) (mkInst (Cons 0 (Cons 0 (Cons 0 (Cons 0 Nil))))) 1))
!(List.length (varyNKnobs (mkMultip 3) (mkInst (Cons 0 (Cons 0 (Cons 0 (Cons 0 Nil))))) 2))
