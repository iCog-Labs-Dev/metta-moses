;; Helper functions that are going to be useful for writing any metta code

(: ~= (-> Atom Atom Bool))
(= (~= $a $b) (not (== $a $b)))

;Function to cocatinate two tuples (A B) (C D) ==> (A B C D)
;(: cocatTuple (-> Expression Expression Expression))
 (= (concatTuple $xs $ys)
   (if (== $xs ())
       $ys
       (let* (($head (car-atom $xs)) 
              ($tail (cdr-atom $xs)) 
              ($tailNew (concatTuple $tail $ys)))
         (cons-atom $head $tailNew)
       )
   )
)
