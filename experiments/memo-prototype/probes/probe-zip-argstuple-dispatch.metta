;; ---------------------------------------------------------------------------
;; Probe 3 (zipform Phase 1, probe gate). Gates zipWithN (an N-ary zip whose
;; row function receives one tuple of N column-values rather than N separate
;; positional args). Defines XOR3 dispatched on an ARGUMENT-TUPLE pattern
;; `($a $b $c)`, and verifies it fires correctly via var-headed application
;; `($f (a b c))` -- both with a literal tuple and with a tuple assembled at
;; runtime via `cons` (the shape zipWithN would actually hand it: a
;; transposed row built by consing column cells together, not typed in as
;; source syntax).
;; Both runtimes (PeTTaV1 -s, PeTTa-pr165).
;; ---------------------------------------------------------------------------

;; --- odd-count-true 3-input XOR, dispatched on an arg-tuple pattern ------
(= (xorb $a $b) (if (== $a $b) False True))
(= (XOR3 ($a $b $c)) (xorb (xorb $a $b) $c))

;; runtime tuple constructor (mirrors a zipWithN row assembled by cons, not
;; typed literally in source)
(= (mkTuple3 $a $b $c) (cons $a (cons $b (cons $c ()))))

;; =====================  literal-tuple dispatch  =============================
!(println! (LIT_TTT (let $f XOR3 ($f (True True True)))))
!(test (let $f XOR3 ($f (True True True))) True)

!(println! (LIT_TFT (let $f XOR3 ($f (True False True)))))
!(test (let $f XOR3 ($f (True False True))) False)

!(println! (LIT_FFF (let $f XOR3 ($f (False False False)))))
!(test (let $f XOR3 ($f (False False False))) False)

!(println! (LIT_TFF (let $f XOR3 ($f (True False False)))))
!(test (let $f XOR3 ($f (True False False))) True)

;; =====================  runtime-built-tuple dispatch  ========================
;; Same four cases, but the 3-tuple argument is assembled at runtime via
;; `cons` (mkTuple3) instead of written as literal source syntax.
!(println! (RT_TTT (let $f XOR3 ($f (mkTuple3 True True True)))))
!(test (let $f XOR3 ($f (mkTuple3 True True True))) True)

!(println! (RT_TFT (let $f XOR3 ($f (mkTuple3 True False True)))))
!(test (let $f XOR3 ($f (mkTuple3 True False True))) False)

!(println! (RT_FFF (let $f XOR3 ($f (mkTuple3 False False False)))))
!(test (let $f XOR3 ($f (mkTuple3 False False False))) False)

!(println! (RT_TFF (let $f XOR3 ($f (mkTuple3 True False False)))))
!(test (let $f XOR3 ($f (mkTuple3 True False False))) True)
