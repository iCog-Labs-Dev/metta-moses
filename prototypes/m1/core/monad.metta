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

;; `if` over a plain Bool, choosing between two COMPUTATIONS. The test is an
;; ordinary value, not an m Bool -- Haskell's `if`, not its `ifM`.
;;
;; It exists because a clause body that ends in a bare `if` does not
;; eta-expand: the enclosing operator would compile one argument short and
;; every program would silently score worst. Ending in a call to this instead
;; keeps that from happening.
;;
;; Both branches arrive as unapplied computations and only the chosen one is
;; ever run -- that is where the laziness in and_seq / AND comes from.
(= (ifM $test $then $else $ctx) (if $test ($then $ctx) ($else $ctx)))

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

;; Control.Monad.Extra.allM / anyM. Haskell writes them with its own ifM,
;;
;;     allM p (x:xs) = ifM (p x) (allM p xs) (return False)
;;
;; which desugars to exactly what is below: run the head, then branch on the
;; value it produced. The `\v -> ...` becomes a named step, because there are
;; no lambdas here -- the same trick pickBranch uses in core/operators.metta,
;; with the captured variables hoisted into leading parameters so that a
;; partial application is the closure. The step also takes $ctx, for the reason
;; given above: written value-last it would eta-expand, and the specializer
;; then emits a call at the pre-eta arity that does not exist.
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
(= (allM $fn (cons $x $xs) $ctx) (mbind ($fn $x) (allMStep $fn $xs) $ctx))
(= (allMStep $fn $xs $value $ctx) (ifM $value (allM $fn $xs) (mreturn False) $ctx))

(= (anyM $fn () $ctx) (mreturn False $ctx))
(= (anyM $fn (cons $x $xs) $ctx) (mbind ($fn $x) (anyMStep $fn $xs) $ctx))
(= (anyMStep $fn $xs $value $ctx) (ifM $value (mreturn True) (anyM $fn $xs) $ctx))

;; const True
(= (constTrue $ignored) True)

;; An accessor for tests, not a combinator -- it is allowed to know the shape
;; for the same reason a pattern match in a test is allowed to.
(= (resValOf (mkRes $value $ctx)) $value)
