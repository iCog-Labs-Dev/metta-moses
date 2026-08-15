;; ============================================================================
;; core/monad.metta -- the context monad, made ambient.
;;
;; A program is evaluated against a CONTEXT: a world, a board, a table row --
;; whatever the domain threads. Nothing in this file knows which.
;;
;; THE ONE RULE: this is the only file that may name `&ctx`. Everything else
;; reaches the context through `getCtx` and `putCtx`, which are Haskell's
;; MonadState `get` and `put`. That is the abstraction barrier -- the same role
;; `mreturn` and `mbind` used to play by being the only things that knew what a
;; computation was made of. If the context ever has to go back to being a
;; threaded value, these two are the seam.
;;
;; WHY THERE IS NO `mbind` HERE. An earlier version of this file was a real
;; State monad: a computation was a partially applied call awaiting a context,
;; and `mbind` could hold one unrun and decide whether to run it. That rested on
;; three things PeTTa adds to MeTTa -- partial application, eta-expansion, and
;; `|->` lambdas -- and this file no longer uses any of them.
;;
;; Take those away and the monad OPERATIONS stop being definable functions,
;; because arguments here are built strictly:
;;
;;     m >>= k     is   let          (by the time a function is entered its
;;     fmap f m    is   (f m)         arguments have already run, so a
;;     return v    is   v             user-defined bind could never choose)
;;     ifM         is   if
;;
;; `ifM` in particular MUST be `if`. Written as a function, the arguments
;; `(allM $fn $xs)` and `False` would both be built before the test was even
;; looked at, and the recursion below would never stop. Only a special form can
;; be lazy, and `if` is one: it compiles to Prolog's (Cond -> Then ; Else), so
;; only the taken branch runs. core/prelude.metta's `rangeFrom` and `repeat`
;; already depend on that and terminate.
;;
;; This is not a retreat from monads -- it is the other way Haskell hides state.
;; `State s a = s -> (a, s)` hides it inside a wrapped function and needs
;; closures; `IO` and `ST` hide it by making it AMBIENT, and `RealWorld` is a
;; fiction nothing threads. Control.Monad.Extra's allM is `Monad m => ...` and
;; is written identically for both, which is why the two definitions below are
;; character-for-character the Haskell ones.
;;
;; WHAT THIS COSTS. The context is mutated rather than passed, and `nb_setval`
;; is not undone by backtracking. Two consequences live in
;; core/evaluator.metta: `once` sits inside every `collapse` so a second
;; solution can never re-run an action, and a program that fails PARTWAY keeps
;; whatever it already did rather than handing back the context it was given.
;; ============================================================================

;; PeTTa's state is a global variable (metta.pl:232 -- nb_setval/nb_getval).
;; The initial value is never read: evalProgram sets the cell before anything
;; looks at it.
!(bind! &ctx (new-state ()))

;; MonadState:  get :: m s   /   put :: s -> m ()
(= (getCtx)      (get-state &ctx))
(= (putCtx $ctx) (change-state! &ctx $ctx))


;; ---------------------------------------------------------------------------
;; Control.Monad.Extra.allM / anyM:
;;
;;     allM p []     = return True
;;     allM p (x:xs) = ifM (p x) (allM p xs) (return False)
;;
;; Generic in the predicate, and what they do with the context is nothing at
;; all -- it is carried by the cell. The recursive call sits in a branch of
;; `if`, so a walk genuinely stops at the first False instead of running the
;; rest for its effects.
;;
;; The two clauses match on the SHAPE of the list rather than testing it for
;; emptiness. That is not a style choice: arguments are built strictly, so a
;; body that took the head off the list would run car-atom on () in the empty
;; case, produce nothing, and take the whole call down silently.
;;
;; It also means a `children` that is not a list at all matches neither clause
;; and simply fails -- which is what maps a malformed node to the worst score,
;; and is why the operators need no guard of their own.
;; ---------------------------------------------------------------------------
(= (allM $fn ())            True)
(= (allM $fn (cons $x $xs)) (if ($fn $x) (allM $fn $xs) False))

(= (anyM $fn ())            False)
(= (anyM $fn (cons $x $xs)) (if ($fn $x) True (anyM $fn $xs)))

;; const True
(= (constTrue $ignored) True)

;; An accessor for tests, not a combinator -- it is allowed to know the shape of
;; what evalProgram hands back for the same reason a pattern match in a test is.
(= (resValOf (mkRes $value $ctx)) $value)
