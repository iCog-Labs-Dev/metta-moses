;; ================================================================
;; External Bot Action Domain
;; ================================================================
;;
;; This file is intentionally external to the generic MOSES
;; implementation.
;;
;; It defines:
;;   1. Domain state
;;   2. Domain actions
;;   3. Domain perceptions
;;   4. Fitness
;;   5. Best-score contract
;;   6. MOSES parameter bindings
;;
;; It is loaded through:
;;
;;     --domainFile=<path>
;;
;; The generic MOSES pipeline should not need to know anything
;; about this domain.
;; ================================================================


;; ----------------------------------------------------------------
;; Domain state
;; ----------------------------------------------------------------

;; Bot world:
;;
;;   $pos  = current position
;;   $fuel = remaining number of actions
;;
;; Goal:
;;
;;   position 3
;;
;; ----------------------------------------------------------------

;; ----------------------------------------------------------------
;; Action: move forward
;; ----------------------------------------------------------------

(= (botForward $params (mkBotWorld $pos $fuel))
   (if (> $fuel 0)
       (mkARes
          True
          (mkBotWorld
             (+ $pos 1)
             (- $fuel 1)))
       (mkARes
          False
          (mkBotWorld
             $pos
             $fuel))))


;; ----------------------------------------------------------------
;; Action: move backward
;; ----------------------------------------------------------------

(= (botBackward $params (mkBotWorld $pos $fuel))
   (if (> $fuel 0)
       (if (> $pos 0)
           (mkARes
              True
              (mkBotWorld
                 (- $pos 1)
                 (- $fuel 1)))
           (mkARes
              False
              (mkBotWorld
                 $pos
                 $fuel)))
       (mkARes
          False
          (mkBotWorld
             $pos
             $fuel))))


;; ----------------------------------------------------------------
;; Perception: are we at the goal?
;; ----------------------------------------------------------------

(= (botAtGoal $params (mkBotWorld $pos $fuel))
   (mkARes
      (== $pos 3)
      (mkBotWorld
         $pos
         $fuel)))


;; ----------------------------------------------------------------
;; Fitness
;; ----------------------------------------------------------------
;;
;; MOSES action fitness contract:
;;
;;     (fitness $exemplar $trial-index)
;;
;; The action expression is evaluated from an initial world.
;;
;; We use two starting positions so that the evolved program
;; must handle more than one initial condition.
;;
;; Success:
;;     final position == 3
;;
;; Score:
;;     1.0  -> success
;;    -1.0  -> failure
;;
;; ----------------------------------------------------------------

(= (botFitness $exp $i)
   (let*
      (
        ($start
           (if (isEven $i)
               (mkBotWorld 0 9)
               (mkBotWorld 2 9)))

        ((mkARes
            $v
            (mkBotWorld $pos $fuel))
         (evalAction
            $exp
            $start))
      )

      (if (== $pos 3)
          1.0
          -1.0)))


;; ----------------------------------------------------------------
;; Best possible score
;; ----------------------------------------------------------------
;;
;; MOSES calls:
;;
;;     (bestScore $nTrials)
;;
;; where $nTrials is the configured number of fitness trials.
;;
;; Every trial can score 1.0, therefore:
;;
;;     bestScore(n) = n
;;
;; ----------------------------------------------------------------

(= (botBestScore $n)
   (* 1.0 $n))


;; ----------------------------------------------------------------
;; External domain configuration
;; ----------------------------------------------------------------
;;
;; These are the parameters consumed by the generic action route.
;;
;; actions:
;;     Vocabulary available to the action representation.
;;
;; perceptions:
;;     Perception vocabulary available to evolved programs.
;;
;; fitness:
;;     Domain fitness function.
;;
;; bestScore:
;;     Domain best-score function.
;;
;; quote is important because actions/perceptions are vocabulary
;; values rather than calls that should be evaluated immediately.
;; ----------------------------------------------------------------

!(set-param actions
   (quote
      (botForward
       botBackward)))

!(set-param perceptions
   (quote
      (botAtGoal)))

!(set-param fitness
   botFitness)

!(set-param bestScore
   botBestScore)

