(= (-inf) (py-call (float -inf)))
(= (round $n $p) (py-call (builtins.round $n $p)))

; (: List.at (-> Number (List $a) $a))
(= (List.at $i Nil) (Error Nil "Empty List"))
(= (List.at $i (Cons $x $xs))
    (if (== $i 0)
        $x
        (List.at (- $i 1) $xs)))

;; return tuple of unique values and their count
;; this one is assuming the list of values have been returned contains the row information. 
; (: List.uniqueValuesCount (-> (List $a) Expression))
(= (List.uniqueValuesCount $list $acc)
    (eval (unify $list Nil $acc
            (if (= $list (Cons $x $xs))
            (if (patternExists ($x $c) $acc)
                (chain (eval (updateCount $x $acc)) $count-updated
                    (List.uniqueValuesCount $xs $count-updated))
                (chain (union-atom $acc (($x 1))) $new-tuple-added
                    (List.uniqueValuesCount $xs $new-tuple-added))) (Error $list UnrecognizedFormat)))))

; (: Table.getColumn (-> Number (List (List $a)) (List $a)))
(= (Table.getColumn $i $rows)
    (eval (unify $rows Nil Nil
       (if (= $rows (Cons $row $rest))
            (Cons (List.at $i $row) (Table.getColumn $i $rest)) ()))))
; ;; Table.pop        -- gets and removes a column from the current ttable structure
; ;;                  -- returns the remaining table and the culumn asked for
(= (Table.pop $i $rows)
    (eval (unify $rows Nil Nil
        (eval (if (= $rows (Cons (Cons $d $ds) $rest))  ;; $d and $ds for data and rest of data
                (if (== $i 0)
                    (Cons $ds (Table.pop $i $rest))
                    (Cons (Cons $d (eval (List.pop (- $i 1) $ds))) (Table.pop $i $rest))) ())))))
; ;; removes the first column from table
; (: Table.pop (-> (List (List $a)) (List (List $a))))
; (= (Table.pop $rows)
;     (unify $rows Nil Nil
;         (unify $rows (Cons (Cons $d $ds) $rest)
;             (Cons $ds (Table.pop $rest)))))

;; returns the last column of the table
; (: Table.getOutputColumn (-> ITable (List $a)))
(= (Table.getOutputColumn (mkITable $table $labels))
    (chain (eval (List.length $labels)) $colNum 
    (chain (Table.getColumn (- $colNum 1) $table) $oc   
    $oc  ))
)

;;;;;;;;;;;;;;
;; Transpose;;
;;;;;;;;;;;;;;
; (: Table._transposeHelper (-> (List Number) (List (List $a)) (List (List $a))))
(= (Table._transposeHelper $indices $table)
    (eval (unify $indices Nil Nil
        (if (= $indices (Cons $i $rest))
            (Cons (eval (Table.getColumn $i $table))
                    (Table._transposeHelper $rest $table)) ()))))

; (: Table.transpose (-> (List (List $a)) (List (List $a))))
(= (Table.transpose $table)
    (let $numCols (List.length (List.head $table))
        (let $indices (List.range 0 $numCols)
            (Table._transposeHelper $indices $table))))
;;;;;;;;;;;;;;
;; Transpose;;
;;;;;;;;;;;;;;

;;(: List.head (-> (List $a) $a))
;;(= (List.head $list)
;;    (unify $list 
;;        Nil (Error "Empty list has no head")
;;        (unify $list (Cons $h $t) $h ())))

; (: List.range (-> Number Number (List Number))) ;; inclusive start, exclusive end
(= (List.range $start $end)
    (if (>= $start $end)
        Nil
        (chain (List.range (+ 1 $start) $end) $res (Cons $start $res))))

;; check for a pattern in tuple of tuples                
; (: patternExists (-> Expression Expression Bool))
(= (patternExists $pat $collection)
    (let $a (collapse (chain (superpose $collection) $s
        (eval (if (= $s $pat) True False)))) (foldl or $a False)))        
        
;; replace value and count pair in collection with one higher count pair        
; (: updateCount (-> Expression Expression Expression))
(= (updateCount $val $collection)
    (collapse (chain (superpose $collection) $s 
                (eval (if (= $s ($val $count)) ($val (+ 1 $count)) $s))))) 

