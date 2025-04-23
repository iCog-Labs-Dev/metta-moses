
;; pick -> Pick a random number which is not in the list
;; params:
;;        $lower: lower bound of the random number
;;        $upper: upper bound of the random number
;;        $picked: list of picked numbers
(: pick (-> Number Number Expression Number))
(= (pick $lower $upper $picked )
    (let $rand ((py-atom random.randint) $lower $upper)       ;; (random-int $lower $upper) 
        (if (isMember $rand $picked)
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
    (chain (pick $lower $upper $picked ) $rand 
        (if  (== $n 0) 
            $picked
            (if  (< (+ (- $upper $lower) 1) (+ (size-atom $picked) $n))
                (Error break "number of elements to select is greater than list size")
                (let $picked_ (cons-atom $rand $picked) (lazyRandomSelector $lower $upper (- $n 1) $picked_))
            )
        )
    )
)
