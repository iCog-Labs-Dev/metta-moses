;; ============================================================================
;; core/monad.metta -- the context monad.
;;
;; A program is evaluated against a CONTEXT: a world, a board, a table row --
;; whatever the domain threads. Nothing in this file knows which.
;;
;;     (mkRes <value> <context>)
;;
;; is a computation that has already been run: it carries the value produced
;; and the (possibly changed) context.
;;
;; THE ONE RULE: the context is the LAST parameter of every operation here.
;; That is what lets a partially applied operation stand for "a computation
;; waiting for a context", which is what lets operators be written without
;; mentioning the context at all (see core/operators.metta).
;;
;; THE OTHER RULE: only `mreturn` and `mbind` below may mention `mkRes`. They
;; are the instance -- Haskell's `return` and `>>=`. Everything after them is
;; DERIVED, exactly as it is derived in Haskell, and would keep working if the
;; representation of a computation changed. A combinator that takes the result
;; apart is not a monadic combinator; it is this monad's code wearing a general
;; name.
;;
;; Nothing in this file may carry a (: ...) type declaration -- a declared
;; return type makes partial application fail, which would break exactly the
;; mechanism above.
;; ============================================================================

;; ---------------------------------------------------------------------------
;; The instance. These two clauses, and only these two, know what a computation
;; is made of.
;; ---------------------------------------------------------------------------

;; return :: a -> m a
(= (mreturn $value $ctx) (mkRes $value $ctx))

;; (>>=) :: m a -> (a -> m b) -> m b
;; The next step depends on the value AND may change the context.
(= (mbind $computation $next $ctx)
   (let (mkRes $value $after) ($computation $ctx) (($next $value) $after)))


;; ---------------------------------------------------------------------------
;; Derived. Nothing below mentions mkRes.
;; ---------------------------------------------------------------------------

;; Data.Bool.bool -- choose between two things on a plain Bool. The test comes
;; LAST so that (chooseM $then $else) is a continuation mbind can be handed.
(= (chooseM $then $else $test) (if $test $then $else))

;; Control.Monad.Extra.ifM :: m Bool -> m a -> m a -> m a
;;     ifM b t f = do { b' <- b ; if b' then t else f }
;; Both branches arrive as unapplied computations and only the chosen one is
;; ever run -- that is where the laziness in and_seq / AND actually comes from.
(= (ifM $test $then $else $ctx) (mbind $test (chooseM $then $else) $ctx))

;; liftM, i.e. fmap for a monad:  fmap f m = m >>= (return . f)
;;
;; EVERY combinator in this file keeps $ctx as an explicit last parameter, and
;; that is not cosmetic -- it is the rule that makes the file work. A clause's
;; arity is registered from its SOURCE head, before any eta-expansion, so a
;; combinator written without $ctx registers one lower; a call meaning to
;; partially apply it then looks like a complete call and compiles to a
;; predicate that does not exist. Both of these were caught here, and only by
;; the arity smoke tests at the top of tests/t-operators.metta:
;;   - (mfmap $fn $computation) made `(mfmap not (evalProgram $child))` in NOT
;;     compile to a nonexistent mfmap/3;
;;   - (fmapStep $fn $value) eta-expanded to /4, and the specializer then
;;     emitted a call to its /3, which does not exist.
(= (fmapStep $fn $value $ctx) (mreturn ($fn $value) $ctx))
(= (mfmap $fn $computation $ctx) (mbind $computation (fmapStep $fn) $ctx))

;; Control.Monad.Extra.allM / anyM, written the way Haskell writes them:
;;
;;     allM p []     = return True
;;     allM p (x:xs) = ifM (p x) (allM p xs) (return False)
;;     anyM p []     = return False
;;     anyM p (x:xs) = ifM (p x) (return True) (anyM p xs)
;;
;; The two clauses match on the SHAPE of the list rather than testing it for
;; emptiness. That is not a style choice: arguments here are built strictly, so
;; a body that took the head off the list would run car-atom on () in the empty
;; case, produce nothing, and take the whole call down silently.
;;
;; It also means a `children` that is not a list at all matches neither clause
;; and simply fails -- which is what maps a malformed node to the worst score,
;; and is why the operators need no guard of their own.
(= (allM $fn () $ctx) (mreturn True $ctx))
(= (allM $fn (cons $x $xs) $ctx)
   (ifM ($fn $x) (allM $fn $xs) (mreturn False) $ctx))

(= (anyM $fn () $ctx) (mreturn False $ctx))
(= (anyM $fn (cons $x $xs) $ctx)
   (ifM ($fn $x) (mreturn True) (anyM $fn $xs) $ctx))

;; const True
(= (constTrue $ignored) True)

;; An accessor for tests, not a combinator -- it is allowed to know the shape
;; for the same reason a pattern match in a test is allowed to.
(= (resValOf (mkRes $value $ctx)) $value)
