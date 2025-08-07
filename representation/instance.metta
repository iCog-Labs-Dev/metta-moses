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
(: Instance Type)
(: mkInst (-> (List Number) Instance))

;;------------------------------------------------------------
;;  ScoredInstance
;;------------------------------------------------------------
;;  +---------------------+
;;  | Pair Instance Score |  -->  ScoredInstance<Score>
;;  +---------------------+
;;  Combines an Instance with a score value.
(: ScoredInstance (-> $score Type))
(: mkSInst (-> (Pair Instance $score) (ScoredInstance $score)))

;;------------------------------------------------------------
;;  InstanceSet
;;------------------------------------------------------------
;;  +-----------------------------------------+
;;  | List of ScoredInstance<Score>           |  -->  InstanceSet<Score>
;;  +-----------------------------------------+
;;  Represents a list of scored instances.
(: InstanceSet (-> $score Type))
(: mkSInstSet (-> (List (ScoredInstance $score)) (InstanceSet $score)))

;; ============================================================
;; Conversion Helpers
;; ============================================================

;;------------------------------------------------------------
;; instToExpr
;;------------------------------------------------------------
;;  Instance  -->  Expression
;;  Converts an Instance into an Expression form.
(: instToExpr (-> Instance Expression))
(= (instToExpr (mkInst $lst)) (List.listToExpr $lst))

;;------------------------------------------------------------
;; exprToInst
;;------------------------------------------------------------
;;  Expression  -->  Instance
;;  Parses an Expression into an Instance.
(: exprToInst (-> Expression Instance))
(= (exprToInst $expr) (mkInst (exprToList $expr)))

;;------------------------------------------------------------
;; sInstToExpr
;;------------------------------------------------------------
;;  ScoredInstance<Score>  -->  Expression
;;  Converts a scored instance into an Expression
;;  combining instance and score.
(: sInstToExpr (-> (ScoredInstance $score) Expression))
(= (sInstToExpr (mkSInst (mkPair $inst $score)))
    (let* (
      ($instExpr (instToExpr $inst))
      ($scoreExpr (cScoreToExpr $score))
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
      ($score (exprToCScore $scoreExpr))
    )
      (mkSInst (mkPair $inst $score))))

;;------------------------------------------------------------
;; sInstSetToExpr
;;------------------------------------------------------------
;;  InstanceSet<Score>  -->  Expression
;;  Converts a scored instance set into Expression form.
(: sInstSetToExpr (-> (InstanceSet $score) Expression))
(= (sInstSetToExpr (mkSInstSet $lst)) (sInstSetListToExpr $lst))

;;------------------------------------------------------------
;; sInstSetListToExpr
;;------------------------------------------------------------
;;  List<ScoredInstance<Score>>  -->  Expression
;;  Converts a list of scored instances to Expression.
; (: sInstSetListToExpr (-> (List (ScoredInstance $score)) Expression))
(= (sInstSetListToExpr $lst)
    (List.listToExpr (List.map sInstToExpr $lst)))

;;------------------------------------------------------------
;; exprToSInstSet
;;------------------------------------------------------------
;;  Expression  -->  InstanceSet<Cscore>
;;  Parses Expression into a scored instance set.
(: exprToSInstSet (-> Expression (InstanceSet Cscore)))
(= (exprToSInstSet $expr)
    (mkSInstSet (List.map exprToSInst (exprToList $expr))))

;; ============================================================
;; Sorting
;; ============================================================

;;------------------------------------------------------------
;; sortDeme
;;------------------------------------------------------------
;;  InstanceSet<Cscore>  -->  InstanceSet<Cscore>
;;  Sorts a scored instance set in descending score order.
;;  (Replaces need for sortSInst and insertSInst helpers.)
(: sortDeme (-> (InstanceSet Cscore) (InstanceSet Cscore)))
(= (sortDeme $set)
    (let* (
      ($expr (sInstSetToExpr $set))
      ($n (len $expr))
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
(: sInstComparator (-> Expression Expression Bool))
(= (sInstComparator $a $b)
    (let* (
      (($instA $scoreA) (decons-atom $a))
      (($instB $scoreB) (decons-atom $b))
      ($result (cScoreExpr< $scoreB $scoreA))
    )
      $result))

;;------------------------------------------------------------
;; getSInstScore
;;------------------------------------------------------------
;;  ScoredInstance<Score>  -->  Score
;;  Extracts score from a scored instance.
(: getSInstScore (-> (ScoredInstance $score) $score))
(= (getSInstScore (mkSInst (mkPair $inst $score))) $score)

;;------------------------------------------------------------
;; getInst
;;------------------------------------------------------------
;;  ScoredInstance<Score>  -->  Instance
;;  Extracts the instance from a scored instance.
(: getInst (-> (ScoredInstance $score) Instance))
(= (getInst (mkSInst (mkPair $inst $score))) $inst)

;;------------------------------------------------------------
;; instance>=
;;------------------------------------------------------------
;;  ScoredInstance<Score>, ScoredInstance<Score>  -->  Bool
;;  True if first scored instance has a score >= second.
(: instance>= (-> (ScoredInstance $score) (ScoredInstance $score) Bool))
(= (instance>= (mkSInst (mkPair $inst1 $score1))
               (mkSInst (mkPair $inst2 $score2)))
    (cScore>= $score1 $score2))
