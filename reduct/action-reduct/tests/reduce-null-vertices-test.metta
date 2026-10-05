!(import! &self ../../../utilities/general-helpers)
!(import! &self ../../../utilities/tree)
!(import! &self ../action-vocab)
!(import! &self ../action-helpers)
!(import! &self ../reduce-null-vertices)

;; ============================================================================
;; levelNode: single-node associative flattening
;; ============================================================================

;; Flatten same-operator nesting in and_seq
!(assertEqual (levelNode (and_seq A (and_seq B C) D)) (and_seq A B C D))
;; Flatten same-operator nesting in or_seq
!(assertEqual (levelNode (or_seq A (or_seq B C) D)) (or_seq A B C D))
;; Flatten same-operator nesting in exec_seq
!(assertEqual (levelNode (exec_seq A (exec_seq B C) D)) (exec_seq A B C D))
;; Non-associative operators are not flattened
!(assertEqual
  (levelNode (action_bool_if C (and_seq A (and_seq B C)) D))
  (action_bool_if C (and_seq A (and_seq B C)) D))
;; Multiple operators: only matching nests are flattened at this level
!(assertEqual
  (levelNode (and_seq A (and_seq B C) (or_seq D (or_seq E F)) (exec_seq G (exec_seq H I))))
  (and_seq A B C (or_seq D (or_seq E F)) (exec_seq G (exec_seq H I))))

;; ============================================================================
;; removeNullVertices: remove null vertex arguments from sequences and cond
;; ============================================================================

;; and_seq: remove null vertex children
!(assertEqual (removeNullVertices (and_seq A (mkNullVex $children) B)) (and_seq A B))
!(assertEqual (removeNullVertices (and_seq A (mkNullVex ()) B)) (and_seq A B))
!(assertEqual (removeNullVertices (and_seq A (mkNullVex (C D)) B)) (and_seq A B))
;; cond: remove null vertex condition pairs
!(assertEqual (removeNullVertices (cond (mkNullVex $children) A B C)) (cond B C))
!(assertEqual (removeNullVertices (cond (mkNullVex ()) A B C)) (cond B C))
