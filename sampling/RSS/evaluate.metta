!(bind! rnd (py-atom random))

;;generate a random fitness score
(=(randomFit ())(
   (py-dot rnd random)
))

;;gives programs a new fitness score 
;;ex: !(fitness (program 11 0) 15) -> (program 11 15)
;;(: fitness (-> program Number program))
(=(fitness ($program $index $fitness) $newFitness)(
   $program $index $newFitness
))

;;evaluates programs on the sample data
;;this function doesn't actually use the sample data for the evaluation, 
;;rather it gives a random score simulating the programs are being evaluated with their performance over the sample data
;; params
;;       program/s(list)
;;       sample data(lilst)
;; output
;;       evaluated(scored) program/s(list)
;;       ex:(program $index $fitness) (program 18 0.09673923162099896)
;;(: evaluate (-> list list list))
(=(evaluate $population $dataset)
  (case $population
     (((program $index $fitness) (fitness $population (randomFit ())))
      ($population (collapse (fitness (superpose $population) (randomFit ()))))
     )
   )
)


;; testcases
;; !(randomFit ())
;; !(fitness (program 11 0) 15)
;; !(evaluate ( (program 11 0) (program 12 0) (program 15 0) (program 3 0) (program 2 0) (program 9 0) (program 10 0) (program 16 0) (program 1 0) (program 8 0) (program 5 0) (program 14 0) (program 4 0) (program 6 0) (program 18 0) (program 0 0)) ((data_point 8) (data_point 13) (data_point 21) (data_point 11)))