;; =====================================================================
;;               Univariate Optimization Algorithm
;; =====================================================================
;;
;;  This implementation performs probabilistic, univariate optimization 
;;  inspired by Estimation of Distribution Algorithms (EDA) used in MOSES.
;;  It evolves a population of candidate solutions by learning a simple 
;;  probability model from the best-performing instances and generating 
;;  new ones based on this learned distribution.
;;
;;  The main workflow:
;;    1. Initialize a random population of instances.
;;    2. Evaluate and score each instance using a fitness function.
;;    3. Select the top-performing instances (tournament selection).
;;    4. Learn a univariate probability model from selected instances.
;;    5. Sample new instances using this probability model (Roulette-Wheel selection.).
;;    6. Replace the worst-performing old instances with new ones.
;;    7. Repeat until convergence or the maximum generation limit is reached.
;;
;; =====================================================================

; Generates an initial population (list of scored instances).
; Each instance has a random structure and is assigned the worst initial score.
; Params:
;   $instLength — length of each instance.
;   $nGenerate — number of instances to generate.
; Returns: List of mkSInst objects representing the population.
; (: generateInitialSample (-> Number Number List))
(= (generateInitialSample $instLength $nGenerate)
   (if (== $nGenerate 0)
       Nil
       (Cons (mkSInst (mkPair (mkInst (eval (generateRandomInstance $instLength))) (worstCscore))) (eval (generateInitialSample $instLength (- $nGenerate 1))))))

; Recursively performs tournament comparison to pick the best instance.
; Randomly selects another instance and keeps the better one based on score.
; Params:
;   $instSet — full set of instances.
;   $res — current best candidate.
;   $tSize — remaining number of comparisons to perform.
; Returns: The best mkSInst found after all comparisons.
; (: tournamentCompare (-> (InstanceSet $score) (ScoredInstance $score) Number (ScoredInstance $score)))
(= (tournamentCompare (mkSInstSet $instSet) $res $tSize)
(if (== $tSize 0) $res
(let*
  (
    ($instSetLen (eval (List.length $instSet)))
    ($tmp (eval (List.getByIdx $instSet (random-int 0 (- $instSetLen 1)))))
    ($updatedRes (if (eval (cScore>= (getSInstScore $tmp) (eval (getSInstScore $res)))) $tmp $res))
  )
  (eval (tournamentCompare (mkSInstSet $instSet) $updatedRes (- $tSize 1))))))

; Selects the best individuals from a set using tournament selection.
; Randomly samples $tSize individuals and keeps the best one, repeating $nSelect times.
; Params:getSInstScore
;   $instSet — the full set of scored instances.
;   $tSize — tournament size (number of competitors per selection).
;   $nSelect — number of individuals to select.
;   $selectedList — accumulator list for results (initially Nil).
; Returns: List of selected mkSInst objects.
; (: tournamentSelection (-> (InstanceSet $score) Number Number List List))
(= (tournamentSelection (mkSInstSet $instSet) $tSize $nSelect $selectedList)
(if (== $nSelect 0) $selectedList
(let*
  (
    ($_ (println! (Tournament selection, remaining to select:  $nSelect)))
    ($instSetLen (eval (List.length $instSet)))
    ($_ (println! (Instance set length:  $instSetLen)))
    ($res (eval (List.getByIdx $instSet (random-int 0 $instSetLen))))
    ($_ (println! (Initial random candidate:  $res)))
    ($updatedRes (tournamentCompare (mkSInstSet $instSet) $res (- $tSize 1)))
    ($_ (println! (Selected candidate:  $updatedRes)))

  )
  (tournamentSelection (mkSInstSet $instSet) $tSize (- $nSelect 1) (Cons $updatedRes $selectedList)))))

; Extracts the value of the nth knob (field) from each instance expression.
; Builds a list of the values at the same index position across all instances.
; Params:
;   $instsExp — list of instance expressions ((inst score) ...).
;   $noInsts — total number of instances.
;   $nthInstCtr — current instance index (loop counter).
;   $nthKnobCtr — index of the knob/field to extract.
;   $acc — accumulator for collected field values.
; Returns: List of field values for the specified knob position.
; (: getNthInstFields (-> Expression Number Number Number Expression Expression))
(= (getNthInstFields $instsExp $noInsts $nthInstCtr $nthKnobCtr $acc)
   (if (== $nthInstCtr $noInsts)
       $acc
       (let* (
           ($nthInst (index-atom $instsExp $nthInstCtr))
           (($inst $score) $nthInst)
           ($nthKnob (index-atom $inst $nthKnobCtr))
           ($rest (getNthInstFields $instsExp $noInsts (+ $nthInstCtr 1) $nthKnobCtr $acc))
         )
         (cons-atom $nthKnob $rest)
       )
   )
)

