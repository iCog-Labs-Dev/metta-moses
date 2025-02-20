;; Checks if a program is fit (fitness ≥ 0.5) and returns the program itself(if it's fit) or ()(if it's not). 
;; params
;;       program
;; output
;;       program or ()
(=(isFit ($program $index $fitness))(
   if ( >= $fitness 0.50) 
       ($program $index $fitness)
       (empty)
   )
)

;; filters a list of programs based on their fitness
;; params
;;       program/s
;; output
;;       fit program/s
(= (filter $list)
   (
      case $list
      (
         ((program $index $fitness) $list)
         ($list (collapse (isFit (superpose $list))))
      )
   )
   
)

;; return the fittest programs if there are any, if not, return the list it self for it to be evaluated 
;; over another sample dataset
;; params
;;       program/s
;; output
;;       fit program/s
;; (: evolve (-> list list))
(=(evolve $population)
(let $program (filter $population)
  (if (== $program ())
       $population
       $program
   )
)
  
)

;; testcases
;; !(evolve ((program 31 0.514647685599923)(program 31 0.014647685599923)))
;; !(isFit (program 7 0.7))
;; !(filter ((program 7 0.9) (program 7 0.2) (program 7 0.2)))

