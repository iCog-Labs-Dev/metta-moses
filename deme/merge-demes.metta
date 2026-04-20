;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                 Merge Demes                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Removes adjacent duplicate ScoredInstances from a sorted list, keeping up to $topCnd unique instances.
;; Params:
;;    (List (ScoredInstance Cscore)): Sorted list of scored instances.
;;    $topCnd: Maximum number of instances to keep.
;; Return: (List (ScoredInstance Cscore)): List with adjacent duplicates removed, limited by $topCnd.
; (: removeDupInsts (-> (List (ScoredInstance Cscore)) Number (List (ScoredInstance Cscore))))
(= (removeDupInsts $rep () $topCnd) ())
(= (removeDupInsts $rep (cons $x ()) $topCnd)
   (if (> $topCnd 0) (cons $x ()) ()))
(= (removeDupInsts $rep (cons (mkSInst $x) (cons (mkSInst $y) $rest)) $topCnd)
   (let $lengthOfTail (List.length (cons (mkSInst $y) $rest))
   (if (> $topCnd 0)
       (if (isApproxEq (getPenScore (Pair.second $x)) (getPenScore (Pair.second $y))) ;; They maybe identical
           (let*
              (
                ($tr1 (getCandidate $rep (Pair.first $x)))
                ($tr2 (getCandidate $rep (Pair.first $y)))
                ;; ($_ (println! (Tree1: (preOrder $tr1) Tree2: (preOrder $tr2))))
              )
              (if (== $tr1 $tr2)
                  (removeDupInsts $rep (cons (mkSInst $x) $rest) (min-atom ($topCnd $lengthOfTail)))
                  (cons (mkSInst $x) (removeDupInsts $rep (cons (mkSInst $y) $rest) (- $topCnd 1))) ;; Keep $x, reduce topCnd
              )
           )
           (cons (mkSInst $x) (removeDupInsts $rep (cons (mkSInst $y) $rest) (- $topCnd 1))))  ;; Keep $x, reduce topCnd
       ())))

;; Extracts up to $maxCandsPerDeme unique ScoredInstances from a sorted InstanceSet, limited by $nEval.
;; Params:
;;   (InstanceSet Cscore): Sorted set of scored instances.
;;   $nEval: Maximum evaluations.
;;   $maxCandsPerDeme: Maximum candidates per deme.
;; Return: (List (ScoredInstance Cscore)): List of unique top-scoring instances.
; (: keepTopUniqueCandidates (-> (InstanceSet Cscore) Number Number (List (ScoredInstance Cscore))))
(= (keepTopUniqueCandidates $rep (mkSInstSet $sortedSInstList) $nEval $maxCandsPerDeme)
 (let*
 (
    ;; ($instExpr (List.listToExpr $sortedSInstList))
    ;; ($uniqueSortedInstExpr (unique-atom $instExpr))
    ;; ($uniqueSortedInstList (exprToList $uniqueSortedInstExpr))
    ;; ($lenSInstList (List.length $uniqueSortedInstList))
    ($lenSInstList (List.length $sortedSInstList))
    ($_ (println! (nEval: $nEval LenSInstList: $lenSInstList)))
    ($topCnd (min-atom ($nEval $lenSInstList)))
    ($_ (println! (TopCnd: $topCnd)))
    ($uTopCnd (if (>= $maxCandsPerDeme 0) (min-atom ($topCnd $maxCandsPerDeme)) $topCnd))
    ($_ (println! (Keep $uTopCnd Unique instances from (List.length $sortedSInstList))))
    ;; ($_ (println! ""))
    ;; ($_ (println! (Before removing duplicates)))
    ;; ($exprList (List.listToExpr $sortedSInstList))
    ;; ($bmr (map-atom $exprList $inst (let (mkSInst $x) $inst (println! (Tree: (preOrder (getCandidate $rep (Pair.first $x))) Inst: (List.listToExpr (second (Pair.first $x))))))))
    ;; ($uniqueTopCandidates (removeDupInsts $uniqueSortedInstList $uTopCnd))
    ($uniqueTopCandidates (removeDupInsts $rep $sortedSInstList $uTopCnd))
    ;; ($uExprList (List.listToExpr $uniqueTopCandidates))
    ;; ($_ (println! ""))
    ;; ($_ (println! (After removing duplicates)))
    ;; ($amr (map-atom $uExprList $inst (let (mkSInst $x) $inst (println! (preOrder (getCandidate $rep (Pair.first $x)))))))
 )
 $uniqueTopCandidates
 ))

