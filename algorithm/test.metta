! (bind! NTS (start expr bop uop term))
(= (isMemberTerminal $exp)
    (if (isLiteral $exp)
        (not (isMember $exp NTS))
        (let $a 
                (collapse (let $el (unNest $exp)
                            (not (isMember $el NTS))))
                (foldr and True $a))))
;;

(: foldr (-> (-> $a $b $b) $b $c $d))
(= (foldr $f $i $xs)
   (if (== $xs ())
       $i
       (let* (($h (car-atom $xs))
              ($t (cdr-atom $xs))
              ($ft (foldr $f $i $t)))
         ($f $h $ft))))
;;

(= (unNest $exp)
    (let $el (superpose $exp)
        (if (isLiteral $el)
            $el
            (unNest $el))))
;;

(= (isLiteral $a)
    (if (or (== (get-metatype $a) Grounded) (== (get-metatype $a) Symbol))
        True
        (if (== (car-atom $a) NOT)
            True
            False )))
;;

(= (isMember $x $list)
    (not (== (collapse (intersection (superpose ($x)) (superpose $list))) ()))
)

;; 

(= (flatten $exp) (collapse (unNest $exp)))

;;

(= (notMember $symbol $expr)
    (not (isMember $symbol $expr))
)

(= (isValidExp $exp)
    (if (== (get-metatype $exp) Symbol)
        (notNt $exp)
        (let*
            (
                ($f (flatten $exp))
                ($t (map notNt NTS $f))
            ) 
            (foldr and True $t)
        )))
;;
(: map` (-> (-> $a $a $b) $a $c $d))
(= (map` $f $x $xs)
   (if (== $xs ())
       ()
       (let* (($h (car-atom $xs))
              ($t (cdr-atom $xs))
              ($fh ($f $h $x))
              ($ft (map` $f $x $t)))
         (cons-atom $fh $ft))))

(= (add $x $y)
    (+ $x $y)
)

! (map` add 2 (1 2 3 4 5))

! (notMember 2 (1 2 3))

! (map` notMember (1 2 3) (2 4 1 3))

;; tests

; ! (notNt null)
; ! (isMemberTerminal (OR null A))

; ! (foldr and True (map notNt (OR A B)))
; ! (isValidExp (OR A B))
; ! (isValidExp (OR A (AND (NOT (NOT (NOT X))) B)))
; ! (isValidExp (NOT (AND B null)))
; ! (isValidExp (AND (OR (NOT null) null) null))