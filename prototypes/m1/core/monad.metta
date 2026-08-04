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
;; Nothing in this file may carry a (: ...) type declaration -- a declared
;; return type makes partial application fail, which would break exactly the
;; mechanism above.
;; ============================================================================

;; return -- a value, context untouched
(= (mreturn $v $ctx) (mkRes $v $ctx))

;; the "worst" result. Note it hands back the context it was GIVEN, so a
;; failed subprogram cannot corrupt anything: the context is a value being
;; returned, not a location being written.
(= (mzero $ctx) (mkRes False $ctx))

;; fmap -- change the VALUE, leave the context alone.
;; $m is a computation waiting for a context, NOT an already-computed result.
;; Written the other way round it would be a complete application, no partial
;; would be produced, and every operator built on it would silently compile
;; with the wrong number of arguments.
(= (mfmap $f $m $ctx)
   (let (mkRes $v $c) ($m $ctx) (let $r ($f $v) (mkRes $r $c))))

;; bind -- the next step depends on the value AND may change the context
(= (mbind $m $k $ctx) (let (mkRes $v $c) ($m $ctx) (($k $v) $c)))

;; a conditional that ends in a call, so an operator body using it still
;; produces a partial (a bare `if` does not, and that breaks the mechanism)
(= (ifM $c $t $e $ctx) (if $c ($t $ctx) ($e $ctx)))

;; short-circuiting monadic all/any. allM stops at the first False and keeps
;; that context (empty -> True); anyM stops at the first True (empty -> False).
;; Once stopped, the remaining children are never evaluated -- which is what
;; keeps an untaken branch untaken.
(= (allM $f $xs $ctx)
   (foldl-atom $xs (mkRes True $ctx) $acc $x
     (let (mkRes $v $w) $acc (if (== $v False) $acc ($f $x $w)))))

(= (anyM $f $xs $ctx)
   (foldl-atom $xs (mkRes False $ctx) $acc $x
     (let (mkRes $v $w) $acc (if (== $v True) $acc ($f $x $w)))))

(= (constTrue $_) True)
(= (resValOf (mkRes $v $w)) $v)