;; Filters a sorted list of ScoredInstances, removing instances with penalized scores below $botSc, starting from $lastIndex.
;; Params:
;;   (List (ScoredInstance Cscore)): Sorted list of scored instances.
;;   $lastIndex: Index to start checking from (end of list).
;;   $botSc: Minimum penalized score threshold.
;; Return: (List (ScoredInstance Cscore)): Filtered list with low-scoring instances removed.
; (: filterDemeByScore (-> (List (ScoredInstance Cscore)) Number Number (List (ScoredInstance Cscore))))
(= (filterDemeByScore () $lastIndex $botSc) ())
(= (filterDemeByScore (cons $x $xs) $lastIndex $botSc)
(if (== $lastIndex 0) (cons $x $xs) (let*
(
   ($listOfScoredInsts (cons $x $xs))
   ($lastSInst (List.getByIdx $listOfScoredInsts $lastIndex))
   ($lastSInstScore (getSInstScore $lastSInst))
   ($lastSInstPenScore (getPenScore $lastSInstScore))
)
(if (< $lastSInstPenScore $botSc) 
    (let $lastRemovedList (List.removeAtIdx $listOfScoredInsts $lastIndex) (filterDemeByScore $lastRemovedList (- $lastIndex 1) $botSc))
    (filterDemeByScore $listOfScoredInsts (- $lastIndex 1) $botSc)
    )
)))

;; Trims a sorted list of ScoredInstances to remove low-scoring instances based on a score range derived from $complexityTemperature, unless size ≤ $minPoolSize or 1.
;; Params:
;;   (List (ScoredInstance Cscore)): Sorted list of scored instances.
;;   $minPoolSize: Minimum number of instances to retain.
;;   $complexityTemperature: Parameter for computing score range.
;;Return: (List (ScoredInstance Cscore)): Trimmed list of instances.
; (: trimDownDeme (-> (List (ScoredInstance Cscore)) Number Number (List (ScoredInstance Cscore))))
(= (trimDownDeme $sInstList $minPoolSize $complexityTemperature)
(let $demeSize (List.length $sInstList)
(if (or (>= $minPoolSize $demeSize) (<= $demeSize 1)) 
    $sInstList
    (let*
      (
       ($topInst (List.head $sInstList))
       ($topScore (getSInstScore $topInst))
       ($topPenScore (getPenScore $topScore))
       ;; ($_ (println! (TopPenScore: $topPenScore)))
       ($botSc (- $topPenScore (usefulScoreRange $complexityTemperature)))
       ;; ($_ (println! (UsefullscoreRange: $botSc)))
       ($filteredSInstList (filterDemeByScore $sInstList (- $demeSize 1) $botSc)))     
       $filteredSInstList))))

;; Converts a Deme into a list of Exemplars by transforming each ScoredInstance into a scored tree.
;; Params:
;;   $deme: A deme containing a representation, scored instance set, and demeId.
;;   $itable: The input table.
;; Return: (List (Exemplar $a)) - List of exemplars with scored trees.
; (: demeToTrees (-> Deme (ITable $a) (List (Exemplar $a))))
(= (demeToTrees (mkDeme $rep (mkSInstSet ()) $demeId) $scoringContext) ())
(= (demeToTrees (mkDeme $rep (mkSInstSet (cons $si $sil)) $demeId) $scoringContext)
(let*
    (
        ;; ($_ (println! (===Inside DemeToTrees===)))
        ($cscore (getSInstScore $si))
        ($inst (getInst $si))
        ;; ($_ (println! (Representation: $rep)))
        ;; ($_ (println! (Instance: $inst)))
        ($tree (getCandidate $rep $inst))
        ;; ($_ (println! (Tree: (preOrder $tree))))
        ;; ($_ (println! (ScoringContext: $scoringContext)))
        ($bscore (case $scoringContext
                    (((mkITable $rows $labels) (scoreTree $scoringContext $tree &bscoreCache))
                     (($nGames $opponentPolicy) (scoreStrategyTree $tree $nGames $opponentPolicy &strategyScoreCache)))))
        ($scoredTree (mkExemplar $tree $demeId $cscore $bscore))
        ;; ($_ (println! (Returning...)))
    )
    (cons $scoredTree (demeToTrees (mkDeme $rep (mkSInstSet $sil) $demeId) $scoringContext))
    )
)
;; Filters a list of Exemplars, keeping only those not already in the metaPop (ordered set).
;; Params:
;;   (List (Exemplar $a)): List of exemplars to filter.
;;   $metaPop: Ordered set of existing exemplars.
;; Return: (List (Exemplar $a)): List of new exemplars not in metaPop.
; (: getNewCandidates (-> (List (Exemplar $a)) (OS (Exemplar $a)) (List (Exemplar $a))))
(= (getNewCandidates () $metaPop) ())
(= (getNewCandidates (cons $xmp $xmpl) $metaPop)
     (if (OS.isMember $xmp $metaPop)
        (getNewCandidates $xmpl $metaPop)
        (let $updatedMetaPop (OS.insert compareExemplar $xmp $metaPop) (cons $xmp (getNewCandidates $xmpl $updatedMetaPop))))
)

