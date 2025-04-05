;; Boolean Expression
;; Continuous Expression
;; Knob Values
;; NullVertex

(: List (-> $a Type))
(: Nil (List $a))
(: Cons (-> $a (List $a) (List $a)))

(: Tree (-> $a Type))
(: mkTree (-> (Node $a) (List (Tree $a)) (Tree $a)))
;; (AND A B)
;; (A Nil)
;; (B Nil)

(: Node (-> $a Type))
(: mkNode (-> $a (Node $a)))

(: NullVertex (Tree $a))
(: mkNullVex (-> (List (LSK $a)) (Tree $a)))
(: LSK (-> (Tree $a) ...))

(: A Bool)
;; (: AND (-> Bool Bool Bool))
;; (AND A (OR B C))
!(mkTree (mkNode AND) ;; 0
            (Cons
                (mkTree (mkNode A) Nil) (Cons ;; 0
                (mkTree (mkNode OR) (Cons (mkTree (mkNode B) Nil) (Cons (mkTree (mkNode C) Nil) Nil))) Nil))) ;; 1

;; (AND A (OR B C))
;; (mkTree (mkNode AND) (Cons (mkNullVec Nil) ()))
;; !(mkTree (mkNode A) (Cons (mkNullVex (Cons (mkKnob B) Nil)) Nil))
;; (mkTree (mkNode OR) (Cons () ()))
;; !(mkTree (mkNode B) Nil)
;; !(mkTree (mkNode C) Nil)
;;      AND
;;  A        OR
;;        B       C


!(get-type (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode B) Nil) (Cons (mkTree (mkNode C) Nil) Nil))) Nil))))

(: someTree (-> (Tree Bool) (Tree Bool)))
(= (someTree $tree) $tree)

;; !(someTree (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode B) Nil) (Cons (mkTree (mkNode C) Nil) Nil))) Nil))))

(: map (-> (-> $a $b) (List $a) (List $b)))
(= (map $f Nil) Nil)
(= (map $f (Cons $x $xs)) (Cons ($f $x) (map $f $xs)))

(: filter (-> (-> $a Bool) (List $a) (List $a)))
(= (filter $p Nil) Nil)
(= (filter $p (Cons $x $xs)) (if ($p $x) (Cons $x (filter $p $xs)) (filter $p $xs)))

(: listToExpr (-> (List $a) Expression))
(= (listToExpr Nil) ())
(= (listToExpr (Cons $x $xs)) (let $t (listToExpr $xs) (cons-atom $x $t)))

(: double (-> Number Number))
(= (double $x) (* 2 $x))

;; !(listToExpr (Cons 1 (Cons 2 Nil)))
;; !(map double (Cons 1 (Cons 2 Nil)))
;; !(map listToExpr (Cons (Cons 1 (Cons 2 Nil)) Nil))
;; !(listToExpr (Cons 1 (Cons 2 Nil)))
(: isEven (-> Number Bool))
(= (isEven $x) (== (% $x 2) 0))

(: isOdd (-> Number Bool))
(= (isOdd $x) (not (isEven $x)))

(: isUnit (-> $a Bool))
(= (isUnit $x) (== $x ()))

;; A trick to define `curry` in MeTTa without `lambda`
(: curry (-> (-> $a $b $c) (-> $a (-> $b $c))))
(= (((curry $f) $x) $y) ($f $x $y))

(: . (-> (-> $b $c) (-> $a $b) (-> $a $c)))
(= ((. $g $f) $x) ($g ($f $x)))

;; !(filter (. not isOdd) (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil)))))
;; !(filter (. not isEven) (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil)))))
;; !(filter (. not isUnit) (Cons A (Cons (OR B C) Nil)))

;; (AND A (OR B C))
;; (AND A (OR B C))
!(mkTree (mkNode AND) ;; 0
            (Cons
                (mkTree (mkNode A) Nil) (Cons ;; 0
                (mkTree (mkNode OR) (Cons (mkTree (mkNode B) Nil) (Cons (mkTree (mkNode C) Nil) Nil))) Nil))) ;; 1


;;      AND
;;  A        OR
;;        B       C

(: preOrder (-> (Tree $a) $a))
(= (preOrder (mkTree (mkNode $r) Nil)) $r)
(= (preOrder (mkNullVex $knobs)) ())
(= (preOrder (mkTree (mkNode $r) (Cons $x $xs)))
     (let*
         (
           ($lc  (map preOrder (Cons $x $xs))) ;; (Cons B (Cons C (Cons () Nil)))
           ($lc' (filter (. not isUnit) $lc)) ;; (Cons B (Cons C Nil))
           ($lcE (listToExpr $lc')) ;; (B C)
           ;; (()   (println! (Root: $r Children: $lc Children': $lc' Expression: $lcE)))
           ($exp (cons-atom $r $lcE)) ;; (OR B C)
         )
         $exp)
) ;; (AND A (OR B C))

!(preOrder (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode B) Nil) (Cons (mkTree (mkNode C) Nil) Nil))) Nil))))
;; !(get-type (preOrder (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode B) Nil) (Cons (mkTree (mkNode C) Nil) Nil))) Nil)))))

;; !(mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode B) Nil) (Cons (mkTree (mkNode C) Nil) Nil))) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) Nil))))
;; !(get-type (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode B) Nil) (Cons (mkTree (mkNode C) Nil) Nil))) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) Nil)))))

;; !(preOrder (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode OR) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode C) Nil) Nil))) Nil))))

;; !(preOrder (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode B) Nil) (Cons (mkTree (mkNode C) Nil) Nil))) (Cons (mkNullVex Nil) Nil)))))