; Collects field values for all knob indices across all instances.
; Calls getNthInstFields for each knob position and accumulates the results.
; Params:
;   $instsExp — list of instance expressions ((inst score) ...).
;   $instLength — number of knobs (fields) per instance.
;   $noInsts — total number of instances.
;   $n — current knob index (loop counter).
;   $acc — accumulator for tuples of field values.
; Returns: List of lists, where each sublist contains all values for one knob position.
; (: instsToFieldValues (-> Expression Number Number Number Expression Expression))
(= (instsToFieldValues $instsExp $instLength $noInsts $n $acc)
     (if (== $n $instLength)
         $acc
         (let* (
             ($nthFields (eval (getNthInstFields $instsExp $noInsts 0 $n ())))
             ($rest (instsToFieldValues $instsExp $instLength $noInsts (+ $n 1) $acc))
           )
           (cons-atom $nthFields $rest)
         )
     )
)

; Learns the frequency of each possible field value (0, 1, 2) for every knob (field) across all instances.
; Used later to derive probability-based sampling distributions.
; Params:
;   $fieldVals — list of tuples; each tuple contains all field values for one knob index across all instances.
;   $acc — accumulator for probability counts.
; Returns: List of tuples (count0, count1, count2) for each field position.
; (: learnProbability (-> Expression Expression Expression))
(= (learnProbability $fieldVals $acc)
   (if (== $fieldVals ())
       $acc
       (let* (
           ($fieldVal (car-atom $fieldVals))
           ($count0 (count 0 $fieldVal))
           ($count1 (count 1 $fieldVal))
           ($count2 (count 2 $fieldVal))
           ($rest (learnProbability (cdr-atom $fieldVals) $acc))
         )
         (cons-atom ($count0 $count1 $count2) $rest)
       )
   )
)
;; Helper function for roulette-wheel selection.
;; Recursively checks cumulative counts to find the selected field index.
;; Params:
;;   $fieldCount — tuple of counts (count0, count1, count2) for one knob.
;;   $ctr — index counter (initially 0).
;;   $ajstdSum — adjusted random sum for selection.
;; Returns: The selected field index (0, 1, or 2).
; (: roulette_helper (-> Expression Number Number Number))
(= (roulette_helper $fieldCount $ctr $ajstdSum)
(if (== $fieldCount ()) (- $ctr 1)
(if (<= (- $ajstdSum (car-atom $fieldCount)) 0) $ctr
      (roulette_helper (cdr-atom $fieldCount) (+ $ctr 1) (- $ajstdSum (car-atom $fieldCount))))))

; Selects one field value (0, 1, or 2) using roulette-wheel selection.
; The selection is proportional to the frequency of each field value.
; Params:
;   $fieldCount — tuple of counts (count0, count1, count2) for one knob.
;   $tot — total sum of all counts (used to scale random selection).
;   $ctr — index counter (initially 0).
; Returns: The selected field index (0, 1, or 2).
; (: roulette_select (-> Expression Number Number Number))
(= (roulette_select $fieldCount $tot $ctr)
(let*
  (
    ($rndfloat (randomFloat))
    ($ajstdSum (* $tot $rndfloat)))
  (roulette_helper $fieldCount $ctr $ajstdSum)
))

; Samples a single instance based on the learned probability model.
; For each knob, selects one value using roulette selection.
; Params:
;   $probabilityModel — list of tuples [(count0, count1, count2), ...]
;                            representing each knob’s distribution.
;   $tot — total count sum for normalization in roulette selection.
;   $acc — accumulator for the selected field values.
; Returns: A list representing one sampled instance (e.g., (2 0 1)).
; (: sample (-> Expression Number Expression Expression))
(= (sample $probabilityModel $tot $acc)
   (if (== $probabilityModel ())
       $acc
       (let* (
           ($fieldCount (car-atom $probabilityModel))
           ($selectedFieldVal (eval (roulette_select $fieldCount $tot 0)))
           ($rest (sample (cdr-atom $probabilityModel) $tot $acc))
         )
         (cons-atom $selectedFieldVal $rest)
       )
   )
)