;; Determines if one BehavioralScore dominates another by comparing their score lists.
;; Params:
;;   $bscore1: First bscore 
;;   $bscore2: Second score
;; Return: True if $bscore1 dominates, 
;;         False if $bscore2 dominates, 
;;         Indeterminate otherwise.
;; x dominates y if:
;; for all i x_i >= y_i and there exists i such that x_i > y_i
; (: dominates (-> BehavioralScore BehavioralScore Atom))
(= (dominates (mkBScore ()) (mkBScore ())) Indeterminate)
(= (dominates (mkBScore ()) (mkBScore (cons $by $bys))) False)
(= (dominates (mkBScore (cons $bx $bxs)) (mkBScore ())) True)
(= (dominates (mkBScore (cons $bx $bxs)) (mkBScore (cons $by $bys)))
   (dominatesRec (mkBScore (cons $bx $bxs)) (mkBScore (cons $by $bys)) Indeterminate))

;; helper function for dominates
; (: dominatesRec (-> BehavioralScore BehavioralScore Atom Atom))
(= (dominatesRec (mkBScore ()) (mkBScore ()) $res) $res)
(= (dominatesRec (mkBScore (cons $bx $bxs)) (mkBScore (cons $by $bys)) $res)
   (if (> $bx $by)
       (if (== $res False) 
           Indeterminate
           (dominatesRec (mkBScore $bxs) (mkBScore $bys) True))
       (if (> $by $bx)
           (if (== $res True)
               Indeterminate
               (dominatesRec (mkBScore $bxs) (mkBScore $bys) False))
           (dominatesRec (mkBScore $bxs) (mkBScore $bys) $res))))

;; Removes dominated exemplars from a list based on their BehavioralScores.
;; Params:
;;   (List (Exemplar $a)): List of exemplars to filter.
;; Return: (List (Exemplar $a)): List of non-dominated exemplars.
; (: removeDominated (-> (List (Exemplar $a)) (List (Exemplar $a))))
(= (removeDominated ()) ())
(= (removeDominated (cons $exemplar ())) (cons $exemplar ()))
(= (removeDominated (cons $exemplar (cons $next $rest)))
   (removeDominatedRec $exemplar (cons $next $rest) ()))

;; Helper: Compares an exemplar with others, accumulating non-dominated exemplars.
;; Params:
;;   $exemplar: Current exemplar to compare.
;;   (List (Exemplar $a)): Remaining exemplars to process.
;;   $acc: Accumulator for non-dominated exemplars.
;; Return: List including $exemplar and non-dominated others.
; (: removeDominatedRec (-> (Exemplar $a) (List (Exemplar $a)) (List (Exemplar $a)) (List (Exemplar $a))))
(= (removeDominatedRec $exemplar () $acc)
   (cons $exemplar $acc))
(= (removeDominatedRec $exemplar (cons $other $rest) $acc)
   (let $domResult (dominates (getExemplarBScore $exemplar) (getExemplarBScore $other))
      ;; (trace! (if (== $domResult True) Dominated $domResult)
      (if (== $domResult True) ;; Could also be Indeterminate that's why we use explicit == comparison
          (removeDominatedRec $exemplar $rest $acc)
          (if (== $domResult False)
              (removeDominated (cons $other $rest))
              (removeDominatedRec $exemplar $rest (cons $other $acc))))
      ;; )
      ))

;; Merges a list of exemplars into the metapopulation, maintaining order based on exemplar comparison.
;; Assumes the exemplars are already filtered so it directly inserts them to the metapopulation
;; Params:
;;   (List (Exemplar $a)): List of exemplars to merge 
;;   $metapop: Ordered set to merge into.
;; Return: $updatedMetaPop: Updated ordered set with merged exemplars.
; (: mergeCandidates (-> (List (Exemplar $a)) (OS (Exemplar $a)) (OS (Exemplar $a))))
(= (mergeCandidates () $metapop) $metapop)
(= (mergeCandidates (cons $x $xs) $metapop)
   (let $updatedMetaPop (OS.insert compareExemplar $x $metapop)
      (mergeCandidates $xs $updatedMetaPop)))

