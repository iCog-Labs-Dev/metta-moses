(: someFunction (-> Number Number))
(: someFunction (-> Bool Number))
(: someFunction (-> Bool Number Bool))
(= (someFunction $x) (if (== (get-type $x) Bool) True 1))
(= (someFunction $x $y) (if $x (not (== $y 0)) (== $y 1)))

;; !(someFunction True 1)

(A (B C))
(B _)
(C D)
(D _)

;; A -> D
(A (B C))

;; B -> D
(B _)

;; C -> D
(C D)

;; D -> D
(A C D)

(: add (-> $a (List $a) (List $b)))
(: add (-> Number (List Number) (List Number)))
(: add (-> String (List String) (List String)))
(= (add $x $y $z $a $b) (+ $x (+ $y (+ $z (+ $a $b)))))

;; !(add 1 2 3 4 5)


(: Vect (-> Number Type Type))
(: Nil (Vect 0 $a))
(: Cons (-> $a (Vect $n $a) (Vect (+ 1 $n) $a)))

(: Row (List $t))
(: Table (List Row))

;; !(get-type (Cons 2 (Cons 1 Nil)))

(: addOnEmpty (-> (Vect (between 0 $inputSize) $a)))
(: ++ (-> (Vect $n $a) (Vect $m $a) (Vect (+ $n $m) $a)))
(= (++ Nil $ys) Nil)
(= (++ (Cons $x $xs) $ys) (Cons $x (++ $xs $ys)))
(= (($r $c $type) (get-type $table)))

;; !(not (and $a (or $b $c)))
;; !(py-atom (V("a")))

;; !(AND A (OR B (NOT C)))
;; !(get-type (AND A (OR B (NOT C))))
;; !(and $a (or $b (not $c)))
;; !(get-type (and a (or $b (not $c))))


(: And (-> Bool Bool))
(: And (-> Bool Bool Bool))
(= (And $x) $x)
(= (And $x $y) (and $x $y))

(: or (-> Bool Bool Bool))
;; !(get-type (Or $a $b))

(= (reduce ($0 $1 $2 $3 $4) $input) (let (quote $expression) $input $expression))
;; !(reduce (True False False False True))

;; !(get-metatype $head)

(: Distance Type)
(: mkDistance (-> Number Distance))

(: addDistance (-> Distance Distance Distance))
(= (addDistance (mkDistance $a) (mkDistance $b))
   (mkDistance (+ $a $b)))

;; (: List (-> Type Type))
;; (: Nil (List $a))
;; (: Cons (-> $a (List $a) (List $a)))

(= (append Nil) ...)
(= (append (Cons $x $xs)) ...)

(List (a b c d)) ;; (List Letter)
(Map ((k v) b c d)) ;; (Map Letter)
(Set (a b c d)) ;; (Set Letter)

(: A Bool)
(: B Bool)

;; (: List Type)
(: List (-> $a Type))
(: Nil (List $a))

(: (A B) P)
(: P Type)
(: ())

;; !(get-type (A B))

(: mkList (-> $l (List $a)))

;; !(get-type (mkList (1 2 3 4)))

;; !(get-type (mkList (1 2 3 4)))

(: Cons (-> $a (List $a) (List $a)))
;; (= (Cons $a Nil) (mkList ($a)))
;; (= (Cons $a (mkList $list)) (let $l (cons-atom $a $list) (mkList $l)))

;; !(Cons a (Cons 1 (Cons b Nil)))
;; !(get-type (Cons B (Cons A (Cons 3 Nil))))

(= (fromListToExpr $list) Expression)
(= (fromExprToList $list) Expression)

;; !(get-type (= 1 1))
(= 1 3)

;; !(= (= $x $x) T)

;; !(1)


;; !(get-type (mkList (1 2)))
;; !(Cons 1 (Cons 2 Nil))
;; !(get-type (Cons 1 (Cons 2 Nil)))

