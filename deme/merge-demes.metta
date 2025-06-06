;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                 Merge Demes                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Removes adjacent duplicate ScoredInstances from a sorted list, keeping up to $topCnd unique instances.
;; Params:
;;    (List (ScoredInstance Cscore)): Sorted list of scored instances.
;;    $topCnd: Maximum number of instances to keep.
;; Return: (List (ScoredInstance Cscore)): List with adjacent duplicates removed, limited by $topCnd.
(: removeDupInsts (-> (List (ScoredInstance Cscore)) Number (List (ScoredInstance Cscore))))
(= (removeDupInsts Nil $topCnd) Nil)
(= (removeDupInsts (Cons $x Nil) $topCnd)
   (if (> $topCnd 0) (Cons $x Nil) Nil))
(= (removeDupInsts (Cons $x (Cons $y $rest)) $topCnd)
   (let $lengthOfTail (List.length (Cons $y $rest))
   (if (> $topCnd 0)
       (if (== $x $y)
           (removeDupInsts
             (Cons $y $rest)
             (min-atom ($topCnd $lengthOfTail)))  ;; Update topCnd
           (Cons $x (removeDupInsts
                      (Cons $y $rest)
                      (- $topCnd 1))))  ;; Keep $x, reduce topCnd
       Nil)))

;; Extracts up to $maxCandsPerDeme unique ScoredInstances from a sorted InstanceSet, limited by $nEval.
;; Params:
;;   (InstanceSet Cscore): Sorted set of scored instances.
;;   $nEval: Maximum evaluations.
;;   $maxCandsPerDeme: Maximum candidates per deme.
;; Return: (List (ScoredInstance Cscore)): List of unique top-scoring instances.
(: keepTopUniqueCandidates (-> (InstanceSet Cscore) Number Number (List (ScoredInstance Cscore))))
(= (keepTopUniqueCandidates (mkSInstSet $sortedSInstList) $nEval $maxCandsPerDeme)
 (let*
 (
    ($lenSInstList (List.length $sortedSInstList))
    ($topCnd (min-atom ($nEval $lenSInstList)))
    ($uTopCnd (if (>= $maxCandsPerDeme 0) (min-atom ($topCnd $maxCandsPerDeme)) $topCnd))
    ($uniqueTopCandidates (removeDupInsts $sortedSInstList $uTopCnd))
 )
 $uniqueTopCandidates
 ))

;; Filters a sorted list of ScoredInstances, removing instances with penalized scores below $botSc, starting from $lastIndex.
;; Params:
;;   (List (ScoredInstance Cscore)): Sorted list of scored instances.
;;   $lastIndex: Index to start checking from (end of list).
;;   $botSc: Minimum penalized score threshold.
;; Return: (List (ScoredInstance Cscore)): Filtered list with low-scoring instances removed.
(: filterDemeByScore (-> (List (ScoredInstance Cscore)) Number Number (List (ScoredInstance Cscore))))
(= (filterDemeByScore Nil $lastIndex $botSc) Nil)
(= (filterDemeByScore $listOfScoredInsts 0 $botSc) $listOfScoredInsts)
(= (filterDemeByScore $listOfScoredInsts $lastIndex $botSc)
(let*
(
   ($lastSInst (List.getByIdx $listOfScoredInsts $lastIndex))
   ($lastSInstScore (getSInstScore $lastSInst))
   ($lastSInstPenScore (getPenScore $lastSInstScore))
)
(if (< $lastSInstPenScore $botSc) 
    (let $lastRemovedList (List.removeAtIdx $listOfScoredInsts $lastIndex) (filterDemeByScore $lastRemovedList (- $lastIndex 1) $botSc))
    (filterDemeByScore $listOfScoredInsts (- $lastIndex 1) $botSc)
    )
))

