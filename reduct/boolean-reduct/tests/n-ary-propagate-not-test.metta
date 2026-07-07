!(import! &self ../../../utilities/general-helpers)
!(import! &self ../n-ary-propagate-not)
!(import! &self ../../../scoring/boolean-ops) ;; mirrors moses.metta: AND/OR/NOT become callable AFTER the reduct compiles

!(assertEqual 
  (propagateNot (quote (AND (NOT (OR $A $B)) (NOT (AND $C $D $E)) (OR $A $B) $A $B)))
  (quote (AND (AND (NOT $A) (NOT $B)) (OR (NOT $C) (NOT $D) (NOT $E)) (OR $A $B) $A $B))
)
!(assertEqual
    (propagateNot (quote (AND (OR (AND $G $F $E) $D $C) $B $A)))
    (quote (AND (OR (AND $G $F $E) $D $C) $B $A))
)
!(assertEqual
    (propagateNot (quote (NOT (AND (NOT (OR (AND $G $F $E) $D $C)) $B $A))))
    (quote (OR (OR (AND $G $F $E) $D $C) (NOT $B) (NOT $A)))
  )
!(assertEqual
    (propagateNot (quote (NOT (NOT (OR (AND $G $F $E) $D $C)))))
    (quote (OR (AND $G $F $E) $D $C))
  )
!(assertEqual
    (propagateNot (quote (NOT (AND (OR (AND  $E $F) $D $C)  $A))))
    (quote (OR (AND (OR (NOT $E) (NOT $F)) (NOT $D) (NOT $C)) (NOT $A)))
  )

!(assertEqual
      (propagateNot (quote (OR (AND $A $B) (OR $A $C))))
      (quote (OR (AND $A $B) (OR $A $C)))
  )
!(assertEqual
      (propagateNot (quote (AND $A $B)))
      (quote (AND $A $B))
  )
!(assertEqual
      (propagateNot (quote (NOT $A)))
      (quote (NOT $A))
  )
!(assertEqual
      (propagateNot (quote (OR $A (AND $B $C))))
      (quote (OR $A (AND $B $C)))
  )
!(assertEqual
      (propagateNot (quote (NOT (OR $A (AND $B $C)))))
      (quote (AND (NOT $A) (OR (NOT $B) (NOT $C) )))
  )

!(assertEqual
      (propagateNot (quote (NOT (AND $A (OR $B $C)))))
      (quote (OR (NOT $A) (AND (NOT $B) (NOT $C))))
  )
!(assertEqual
      (propagateNot (quote (AND $A (NOT (OR $B (AND $C $D))))))
      (quote (AND $A (AND (NOT $B) (OR (NOT $C) (NOT $D)))))
  )

!(assertEqual
      (propagateNot (quote (NOT (AND $A (NOT (OR $B (AND $C $D)))))))
      (quote (OR (NOT $A) (OR $B (AND $C $D))))
  )

!(assertEqual
      (propagateNot (quote (AND $A (OR $B (AND $C $D)))))
      (quote (AND $A (OR $B (AND $C $D))))
  )
!(assertEqual
      (propagateNot (quote (NOT (NOT (NOT (NOT (AND $A (AND $B (AND $C $D)))))))))
      (quote (AND $A (AND $B (AND $C $D))))
  )

!(assertEqual
      (propagateNot (quote (NOT (NOT (NOT (NOT (OR $A (AND $B (OR $C $D)))))))))
      (quote (OR $A (AND $B (OR $C $D))))
  )

!(assertEqual
      (propagateNot (quote (NOT (AND (AND $I (AND $J (NOT (OR $K (OR $L $M))))) (AND $B (NOT (AND $C (OR $D (OR $E (NOT (OR $F (AND $G $H))))))))))))
     (quote (OR (OR (NOT $I) (OR (NOT $J) (OR $K (OR $L $M)))) (OR (NOT $B) (AND $C (OR $D (OR $E (AND (NOT $F) (OR (NOT $G) (NOT $H)))))))))
  )

!(assertEqual
      (propagateNot (quote (NOT (OR (OR $I (OR $J (AND $K (AND $L $M)))) (OR $B (OR $C (AND $D (AND $E (AND $F (AND $G $H))))))))))
      (quote (AND (AND (NOT $I) (AND (NOT $J) (OR (NOT $K) (OR (NOT $L) (NOT $M))))) (AND (NOT $B) (AND (NOT $C) (OR (NOT $D) (OR (NOT $E) (OR (NOT $F) (OR (NOT $G) (NOT $H)))))))))
  )

!(assertEqual
      (propagateNot (quote (NOT (OR (OR (OR $C $D) $B) $A))))
      (quote (AND (AND (AND (NOT $C) (NOT $D)) (NOT $B)) (NOT $A)))
  )

!(assertEqual
      (propagateNot (quote (OR (AND (AND $C $D) $B) (NOT $A))))
      (quote (OR (AND (AND $C $D) $B ) (NOT $A) ))
  )

!(assertEqual (propagateNot (quote (AND))) (quote (AND))) ;; check for empty AND

!(assertEqual (propagateNot (quote (AND (OR (AND (OR)) (AND (OR (AND (NOT $X1)))))))) (quote (AND (OR (AND (OR)) (AND (OR (AND (NOT $X1))))))))
