;; ============================================================
;; Types, constructors and functions related to instance.
;; ============================================================

;;------------------------------------------------------------
;;  Instance
;;------------------------------------------------------------
;;  +-------------+
;;  | List Number |  -->  Instance
;;  +-------------+
;;  Represents a vector of numbers as an Instance.
;; (: Instance Type)
;; (: mkInst (-> (List Number) Instance))

;;------------------------------------------------------------
;;  ScoredInstance
;;------------------------------------------------------------
;;  +---------------------+
;;  | Pair Instance Score |  -->  ScoredInstance<Score>
;;  +---------------------+
;;  Combines an Instance with a score value.
;; (: ScoredInstance (-> $score Type))
;; (: mkSInst (-> (Pair Instance $score) (ScoredInstance $score)))

;;------------------------------------------------------------
;;  InstanceSet
;;------------------------------------------------------------
;;  +-----------------------------------------+
;;  | List of ScoredInstance<Score>           |  -->  InstanceSet<Score>
;;  +-----------------------------------------+
;;  Represents a list of scored instances.
;; (: InstanceSet (-> $score Type))
;; (: mkSInstSet (-> (List (ScoredInstance $score)) (InstanceSet $score)))

;; ============================================================
;; Conversion Helpers
;; ============================================================

;;------------------------------------------------------------
;; instToExpr
;;------------------------------------------------------------
;;  Instance  -->  Expression
;;  Converts an Instance into an Expression form.
;; (: instToExpr (-> Instance Expression))
(= (instToExpr (mkInst $lst)) (eval (List.listToExpr $lst)))

;;------------------------------------------------------------
;; exprToInst
;;------------------------------------------------------------
;;  Expression  -->  Instance
;;  Parses an Expression into an Instance.
;; (: exprToInst (-> Expression Instance))
(= (exprToInst $expr) (mkInst (eval (exprToList $expr))))

;;------------------------------------------------------------
;; sInstToExpr
;;------------------------------------------------------------
;;  ScoredInstance<Score>  -->  Expression
;;  Converts a scored instance into an Expression
;;  combining instance and score.
;; (: sInstToExpr (-> (ScoredInstance $score) Expression))
(= (sInstToExpr (mkSInst (mkPair $inst $score)))
    (let* (
      ($instExpr (instToExpr $inst))
      ($scoreExpr (eval (cScoreToExpr $score)))
    )
      (cons-atom $instExpr $scoreExpr)))

;;------------------------------------------------------------
;; exprToSInst
;;------------------------------------------------------------
;;  Expression  -->  ScoredInstance<Score>
;;  Parses an Expression into a scored instance.
; (: exprToSInst (-> Expression ScoredInstance))
(= (exprToSInst $expr)
    (let* (
      (($instExpr $scoreExpr) (decons-atom $expr))
      ($inst (exprToInst $instExpr))
      ($score (eval (exprToCScore $scoreExpr)))
    )
      (mkSInst (mkPair $inst $score))))

;;------------------------------------------------------------
;; sInstSetToExpr
;;------------------------------------------------------------
;;  InstanceSet<Score>  -->  Expression
;;  Converts a scored instance set into Expression form.
;;
;;  How it works:
;;    - Input: An InstanceSet<Score>
;;    - The function sInstSetToExpr calls sInstSetListToExpr on the list inside the set.
;;    - sInstSetListToExpr maps sInstToExpr over each element (scored instance) in the list.
;;    - sInstToExpr turns each scored instance into an Expression by combining the instance and its score.
;;    - Finally, List.listToExpr collects all these expressions into a single Expression list.
;;
;;  Example input:
;;    (Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 Nil))) (mkCscore 100.0 5.0 10.0 2.0 88.0))) Nil)
;;
;;  Output Expression:
;;    ((1 2) (100.0 5.0 10.0 2.0 88.0))
;;
;; (: sInstSetToExpr (-> (InstanceSet $score) Expression))
(= (sInstSetToExpr (mkSInstSet $lst)) (eval (sInstSetListToExpr $lst)))

;;------------------------------------------------------------
;; sInstSetListToExpr
;;------------------------------------------------------------
;;  List<ScoredInstance<Score>>  -->  Expression
;;  Converts a list of scored instances to Expression.
; (: sInstSetListToExpr (-> (List (ScoredInstance $score)) Expression))
(= (sInstSetListToExpr $lst)
    (eval (List.listToExpr (eval (List.map sInstToExpr $lst)))))