;; Trims a sorted list of ScoredInstances to remove low-scoring instances based on a score range derived from $complexityTemperature, unless size ≤ $minPoolSize or 1.
;; Params:
;;   (List (ScoredInstance Cscore)): Sorted list of scored instances.
;;   $minPoolSize: Minimum number of instances to retain.
;;   $complexityTemperature: Parameter for computing score range.
;;Return: (List (ScoredInstance Cscore)): Trimmed list of instances.
(: trimDownDeme (-> (List (ScoredInstance Cscore)) Number Number (List (ScoredInstance Cscore))))
(= (trimDownDeme $sInstList $minPoolSize $complexityTemperature)
(let $demeSize (List.length $sInstList)
(if (or (>= $minPoolSize $demeSize) (<= $demeSize 1)) 
    $sInstList
    (let*
      (
       ($topInst (List.head $sInstList))
       ($topScore (getSInstScore $topInst))
       ($topPenScore (getPenScore $topScore))
       ($botSc (- $topPenScore (usefulScoreRange $complexityTemperature)))
       ($filteredSInstList (filterDemeByScore $sInstList (- $demeSize 1) $botSc)))     
       $filteredSInstList))))

;; Converts a Deme into a list of Exemplars by transforming each ScoredInstance into a scored tree.
;; Params:
;;   $deme: A deme containing a representation, scored instance set, and demeId.
;;   $itable: The input table.
;; Return: (List (Exemplar $a)) - List of exemplars with scored trees.
(: demeToTrees(-> Deme (ITable $a) (List (Exemplar $a))))
(= (demeToTrees (mkDeme $rep (mkSInstSet Nil) $demeId) $itable) Nil)
(= (demeToTrees (mkDeme $rep (mkSInstSet (Cons $si $sil)) $demeId) $itable)
(let*
(
    ($cscore (getSInstScore $si))
    ($inst (getInst $si)) 
    ($tree (getCandidate $rep $inst))
    ($bscore (scoreTree $itable $tree))
    ($scoredTree (mkExemplar $tree $demeId $cscore $bscore))
)
(Cons $scoredTree (demeToTrees (mkDeme $rep (mkSInstSet $sil) $demeId) $itable))
))

;; Filters a list of Exemplars, keeping only those not already in the metaPop (ordered set).
;; Params:
;;   (List (Exemplar $a)): List of exemplars to filter.
;;   $metaPop: Ordered set of existing exemplars.
;; Return: (List (Exemplar $a)): List of new exemplars not in metaPop.
(: getNewCandidates (-> (List (Exemplar $a)) (OS (Exemplar $a)) (List (Exemplar $a))))
(= (getNewCandidates Nil $metaPop) Nil)
(= (getNewCandidates (Cons $xmp $xmpl) $metaPop)
(if (OS.isMember $xmp $metaPop)
    (getNewCandidates $xmpl $metaPop)
    (Cons $xmp (getNewCandidates $xmpl $metaPop))))

;; Determines if one BehavioralScore dominates another by comparing their score lists.
;; Params:
;;   $bscore1: First bscore 
;;   $bscore2: Second score
;; Return: True if $bscore1 dominates, 
;;         False if $bscore2 dominates, 
;;         Indeterminate otherwise.
;; x dominates y if:
;; for all i x_i >= y_i and there exists i such that x_i > y_i
(: dominates (-> BehavioralScore BehavioralScore Atom))
(= (dominates (mkBScore Nil) (mkBScore Nil)) Indeterminate)
(= (dominates (mkBScore Nil) (mkBScore (Cons $by $bys))) False)
(= (dominates (mkBScore (Cons $bx $bxs)) (mkBScore Nil)) True)
(= (dominates (mkBScore (Cons $bx $bxs)) (mkBScore (Cons $by $bys)))
   (dominatesRec (mkBScore (Cons $bx $bxs)) (mkBScore (Cons $by $bys)) Indeterminate))

;; helper function for dominates
(: dominatesRec (-> BehavioralScore BehavioralScore Atom Atom))
(= (dominatesRec (mkBScore Nil) (mkBScore Nil) $res) $res)
(= (dominatesRec (mkBScore (Cons $bx $bxs)) (mkBScore (Cons $by $bys)) $res)
   (if (> $bx $by)
       (if (== $res False) Indeterminate
           (dominatesRec (mkBScore $bxs) (mkBScore $bys) True))
       (if (> $by $bx)
           (if (== $res True) Indeterminate
               (dominatesRec (mkBScore $bxs) (mkBScore $bys) False))
           (dominatesRec (mkBScore $bxs) (mkBScore $bys) $res))))

