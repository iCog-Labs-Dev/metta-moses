;; ============================================================================
;; tests/t-operators.metta -- the runtime: operators, laziness, coexistence.
;;
;; Everything is `test`, never `assert`: `test` compares against ALL the answers
;; a call produced, so it catches "no answer" and "two answers" as well as
;; "wrong answer". Those are the shapes the failures here actually take.
;; ============================================================================

;; --- READ THESE FIRST -------------------------------------------------------
;; Each one proves an operator was compiled with the number of arguments the
;; evaluator calls it with. If an operator body accidentally ends in a bare
;; `if`, it is compiled one argument short, dispatch quietly fails, and EVERY
;; program scores worst while the run still looks healthy. These catch that
;; before any score is computed.
(= (arityOk $op $children)
   (let $e (quote ($op $children w0))
     (collapse (let (mkRes $v $w) (reduce $e) True))))

!(test (arityOk and_seq ())                       (True))
!(test (arityOk or_seq ())                        (True))
!(test (arityOk AND ())                           (True))
!(test (arityOk OR ())                            (True))
!(test (arityOk NOT (True))                       (True))
!(test (arityOk action_not (True))                (True))
!(test (arityOk return_success (True))            (True))
!(test (arityOk action_success ())                (True))
!(test (arityOk action_failure ())                (True))
!(test (arityOk action_bool_if (True True False)) (True))

;; --- empty cases. The search depends on these: a condition with everything
;;     switched off must mean "no test", not "disaster".
!(test (evalProgram (quote (and_seq ())) w0) (mkRes True w0))
!(test (evalProgram (quote (or_seq ()))  w0) (mkRes False w0))
!(test (evalProgram (quote (AND ()))     w0) (mkRes True w0))
!(test (evalProgram (quote (OR ()))      w0) (mkRes False w0))

;; --- malformed children score worst, they do not crash ---------------------
;; There is no guard in the operators for this. allM and anyM match on the
;; shape of the list, so children that are not a list match no clause, the call
;; produces nothing, and evalNode's collapse turns that into the worst result.
;; Delete this check and the guard's removal stops being covered by anything.
!(test (evalProgram (quote (AND notATuple)) w0) (mkRes False w0))
!(test (evalProgram (quote (and_seq notATuple)) w0) (mkRes False w0))

;; --- the boolean operators on programs, threading a context ----------------
!(test (evalProgram (quote (AND ((m1FoodHere ()) (m1FoodAhead ())))) (mkW (F F) 0 0 0 5))
       (mkRes True (mkW (F F) 0 0 0 5)))
!(test (evalProgram (quote (AND ((m1FoodHere ()) (m1FoodAhead ())))) (mkW (F E) 0 0 0 5))
       (mkRes False (mkW (F E) 0 0 0 5)))
!(test (evalProgram (quote (NOT ((m1FoodHere ())))) (mkW (E F) 0 0 0 5))
       (mkRes True (mkW (E F) 0 0 0 5)))

;; --- an operator takes no context of its own --------------------------------
;; It is reached at the arity the evaluator uses, and there is no version one
;; argument wider. Adding a context parameter breaks both of these at once.
!(test (evalProgram (quote (AND ((m1FoodHere ())))) (mkW (F E) 0 0 0 5))
       (mkRes True (mkW (F E) 0 0 0 5)))
!(test (let $e (quote (AND ((m1FoodHere ())) somethingExtra (mkW (F E) 0 0 0 5)))
         (collapse (let (mkRes $v $w) (reduce $e) True)))
       ())

;; --- laziness ---------------------------------------------------------------
;; Every check below puts an ACTION where a skipped evaluation would show up.
;; Perceptions hand the world back untouched, so a laziness test written with
;; perceptions alone passes whether or not anything was skipped -- it proves
;; nothing. Do not "simplify" these.
;; The untaken branch never runs: had the else run, position would be 1.
!(test (evalProgram (quote (action_bool_if ((m1FoodHere ()) (m1Grab ()) (m1Step ()))))
                    (mkW (F E) 0 0 0 5))
       (mkRes True (mkW (E E) 0 1 0 4)))
;; and the other way: had the then run, a move would have been wasted
!(test (evalProgram (quote (action_bool_if ((m1FoodHere ()) (m1Grab ()) (m1Step ()))))
                    (mkW (E F) 0 0 0 5))
       (mkRes True (mkW (E F) 1 0 0 4)))
;; AND stops at the first False -- fuel untouched, so the grab never happened
!(test (evalProgram (quote (AND ((m1FoodHere ()) (m1Grab ())))) (mkW (E F) 0 0 0 5))
       (mkRes False (mkW (E F) 0 0 0 5)))
!(test (evalProgram (quote (AND ((m1FoodHere ()) (m1Grab ())))) (mkW (F E) 0 0 0 5))
       (mkRes True (mkW (E E) 0 1 0 4)))
;; the context really is threaded: the grab clears the cell, so the following
;; look must report nothing there
!(test (evalProgram (quote (AND ((m1Grab ()) (m1FoodHere ())))) (mkW (F E) 0 0 0 5))
       (mkRes False (mkW (E E) 0 1 0 4)))

;; --- constants stay constants, operators stay operators ---------------------
;; The second pair is what the tempting "has no declared type" test gets wrong:
;; a declared operator would stop being called and start returning itself.
!(test (isGroundLiteral True)  True)
!(test (isGroundLiteral 7)     True)
!(test (isGroundLiteral m1FoodHere)     False)
!(test (isGroundLiteral action_bool_if) False)
!(test (isGroundLiteral return_success) False)   ;; undeclared -- still an operator
!(test (evalProgram m1FoodHere (mkW (F E) 0 0 0 5)) (mkRes True (mkW (F E) 0 0 0 5)))
!(test (evalProgram True       (mkW (F E) 0 0 0 5)) (mkRes True (mkW (F E) 0 0 0 5)))
