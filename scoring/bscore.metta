!(import! &self scoring/boolean-ops)

;; Type definitions and functions related to beahvioral socre, behavioral complexity score and turth table behavioral score.
;; Behavioral score is a list of numbers, where each number represents the score of a particular output. 
;; For boolean expressions, the score is either 0 or -1. Therefore, this behavioral score is a list of 0s and -1s.
;; In the C++ version, floating point scores and numbers different than -1 and 0 are used as a result of table compression 
;;  and weighting options. However, we don't have that yet.

; (: BehavioralScore Type)
; ;(: mkBScore (-> (List Number) BehavioralScore))

;; Subtrace two behavioral scores
;(: BScore.sub (-> BehavioralScore BehavioralScore BehavioralScore))
(= (BScore.sub (mkBScore $bs1) (mkBScore $bs2))
   (if (not (== (List.length $bs1) (List.length $bs2)))
       (Error ($bs1 $bs2) "Incompatible behavioral scores")
       (mkBScore (List.sub $bs1 $bs2))))

;; Sums the behavioral score to get a single number.
;(: sumBScore (-> BehavioralScore Number))
(= (sumBScore (mkBScore $bs)) (List.sum $bs))

;; Count wins in a BehavioralScore for game strategies
;; For game strategies: 1.0 = win, -1.0 = loss, 0.0 = draw
;; Returns the total number of wins
;(: countWins (-> BehavioralScore Number))
(= (countWins (mkBScore ())) 0)
(= (countWins (mkBScore (cons $head $tail)))
   (if (== $head 1.0)
       (+ 1 (countWins (mkBScore $tail)))
       (countWins (mkBScore $tail))))

;; Input table with rows, columns and labels of the columns
;; An Input Table is just a list of lists.
;(: ITable (-> $a Type))
;(: mkITable (-> (List (List $a)) (List Symbol) (ITable $a)))

;; TruthTableBScore is a type that contains the complexity coefficient, size of the table and the input table itself.
;; Using this type we can get behavioral score and behavioral complexity score.
;; This table is the cTruthTableBScore in the C++. The C stands for compressed. But omitted here since the table won't be compressed during this version.
;;  It is left as future work.
;(: TruthTableBScore (-> $a Type))
;(: mkTruthTableBScore (-> Number Number (ITable $a) (TruthTableBScore $a)))

;; A constuctor for truthTableBScore to assign the size of the table on it's own.
;; INFO: This could have been done by overloading the mkTruthTableBScore function, but
;;  that has shown to be problematic for certain cases. Best to avoid it whenever we can.
;(: createTruthTableBScore (-> Number (ITable $a) (TruthTableBScore $a)))
(= (createTruthTableBScore $complexityCoeff (mkITable $itable $labels)) (mkTruthTableBScore $complexityCoeff (List.length $itable) (mkITable $itable $labels)))

;; Return the table from truth table bscore
;(: getTable (-> (TruthTableBScore $a) (ITable $a)))
(= (getTable (mkTruthTableBScore $compCoeff $size $table)) $table)

;; Ground cache key for a preOrder'd candidate expression: every leaf var is
;; replaced by (lbl <index-in-$labels>). Space `match` unifies, so caching
;; var-leaf trees directly conflates every same-shaped candidate (an unbound
;; leaf unifies with anything — see repro-2-bscore-cache-conflation.metta),
;; and a repr-string key cannot restore identity on retrieval (parsing
;; recreates fresh vars). The ground index form is exact both ways:
;; List.index compares with == (var identity), so distinct table vars map to
;; distinct indices. Direct recursion on purpose: a map-atom body capturing
;; $labels would copy_term the captured vars per element and break the
;; identity lookup.
(= (groundCacheKey $expr $labels)
   (if (== (get-metatype $expr) Variable)
       (lbl (List.index $labels $expr))
       (if (not (== (get-metatype $expr) Expression))
           $expr
           (if (== $expr ())
               ()
               (let ($h $t) (decons-atom $expr)
                 (cons-atom (groundCacheKey $h $labels) (groundCacheKey $t $labels)))))))

;; Inverse of groundCacheKey: rebuild a var-leaf expression from the ground
;; (lbl N) form by relinking each index to the ORIGINAL label var object.
(= (ungroundKey $expr $labels)
   (if (not (== (get-metatype $expr) Expression))
       $expr
       (if (== $expr ())
           ()
           (let ($h $t) (decons-atom $expr)
             (if (== $h lbl)
                 (List.getByIdx $labels (car-atom $t))
                 (cons-atom (ungroundKey $h $labels) (ungroundKey $t $labels)))))))