(: Map (-> (Type Type) Type))
(: Nil' (Map ($k $v)))

(: mkMap (-> ($k $v) $m (Map ($k $v))))
(: mkMap (-> $m (Map ($k $v))))

;; Adding the following might work
(: mkMap (-> ($k $v) $m (Map ($k $v))))
(= (mkMap ($k $v) $m) (mkMap $m))

;; This function definition doesn't work for a when calling for more than one function. That's when hte mkMap tries to take a type as input.
(: Cons' (-> ($k $v) (Map ($k $v)) (Map ($k $v))))
(= (Cons' ($k $v) Nil') (let ($kt $vt) ((get-type $k) (get-type $v)) (mkMap ($kt $vt) (($k $v)))))
(= (Cons' ($k $v) (mkMap ($kt $vt) $map)) (let ($l ($kt $vt)) ((cons-atom ($k $v) $map) ((get-type $k) (get-type $v))) (mkMap ($kt $vt) $l)))

;; This function was the original one that doesn't work for recursion.
;; Basically that's because MeTTa can't infer types and we need to
;; explicitly set the type of the map after the reduction of the Cons' function.
(: Cons' (-> ($k $v) (Map ($k $v)) (Map ($k $v))))
(= (Cons' ($k $v) Nil') (mkMap (($k $v))))
(= (Cons' ($k $v) (mkMap $map)) (let $l (cons-atom ($k $v) $map) (mkMap $l)))

(: Cons' (-> ($k $v) (Map ($k $v)) (Map ($k $v))))
(= (Cons' ($k $v) Nil') (mkMap ($k $v) (($k $v))))
(= (Cons' ($k $v) (mkMap $t $map)) (let $l (cons-atom ($k $v) $map) (mkMap ($k $v) $l)))

;; !(mkList (1 2 3 4))
;; !(mkList (1 2 3 A))

;; !(mkMap ((1 2) (2 3)))

;; !(Cons 1 (Cons 2 (Cons 3 (Cons 4 (Cons 5 (Cons 6 Nil))))))
;; !(Cons' (1 2) (Cons' (2 3) (Cons' (4 5) (Cons' (5 6) (Cons' (6 7) (Cons' (7 8) Nil'))))))
;; !(Cons' (1 2) (Cons' (2 3) Nil'))
;; !(Cons' (1 2) Nil')
;; !(let $m (mkMap (String Number) ()) (get-type $m))
;; !(let $m (Cons' (1 2) Nil') (get-type $m))
;; !(Cons' (1 2) (mkMap (Number Number) ((2 3))))

(: checkUnd (-> $a Type))

(: getFirst (-> (Map (Number Number)) Number))
(= (getFirst Nil') (Error (Map is empty)))
(= (getFirst (mkMap $map)) (let ($k $v) (car-atom $map) $v))

(: getFirst (-> (List Number) Number))
(= (getFirst Nil) (Error (List is empty)))
(= (getFirst (mkList $map)) (let $v (car-atom $map) $v))

;; !(get-type (Cons' (1 1) (Cons' (1 2) Nil')))
;; !(getFirst (Cons' (1 (checkUnd a)) (Cons' (1 2) Nil')))
;; !(getFirst (Cons 1 (Cons 2 Nil)))

(: addOne (-> (Map $k Number) (Map $k Number)))
(= (addOne Nil') Nil')
(= (addOne (mkMap $tt $map))
      (let*
          (
            ((($k $v) $t) (decons-atom $map))
            ($v' (+ 1 $v))
            ($mapp (mkMap $tt $t))
            (() (println! (Map: $mapp)))
            (() (println! (Maptype: (get-type $mapp))))
            ($t' (addOne $mapp))
            (() (println! (Updated tail: $t')))
          )
          (Cons' ($k $v') $t')
      )
)


(: addOne (-> (Map $k Number) (Map $k Number)))
(= (addOne Nil') Nil')
(= (addOne (mkMap $map))
      (let*
          (
            ((($k $v) $t) (decons-atom $map))
            ($v' (+ 1 $v))
            ($mapp (mkMap $t))
            ;; (() (println! (Map: $mapp)))
            ;; (() (println! (Maptype: (get-type $mapp))))
            ($t' (addOne $mapp))
            ($map' (cons-atom ($k $v') $t'))
            ;; (() (println! (Updated tail: $t')))
          )
          ;; (Cons' ($k $v') $t')
          (mkMap $map')
      )
)

(: addONe (-> (List Number) (List Number)))
(= (addONe Nil) Nil)
(= (addONe (mkList $list))
      (if (== $list ())
          ()
          (let*
              (
                (($h $t) (decons-atom $list))
                ($h' (+ 1 $h))
                ($tList (mkList $t))
                ($t' (addONe $tList))
                ($list' (cons-atom $h' $t'))
              )
              (mkList $list'))
      )
)

;; !(addONe (Cons 1 (Cons 2 Nil)))
;; !(addOne (Cons' (1 2) (Cons' (2 3) Nil')))
;; !(get-type (Cons' (1 2) (Cons' (2 3) Nil')))

;; !(get-type (Cons' (1 2) Nil'))
;; !(get-type (Cons' (1 2) (Cons' (2 3) (Cons' (4 5) (Cons' (5 6) (Cons' (6 7) (Cons' (7 8) Nil')))))))
;; !(let $map (Cons' (1 2) (Cons' (2 3) (Cons' (4 5) (Cons' (5 6) (Cons' (6 7) (Cons' (7 8) Nil')))))) (getFirst $map))
;; !(getFirst Nil')

;; !(Cons' (1 2) (mkMap ))
;; !(let $map (Cons' (1 2) (Cons' (2 3) (Cons' (4 5) (Cons' (5 6) (Cons' (6 7) (Cons' (7 8) Nil')))))) (addOne $map))


(: Or (-> Bool (-> Bool Bool)))
(: Or (-> Bool Bool Bool))
(= (Or $x $y) (or $x $y))
