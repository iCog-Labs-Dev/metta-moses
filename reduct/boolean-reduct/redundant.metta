
; This function assumes it receives a dominant set and the current expression as parameters. 
; It then removes redundant guard sets from the current expression that already exist in the dominant set. 
; The dominant set should be the set of guard sets of the parent AND nodes for the current AND node.
; This function also can be used for lCCSUBTRACT transformation with command set and current expression given as a parameter.
; The function uses isMember from general helpers functions.


(: setDifference (-> Expression Expression Expression))
(= (setDifference $dominantSet $current) 
    (if (== $current ()) () ; Base case: return empty list when $current is empty
        (let* (
            ($head (car-atom $current))  ; Extract the head of the current set
            ($tail (cdr-atom $current))  ; Extract the tail of the current set
            ($newtail (setDifference $dominantSet $tail))  ; Recursively process the tail
        )
            ; Check if the $head is in the dominantSet, if so, skip it
            (if (isMember $head $dominantSet) 
                $newtail 
                ; Otherwise, add the head to the new tail, avoiding unnecessary parentheses
                (if (== (get-metatype $newtail) Expression) 
                    (cons-atom $head $newtail)
                    $head)  ; Avoid wrapping the head if it's already properly structured
            )
        )
    )
)
