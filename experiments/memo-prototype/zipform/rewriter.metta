;; ---------------------------------------------------------------------------
;; zipform/rewriter.metta -- (rewriteTree $exp): wrapped candidate expression
;; ((AND (x (OR (y z)))) shape, common/reference-formulas.metta) -> the
;; materialized zip term ((zipWith and (col x) (zipWith or (col y) (col z)))
;; shape) that zipform/evaluator-common.metta's evalZipTermCore scores
;; columnar-ly.
;;
;; Every constructed node is built via `cons`, never written as a literal
;; (zipWith ...) / (col ...) / (fmap ...) / (zipWithN ...) source form --
;; those heads ARE given clauses elsewhere (the evaluator modules import
;; this file's callers alongside evaluator-common in the same harness), so a
;; literal occurrence of a live head compiles as a goal call under the
;; whole-file-prescan rule verified in probe-zip-quote-unfired.metta. This
;; module's own probe-verified starting point is probe-zip-quote-unfired's
;; `zipRewrite` (arity-2 only); this file generalizes it to arity 0/1/2/>2
;; per zipform/ops.metta's op tables. Recursive results are let-bound before
;; being wrapped.
;;
;; Single-clause + if-guard style throughout for rewriteTree itself -- never
;; overlapping literal-vs-variable clauses for the same head (probe-zip-
;; deep-column-4096's documented infinite-backtracking hazard).
;;
;; NOTE ON IMPORTS: this file deliberately has NO `!(import! ...)` of its own
;; (matching common/kernel-common.metta's existing convention, and the
;; documented "import! does not dedupe" hazard -- verified empirically while
;; building this harness: a module imported via two independent paths from
;; the same entry file gets its clauses asserted twice, so every call
;; through it returns duplicate solutions, which corrupts `test`'s
;; single-value comparison). This file needs common/list-helpers (List.
;; length) and zipform/ops (rowFnOf / isMonoid / mempty) already
;; loaded; the entry harness is the single choke point that imports both,
;; exactly once each, before importing this file.
;; ---------------------------------------------------------------------------

;; foldr1: right-fold an already-rewritten (arity > 2) child-column
;; list into nested binary zipWith terms using row-fn $fn:
;;   foldr1(fn, (c1))          = c1
;;   foldr1(fn, (c1 c2 .. cn)) = (zipWith fn c1 (foldr1 fn (c2..cn)))
;; i.e. c1 fn (c2 fn (c3 fn (... fn cn))) -- right-associated, no seed needed
;; (the last element is the recursion's base case instead of an injected
;; identity element, since the caller only invokes this for arity > 2).
(= (foldr1 $fn $children)
   (if (== (List.length $children) 1)
       (car-atom $children)
       (let $rest (foldr1 $fn (cdr-atom $children))
         (cons zipWith (cons $fn (cons (car-atom $children) (cons $rest ())))))))

;; rewriteTree: the recursive rewriter. Node shape is uniformly
;; ($op ($c1 .. $ck)) (same convention as combineOp in common/kernel-common
;; and scoring/fitness.metta); leaves are bare label symbols; grounded
;; True/False constants pass through unchanged (the evaluator broadcasts
;; them directly, see evaluator-common's Grounded branch).
(= (rewriteTree $exp)
   (if (== (get-metatype $exp) Grounded)
       $exp
       (if (== (get-metatype $exp) Symbol)
           (col $exp)
           (let ($op $children) $exp
             (let $k (List.length $children)
               (if (== $k 0)
                   ;; nullary: only meaningful for a monoid op's identity
                   (if (isMonoid $op)
                       (mempty $op)
                       (Error $exp "rewriteTree: nullary non-foldable op"))
                   (if (== $k 1)
                       (let $c1 (rewriteTree (car-atom $children))
                         (if (isMonoid $op)
                             ;; singleton AND/OR is a semantic identity: (AND
                             ;; (c)) == c, (OR (c)) == c -- return the
                             ;; rewritten child directly, no wrapper at all
                             ;; (never a unary fmap/zipWithN call to a
                             ;; binary row-fn like `and`/`or`, which PeTTa
                             ;; would silently evaluate to a grounded partial
                             ;; application, corrupting every downstream
                             ;; column -- see the smoke-test regression this
                             ;; fixes).
                             $c1
                             (let $rfn (rowFnOf $op)
                               (if (== $rfn $op)
                                   ;; no rowFnTable entry: unmapped unary op,
                                   ;; dispatch var-headed via the args-tuple
                                   ;; convention (same shape as the arity>2
                                   ;; non-foldable zipWithN arm), so a future
                                   ;; unary op defined as `(= (XYZ ($a)) ...)`
                                   ;; needs no table entry at all.
                                   (cons zipWithN (cons $op (cons (cons $c1 ()) ())))
                                   ;; explicit rowFnTable mapping (NOT -> not):
                                   ;; emit the row-fn fmap call as before.
                                   (cons fmap (cons $rfn (cons $c1 ())))))))
                       (if (== $k 2)
                           (let* (($l (rewriteTree (index-atom $children 0)))
                                  ($r (rewriteTree (index-atom $children 1))))
                             (cons zipWith (cons (rowFnOf $op) (cons $l (cons $r ())))))
                           ;; arity > 2
                           (if (isMonoid $op)
                               (let $recChildren (map-atom $children $c (rewriteTree $c))
                                 (foldr1 (rowFnOf $op) $recChildren))
                               (let $recChildren (map-atom $children $c (rewriteTree $c))
                                 (cons zipWithN (cons $op (cons $recChildren ())))))))))))))