;; sorting pairs 
;; $op -- comparator $pairTuple -- tuple of pairs
;; $count -- sort count -- partial sort
;; $acc -- the accumulator
; (= (sortPairs $op $pairTuple $count $acc)
;     (if (or (<= $count 0) (== $pairTuple ()))
;         (union-atom $acc $pairTuple)
;         ;; find max pair from the tuple of pairs
;         ;; use of union assumes the pairs are non repeating -- same score is possible but always different label
;         (chain (foldl-atom $pairTuple (-inf $label) $ac $pair ($op $ac $pair)) $max-pair
;         (chain (union-atom $acc ($max-pair)) $new-acc
;         (chain (collapse (chain (superpose $pairTuple) $el (if (== $el $max-pair) (Empty) $el))) $rest
;         (sortPairs $op $rest (- $count 1) $new-acc))))))  ;; recursive call

;; a slight tweak to the above sorting function removes duplicate expressions in the form of differently ordered tuples
;; assumes pairs having numerical values as second part

; (: sortPairs (-> (-> $a $a $a) Expression Number Expression Expression))
(= (sortPairs $op $pairTuple $count $acc)
    (if (or (<= $count 0) (== $pairTuple ()))
        ; (union-atom $acc $pairTuple)                                                          ;; started as a partial sort
        $acc                                                                                    ;; but later turned out that we do not need the unsorted part -just sort the top N and return that
        (chain (foldl $op $pairTuple ((-inf) (1 0))) $max-pair    ;; find max pair from the tuple of pairs    
        (chain (union-atom $acc ($max-pair)) $new-acc                                          ;; use of union assumes the pairs are non repeating -- same score is possible but always different label (due to ordering of tuple elem)
        (chain (collapse 
                (chain (superpose $pairTuple) $el 
                    (if (isPairEqual $el $max-pair) (empty) $el))) $rest                        ;; removes reduandant tuples
                        (sortPairs $op $rest (- $count 1) $new-acc))))))

;; insertPair 
;; ($iv $new-i) -- piar of score value and feature index  
;; $op -- comparison operator
;; $list -- tuple of item value-label pairs 
;; XXX : make sure to use strict comparators > as the comparator
; (: insertPair (-> (-> ($a $b) ($a $b) Bool) ($a $b) Expression Expression))
(= (insertPair $op ($mi $new-i) $list)
    (if (== $list ())
        (($mi $new-i))
        (let ($h $t) (decons-atom $list)
            (eval (if (= ($mi-old $i) $h)
                    (if ($op $mi $mi-old)
                        (cons-atom ($mi $new-i) $list)
                        (if (== $mi $mi-old)
                            (if (<= $new-i $i)                          ;; tie breaker -- index value -- lower index values come first -- keeping the normal order
                                (cons-atom ($mi $new-i) $list)
                                (chain (insertPair $op ($mi $new-i) $t) $res (cons-atom $h $res)))
                            (chain (insertPair $op ($mi $new-i) $t) $res (cons-atom $h $res))))
                        ())))))

;; find maximum of two pairs
;; XXX notice the use of => for comparison -- as per current mettlog interpreter implementation
; (: pairMax (-> (Number $a) (Number $a) (Number $a)))
(= (pairMax ($val1 $label1) ($val2 $label2)) (if (>= $val1 $val2) ($val1 $label1) ($val2 $label2)))

;; exponentialSelection
;;          $mean                   -- mean of num desired for the exponential dist -- controls steepness of selection
;;          $numDesired             -- number of features to be selected
;;          $scoreLableTuple        -- tuple of MI scores and corresponding labels -- this might change into index values
;;          $xn                     -- factor controlling what gets selected -- starts as 1 -- the current exponential decay multiplier.
;;          $acc                    -- accumulator for selected features

; (: exponentialSelection (-> Number Number Expression Number Expression Expression))
(= (exponentialSelection $mean $numDesired $scoreLabelTuple $xn $acc)
    (if (== $numDesired 0)
        $acc
        (trace! ($rndFloat $xn)
            (if (= $scoreLabelTuple ())
                $acc
                (let* ((($h $t) (decons-atom $scoreLabelTuple))
                        ($rndFloat (random-float 0 1)))

                        (if (< $rndFloat $xn)
                            (chain (union-atom $acc ($h)) $new-acc
                              (exponentialSelection $mean (- $numDesired 1) $t (* $xn $mean) $new-acc))
                            (exponentialSelection $mean $numDesired $t (* $xn $mean) $acc))))))) ;; some adjustment needed here to make sure numDesired amount is returned check if numDesired is equal to what is left. if so append all to the acc to make sure  

;; take N values from tuple
; (: takeN (-> Number Expression Expression))
(= (takeN $n $expr) 
    (if (or (== $n 0) (== $expr ()))
        ()
        (let* ((($h $t) (decons-atom $expr))
                ($res (takeN (eval (- $n 1)) $t)))
            
                (cons-atom $h $res)))) 
                
                