;;------------------------------------------------------------
;; exprToSInstSet
;;------------------------------------------------------------
;;  Expression  -->  InstanceSet<Cscore>
;;  Parses Expression into a scored instance set.
;; (: exprToSInstSet (-> Expression (InstanceSet Cscore)))
(= (exprToSInstSet $expr)
    (mkSInstSet (eval (List.map exprToSInst (exprToList $expr)))))

;; Sorting
;; ============================================================
;; ============================================================

;;------------------------------------------------------------
;; sortDeme
;;------------------------------------------------------------
;;  InstanceSet<Cscore>  -->  InstanceSet<Cscore>
;;  Sorts a scored instance set in descending score order.
;;  (Replaces need for sortSInst and insertSInst helpers.)
;; (: sortDeme (-> (InstanceSet Cscore) (InstanceSet Cscore)))
(= (sortDeme $set)
    (let* (
      ($expr (sInstSetToExpr $set))
      ($n (size-atom $expr))
      ($sortedExpr (selectionSort $expr $n sInstComparator))
    )
      (exprToSInstSet $sortedExpr)))

;; ============================================================
;; Comparators and Accessors
;; ============================================================

;;------------------------------------------------------------
;; sInstComparator
;;------------------------------------------------------------
;;  Expression, Expression  -->  Bool
;;  Compares two scored instance expressions by score
;;  (descending: highest score first).
;; (: sInstComparator (-> Expression Expression Bool))
(= (sInstComparator $a $b)
    (let* (
      (($instA $scoreA) (decons-atom $a))
      (($instB $scoreB) (decons-atom $b))
      ($result (eval (cScoreExpr< $scoreB $scoreA)))
    )
      $result))

;;------------------------------------------------------------
;; getSInstScore
;;------------------------------------------------------------
;;  ScoredInstance<Score>  -->  Score
;;  Extracts score from a scored instance.
;; (: getSInstScore (-> (ScoredInstance $score) $score))
(= (getSInstScore (mkSInst (mkPair $inst $score))) $score)

;;------------------------------------------------------------
;; getInst
;;------------------------------------------------------------
;;  ScoredInstance<Score>  -->  Instance
;;  Extracts the instance from a scored instance.
;; (: getInst (-> (ScoredInstance $score) Instance))
(= (getInst (mkSInst (mkPair $inst $score))) $inst)

;;------------------------------------------------------------
;; instance>=
;;------------------------------------------------------------
;;  ScoredInstance<Score>, ScoredInstance<Score>  -->  Bool
;;  True if first scored instance has a score >= second.
;; (: instance>= (-> (ScoredInstance $score) (ScoredInstance $score) Bool))
(= (instance>= (mkSInst (mkPair $inst1 $score1))
               (mkSInst (mkPair $inst2 $score2)))
    (eval (apply >= $score1 $score2)))

;; (: instanceFs>= (-> (ScoredInstance $score) (ScoredInstance $score) Bool))
(= (instanceFs>= (mkSInst (mkPair $inst1 $score1))
               (mkSInst (mkPair $inst2 $score2)))
    (=> $score1 $score2))

; Generates a single random instance of the given length.
; Each element is produced by biasedRandomInt.
; Params:
;   $instLength — number of elements in the instance.
; Returns: List of integers (0–2) representing one instance.
;; (: generateRandomInstance (-> Number List))
(= (generateRandomInstance $instLength)
   (if (== $instLength 0)
       Nil
       (Cons (biasedRandomInt) (generateRandomInstance (- $instLength 1)))))

; Converts a list of scored instances (mkSInst) into a list of expressions.
; Each scored instance is transformed using sInstToExpr and accumulated.
; Params:
;   $sInsts — list of scored instances.
;   $acc — accumulator (initially Nil).
; Returns: List of instance expressions ((inst score) ...).
; (: sInstsToExp (-> (List $a) Expression Expression))
(= (sInstsToExp Nil $acc) $acc)
(= (sInstsToExp (Cons $scoredInst $rest) $acc)
(let $instExp (sInstToExpr $scoredInst)
     (sInstsToExp $rest (cons-atom $instExp $acc))))
