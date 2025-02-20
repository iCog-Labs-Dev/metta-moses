;; evaluate programs on sample data
;; params
;;       program/s
;;       sample data
;; output
;;       evaluated(scored) programs
;;       ex:(program $index $fitness) (program 18 0.09673923162099896)
!(bind! rnd (py-atom random))

;generate a random fitness score
(=(random_fit ())(
   (py-dot rnd random)
))

;gives programs a new fitness score 
;ex: !(fitness (program 11 0) 15) -> (program 11 15)
(=(fitness ($program $index $fitness) $newFitness)(
   $program $index $newFitness
))

;evaluates programs on the sample data
;this function doesn't actually use the sample data for the evaluation, 
;rather it gives a random score simulating the programs are being evaluated with their performance over the sample data
;(: evaluate (-> list list fitness))
(=(evaluate $population $dataset)
  (case $population
     (((program $index $fitness) (fitness $population (random_fit ())))
      ($population (collapse (fitness (superpose $population) (random_fit ()))))
     )
   )
)


;testcases
; !(random_fit ())
; !(fitness (program 11 0) 15)
; !(evaluate ( (program 11 0) (program 12 0) (program 15 0) (program 3 0) (program 2 0) (program 9 0) (program 10 0) (program 16 0) (program 1 0) (program 8 0) (program 5 0) (program 14 0) (program 4 0) (program 6 0) (program 18 0) (program 0 0)) ((data_point 8) (data_point 13) (data_point 21) (data_point 11)))