! (bind! np-rnd (py-atom numpy.random))
;!(bind! &fortest (new-space))
(= (manuplate-space $opration $space $elements)(
    (superpose ($opration)) (superpose ($space)) (superpose $elements)
))

(= (isMember $x $tuple)
    (if (== $tuple ()) False
        (let*
            (
                ($head (car-atom $tuple))
                ($tail (cdr-atom $tuple))
            )
        (
            if (== $x $head) True (isMember $x $tail)
        )
)
)
)

;This Function Generates random n unique numbers from m numbers
(: random (-> Number Number list tuple))
(=($x) $x)
(=(random $num $range $list )(
  if(== $num 0)
    $list
    (let $item ((py-dot np-rnd randint) $range) (
      if(isMember $item $list)
        (random $num $range $list)
        ((let* (
               ($newlist (cons-atom $item $list))
               ($newNum (- $num 1))
               )
              (random $newNum $range $newlist)
       ))
    ))
  
))

;testcases
; !(manuplate-space add-atom &fortest (1 2 3))
; !(match &fortest $y $y)

; !(isMember 1 (1 2 3 ))
; !(random 10 100 ())