; Generates multiple sampled instances using the probability model.
; Each instance is generated by 'sample' and given a default (worst) score.
; Params: 
;   $probabilityModel — learned probability model for all knobs.
;   $nGenerate — number of instances to generate.
;   $tot — total count sum used in selection.
;   $acc — accumulator for the generated scored instances.
; Returns: List of scored instances: [((inst) (worstCscore)), ...].
; (: sampleInsts (-> Expression Number Number Expression Expression))
(= (sampleInsts $probabilityModel $nGenerate $tot $acc)
(if (== $nGenerate 0) $acc
    (let $sampledInst (eval (sample $probabilityModel $tot ()))
         (sampleInsts $probabilityModel (- $nGenerate 1) $tot (cons-atom ($sampledInst (worstCscore)) $acc))
)))


; Replaces the worst-performing instances in the old population with newly generated ones.
; Keeps the top (oldLength - newLength) individuals from the old set and appends the new set.
; Params:
;   $oldInstSet – the current sorted population (best to worst)
;   $newInstSet – the newly generated and scored instances
; Returns: A combined instance set where the worst individuals are replaced by the new ones.
; (: replaceTheWorst (-> (InstanceSet $score) (InstanceSet $score) Expression))
(= (replaceTheWorst (mkSInstSet $oldInstSet) (mkSInstSet $newInstSet))
(let* (
  ($newLength (eval (List.length $newInstSet)))
  ($oldLength (eval (List.length $oldInstSet)))
  ($toTakeFromOld (- $oldLength $newLength))
  ($leftOld (eval (List.takeN $toTakeFromOld $oldInstSet)))
)
 (eval (List.concat $leftOld $newInstSet))
)
)


; The main optimization loop for univariate evolutionary search.
; Performs selection, probability model learning, sampling, scoring, and replacement per generation.
; Recursively iterates until the generation limit or best score is reached.
; Params:
;   $sortedSInstSet – current sorted population (best first)
;   $genCount – current generation number
;   $maxGensTotal – maximum number of generations allowed
;   $nSelect – number of individuals to select for model learning
;   $nGenerate – number of new instances to generate each generation
;   $bestPossibleCscore – ideal (target) best possible score
;   $bestCscore  – current best score in the population
;   $rep – representation object 
;   $itable – input table
;   $complexityRatio – complexity ratio
; Returns: The final optimized and sorted instance set after completing all generations.
; (: univariateMainLoop (-> (InstanceSet $score) Number Number Number Number Cscore Cscore Representation (ITable $a) Number (InstanceSet $score)))
(= (univariateMainLoop $sortedSInstSet $genCount $maxGensTotal $nSelect $nGenerate $bestPossibleCscore $bestCscore $rep $itable $complexityRatio)
(if (and (< $genCount $maxGensTotal) (apply < $bestCscore $bestPossibleCscore))
(let*
  (
    ($_ (println! (~~~~Generation~~~~ $genCount)))
    ($selectedInsts (eval (tournamentSelection $sortedSInstSet 2 $nSelect Nil)))
    ($_ (println! (Selected Best Instances:  $selectedInsts)))
    ($instsExp (eval (sInstsToExp $selectedInsts ())))
    ($_ (println! (Selected Instances as Expressions:  $instsExp)))
    ($noInsts (size-atom $instsExp))
    ($_ (println! (Numbr of Selected Instances:  $noInsts)))
    ($instLength (size-atom (car-atom (index-atom $instsExp 0))))
    ($_ (println! (Instance Length (Numbr of Knobs):  $instLength)))
    ($fieldVals (eval (instsToFieldValues $instsExp $instLength $noInsts 0 ())))
    ($_ (println! (Field Values for Each Knob:  $fieldVals)))
    ($probabilityModel (eval (learnProbability $fieldVals ())))
    ($_ (println! (Probability Model:  $probabilityModel)))
    (($count0 $count1 $count2) (car-atom $probabilityModel))
    ($tot (+ $count0 (+ $count1 $count2)))
    ($generatedInsts (sampleInsts $probabilityModel $nGenerate $tot ()))
    ($_ (println! (Generated New Instances:  $generatedInsts)))
    ($generatedSInstSet (exprToSInstSet $generatedInsts))
    ($scoredGeneratedInstSet (eval (transform $generatedSInstSet $rep $itable $complexityRatio)))
    ($_ (println! (Scored Generated New Instances:  $scoredGeneratedInstSet)))
    ($finalInstSet (eval (replaceTheWorst $sortedSInstSet $scoredGeneratedInstSet)))
    ($_ (println! (Replaced Worst Instances:  $finalInstSet)))
    ((mkSInstSet $sortedFinalInstSet) (sortDeme (mkSInstSet $finalInstSet)))
    ($_ (println! (Sorted Final Instance Set:  $sortedFinalInstSet)))
    ($bestCurrentScore (getSInstScore (eval (List.getByIdx $sortedFinalInstSet 0))))
  )
  (univariateMainLoop (mkSInstSet $sortedFinalInstSet) (+ $genCount 1) $maxGensTotal $nSelect $nGenerate $bestPossibleCscore $bestCurrentScore $rep $itable $complexityRatio)
)
$sortedSInstSet
))

