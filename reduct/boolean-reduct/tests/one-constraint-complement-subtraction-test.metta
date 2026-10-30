!(import! &self ../../../utilities/general-helpers)
!(import! &self ../rte-helpers)

;; reduceToElegance does the 1-CC subtraction inline; rte1..7 test it.
;; The asserts below test === from utilities/general-helpers.metta.

;; Test for helper function ===
!(assertEqual (=== A B) False)
!(assertEqual (=== A A) True)
!(assertEqual (=== () (A)) False)
!(assertEqual (=== (A) () ) False)
!(assertEqual (=== (A B) (A)) False)
!(assertEqual (=== (A B) (A B)) True)
!(assertEqual (=== (B A) (A B)) True)
!(assertEqual (=== (B C D E A) (B C D E A)) True)
!(assertEqual (=== (B C D E A) (C D A E B)) True)
!(assertEqual (=== (B F D E A) (B C D E A)) False)
