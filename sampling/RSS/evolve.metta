; Checks if a program is fit (fitness ≥ 0.5) and returns the program or (). 
(=(isFit ($program $index $fitness))(
   if ( >= $fitness 0.50) 
       ($program $index $fitness)
       (empty)
   )
)

;filters a list of programs based on their fitness
(= (filter $list)
   (
      case $list
      (
         ((program $index $fitness) $list)
         ($list (collapse (isFit (superpose $list))))
      )
   )
   
)

;return the fittest programs if there are any, if not, return the list it self for it to be evaluated 
;over another sample dataset
;(: evolve (-> list list fitness))
(=(evolve $population)
(let $program (filter $population)
  (if (== $program ())
       $population
       $program
   )
)
  
)

;testcases
; !(evolve ((program 31 0.514647685599923)(program 31 0.014647685599923)))
; !(isFit (program 7 0.7))
; !(filter ((program 7 0.9) (program 7 0.2) (program 7 0.2)))

