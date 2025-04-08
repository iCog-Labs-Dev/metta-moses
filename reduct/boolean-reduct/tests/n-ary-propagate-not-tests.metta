! (register-module! ../../../../metta-moses)
! (import! &self metta-moses:reduct:boolean-reduct:n-ary-propagate-not)

!(assertEqual 
  (propagateNot (AND (NOT (OR A B)) (NOT (AND C D E)) (OR A B) A B))
  (AND (AND (NOT A) (NOT B)) (OR (NOT C) (NOT D) (NOT E)) (OR A B) A B)
)
!(assertEqual
    (propagateNot (AND (OR (AND G F E) D C) B A))
    (AND (OR (AND G F E) D C) B A)
)
!(assertEqual
    (propagateNot (NOT (AND (NOT (OR (AND G F E) D C)) B A)))
    (OR (OR (AND G F E) D C) (NOT B) (NOT A))
  )
!(assertEqual
    (propagateNot (NOT (NOT (OR (AND G F E) D C))))
    (OR (AND G F E) D C)
  )
!(assertEqual
    (propagateNot (NOT (AND (OR (AND  E F) D C)  A)))
    (OR (AND (OR (NOT E) (NOT F)) (NOT D) (NOT C)) (NOT A))
  )

!(assertEqual
      (propagateNot (OR (AND A B) (OR A C)))
      (OR (AND A B) (OR A C))
  )
!(assertEqual
      (propagateNot (AND A B))
      (AND A B)
  )
!(assertEqual
      (propagateNot (NOT A))
      (NOT A)
  )
!(assertEqual
      (propagateNot (OR A (AND B C)))
      (OR A (AND B C))
  )
!(assertEqual
      (propagateNot (NOT (OR A (AND B C))))
      (AND (NOT A) (OR (NOT B) (NOT C) ))
  )

!(assertEqual
      (propagateNot (NOT (AND A (OR B C))))
      (OR (NOT A) (AND (NOT B) (NOT C)))
  )
!(assertEqual
      (propagateNot (AND A (NOT (OR B (AND C D)))))
      (AND A (AND (NOT B) (OR (NOT C) (NOT D))))
  )

!(assertEqual
      (propagateNot (NOT (AND A (NOT (OR B (AND C D))))))
      (OR (NOT A) (OR B (AND C D)))
  )

!(assertEqual
      (propagateNot (AND A (OR B (AND C D))))
      (AND A (OR B (AND C D)))
  )
!(assertEqual
      (propagateNot (NOT (NOT (NOT (NOT (AND A (AND B (AND C D))))))))
      (AND A (AND B (AND C D)))
  )

!(assertEqual
      (propagateNot (NOT (NOT (NOT (NOT (OR A (AND B (OR C D))))))))
      (OR A (AND B (OR C D)))
  )

!(assertEqual
      (propagateNot (NOT (AND (AND I (AND J (NOT (OR K (OR L M))))) (AND B (NOT (AND C (OR D (OR E (NOT (OR F (AND G H)))))))))))
     (OR (OR (NOT I) (OR (NOT J) (OR K (OR L M)))) (OR (NOT B) (AND C (OR D (OR E (AND (NOT F) (OR (NOT G) (NOT H))))))))
  )

!(assertEqual
      (propagateNot (NOT (OR (OR I (OR J (AND K (AND L M)))) (OR B (OR C (AND D (AND E (AND F (AND G H)))))))))
      (AND (AND (NOT I) (AND (NOT J) (OR (NOT K) (OR (NOT L) (NOT M))))) (AND (NOT B) (AND (NOT C) (OR (NOT D) (OR (NOT E) (OR (NOT F) (OR (NOT G) (NOT H))))))))
  )

!(assertEqual
      (propagateNot (NOT (OR (OR (OR C D) B) A)))
      (AND (AND (AND (NOT C) (NOT D)) (NOT B)) (NOT A))
  )

!(assertEqual
      (propagateNot (OR (AND (AND C D) B) (NOT A)))
      (OR (AND (AND C D) B ) (NOT A) )
  )
