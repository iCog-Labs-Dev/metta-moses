;; ---------------------------------------------------------------------------
;; Minimal, stock-safe list helpers for the memo-prototype kernels.
;; These are trimmed copies of the shapes used in utilities/list-methods.metta
;; (NOT an import of that module -- the prototype must stay self-contained
;; under experiments/memo-prototype/). Every builtin used below (size-atom,
;; foldl-atom, index-atom, map-atom, car-atom, cons, structural ==) was
;; grepped in both /home/yab/PeTTaV1/src/metta.pl and
;; /home/yab/PeTTa-pr165/src/metta.pl and found byte-for-byte identical
;; (same 'size-atom'/2, 'foldl-atom'/4, 'map-atom'/3, 'car-atom'/2 clauses),
;; so no runtime-specific divergence was needed here.
;; ---------------------------------------------------------------------------

;; List.length: number of elements in a flat expression.
(= (List.length $xs) (size-atom $xs))

;; List.repeat: $a repeated $n times.
(= (List.repeat $n $a)
   (if (== $n 0)
       ()
       (cons $a (List.repeat (- $n 1) $a))))

;; List.foldl: fold a tuple from left to right; $f receives (elem acc).
(= (List.foldl $f $i $xs)
   (foldl-atom $xs $i $acc $x ($f $x $acc)))

;; List.zipWith: structural cons recursion (no map-atom/copy_term hazards --
;; this walks two lists positionally in lockstep).
(= (List.zipWith $f () ()) ())
(= (List.zipWith $f () (cons $y $ys)) ())
(= (List.zipWith $f (cons $x $xs) ()) ())
(= (List.zipWith $f (cons $x $xs) (cons $y $ys))
   (cons ($f $x $y) (List.zipWith $f $xs $ys)))

;; List.index: position of $target in the flat expr $xs; -1 if absent.
(= (List.index () $target) -1)
(= (List.index (cons $x $xs) $target)
   (if (== $x $target)
       0
       (chain (List.index $xs $target) $idx
         (if (< $idx 0) $idx (+ 1 $idx)))))