;; Row evaluator for the GROUND cache-key form of a candidate ((lbl N)
;; leaves; AND/OR carry a wrapped kids tuple, NOT is unary, any other
;; operator keeps preOrder's flat n-ary shape). Called once per (candidate,
;; row) pair as a plain compiled function — no per-row template copy and no
;; per-row (eval ...) re-translation, which is what made evalParsed the
;; scoring bottleneck. AND/OR short-circuit on the first False/True.
;;
;; Extensibility contract (same as eval's): an operator this evaluator does
;; not know is dispatched via `reduce` on its already-evaluated children —
;; a direct call into whatever compiled clause (= (op ...) ...) exists, so
;; new operators need no change here. The reduce argument must be let-bound
;; first: reduce on a literal (cons-atom ...) form would dispatch cons-atom
;; itself rather than the constructed term.
;;
;; A Symbol leaf yields no result — mirroring evalParsed, whose row
;; unification produced no result for symbolic-label tables (callers such as
;; deme/tests/score-deme-test.metta rely on that silent failure). Boolean
;; and grounded (numeric) leaves pass through.
(= (evalRow $e $row)
   (if (not (== (get-metatype $e) Expression))
       (if (or (== $e True) (== $e False))
           $e
           (if (== (get-metatype $e) Grounded) $e (empty)))
       (if (== $e ())
           ()
           (let ($h $t) (decons-atom $e)
             (if (== $h lbl)
                 (List.getByIdx $row (car-atom $t))
                 (if (== $h AND)
                     (andRow (car-atom $t) $row)
                     (if (== $h OR)
                         (orRow (car-atom $t) $row)
                         (if (== $h NOT)
                             (notRow (evalRow (car-atom $t) $row))
                             ;; Operator head: registered function symbols
                             ;; report metatype Grounded (not Symbol), so
                             ;; dispatch every non-Expression head; reduce
                             ;; leaves non-callable heads (e.g. a bare
                             ;; boolean tuple) as data.
                             (if (not (== (get-metatype $h) Expression))
                                 (let $call (cons-atom $h (map-atom $t $k (evalRow $k $row)))
                                   (reduce $call))
                                 (map-atom $e $k (evalRow $k $row)))))))))))

;; Short-circuit conjunction/disjunction over a kids tuple; non-boolean
;; child values pass through unless decisive, matching all/any's is-member
;; scan semantics.
(= (andRow $kids $row)
   (if (== $kids ())
       True
       (let ($k $rest) (decons-atom $kids)
         (if (== (evalRow $k $row) False)
             False
             (andRow $rest $row)))))
(= (orRow $kids $row)
   (if (== $kids ())
       False
       (let ($k $rest) (decons-atom $kids)
         (if (== (evalRow $k $row) True)
             True
             (orRow $rest $row)))))
(= (notRow $v)
   (if (== $v True) False (if (== $v False) True (empty))))

;; Function to give a behavioral score for a given tree.
;; It takes the Input table and the tree then scores the input table on each row. After which it builds the behavioral score.
;;
;; Params: $table - Input table
;;         $labels - Column labels
;;         $tree - The tree to be scored
;;
;; Returns: Beahvioral score for the given tree.
; (: scoreTree (-> (ITable $a) (Tree $a) BehavioralScore))
(= (scoreTree (mkITable $table $labels) $tree $cacheSpace)
   (if (== $tree (mkTree (mkNode AND) ()))
       (worstPossibleScore (createTruthTableBScore $compCoeff (mkITable $table $labels)))
       (let $preordered (preOrder $tree)
       (let $key (groundCacheKey $preordered $labels)
       (chain (collapse (match $cacheSpace
               ($key $bscore)
               $bscore))
           $val
           (if (== $val ())
               (let* (
                   ;; Each row is scored (evalRow on the ground key) and
                   ;; compared against its output column (the row's last
                   ;; element) in a single pass.
                   ($lastIdx (- (List.length $labels) 1))
                   ($bScore (map-atom $table $ts
                       (compareAndScore (evalRow $key $ts)
                                        (List.getByIdx $ts $lastIdx))))
                   ($result (mkBScore $bScore))
                   ($_ (add-atom $cacheSpace ($key $result)))
               )
               $result)
               (car-atom $val)
           ))))))

(= (scoreTreeHelper $template $row) (evalParsed $template $row))
;; Return the best possible BehavioralScore given the size of the table.
;;  Altohugh the whole table is given for consistency and to distinguish 
;;  from the same function that works on BehavioralCScore, it uses only the size of the table.
;(: bestPossibleScore (-> (TruthTableBScore $a) BehavioralScore))
(= (bestPossibleScore (mkTruthTableBScore $compCoeff $size $table)) (mkBScore (List.repeat $size 0)))


;; Return the worst possible BehavioralScore given the size of the table.
;;  Altohugh the whole table is given for consistency and to distinguish 
;;  from the same function that works on BehavioralCScore, it uses only the size of the table.
;(: worstPossibleScore (-> (TruthTableBScore $a) BehavioralScore))
(= (worstPossibleScore (mkTruthTableBScore $compCoeff $size $table)) (mkBScore (List.repeat $size -1)))

;; When we have a compressed tree, the min improvement 
;;  will be calculated. For now it's fixed.
;(: minImprove (-> (TruthTableBScore $a) Number))
(= (minImprove $_) 0.5)

;; Score tree helepr function that compares two values and returns a number instead of a bool.
;; It returns 0 if the values are equal, -1 they're not equal.
;(: compareAndScore (-> $a $a Number))
(= (compareAndScore $a $b) (if (== $a $b) 0 -1))

;; A wrapper function to return the complexity a tree.
;(: (getComplexity (-> (Tree $a) Number)))
(= (getComplexity $tree) (treeComplexity $tree))

;; Replace every occurence of a lable inside an expression with a truth value.
;;
;; Params: $boolExpr - The expression to be modified
;;         $b - The truth value to replace with
;;         $l - The variable to be replaced
;;
;; Returns: Modified version of the boolean expression.
;(: replaceVarWithTruth (-> (Bool Symbol) $a $a))
(= (replaceVarWithTruth ($b $l) $boolExpr)
   (if (== (get-metatype $boolExpr) Expression) ;; If not symbol or Grounded
       (let ($h $t) (decons-atom $boolExpr)
            (if (== $t ())
                (replaceVarWithTruth ($b $l) $h)
                (let $t' (map-atom $t $ts (replaceVarWithTruth ($b $l) $ts))
                  (if (== $h $l)
                      (cons-atom $b $t')
                      (cons-atom $h $t')))))
       (if (== $boolExpr $l) $b (if (once (is-member $boolExpr (quote (AND OR)))) (quote ($boolExpr)) $boolExpr))))

;; Replace ever occurence of all labels (boolean variables) 
;;  inside an expression with their corresponding truth values.
;;
;; Params: $boolExpr - The expression to be modified
;;         $lList - list of variables to be replaced
;;         $bList - list of the corresponding truth values to replace the variables with
;;
;; Returns: Modified version of the boolean expression.
;(: replaceVarsWithTruth (-> ((List Symbol) Expression) (List Bool) Expression))
(= (replaceVarsWithTruth ($lList $boolExpr) $bList)
   (let $blList (List.zip $bList $lList) (List.foldl replaceVarWithTruth $boolExpr $blList)))

;; Behavioral complexity score. Although this type adds no additional atttributes to the truth table bscore,
;;  It is used to distinguish between the two types. The behavioral complexity score is treated differently than the latter one.
;;  Instead of a list of scores in the BehavioralScore this type deals with a single score values.
;(: BehavioralCScore (-> $a Type))
;(: mkBCScore (-> (TruthTableBScore $a) (BehavioralCScore $a)))

;; Return the best possible Behavioral composite score given the table. 
;;  Although the whole table is given for consistency and to distinguish 
;;  from the same function that works on BehavioralScore, it only needs the size of the table.
;(: bestPossibleScore (-> (BehavioralCScore $a) Number))
(= (bestPossibleScore (mkBCScore $truthTableBScore)) (let (mkBScore $bscore) (bestPossibleScore $truthTableBScore) (List.sum $bscore)))

;; Return the worst possible Behavioral composite score given the table.
;;  Although the whole table is given for consistency and to distinguish
;;  from the same function that works on BehavioralScore, it only needs the size of the table.
;(: worstPossibleScore (-> (BehavioralCScore $a) Number))
(= (worstPossibleScore (mkBCScore $truthTableBScore)) (let (mkBScore $bscore) (worstPossibleScore $truthTableBScore) (List.sum $bscore)))

;; When we have a compressed tree, the min improvement
;;  will be calculated. For now it's fixed.
;(: minImprove (-> (BehavioralCScore $a) Number))
(= (minImprove (mkBCScore $truthTableBScore) (minImprove $truthTableBScore)))


;;------------------------------------------------------------
;; getArgLabels
;;------------------------------------------------------------
;;  Extracts argument labels (all but the last) from an ITable.
;;
;;  The ITable structure is:
;;    (mkITable $rows $labels)
;;      where $rows   = list of data rows (each a list of values)
;;            $labels = list of column labels (symbols)
;;
;;  This function returns an expressison of all column labels except the last one,
;;  which is typically the output label in a truth table.
;;
;;  Example:
;;    (mkITable
;;      (cons (cons True (cons False (cons True ())))
;;            (cons (cons False (cons True (cons False ()))) ()))
;;      (cons 'A (cons 'B (cons 'Y ()))))
;;
;;    Labels:   +---+---+---+
;;              | A | B | Y |
;;              +---+---+---+
;;    Output:   ('A 'B)
;;
;;   
;;      +---+---+---+
;;      | A | B | Y |
;;      +---+---+---+
;;      | T | F | T |
;;      | F | T | F |
;;      +---+---+---+
;;      ^^^^^^^^^^^^
;;      getArgLabels returns only the input labels: [A, B]
;;
;;  Usage:
;;    (getArgLabels $itable)  ; returns (cons 'A (cons 'B ()))
;;
;(:getArgLabels (-> (ITable $a) (List Symbol)))
(= (getArgLabels (mkITable $rows $labels))
   (let $args
        (List.takeN (- (List.length $labels) 1) $labels )
        (List.listToExpr $args)))
