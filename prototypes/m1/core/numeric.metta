;; ============================================================================
;; core/numeric.metta -- the bridge from numbers to conditions.
;;
;; NOT IMPORTED BY all.metta, and that is the point of it being its own file.
;; numGt returns Bool, so declaring it in core/ would put it in `opsOfType Bool`
;; for every domain -- including the four with no numbers -- moving every
;; candidate list, knob count and score. Runners that want numbers import it
;; themselves, after all.metta and before their domain.
;;
;; A MeTTa builtin cannot serve directly: every node arrives as (op (children)),
;; one argument, so `>` would be looked up at arity 2 and come back a partial.
;; This is classic's `greater_than_zero`, except that classic hardcodes that one
;; symbol and nothing here is named in core/ or knobs/ -- declare another
;; Bool-returning operator over Number slots and it joins the vocabulary.
;;
;; No guard for a non-numeric child: `>` raises, reduce catches it, and evalNode
;; maps the empty collapse to False -- the path any malformed child takes.
;; ============================================================================
(: numGt (-> (Number Number) $ctx Bool))
(= (numGt ($a $b)) (> (evalTerm $a) (evalTerm $b)))
