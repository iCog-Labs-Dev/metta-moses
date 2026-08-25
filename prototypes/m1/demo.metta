;; ============================================================================
;; demo.metta -- THE TAPE WORLD: is it worth LOOKING before you grab?
;;
;;   ( ulimit -v 8000000; timeout 900 \
;;       sh /home/yab/PeTTaV1/run.sh prototypes/m1/demo.metta -s )
;;
;; WORLD        a strip of cells, some holding food. The creature has fuel, a
;;              position, and a tally of what it ate and what it wasted.
;; CONTEXT      that world -- and the program CHANGES it. Every action spends
;;              fuel and either moves or eats, so the context handed to the next
;;              step is not the one this step got. This is the case the whole
;;              context-threading machinery exists for.
;; IT CAN DO    m1Step (move on), m1Grab (eat what is here).
;; IT CAN SEE   m1FoodHere, m1FoodAhead. Looking costs nothing.
;; SCORE        food eaten minus food wasted, summed over two episodes. Higher
;;              is better; 10 is everything there is to get.
;; THE POINT    grabbing blindly wastes more than it gains, and NO program that
;;              never looks can score above 2 -- the two episodes agree in one
;;              place and differ everywhere else, so a blind program runs an
;;              identical course on both and gives back whatever it gains. The
;;              question is whether the search discovers that looking first
;;              pays, which means BUILDING a conditional rather than picking an
;;              action.
;;
;; The exemplar is deliberately backwards: it steps when it sees food and grabs
;; when it does not.
;;
;; One call. Everything else -- building the knobs, walking the neighbourhood,
;; decoding, scoring -- is search/moses.metta, and it is the same call every
;; other demo here makes.
;; ============================================================================
!(import! &self prototypes/m1/all)
!(import! &self prototypes/m1/domain/tape)

!(m1Moses tape (m1Exemplar) m1ScoreExp (m1BestScore))
