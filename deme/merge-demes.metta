;; it takes a deme and merge the optimized instances in the deme into the metapopulation
;; - sorting the instances inside the deme
;; - selects top unique instances
;; - deme is trimmed
;; - candidates converted to tree
;; - trees added to set of potential candidates
;; - remove candidates already found in the metapopulation
;; - remove dominated trees
;; TODO 
;; - merge candidates with the metapop
;; - resize the metapop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;(Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 (Cons 3 (Cons 2.0 Nil))))) 3.2)) Nil)

(: Exemplar (-> $type Type))
(: mkExemplar (-> (Tree $a) DemeId Cscore BehavioralScore (Exemplar $a)))

;; Extract BScore from Exemplar
(: getExemplarBScore (-> (Exemplar $a) BehavioralScore))
(= (getExemplarBScore (mkExemplar $tree $demeId $cscore $bscore)) $bscore)

!(bind! EPSILON (pow-math 10 -6))
(= (isApproxEq $a $b $epsilon) (< (abs-math (- $a $b)) $epsilon))

;; remove adjacent duplicate instances, limited by topCnd
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

;; removing duplicates and keeping top scoring unique ones
(: keepTopUniqueCandidates (-> (InstanceSet Cscore) Number Number (List (ScoredInstance Cscore))))
(= (keepTopUniqueCandidates $sortedSInstList $nEval $maxCandsPerDeme)
 (let*
 (
    (() (println! "inside keep"))
    ($lenSInstList (List.length $sortedSInstList))
    ($topCnd (min-atom ($nEval $lenSInstList)))
    ($uTopCnd (if (>= $maxCandsPerDeme 0) (min-atom ($topCnd $maxCandsPerDeme)) $topCnd))
    ($uniqueTopCandidates (removeDupInsts $sortedSInstList $uTopCnd))
 )
 $uniqueTopCandidates
 ))

(= (usefulScoreRange $complexityTemperature)(/ (* 30 $complexityTemperature) 100.0))

(= (filterDemeByScore Nil $lastIndex $botSc) Nil)
(= (filterDemeByScore (Cons $si $sis) 0 $botSc) (Cons $si $sis))
(= (filterDemeByScore (Cons $si $sis) $lastIndex $botSc)
(let*
(
   ($lastSInst (List.getByIdx (Cons $si $sis) $lastIndex))
   ($lastSInstScore (getSInstScore $lastSInst))
   ($lastSInstPenScore (getPenScore $lastSInstScore))
)
(if (< $lastSInstPenScore $botSc) 
    (let $lastRemovedList (List.removeAtIdx (Cons $si $sis) $lastIndex) (filterDemeByScore $lastRemovedList (- $lastIndex 1) $botSc))
    (filterDemeByScore (Cons $si $sis) (- $lastIndex 1) $botSc)
    )
))

(: trimDownDeme (-> Deme Number Number Deme))
(= (trimDownDeme (mkDeme $rep (mkSInstSet $sInstList) (mkDemeId $demeId)) $minPoolSize $complexityTemperature)
(let $demeSize (List.length $sInstList)
(if (or (>= $minPoolSize $demeSize) (<= $demeSize 1)) 
    (mkDeme $rep (mkSInstSet $sInstList) (mkDemeId $demeId))
    (let*
      (
       ($topInst (List.head $sInstList))
       ($topScore (getSInstScore $topInst))
       ($topPenScore (getPenScore $topScore))
       ($botSc (- $topPenScore (usefulScoreRange $complexityTemperature)))
       ($filteredSInstList (filterDemeByScore $sInstList (- $demeSize 1) $botSc)))     
      (mkDeme $rep (mkSInstSet $filteredSInstList) (mkDemeId $demeId))))))

