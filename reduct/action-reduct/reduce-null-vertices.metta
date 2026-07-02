;; ---------------------------------------------------------------------------
;; General reduction rules: level (flatten associative operators)
;; and remove_null_vertices
;; ---------------------------------------------------------------------------

;; Check if action operator is associative
(= (isAssociative $op)
   (is-member $op (and_seq or_seq exec_seq)))

;; levelNode: flatten one action sequence node.
;; If the current root is an associative action sequence operator, splice
;; children with the same operator into the current argument list:
;;
;;   and_seq(A, and_seq(B, C)) -> and_seq(A, B, C)
;;
;; `flattenAssoc` recursively flattens deeper nested children with that same
;; operator, but `levelNode` itself does not traverse unrelated subexpressions.
;; The full action reducer gets whole-expression behavior by applying this as a
;; downwards pass, mirroring C++ `downwards(level())`.

(= (levelNode $expr)
   (if (and (== (get-metatype $expr) Expression) (!= $expr ()))
       (let ($op $args) (decons $expr)
         (if (isAssociative $op)
             (cons-atom $op (flattenAssoc $op $args))
             $expr))
       $expr))

;; removeNullVertices: remove null_vertex arguments from sequences (or pairs for cond)
(= (removeNullVertices $expr)
   (if (and (== (get-metatype $expr) Expression) (!= $expr ()))
       (let ($op $args) (decons $expr)
         (if (== $op cond)
             (cons-atom cond (removeNullCondPairs $args))
             (cons-atom $op (filter-atom $args $x (not (isNullVertex $x))))))
       $expr))

;; removeNullCondPairs: helper for cond pairs
(= (removeNullCondPairs ()) ())
(= (removeNullCondPairs $args)
   (let* ((($cond $rest1) (decons $args))
          (($conseq $rest2) (decons $rest1)))
     (if (isNullVertex $cond)
         (removeNullCondPairs $rest2)
         (cons-atom $cond (cons-atom $conseq (removeNullCondPairs $rest2))))))