;; mutualInformation        -- mutual information based on =∑p(x1,x2..:y)/ (p(x1, x2 ..)*p(y) )
;;          $if             --  input feature list as (Cons ..)
;;          $of             --  out feature list as (Cons ..)
; (: mutualInformation (-> (List $a) (List $a) Number))
(= (mutualInformation $if $of)
    (chain (eval (List.zip $if $of)) $io-zip
    (chain (List.uniqueValuesCount $io-zip ()) $io-c
    (chain (eval (List.length $if)) $rowNum
    (chain (List.uniqueValuesCount $if ()) $ic         ;; input feature unique values count pairs
    (chain (List.uniqueValuesCount $of ()) $oc 
    (chain (marginalProbs $rowNum $io-c) $io-p          ;; input output mutual probs
    (chain (collapse (chain (superpose $io-p) $io-prob-pair    ;; ((inout output)  prob) piar -- single -- superposed
        (if (= $io-prob-pair ($pair $prob))
                (let* (($temp (/ $prob (* (/ (eval (getCount $ic (first-from-pair $pair))) $rowNum) (/ (eval (getCount $oc (second-from-pair $pair))) $rowNum))))
                        ($log (log-math 2 $temp)))
                        
                        (* $prob $log))
                ()))) $probTuple
        (chain (foldl + $probTuple 0) $final-result (round $final-result 3))))))))))

; (: zipColumn (-> Expression (List (List $a)) (List $a)))        
(= (zipColumn $indices $datarows)
    (if (== $indices ())
        Nil
        (eval (unify $datarows Nil Nil
            (eval (if (= $datarows (Cons $row $rows))
                (chain (map-atom $indices $i (eval (List.at $i $row))) $dataTuple
                    (Cons $dataTuple (zipColumn $indices $rows)))
                ()))))))

;; return marginal probabilities as tuple (p1 p2)
; (: marginalProbs (-> Number Expression Expression))
(= (marginalProbs $len $countTuple)                         ;; depending on how the above goes most of the code for calculating frequencies could be included in this function
    (collapse (chain (superpose $countTuple) $pair (eval (if (= $pair ($val $count)) ($val (/ $count $len)) ()))))) 

;; return the value associated with a value in a tuple of pairs
;; as in ((True 0.6) (False 0.4)) -- if one wants to get value associated with True
; (: getCount (-> Expression $a Number))
(= (getCount $tuples $cue)
    (chain (superpose $tuples) $pair
        (eval (if (= $pair ($cue $prob)) $prob (empty)))))

;; check for equality of expressions -- to make up for ordering issues     
; (: isEqual (-> $a $b Bool))
(= (isEqual $a $b)
    (chain (subtraction-atom $a $b) $a-diff 
        (chain (subtraction-atom $b $a) $b-diff (and (== (size-atom $a) (size-atom $b)) (== $a-diff $b-diff)))))

;; generate from $l to $u (excluding) in $step steps         
; (: range (-> Number Number Number Expression))
(= (range $l $step $u)
    (if (== $step 0)
        (Error $step "Step value of 0 not allowed!!")
        (if (>= $l $u)
            ()
            (chain (range (+ $l $step) $step $u) $res
                (cons-atom $l $res)))))

;; check for equality of pairs -- to make up for ordering issues   
; (: isPairEqual (-> (Number $a) (Number $b) Bool))
(= (isPairEqual ($val1 $item1) ($val2 $item2))
    (if (== $val1 $val2)
        (isEqual $item1 $item2)
        False))

; (: shuffle (-> Atom Atom Atom))        
(= (shuffle $expr $acc)
    (if (== $expr ())
        $acc
        (chain (size-atom $expr) $len
            (chain (py-call (random.randint 0 (- $len 1))) $rnd-index ;; by using py-atom bound rnd function from general-helpers
                (chain (index-atom $expr $rnd-index) $val
                (chain (cons-atom $val $acc) $new-acc
                    (chain (subtraction-atom $expr ($val)) $rem ;; if we are certain that a pattern is never repeated in the original expression
                        (shuffle $rem $new-acc))))))))        


;; better log implementation using mercator series expansion and log properties
(= (ln2) 0.6931471805599453)
; (: logMath (-> Number Number Number))
(= (logMath $baseValue $inputValue)
    (if (or (<= $baseValue 0) (or (== $baseValue 1) (<= $inputValue 0)))
        (Error "Invalid input: base must be > 1, value must be > 0")
        (if (== $inputValue 1)
            0                                                                  ;; log_b(1) = 0 for any base
            (if (== $inputValue $baseValue)                                     ;; log_b(b) = 1 for any base
                1                                                               
                (round (/ (lnMercator $inputValue 0) (lnMercator $baseValue 0)) 3)))))    ;; log_b(x) = ln(x) / ln(b)
