;; ================================================================
;; External Bot Action Domain
;; ================================================================
;;
;; This file defines a complete action domain outside the generic
;; MOSES implementation.
;;
;; It defines:
;;   - domain state
;;   - actions
;;   - perceptions
;;   - fitness
;;   - best-score contract
;;   - MOSES parameter bindings
;;
;; Loaded with:
;;
;;   --domainFile=<path>
;;
;; The generic MOSES pipeline does not contain any domain-specific
;; knowledge about this environment.
;; ================================================================


;; ----------------------------------------------------------------
;; Domain State
;; ----------------------------------------------------------------
;;
;; Bot world:
;;   $pos  = current position
;;   $fuel = remaining actions
;;
;; Goal:
;;   position 3
;; ----------------------------------------------------------------


;; ----------------------------------------------------------------
;; Action: Move Forward
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
;; Action: Move Backward
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
;; Perception: At Goal
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
;; Fitness contract:
;;   (fitness $exemplar $trial-index)
;;
;; Each trial evaluates the action expression from an initial
;; world state.
;;
;; Two starting positions are used so the evolved program must
;; handle multiple initial conditions.
;;
;; Score:
;;   1.0  = success
;;  -1.0  = failure
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
;; Best Score
;; ----------------------------------------------------------------
;;
;; Contract:
;;   (bestScore $nTrials)
;;
;; Each trial can achieve a score of 1.0, so the best possible
;; score is equal to the number of trials.
;; ----------------------------------------------------------------

(= (botBestScore $n)
   (* 1.0 $n))


;; ----------------------------------------------------------------
;; External Domain Configuration
;; ----------------------------------------------------------------
;;
;; Configure the parameters consumed by the generic action route.
;;
;; actions:
;;   Action vocabulary available to the action representation.
;;
;; perceptions:
;;   Perception vocabulary available to evolved programs.
;;
;; fitness:
;;   Domain fitness function.
;;
;; bestScore:
;;   Domain best-score function.
;;
;; Vocabulary values are quoted so they are stored as values rather
;; than evaluated immediately.
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