;; Removes dominated exemplars from a list based on their BehavioralScores.
;; Params:
;;   (List (Exemplar $a)): List of exemplars to filter.
;; Return: (List (Exemplar $a)): List of non-dominated exemplars.
(: removeDominated (-> (List (Exemplar $a)) (List (Exemplar $a))))
(= (removeDominated Nil) Nil)
(= (removeDominated (Cons $exemplar Nil)) (Cons $exemplar Nil))
(= (removeDominated (Cons $exemplar (Cons $next $rest)))
   (removeDominatedRec $exemplar (Cons $next $rest) Nil))

;; Helper: Compares an exemplar with others, accumulating non-dominated exemplars.
;; Params:
;;   $exemplar: Current exemplar to compare.
;;   (List (Exemplar $a)): Remaining exemplars to process.
;;   $acc: Accumulator for non-dominated exemplars.
;; Return: List including $exemplar and non-dominated others.
(: removeDominatedRec (-> (Exemplar $a) (List (Exemplar $a)) (List (Exemplar $a)) (List (Exemplar $a))))
(= (removeDominatedRec $exemplar Nil $acc)
   (Cons $exemplar $acc))
(= (removeDominatedRec $exemplar (Cons $other $rest) $acc)
   (let $domResult (dominates (getExemplarBScore $exemplar) (getExemplarBScore $other))
      (if (== $domResult True)
          (removeDominatedRec $exemplar $rest $acc)
          (if (== $domResult False)
              (removeDominated (Cons $other $rest))
              (removeDominatedRec $exemplar $rest (Cons $other $acc))))))

;; Merges a list of exemplars into the metapopulation, maintaining order based on exemplar comparison.
;; Assumes the exemplars are already filtered so it directly inserts them to the metapopulation
;; Params:
;;   (List (Exemplar $a)): List of exemplars to merge 
;;   $metapop: Ordered set to merge into.
;; Return: $updatedMetaPop: Updated ordered set with merged exemplars.
(: mergeCandidates (-> (List (Exemplar $a)) (OS (Exemplar $a)) (OS (Exemplar $a))))
(= (mergeCandidates Nil $metapop) $metapop)
(= (mergeCandidates (Cons $x $xs) $metapop)
   (let $updatedMetaPop (OS.insert compareExemplar $x $metapop)
      (mergeCandidates $xs $updatedMetaPop)))

;; Merges a deme's candidates into a metapopulation, processing through sorting, deduplication, trimming, tree conversion, filtering, dominance removal, merging, and resizing.
;; Params:
;;   $deme: Input deme
;;   $nEval: Number of evaluations for candidate selection.
;;   $maxCandsPerDeme: Maximum candidates per deme.
;;   $minPoolSize: Minimum deme size to retain.
;;   $complexityTemperature: Parameter for score range in trimming.
;;   $itable: The input table.
;;   $metapop: Ordered set of existing exemplars.
;;   $nToKeep: Target size for resized metapopulation.
;;   $capCoef: Capacity coefficient for resizing.
;;   $genCount: Generation count for resizing.
;; Return: Updated and resized metapopulation.
(: mergeDemes (-> Deme Number Number Number Number (ITable $a) (OS (Exemplar $a)) Number Number Number (OS (Exemplar $a))))
(= (mergeDemes (mkDeme $rep $sInstList $demeId) $nEval $maxCandsPerDeme $minPoolSize $complexityTemperature $itable $metapop $nToKeep $capCoef $genCount)
(let*
( 
    ($sortedSInstList (sortDeme $sInstList)) ;; sorting the instances inside the deme by decreasing order
    ($unqCandidates (keepTopUniqueCandidates $sortedSInstList $nEval $maxCandsPerDeme))  ;;remove duplicates and limits the size by keeping the top scoring
    ($trimmedDeme (trimDownDeme $unqCandidates $minPoolSize $complexityTemperature))  ;; further trims the deme
    ($potCandidates (demeToTrees (mkDeme $rep (mkSInstSet $trimmedDeme) $demeId) $itable)) ;;convert instances to trees
    ($candidates (getNewCandidates $potCandidates $metapop)) ;;which aren't found in the meta pop
    ($removedDominated (removeDominated $candidates))  ;;removeDominated 
    ($updatedMetaPop (mergeCandidates $removedDominated $metapop))  ;;merge candidates into metapop
    ($resizedMetapop (resizeMetapop $updatedMetaPop $nToKeep $minPoolSize $complexityTemperature $capCoef $genCount))  ;;resize the metapop
)
$resizedMetapop))

