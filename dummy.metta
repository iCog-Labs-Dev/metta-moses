;; !(cons A (cons () ()))
;; !(cons-atom A (cons-atom (A) ()))
;; !(== $a $b)

;; (= (repeat $a $n)
;;    (if (== $n 0)
;;        ()
;;        (let $t (repeat $a (- $n 1)) (cons-atom $a $t))
;;    )
;; )

;; !(let ($A $B) ($A $B) (($A $B) (union-atom ($A) ($B))))
;; !(union-atom ($A) ($B))

;; (= (any $bools) (once (is-member True $bools))) ;; is-member needs to be used in a once as it returns boolean value for all matches.
;; (= (all $expressions) (if (once (is-member False $expressions)) False True))
;;
;; (= (AND $args) (all $args))
;; (= (OR  $args) (any $args))

;; !(AND ((A) (B) (OR (A) (B))))

;; (= (reduceCustom $expr) 
;;    (if (or (== $expr ()) (!= (get-metatype $expr) Expression))
;;        $expr
;;        (let*
;;          (
;;           ($tail (map-atom $expr $e (reduceCustom $e)))
;;          )
;;          (reduce $tail)
;;        )
;;    )
;; )
;;
;; !(let $h (quote (and True (or False True))) (reduceCustom $h))

!(map-atom (A B C) $a $b)
