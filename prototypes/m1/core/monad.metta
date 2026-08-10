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
(= (mreturn $value $ctx) (mkRes $value $ctx))

;; the "worst" result. Note it hands back the context it was GIVEN, so a
;; failed subprogram cannot corrupt anything: the context is a value being
;; returned, not a location being written.
(= (mzero $ctx) (mkRes False $ctx))

;; fmap -- change the VALUE, leave the context alone.
;; $computation is waiting for a context, NOT an already-computed result.
;; Written the other way round it would be a complete application, no partial
;; would be produced, and every operator built on it would silently compile
;; with the wrong number of arguments.
(= (mfmap $fn $computation $ctx)
   (let (mkRes $value $after) ($computation $ctx)
     (let $changed ($fn $value) (mkRes $changed $after))))

;; bind -- the next step depends on the value AND may change the context
(= (mbind $computation $next $ctx)
   (let (mkRes $value $after) ($computation $ctx) (($next $value) $after)))

;; a conditional that ends in a call, so an operator body using it still
;; produces a partial (a bare `if` does not, and that breaks the mechanism)
(= (ifM $test $then $else $ctx) (if $test ($then $ctx) ($else $ctx)))

;; short-circuiting monadic all/any. allM stops at the first False and keeps
;; that context (empty -> True); anyM stops at the first True (empty -> False).
;; Once stopped, the remaining children are never evaluated -- which is what
;; keeps an untaken branch untaken.
(= (allM $fn $items $ctx)
   (foldl-atom $items (mkRes True $ctx) $acc $item
     (let (mkRes $value $sofar) $acc
       (if (== $value False) $acc ($fn $item $sofar)))))

(= (anyM $fn $items $ctx)
   (foldl-atom $items (mkRes False $ctx) $acc $item
     (let (mkRes $value $sofar) $acc
       (if (== $value True) $acc ($fn $item $sofar)))))

(= (constTrue $ignored) True)
(= (resValOf (mkRes $value $ctx)) $value)