; Performs the optimization phase for a given deme (population).
; Params:
;   (mkDeme $rep $instSet $id) – the deme to optimize
;   $itable – input table
;   $complexityRatio – complexity ratio
;   $nSelect – number of individuals to select per generation
;   $nGenerate – number of new instances to generate per generation
;   $maxGensTotal – maximum number of generations to run
;   $bestPossibleCscore – ideal (target) best score
;   $bestCscore – current best score (initially worst)
; Returns: A new deme containing the optimized and sorted instance set.
; (: univariateOptimize (-> Deme (ITable $a) Number Number Number Number Cscore Cscore Deme))
(= (univariateOptimize (mkDeme $rep $instSet $id) $itable $complexityRatio $nSelect $nGenerate $maxGensTotal $bestPossibleCscore $bestCscore)
(let*
   (
    ($sInstSet (eval (transform $instSet $rep $itable $complexityRatio)))
    ($_ (println! (Scored Randomly Generated Population:  $sInstSet)))
    ($sortedSInstSet (sortDeme $sInstSet))
    ($_ (println! (Sorted Scored Randomly Generated Population:  $sortedSInstSet)))
    ($finalInstSet (univariateMainLoop $sortedSInstSet 0 $maxGensTotal $nSelect $nGenerate $bestPossibleCscore $bestCscore $rep $itable $complexityRatio))
   )
   (mkDeme $rep $finalInstSet $id)))

;; Initializes and starts the univariate optimization process.
;; Computes generation and population parameters, creates a random initial population,
;; and calls the univariate optimizer to evolve the population.
;; Params:
;;   (mkDeme ...) – initial deme
;;   $itable – input table
;;   $complexityRatio – complexity ratio
;;   $popSizeRatio – ratio to determine population size
;;   $selectionRatio – ratio of individuals to select each generation
;;   $replacementRatio – ratio of individuals to replace each generation
;;   $bestPossibleCscore  – target best possible score
;; Returns:
;;   A deme evolved through univariate optimization with the best-found instances.
; (: univariate (-> Deme (ITable $a) Number Number Number Number Cscore Deme))
(= (univariate (mkDeme (mkRep (mkKbMap (mkDscKbMp $idxMp) (mkDscMp $disc)) $tree) (mkSInstSet $instSet) $id) $itable $complexityRatio $popSizeRatio $selectionRatio $replacementRatio $bestPossibleCscore)
(let* (
        ($maxGensTotal (eval (informationTheoreticBits $disc)))
        ($popSize (ceilMath (* $popSizeRatio (pow-math $maxGensTotal 1.05))))
        ($nSelect (floor-math (* $selectionRatio $popSize)))
        ($nGenerate (floor-math (* $replacementRatio $popSize)))
        ($randPopDeme (mkDeme (mkRep (mkKbMap (mkDscKbMp $idxMp) (mkDscMp $disc)) $tree) (mkSInstSet (generateInitialSample (Map.length $idxMp) $popSize)) $id))  
        ($_ (println! (Randomly Populated Deme: $randPopDeme)))
      ) 
      (univariateOptimize $randPopDeme $itable $complexityRatio $nSelect $nGenerate $maxGensTotal $bestPossibleCscore (worstCscore))))

      
