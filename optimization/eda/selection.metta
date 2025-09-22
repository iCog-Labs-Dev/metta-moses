;; ================================================================================
;; Selection Policy (Tournament Selection)
;; ================================================================================
;;
;; This file implements the selection policy for EDA.
;; Equivalent to selection logic in optimize.h in the C++ implementation.
;;
;; Key Components:
;; - Tournament selection for selecting promising individuals
;; - Random K selection for tournament participants
;; - Best individual selection from tournament participants
;;
;; Selection Strategy:
;; - Uses tournament selection to maintain diversity
;; - Selects n individuals using tournament selection
;; - Each tournament selects the best from k random participants

;; ================================================================================
;; Selection Policy (Tournament Selection)
;; ================================================================================

;; Tournament selection - select n individuals using tournament selection
(: tournament-selection (-> Number Deme Number (InstanceSet $score)))
(= (tournament-selection $tournamentSize $deme $nSelect)
   (let* (
         ((mkDeme $rep (mkSInstSet $instSet) $id) $deme)
         ($scoredInstances $instSet)
         ($selected (select-tournament $tournamentSize $scoredInstances $nSelect))
       )
       (mkSInstSet $selected)))

;; Select individuals using tournament selection
(: select-tournament (-> Number (List (ScoredInstance $score)) Number (List (ScoredInstance $score))))
(= (select-tournament $tournamentSize $instances $nSelect)
  (let* (
        ($len (coll.length $instances))
        ($need (min $nSelect $len))
        ($ts (min $tournamentSize (max 1 $len)))
      )
      (if (or (<= $need 0) (<= $len 0))
          Nil
          (let* (
                ((mkPair $winner $remainingAfter) (run-tournament $ts $instances))
                ($rest (select-tournament $ts $remainingAfter (- $need 1)))
              )
              (Cons $winner $rest)))))

;; Run a single tournament
(: run-tournament (-> Number (List (ScoredInstance $score)) (Pair (ScoredInstance $score) (List (ScoredInstance $score)))))
(= (run-tournament $tournamentSize $instances)
  (let* (
        ((mkPair $participants $rest) (select-random-k $tournamentSize $instances))
        ($winner (if (== (coll.length $participants) 0)
                     (coll.getByIdx $instances 0)
                     (select-best $participants)))
        ($participantsTail (List.tail $participants))
        ($remainingAfter (List.concat $rest $participantsTail))
      )
      (mkPair $winner $remainingAfter)))

;; Select random K participants
(: select-random-k (-> Number (List (ScoredInstance $score)) (Pair (List (ScoredInstance $score)) (List (ScoredInstance $score)))))
(= (select-random-k $k $instances)
  (if (or (<= $k 0) (== (coll.length $instances) 0))
      (mkPair Nil $instances)
      (let* (
            ($len (coll.length $instances))
            ($rf (randomFloat))
            ($idx (int (* $rf $len)))
            ($safeIdx (if (== $idx $len) (- $len 1) $idx))
            ($selected (coll.getByIdx $instances $safeIdx))
            ($remaining (coll.removeByIdx $instances $safeIdx))
            ((mkPair $restSel $restRem) (select-random-k (- $k 1) $remaining))
          )
          (mkPair (Cons $selected $restSel) $restRem))))


;; Select best individual from list
(: select-best (-> (List (ScoredInstance $score)) (ScoredInstance $score)))
(= (select-best $instances)
  (if (== (coll.length $instances) 0)
      (coll.getByIdx (Cons (mkSInst (mkPair (mkInst Nil) (worstCscore))) Nil) 0)
      (let* (
            ($head (coll.getByIdx $instances 0))
            ($tail (List.drop 1 $instances))
          )
          (List.foldl select-best-step $head $tail))))

(: select-best-step (-> (ScoredInstance $score) (ScoredInstance $score) (ScoredInstance $score)))
(= (select-best-step $bestSoFar $candidate)
  (if (apply >= $candidate $bestSoFar) $candidate $bestSoFar))

