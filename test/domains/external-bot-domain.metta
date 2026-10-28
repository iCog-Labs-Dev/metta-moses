
;; External Bot Action Domain
;; ================================================================
;; Defines the bot state, actions, perceptions, fitness, and
;; best-score function for use with the generic MOSES pipeline.
;; Loaded with: --domainFile=<path>


;; Domain State
;; Bot world:
;;              $pos  = current position
;;              $fuel = remaining actions
;; Goal: position 3


;; Action: Move Forward
(= (botForward $params (mkBotWorld $pos $fuel))
   (if (> $fuel 0)
       (mkARes True (mkBotWorld (+ $pos 1) (- $fuel 1)))
       (mkARes False (mkBotWorld $pos $fuel))))

;; Action: Move Backward
(= (botBackward $params (mkBotWorld $pos $fuel))
   (if (> $fuel 0)
       (if (> $pos 0)
           (mkARes True (mkBotWorld (- $pos 1) (- $fuel 1)))
           (mkARes False (mkBotWorld $pos $fuel)))
       (mkARes False (mkBotWorld $pos $fuel))))


;; Perception: At Goal
(= (botAtGoal $params (mkBotWorld $pos $fuel))
   (mkARes (== $pos 3) (mkBotWorld $pos $fuel)))


;; Fitness 
;; Evaluates an action expression from different starting states. 
;; Score: 1.0 = success, -1.0 = failure.

(= (botFitness $exp $i)
   (let*
      (
        ($start (if (isEven $i)
                    (mkBotWorld 0 9)
                    (mkBotWorld 2 9)))

        ((mkARes $v (mkBotWorld $pos $fuel))
         (evalAction $exp $start))
      )
      (if (== $pos 3) 1.0 -1.0)))


;; Best Score 
;; Best possible score is the number of trials

(= (botBestScore $n) (* 1.0 $n))