; (: lnMercator (-> Number Number Number))
(= (lnMercator $inputNumber $reductionCount)
    (if (>= $inputNumber 2)
        (lnMercator (/ $inputNumber 2) (+ $reductionCount 1))                   ;; inputNumber too large: reduce by factor of 2 -- ln(x) = ln(x/2) + ln(2), so increment reductionCount counter
        (if (< $inputNumber 0.5)
            (lnMercator (* $inputNumber 2) (- $reductionCount 1))               ;; inputNumber too small: increase by factor of 2 -- ln(x) = ln(2x) - ln(2), so decrement reductionCount counter
            (chain (/ (- $inputNumber 1) (+ $inputNumber 1)) $u             
                (chain (pow-math $u 2) $uSquared              
                    (chain (mercatorSeriesSum $uSquared $u 1 0) $seriesResult 
                        (+ $seriesResult (* $reductionCount (ln2))) ;; Add reductionCount*ln(2)
                        ))))))

; (: mercatorSeriesSum (-> Number Number Number Number Number))
(= (mercatorSeriesSum $uSquared $currentPower $denominator $accumulator)
  (chain (* 2 (/ $currentPower $denominator)) $currentTerm
    (if (< (abs-math $currentTerm) 0.00000001)
        $accumulator
        (mercatorSeriesSum $uSquared (* $currentPower $uSquared) (+ $denominator 2) (+ $accumulator $currentTerm)))))                        

;; computes entropy from the give tuple of counts by finding the sum of all such (Pi * Log2 Pi) values
;; $countTuple  -- tuple of (Lable Count) tuples like ((True 4) (False 3))
;; $totalCount  -- sum of counts
;; $sum         -- accumulator for (Pi * (Log2 Pi)) values
(= (entropy $countTuple $totalCount $sum)
    (if (= $countTuple ())
        $sum
        (let ($h $t) (decons-atom $countTuple) 
                (eval (if (= $h ($item $count))
                        (chain (/ $count $totalCount) $p-i                                          ;; need a condition to skip calculation of log of 0 values
                            (chain (if (== $p-i 0) $p-i (round (eval (log-math 2 $p-i)) 2)) $log-val    ;; might need to find new ways of calculating rounded values without python binding
                                (chain (* $p-i $log-val) $product
                                    (entropy $t $totalCount (- $sum $product))))) 
                        ())))))

;; filterTable -- filters table by removing features in $ft-to-remove

; (= (filterTable $ft-to-remove (mkITable $table $labels))
;     (if-decons-expr-custom $ft-to-remove $h $t
;         (let* (($filtered-data (Table.pop $h $table))
;                 ($filtered-label (List.pop $h $labels)))
            
;             (filterTable (map-atom $t $x (- $x 1)) (mkITable $filtered-data $filtered-label)))
;         (mkITable $table $labels)))          

(= (filterTable $ft-to-remove (mkITable $table $labels))
    (if (== $ft-to-remove ())
        (mkITable $table $labels)
        (let* ((($h $t) (decons-atom $ft-to-remove))
                ($filtered-data (Table.pop $h $table))
                ($filtered-label (eval (List.pop $h $labels))))
        
        (filterTable (map-atom $t $x (- $x 1)) (mkITable $filtered-data $filtered-label)))))        

; (: getInputLabels (-> (List Symbol) Expression))
(= (getInputLabels $labels)
    (let $res (inputLables $labels) (eval (List.foldl cons-atom () $res))))

; (: inputLables (-> (List Symbol) (List Symbol)))    
(= (inputLables $labels)
    (eval (unify $labels Nil (Error $labels NoLabelsSpecified)
        (eval (if (= $labels (Cons $a $as))
                (if (== $as Nil)
                    Nil
                    (let $r (inputLables $as) (Cons $a $r))) (Error $labels UnrecognizedFormat))))))

; (: fsToNames (-> (List Symbol) Expression Expression))
(= (fsToNames $labels $ft-indices)
	(collapse (chain (superpose $ft-indices) $ft 
		(List.at $ft $labels))))                

