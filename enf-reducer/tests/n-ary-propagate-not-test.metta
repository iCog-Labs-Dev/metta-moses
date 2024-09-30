! (register-module! ../../../metta-moses-reduction)
! (import! &self metta-moses-reduction:types) 
! (import! &self metta-moses-reduction:utilities:list-helpers)
! (import! &self metta-moses-reduction:utilities:tree-helpers)
! (import! &self metta-moses-reduction:enf-reducer:rte-helpers)
! (import! &self metta-moses-reduction:enf-reducer:propagate-truth-value)
! (import! &self metta-moses-reduction:enf-reducer:reduce-to-elegance)

! (import! &self metta-moses-reduction:enf-reducer:post-processing)
! (import! &self metta-moses-reduction:enf-reducer:reduct)
! (import! &self metta-moses-reduction:enf-reducer:gather-junctors)

! (import! &self metta-moses-reduction:enf-reducer:n-ary-propagate-not)

!(assertEqual
   (propagateNot (AND (OR (AND G F E) D C) B A))
   (AND A B (OR C D (AND E F G)))
)
!(assertEqual 
  (propagateNot (NOT (AND (NOT (OR (AND G F E) D C)) B A)))
  (OR (NOT A) (NOT B) (OR C D (AND E F G)))
)
!(assertEqual 
  (propagateNot (NOT (NOT (OR (AND G F E) D C))))
   (OR C D (AND E F G))
)
!(assertEqual 
  (propagateNot (NOT (AND (OR (AND  E F) D C)  A)))
  (OR (NOT A) (AND (NOT C) (NOT D) (OR (NOT F) (NOT E))))
)

!(assertEqual
    (propagateNot (OR (AND A B) (OR A C)))
    (OR (OR C A) (AND B A))
)
!(assertEqual
    (propagateNot (AND A B))
    (AND B A)
)
!(assertEqual
    (propagateNot (NOT A))
    (NOT A)
)
!(assertEqual
    (propagateNot (OR A (AND B C)))
    (OR (AND C B) A )
)
!(assertEqual
    (propagateNot (NOT (OR A (AND B C))))
    (AND  (OR  (NOT C) (NOT B) ) (NOT A))
)

!(assertEqual
    (propagateNot (NOT (AND A (OR B C))))
    (OR (AND (NOT C) (NOT B)) (NOT A))
)
!(assertEqual
    (propagateNot (AND A (NOT (OR B (AND C D)))))
    (AND (AND (OR (NOT D) (NOT C)) (NOT B)) A)
)

!(assertEqual
    (propagateNot (NOT (AND A (NOT (OR B (AND C D))))))
    (OR (OR (AND D C) B) (NOT A))
)

!(assertEqual
    (propagateNot (AND A (OR B (AND C D))))
    (AND (OR (AND D C) B) A)
)
!(assertEqual
    (propagateNot (NOT (NOT (NOT (NOT (AND A (AND B (AND C D))))))))
    (AND (AND (AND D C) B) A)
)

!(assertEqual
    (propagateNot (NOT (NOT (NOT (NOT (OR A (AND B (OR C D))))))))
    (OR (AND (OR D C) B) A)
)


!(assertEqual
    (propagateNot (NOT (AND (AND I (AND J (NOT (OR K (OR L M))))) (AND B (NOT (AND C (OR D (OR E (NOT (OR F (AND G H)))))))))))
    (OR (OR (AND (OR (OR (AND (OR (NOT H) (NOT G)) (NOT F)) E) D) C) (NOT B)) (OR (OR (OR (OR M L) K) (NOT J)) (NOT I)))
)

!(assertEqual
    (propagateNot (NOT (OR (OR I (OR J (AND K (AND L M)))) (OR B (OR C (AND D (AND E (AND F (AND G H)))))))))
    (AND (AND (AND (OR (OR (OR (OR (NOT H) (NOT G)) (NOT F)) (NOT E)) (NOT D)) (NOT C)) (NOT B)) (AND (AND (OR (OR (NOT M) (NOT L)) (NOT K)) (NOT J)) (NOT I)))
)

!(assertEqual
    (propagateNot (NOT (OR (OR (OR C D) B) A)))
    (AND (NOT A) (AND (NOT B) (AND (NOT D) (NOT C))))
)

!(assertEqual
    (propagateNot (OR (AND (AND C D) B) (NOT A)))
    (OR (NOT A) (AND B (AND D C)))
)
