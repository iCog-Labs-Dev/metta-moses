;; ============================================================================
;; all.metta -- loads the whole prototype, in the one order that works.
;;
;; ONLY THIS FILE IMPORTS. Loading a file twice would define everything in it
;; twice over, and duplicate definitions do not replace each other here -- they
;; pile up and every answer comes back doubled. So demo.metta and
;; tests/run.metta each import this and nothing else, and no file below imports
;; anything at all.
;;
;; The order is not arbitrary, and a call to a function that has not been
;; imported yet compiles as DATA rather than failing, so getting it wrong is
;; silent. Two dependencies fix it:
;;   types before evaluator    -- evalNode asks isPrimitive to decide whether a
;;                                symbol takes a context or is context-free
;;   evaluator before operators -- every operator body calls evalTerm
;;
;; NO DOMAIN IS LOADED HERE. Everything below is domain-independent, so a demo
;; or a test suite picks its own world by importing this and then one file out
;; of domain/. Loading two domains at once would merge their vocabularies.
;; ============================================================================
!(import! &self prototypes/m1/core/prelude)
!(import! &self prototypes/m1/core/monad)
!(import! &self prototypes/m1/core/types)
!(import! &self prototypes/m1/core/evaluator)
!(import! &self prototypes/m1/core/operators)

!(import! &self prototypes/m1/knobs/knob)
!(import! &self prototypes/m1/knobs/perms)
!(import! &self prototypes/m1/knobs/builder)
!(import! &self prototypes/m1/knobs/decode)

!(import! &self prototypes/m1/search/hillclimb)