;; readjustIndices  -- when a table is filtered based on requirements in filter selection when, for example, exemplar features are required to be ignored,
;;                  -- the returned index values no longer refer to the original table which is kept for reference in subsequent steps
;;                  -- so unless the indices are readjusted to the orginal labels list, the will be referring to the filtered labels 
;;                  $ft-set-pop         -- pop of selected features as (score feature-set) pairs
;;                  $filtered-labels    -- filtered table labels
;;                  $original-labels    -- original table labels
(= (readjustIndices $ft-set-pop $filtered-labels $original-labels)
    (map-atom $ft-set-pop $ft-set
                            (let* ((($score $indices) ((eval (first $ft-set)) (eval (second $ft-set))))
                                    ($shifted-labels (map-atom $indices $index (List.at $index $filtered-labels)))
                                    ($adjusted-indices (map-atom $shifted-labels $label (eval (List.index $original-labels $label)))))
                                    
                                        ($score $adjusted-indices))))        

;; Incremental Selection Utility Functions
;; Purpose: Remove duplicate expressions from list using isExpEqual
;; Recursively processes expressions and maintains unique accumulator
;; Parameters:
;;   $expr (Expression) → Expression containing potentially duplicate sub-expressions
;;   $acc (Expression) → Accumulator for unique expressions
;; Returns: (Expression) → Expression with duplicates removed
;; Example: (set ((A B) (B A) (C D)) ()) → ((A B) (C D))
; (: set (-> Expression Expression Expression))
(= (set $expr $acc)
    (if (== $expr ())
        $acc
        (let* ((($h $t) (decons-atom $expr))
                ($carry (union-atom $acc ($h)))
                ($rest (collapse (let $h-s (superpose $t)
                                    (if (isEqual $h-s $h)
                                        (empty)
                                        $h-s)))))
                (set $rest $carry))))

;; Purpose: Generate powerSet (all combinations) of specified size from expression
;; This is the core combination generation function used throughout the algorithm
;; Parameters:
;;   $set (Expression) → Set of elements to generate combinations from
;;   $n (Number) → Size of combinations to generate
;;   $exact (Bool) → If True, return only n-sized combinations; if False, return all sizes ≤ n
;; Returns: (Expression) → All combinations of specified size
;; Example: (powerSet (0 1 2) 2 True) → ((0 1) (0 2) (1 2))
; Reference: https://github.com/opencog/cogutil/blob/88da482e38ba7ecec734dd0282d6c9b9be2c3bfd/opencog/util/algorithm.h#L282
; (: powerSet (-> Expression Number Bool Expression))
(= (powerSet $set $n $exact)
   (if (== $n 0)
       (()) 
       (let* (($ps   (powerSet $set (- $n 1) $exact))
              ($new  (collapse 
                       (let $subset (superpose $ps)
                         (let $el (superpose $set)
                           (if (not (is-member $el $subset))
                               (cons-atom $el $subset)
                               (empty)))
                        )
                    )
                )
              ($filteredNew (set $new ()))
              ($res  (if (not $exact)
                        (eval (union-atom-set $filteredNew $ps))
                        $filteredNew
                    )
              )
            )
             $res
        )
    )
)

;; Purpose: Check if difference between two numbers is within epsilon tolerance
;; Parameters:
;;   $min (Number) → Lower bound
;;   $max (Number) → Upper bound  
;;   $epsilon (Number) → Tolerance
;; Returns: (Bool) → True if within epsilon
;; Reference: https://github.com/opencog/cogutil/blob/6b149c457c9cfbf5edccefb166a7a9a1d2d74196/opencog/util/numeric.h#L178(: isWithin (-> Number Number Number Bool))
(= (isWithin $min $max $epsilon)
   (<= (abs-math (- $max $min)) $epsilon))                                        
;; checking the random numebr generator
 

;; Utility function to constrain a value within bounds [min, max]
;; Example: (clamp 1.5 0.0 1.0) -> 1.0, (clamp -0.5 0.0 1.0) -> 0.0
; (: clamp (-> Number Number Number Number))
(= (clamp $val $min $max)
   (if (< $val $min) $min
       (if (> $val $max) $max $val)))


;; Calculate confidence weighting factor based on feature set size
;; This implements fs_scorer_base::confidence() to prevent overfitting
;;
;; The confidence factor penalizes larger feature sets to encourage
;; simpler, more generalizable solutions (Occam's razor principle).
;;
;; Parameters:
;;   $featureSetSize (Number): Number of selected features
;;   $size (Number): Dataset size parameter  (the number of rows)
;;   $confi (Number): Confidence scaling parameter
;;
;; Returns: (Number) Confidence multiplier (0.0 to 1.0)
;;
;; Mathematical formula: 
;;   confidence = size / (size + exp(-featureSetSize * confi))
; (: calculateConfidence (-> Number Number Number Number))
(= (calculateConfidence $featureSetSize $size $confi)
     (/ $size (+ $size (pow-math 2.718 (* -1 (* $featureSetSize $confi)))))
)
