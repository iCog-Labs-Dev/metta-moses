;; ================================================================================
;; Selection Policy (Tournament)
;; ================================================================================
;;
;; Purpose
;; - Select promising individuals via tournament selection.
;; - Maintain diversity by sampling k random participants per tournament.
;;
;; Notes
;; - Non-deterministic due to randomness; tests check sizes, not identities.

;; ================================================================================
;; Selection Policy (Tournament Selection)
;; ================================================================================

;; Tournament selection - select n individuals using tournament selection
(: tournamentSelection (-> Number Deme Number (InstanceSet $score)))
(= (tournamentSelection $tournamentSize $deme $nSelect)
   (let* (
         ((mkDeme $rep (mkSInstSet $instSet) $id) $deme)
         ($scoredInstances $instSet)
         ;; Assert valid parameters
         ($validTournamentSize (if (<= $tournamentSize 0) 1 $tournamentSize))
         ($validNSelect (if (<= $nSelect 0) 0 $nSelect))
         ($selected (selectTournament $validTournamentSize $scoredInstances $validNSelect))
       )
       (mkSInstSet $selected)))

;; Select individuals using tournament selection
(: selectTournament (-> Number (List (ScoredInstance $score)) Number (List (ScoredInstance $score))))
(= (selectTournament $tournamentSize $instances $nSelect)
  (let* (
        ($len (coll.length $instances))
        ($need (min $nSelect $len))
        ($ts (min $tournamentSize (max 1 $len)))
      )
      (if (or (<= $need 0) (<= $len 0))
          Nil
          (let* (
                ((mkPair $winner $remainingAfter) (runTournament $ts $instances))
                ($rest (selectTournament $ts $remainingAfter (- $need 1)))
              )
              (Cons $winner $rest)))))

;; Run a single tournament
(: runTournament (-> Number (List (ScoredInstance $score)) (Pair (ScoredInstance $score) (List (ScoredInstance $score)))))
(= (runTournament $tournamentSize $instances)
  (let* (
        ((mkPair $participants $rest) (selectRandomK $tournamentSize $instances))
        ($winner (selectTournamentWinner $participants $instances))
        ($participantsTail (List.tail $participants))
        ($remainingAfter (List.concat $rest $participantsTail))
      )
      (mkPair $winner $remainingAfter)))

;; Helper function to select tournament winner
(: selectTournamentWinner (-> (List (ScoredInstance $score)) (List (ScoredInstance $score)) (ScoredInstance $score)))
(= (selectTournamentWinner $participants $instances)
  (if (== (coll.length $participants) 0)
      (if (== (coll.length $instances) 0)
          (getDefaultWorstInstance)  ; Both empty - return default
          (coll.getByIdx $instances 0))  ; Participants empty - use first instance
      (selectBest $participants)))  ; Participants available - select best

;; Select random K participants
(: selectRandomK (-> Number (List (ScoredInstance $score)) (mkPair (List (ScoredInstance $score)) (List (ScoredInstance $score)))))
(= (selectRandomK $k $instances)
  (if (or (<= $k 0) (== (coll.length $instances) 0))
      (mkPair Nil $instances)
      (if (> $k (coll.length $instances))
          (mkPair $instances Nil)  ; Return all instances if k > length
          (selectRandomKHelper $k $instances))))

;; Helper function to reduce nesting in selectRandomK
(: selectRandomKHelper (-> Number (List (ScoredInstance $score)) (Pair (List (ScoredInstance $score)) (List (ScoredInstance $score)))))
(= (selectRandomKHelper $k $instances)
  (let* (
        ($len (coll.length $instances))
        ($rf (randomFloat))
        ($idx (int (* $rf $len)))
        ($safeIdx (if (== $idx $len) (- $len 1) $idx))
        ($selected (coll.getByIdx $instances $safeIdx))
        ($remaining (coll.removeByIdx $instances $safeIdx))
        ((mkPair $restSel $restRem) (selectRandomK (- $k 1) $remaining))
      )
      (mkPair (Cons $selected $restSel) $restRem)))


;; Select best individual from list
(: selectBest (-> (List (ScoredInstance $score)) (ScoredInstance $score)))
(= (selectBest $instances)
  (if (== (coll.length $instances) 0)
      (getDefaultWorstInstance)
      (selectBestFromNonEmpty $instances)))

;; Helper function to get default worst instance
(: getDefaultWorstInstance (-> (ScoredInstance $score)))
(= (getDefaultWorstInstance)
  (coll.getByIdx (Cons (mkSInst (mkPair (mkInst Nil) (worstCscore))) Nil) 0))

;; Helper function to select best from non-empty list
(: selectBestFromNonEmpty (-> (List (ScoredInstance $score)) (ScoredInstance $score)))
(= (selectBestFromNonEmpty $instances)
  (let* (
        ($head (coll.getByIdx $instances 0))
        ($tail (List.drop 1 $instances))
      )
      (List.foldl selectBestStep $head $tail)))

(: selectBestStep (-> (ScoredInstance $score) (ScoredInstance $score) (ScoredInstance $score)))
(= (selectBestStep $bestSoFar $candidate)
  (if (apply >= $candidate $bestSoFar) $candidate $bestSoFar))

