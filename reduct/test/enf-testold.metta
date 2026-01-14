!(import! &self ../reduct:enf)

; !(assertEqual (reduce-to (AND A B C)) (AND A B C))
; !(assertEqual (reduce-to (AND (OR A B) A)) (AND A))
; !(assertEqual (reduce-to (AND (OR A B) (NOT A))) (AND (NOT A) B))
; !(assertEqual (reduce-to (AND (OR A B) (NOT A) (NOT B))) (AND (NOT A) (NOT B) (OR)))
; !(assertEqual (reduce-to (AND A B (NOT A))) (AND))

; !(assertEqual (reduce-to (OR (AND A B (NOT A) B))) (AND)) ;;
; !(assertEqual (reduce-to (OR A (AND B C))) (AND (OR (AND A) (AND B C))))
; !(assertEqual (reduce-to (OR A B C D)) (AND (OR (AND A) (AND B) (AND C) (AND D))))
; !(assertEqual (reduce-to (AND)) (AND))
; !(assertEqual (reduce-to (AND)) (AND))
; !(assertEqual (reduce-to (OR)) (AND (OR)))

!(reduce-to (NOT (NOT A)))