;; Merges a deme's candidates into a metapopulation, processing through sorting, deduplication, trimming, tree conversion, filtering, dominance removal, merging, and resizing.
;; Params:
;;   $demes: List of demes to process.
;;   $nEval: Number of evaluations for candidate selection.
;;   $maxCandsPerDeme: Maximum candidates per deme.
;;   $minPoolSize: Minimum deme size to retain.
;;   $complexityTemperature: Parameter for score range in trimming.
;;   $scoringContext: Either (mkITable $rows $labels) for Boolean or ($nGames $opponentPolicy) for Strategy
;;   $metapop: Ordered set of existing exemplars.
;;   $nToKeep: Target size for resized metapopulation.
;;   $capCoef: Capacity coefficient for resizing.
;;   $genCount: Generation count for resizing.
;; Return: Updated and resized metapopulation.
; (: mergeDemes (-> Expression Number Number Number Number (ITable $a) (OS (Exemplar $a)) Number Number Number (OS (Exemplar $a))))
(= (mergeDemes $demes $nEval $maxCandsPerDeme $minPoolSize $complexityTemperature $scoringContext $metapop $nToKeep $capCoef $genCount)
    (if (== $demes ()) $metapop
        (let*
        (
            ;; ($_ (println! ("")))
            ;; ($_ (println! ("--------------------------------")))
            ;; ($_ (println! (===== MergeDemes Starting =====)))
            (($headDeme $tailDeme) (decons-atom $demes))
            ((mkDeme $rep $sInstList $demeId) $headDeme)
            ($sortedSInstList (sortDeme $sInstList)) ;; sorting the instances inside the deme by decreasing order
            ($_ (println! (Demesize: (List.length (second $sortedSInstList)))))
            ;; ($demeExpr (List.listToExpr (second $sortedSInstList)))
            ;; ($_ (println! (UniqueDemeSize: (length (unique-atom $demeExpr)))))
            ($unqCandidates (keepTopUniqueCandidates $rep $sortedSInstList $nEval $maxCandsPerDeme))  ;;remove duplicates and limits the size by keeping the top scoring
            ($_ (println! (KeptUniqueTopCandidates NewSize: (List.length $unqCandidates))))
            ($trimmedDeme (trimDownDeme $unqCandidates $minPoolSize $complexityTemperature))  ;; further trims the deme
            ;; ($_ (println! (DemeToTrees Starting...)))
            ($_ (println! (TrimmedDownDeme: (List.length $trimmedDeme))))
            ($potCandidates (demeToTrees (mkDeme $rep (mkSInstSet $trimmedDeme) $demeId) $scoringContext)) ;;convert instances to trees
            ($_ (println! (Before getNewCandidates: (List.length $potCandidates))))
            ;; ($_ (println! (Metapop: $metapop)))
            ;; ($_ (println! ("--")))
            ($candidates (getNewCandidates $potCandidates $metapop)) ;;which aren't found in the meta pop
            ;; ($_ (println! (NewCandidates: (List.length $candidates))))
            ($removedDominated (removeDominated $candidates))  ;;removeDominated
            ;; ($_ (println! (Removed Dominated: $removedDominated)))
            ($_ (println! (Going to merge (List.length $removedDominated) Instances)))
            ($updatedMetaPop (mergeCandidates $removedDominated $metapop))  ;;merge candidates into metapop
            ;; ($_ (println! (merged Candidate: $updatedMetaPop)))
            ($_ (println! (Metapop size before resize: (OS.length $updatedMetaPop))))
            ($resizedMetapop (resizeMetapop $updatedMetaPop $nToKeep $minPoolSize $complexityTemperature $capCoef $genCount))  ;;resize the metapop
            ($_ (println! (Metapop size after resize: (OS.length $resizedMetapop))))
            ; ($resizedMetapop (if (<= $nToKeep (OS.length $updatedMetaPop)) (OS.getTopN $nToKeep $updatedMetaPop) $updatedMetaPop)) ;; select top nToKeep candidates
            ;; ($_ (println! (Resized Metapop: $resizedMetapop)))
            ;; ($_ (println! ("--------------------------------")))
            ;; ($_ (println! ("")))
        )
            (if (== $tailDeme ()) $resizedMetapop
                (mergeDemes $tailDeme $nEval $maxCandsPerDeme $minPoolSize $complexityTemperature $scoringContext $resizedMetapop $nToKeep $capCoef $genCount)
            )
        )
    )
)
