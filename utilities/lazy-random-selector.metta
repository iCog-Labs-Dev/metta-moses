
;; pick -> Pick a random number which is not in the list
;; params:
;;        $lower: lower bound of the random number
;;        $upper: upper bound of the random number
;;        $picked: list of picked numbers
;; (: pick (-> Number Number Expression Number))
(= (pick $lower $upper $picked )
    (let $rand (py-call  (random.randint $lower $upper));;(random-int $lower $upper)  
        (if (is-member $rand $picked)
            (pick $lower $upper $picked)
            $rand
        )
    ) 
)

;; lazyRandomSelector -> Select $n random index of a list without replacement
;; params:
;;        $lower: lower bound of the random number
;;        $upper: upper bound of the random number
;;        $n: number of elements to select
;;        $picked: list of picked numbers
;;
;; Return a list of selected indexs as Expression 

;; (: lazyRandomSelector (-> Number Number Number Expression ))
(= (lazyRandomSelector $lower $upper $n) (lazyRandomSelector $lower $upper $n ()))
(= (lazyRandomSelector $lower $upper $n $picked)
    (let $totalSize (+ (- $upper $lower) 1)
        (if (> $n $totalSize)
            (Error $n "number of elements to select is greater than list size")
            (if (== $n 0)
                $picked
                (chain (pick $lower $upper $picked) $rand
                    (lazyRandomSelector $lower $upper (- $n 1) (cons-atom $rand $picked)))))
    )
)