(: demeToTrees(-> Deme (ITable $a) (List (Exemplar $a))))
(= (demeToTrees (mkDeme $rep (mkSInstSet Nil) (mkDemeId $demeId)) $itable) Nil)
(= (demeToTrees (mkDeme $rep (mkSInstSet (Cons $si $sil)) (mkDemeId $demeId)) $itable)
(let*
(
    ($cscore (getSInstScore $si))
    ($inst (getInst $si))
    ($tree (getCandidate $rep $inst))
    ($bscore (scoreTree $itable $tree))
    ($scoredTree (mkExemplar $tree (mkDemeId $demeId) $cscore $bscore))
)
(Cons $scoredTree (demeToTrees (mkDeme $rep (mkSInstSet $sil) (mkDemeId $demeId))))
))

(= (getNewCandidates Nil $metaPop) Nil)
(= (getNewCandidates (Cons $xmp $xmpl) $metaPop)
(if (List.isMember $xmp $metaPop)
    (getNewCandidates $xmpl $metaPop)
    (Cons $xmp (getNewCandidates $xmpl $metaPop))
)
)

(: dominates (-> BehavioralScore BehavioralScore $bool))
(= (dominates (mkBScore Nil) (mkBScore Nil)) Indeterminate)
(= (dominates (mkBScore Nil) (mkBScore (Cons $by $bys))) False)
(= (dominates (mkBScore (Cons $bx $bxs)) (mkBScore Nil)) True)
(= (dominates (mkBScore (Cons $bx $bxs)) (mkBScore (Cons $by $bys)))
   (dominatesRec (mkBScore (Cons $bx $bxs)) (mkBScore (Cons $by $bys)) Indeterminate))
(= (dominatesRec (mkBScore (Cons $bx $bxs)) (mkBScore (Cons $by $bys)) $res)
   (if (> $bx $by)
       (if (== $res False) Indeterminate
           (dominatesRec (mkBScore $bxs) (mkBScore $bys) True))
       (if (> $by $bx)
           (if (== $res True) Indeterminate
               (dominatesRec (mkBScore $bxs) (mkBScore $bys) False))
           (dominatesRec (mkBScore $bxs) (mkBScore $bys) $res))))
(= (dominatesRec (mkBScore Nil) (mkBScore Nil) $res) $res)

;; Remove dominated Exemplars
(: removeDominated (-> (List (Exemplar $a)) (List (Exemplar $a))))
(= (removeDominated Nil) Nil)
(= (removeDominated (Cons $exemplar Nil)) (Cons $exemplar Nil))
(= (removeDominated (Cons $exemplar (Cons $next $rest)))
   (removeDominatedRec $exemplar (Cons $next $rest) Nil))

;; Helper: Compare exemplar with rest, accumulate non-dominated
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

()

(: mergeDemes (-> Deme Number Number (ITable $a) (List (ScoredInstance Cscore))))
(= (mergeDemes (mkDeme $rep $sInstList $demeId) $nEval $maxCandsPerDeme $itable)
(let*
(
    ($sortedSInstList (sortDeme $sInstList)) ;; sorting the instances inside the deme by decreasing order
    ($unqCandidates (keepTopUniqueCandidates $sortedSInstList $nEval $maxCandsPerDeme))  ;;remove duplicates and limits the size by keeping the top scoring
    ; ($trimmedDeme (trimDownDeme $unqCandidates))  ;; further trims the deme
    ; ($potCandidates (demeToTrees $trimmedDeme (ITable $a))) ;;convert instances to trees
    ; ($candidates (getNewCandidates $treesToBeMerged)) ;;which aren't found in the meta pop
    ; ($removedDominated (removeDominated $candidates))  ;;removeDominated 
    ; ; ($updatedBestCandidate (updateBestCandidates $removedDominated))  ;;update best candidate
    ; ($candidatesMerged (mergeCandidates $updatedBestCandidate))  ;;merge candidates into metapop
    ; ($resizedMetapop (resizeMetapop))  ;;resize the metapop

)
$unqCandidates
))

