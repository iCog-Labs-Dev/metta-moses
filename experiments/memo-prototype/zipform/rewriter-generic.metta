;; ---------------------------------------------------------------------------
;; zipform/rewriter-generic.metta -- variant G rewriter. Identical in shape to
;; zipform/rewriter.metta, but rowFnTable-FREE: the destructured op symbol is
;; passed STRAIGHT THROUGH into the emitted (zipWith $op ...) / (fmap $op ...)
;; / (foldr1 $op ...) nodes, because zipform/ops-generic.metta defines
;; AND/OR/NOT at their row arity, so `$op` IS the row function. Every place
;; the plain rewriter called `(rowFnOf $op)` this one just uses `$op`.
;;
;; Deliberately keeps the SAME function name `rewriteTree` as
;; zipform/rewriter.metta so the shared zipform/rewrite-cache-memo.metta
;; (`(= (rewriteTreeCached $exp) (rewriteTree $exp))`) and the shared
;; zipform/evaluator-common.metta work UNCHANGED -- an entry file imports
;; EITHER rewriter.metta OR this file, never both (they would collide).
;;
;; The candidate `$exp` MUST arrive as clean data (via `quote` in the entry
;; file's candidate source), because ops-generic.metta gives AND/OR/NOT
;; clauses -- see that file's header. The destructure `(let ($op $children)
;; ...)` below is a VARIABLE head (never a literal `(AND $cs)` head), so it
;; matches the clean quoted candidate structurally without ever compiling to
;; a `partial(...)` pattern (probe-quote-and-destructure / probe-generic).
;;
;; NOTE ON IMPORTS: no `!(import! ...)` of its own (same choke-point
;; convention as rewriter.metta / kernel-common.metta). Needs
;; common/list-helpers (List.length) and zipform/ops-generic (isMonoid /
;; mempty) already loaded by the entry file, exactly once each.
;; ---------------------------------------------------------------------------

;; foldr1: right-fold an already-rewritten (arity > 2) child-column list into
;; nested binary zipWith terms using row-fn $fn (here $fn is the op symbol
;; itself, e.g. AND). Same shape as rewriter.metta's foldr1.
(= (foldr1 $fn $children)
   (if (== (List.length $children) 1)
       (car-atom $children)
       (let $rest (foldr1 $fn (cdr-atom $children))
         (cons zipWith (cons $fn (cons (car-atom $children) (cons $rest ())))))))

;; rewriteTree: wrapped candidate ($op ($c1 .. $ck)) -> materialized zip term.
;; Grounded True/False pass through; a bare label -> (col label); nodes
;; dispatch on child count via a single if-chain (never overlapping literal/
;; variable clauses for one head). Every emitted node is built via `cons`.
(= (rewriteTree $exp)
   (if (== (get-metatype $exp) Grounded)
       $exp
       (if (== (get-metatype $exp) Symbol)
           (col $exp)
           (let ($op $children) $exp
             (case (List.length $children)
               ;; 0 -- nullary: only meaningful as a monoid op's identity
               ((0 (if (isMonoid $op)
                       (mempty $op)
                       (Error $exp "rewriteTree: nullary non-foldable op")))
                ;; 1 -- singleton monoid (AND (c)) == c is an identity (return
                ;; the child, no wrapper); otherwise a unary op (NOT) fmapped
                ;; over the child column ($op is the row fn -- no rowFnTable).
                (1 (let $c1 (rewriteTree (car-atom $children))
                     (if (isMonoid $op)
                         $c1
                         (cons fmap (cons $op (cons $c1 ()))))))
                ;; 2 -- plain binary zipWith over the two rewritten children.
                (2 (let* (($l (rewriteTree (index-atom $children 0)))
                          ($r (rewriteTree (index-atom $children 1))))
                     (cons zipWith (cons $op (cons $l (cons $r ()))))))
                ;; >2 -- monoid ops right-fold into nested binary zipWith
                ;; (foldr1); genuine n-ary ops take the per-row zipWithN path.
                ($_ (let $recChildren (map-atom $children $c (rewriteTree $c))
                      (if (isMonoid $op)
                          (foldr1 $op $recChildren)
                          (cons zipWithN (cons $op (cons $recChildren ()))))))))))))
