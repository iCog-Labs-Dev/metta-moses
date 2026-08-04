;; ============================================================================
;; all.metta -- loads the whole prototype, in the one order that works.
;;
;; ONLY THIS FILE IMPORTS. Loading a file twice would define everything in it
;; twice over, and duplicate definitions do not replace each other here -- they
;; pile up and every answer comes back doubled. So demo.metta and
;; tests/run.metta each import this and nothing else, and no file below imports
;; anything at all.
;;
;; The order is not arbitrary: the evaluator must be in place before the
;; operators, because each operator body ends in a partially applied call to it
;; and that is resolved as the file is read.
;; ============================================================================
!(import! &self prototypes/m1/core/prelude)
!(import! &self prototypes/m1/core/monad)
!(import! &self prototypes/m1/core/evaluator)
!(import! &self prototypes/m1/core/operators)
!(import! &self prototypes/m1/core/types)

!(import! &self prototypes/m1/knobs/knob)
!(import! &self prototypes/m1/knobs/perms)
!(import! &self prototypes/m1/knobs/builder)
!(import! &self prototypes/m1/knobs/decode)

!(import! &self prototypes/m1/search/hillclimb)
!(import! &self prototypes/m1/domain/tape)
