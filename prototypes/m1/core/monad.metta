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

;; Control.Monad.Extra.ifM :: m Bool -> m a -> m a -> m a
;;
;;     ifM b t f = b >>= \b' -> if b' then t else f
;;
;; The TEST is a computation, not a plain Bool, which is what keeps this
;; generic: the only thing it does with a computation is hand it to mbind. An
;; earlier version applied the branches to a context itself, which tied it to
;; this particular shape of monad for no gain.
;;
;; The lambda needs only the value. Its body SELECTS one of two computations
;; and hands it back rather than completing a call, so nothing eta-expands and
;; the second parameter the other lambdas in this file need is unnecessary
;; here. mbind applies whichever branch was chosen to the threaded context --
;; and never touches the other one, which is where the laziness in and_seq and
;; AND comes from.
(= (ifM $test $then $else $ctx) (mbind $test (|-> ($v) (if $v $then $else)) $ctx))

;; `|->` IS A LAMBDA, and it is what keeps this file free of one-off helpers.
;; The runtime compiles (|-> (args) body) into a fresh anonymous clause, works
;; out which variables in the body came from outside, and hands back a closure
;; over them. So `mbind`'s continuation can be written where it is used instead
;; of being lifted out, named, and given its captured variables as leading
;; parameters by hand.
;;
;; TWO PARAMETERS, ALWAYS: the value AND the context. Written with just the
;; value the body would end in a partial, the generated clause would
;; eta-expand, and its arity is registered BEFORE that happens -- so the
;; specializer emits a call to an arity that does not exist:
;;     'mbind_Spec_[...]'/4: Unknown procedure: lambda_2/3
;;                           However, there are definitions for: lambda_2/4
;; This is the same rule every clause here follows -- keep $ctx explicit so the
;; body is a COMPLETE call -- and it has now bitten four times. The arity smoke
;; tests at the top of tests/t-operators.metta are what catch it; nothing else
;; does, because the failure is silent everywhere else.

;; liftM, i.e. fmap for a monad:  fmap f m = m >>= \v -> return (f v)
(= (mfmap $fn $computation $ctx)
   (mbind $computation (|-> ($v $c) (mreturn ($fn $v) $c)) $ctx))

;; Control.Monad.Extra.allM / anyM, as Haskell writes them -- and with a
;; monadic ifM they need no lambda of their own at all:
;;
;;     allM p []     = return True
;;     allM p (x:xs) = ifM (p x) (allM p xs) (return False)
;;
;; The recursive call and the `return False` are both built but unapplied, so
;; only the branch that is chosen ever runs and the walk genuinely stops.
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
(= (allM $fn (cons $x $xs) $ctx) (ifM ($fn $x) (allM $fn $xs) (mreturn False) $ctx))

(= (anyM $fn () $ctx) (mreturn False $ctx))
(= (anyM $fn (cons $x $xs) $ctx) (ifM ($fn $x) (mreturn True) (anyM $fn $xs) $ctx))

;; const True
(= (constTrue $ignored) True)

;; An accessor for tests, not a combinator -- it is allowed to know the shape
;; for the same reason a pattern match in a test is allowed to.
(= (resValOf (mkRes $value $ctx)) $value)
