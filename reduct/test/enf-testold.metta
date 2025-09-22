!(register-module! ../../../metta-moses)
!(import! &self metta-moses:reduct:enf)

!(assertEqual (reduce (AND A B C)) (AND A B C))
!(assertEqual (reduce (AND (OR A B) A)) (AND A))
!(assertEqual (reduce (AND (OR A B) (NOT A))) (AND (NOT A) B))
!(assertEqual (reduce (AND (OR A B) (NOT A) (NOT B))) (AND (NOT A) (NOT B) (OR)))
!(assertEqual (reduce (AND A B (NOT A))) (AND))

!(assertEqual (reduce (OR (AND A B (NOT A) B))) (AND)) ;;
!(assertEqual (reduce (OR A (AND B C))) (AND (OR (AND A) (AND B C))))
!(assertEqual (reduce (OR A B C D)) (AND (OR (AND A) (AND B) (AND C) (AND D))))
!(assertEqual (reduce (AND)) (AND))
!(assertEqual (reduce (AND)) (AND))
!(assertEqual (reduce (OR)) (AND (OR)))


