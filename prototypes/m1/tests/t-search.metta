;; ============================================================================
;; tests/t-search.metta -- does the search actually get anywhere?
;;
;; Checked as PROPERTIES rather than as one memorised answer. There is more
;; than one best program here (test for food and grab, or test for no-food and
;; step), and which one the search reaches first depends on the order it looks
;; in -- which is not what we care about.
;; ============================================================================

(= (bestPair)  (searchBest m1ScoreExp (m1Rep)))
(= (bestInst)  (let ($i $s) (bestPair) $i))
(= (bestScore) (let ($i $s) (bestPair) $s))

;; it starts badly
!(test (m1Score (m1Rep) (defaultInstance (m1Rep))) -25)

;; and ends at the best the world allows
!(test (bestScore) (m1BestScore))
!(test (bestScore) 10)

;; the winner actually looks at something. An empty condition is no test at
;; all -- that is the shape a program that never looks would have.
(= (condOfCandidate $t) (index-atom (kidsOf (car-atom (kidsOf $t))) 0))
(= (looksAtSomething $t) (!= (kidsOf (condOfCandidate $t)) ()))
!(test (looksAtSomething (candidateOf (m1Rep) (bestInst))) True)

;; and it beats every program that never looks -- 10 against a ceiling of 2
!(test (> (bestScore) (maxOf (blindScores))) True)
!(test (- (bestScore) (m1Score (m1Rep) (defaultInstance (m1Rep)))) 35)
