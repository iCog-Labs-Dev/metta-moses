;; Types, constructors and functions related to instance.

;; An instance is just a vector of numbers

(: Instance Type)
(: mkInst (-> (List Number) Instance))

;; A scored instance is just a pair of instance and it's score.
(: ScoredInstance (-> $score Type))
(: mkSInst (-> (Pair Instance $score) (ScoredInstance $score)))

;; An instance set is a list of scored instances.
(: InstanceSet (-> $score Type))
(: mkSInstSet (-> (List (ScoredInstance $score)) (InstanceSet $score)))

;; --- Conversion helpers ---
(: instToExpr (-> Instance Expression))
(= (instToExpr (mkInst $lst)) (List.toExpr $lst))

(: exprToInst (-> Expression Instance))
(= (exprToInst $expr) (mkInst (List.fromExpr $expr)))

(: sInstToExpr (-> (ScoredInstance $score) Expression))
(= (sInstToExpr (mkSInst (mkPair $inst $score)))
    (let* (
      ($instExpr (instToExpr $inst))
      ($scoreExpr (cScoreToExpr $score))
    )
      (cons-atom $instExpr $scoreExpr)))

(= (exprToSInst $expr)
    (let* (
      (($instExpr $scoreExpr) (decons-atom $expr))
      ($inst (exprToInst $instExpr))
      ($score (exprToCScore $scoreExpr))
    )
      (mkSInst (mkPair $inst $score))))

(= (sInstSetToExpr (mkSInstSet $lst)) (sInstSetListToExpr $lst))

(= (sInstSetListToExpr Nil) ())
(= (sInstSetListToExpr (Cons $scoredInst $rest))
    (let* (
      ($sInstExpr (sInstToExpr $scoredInst))
      ($restExpr (sInstSetListToExpr $rest))
    )
      (cons-atom $sInstExpr $restExpr)))

(: exprToSInstSet (-> Expression (InstanceSet Cscore)))
(= (exprToSInstSet $expr)
    (mkSInstSet (List.map exprToSInst (List.fromExpr $expr))))

;; --- Fast selectionSort implementation with conversion ---
(: sortDeme (-> (InstanceSet Cscore) (InstanceSet Cscore)))
(= (sortDeme $set)
    (let* (
      ($expr (sInstSetToExpr $set))
      ($n (len $expr))
      ($sortedExpr (selectionSort $expr $n sInstComparator))
    )
      (exprToSInstSet $sortedExpr)))

(: sortSInst (-> (List (ScoredInstance Cscore)) (List (ScoredInstance Cscore))))
(= (sortSInst $lst)
    (let* (
      ($expr (sInstSetListToExpr $lst))
      ($n (len $expr))
      ($sortedExpr (selectionSort $expr $n sInstComparator))
      ($sortedList (List.map exprToSInst (List.fromExpr $sortedExpr)))
    )
      $sortedList))

(: insertSInst (-> (ScoredInstance Cscore) (List (ScoredInstance Cscore)) (List (ScoredInstance Cscore))))
(= (insertSInst $sinst $lst)
    (sortSInst (Cons $sinst $lst))) 

;; --- Optimized comparator for selectionSort ---
;; This comparator sorts in DESCENDING order (best scores first)
(= (sInstComparator $a $b)
    (let* (
      (($instA $scoreA) (decons-atom $a))
      (($instB $scoreB) (decons-atom $b))
    )
      ;; Use cScoreExpr< in reverse - we want better scores first
      (cScoreExpr< $scoreB $scoreA)))

;; extracts the score of a scored instance object
(= (getSInstScore (mkSInst (mkPair $inst $score))) $score)

;; extracts the instance from a scored instance object
(= (getInst (mkSInst (mkPair $inst $score))) $inst)

;; Scored Instance comparator --> instance>=
(: instance>= (-> (ScoredInstance $score) (ScoredInstance $score) Bool))
(= (instance>= (mkSInst (mkPair $inst1 $score1)) (mkSInst (mkPair $inst2 $score2)))
    (cScore>= $score1 $score2))


