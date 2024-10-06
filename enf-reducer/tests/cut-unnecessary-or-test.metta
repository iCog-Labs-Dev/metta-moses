! (register-module! ../../../metta-moses-reduction)
! (import! &self metta-moses-reduction:enf-reducer:cut-unnecessary-or)

 ;; Test 1: OR with multiple top-level children, sub-expressions not handled (no transformation)
! (assertEqual (orCut (OR a (OR b) (OR c (OR f)))) (OR a (OR b) (OR c (OR f))))

 ;; Test 2: OR with one top-level child (orCut applies)
! (assertEqual (orCut (OR a)) a)

 ;; Test 3: Nested OR inside, should not transform sub-expressions (no transformation)
! (assertEqual (orCut (OR c (OR b (OR k)))) (OR c (OR b (OR k))))

 ;; Test 4: AND node with no OR node, (no transformation)
! (assertEqual (orCut (AND a)) (AND a))

 ;; Test 5: OR with multiple top-level children, sub-expressions not handled (no transformation)
! (assertEqual (orCut (OR a (OR b) (OR c (OR f)))) (OR a (OR b) (OR c (OR f))))

 ;; Test 6: Nested OR inside, should not transform sub-expressions (no transformation)
! (assertEqual (orCut (OR c (OR b (OR k)))) (OR c (OR b (OR k))))

 ;; Test 7: OR with deeply nested sub-expressions, only top-level handled (no transformation)
! (assertEqual (orCut (OR (OR a b) (AND c d) (OR e))) (OR (OR a b) (AND c d) (OR e)))

 ;; Test 8: Single OR with deeply nested AND and OR nodes, but only top-level is handled (no transformation)
! (assertEqual (orCut (OR (AND a b) (OR c d) e)) (OR (AND a b) (OR c d) e))

 ;; Test 9: OR with mixed AND and OR nodes (no transformation, sub-expressions not handled)
! (assertEqual (orCut (OR a (AND b c) (OR d e))) (OR a (AND b c) (OR d e)))

 ;; Test 10: Single literal without OR (no transformation)
! (assertEqual (orCut a) a)

 ;; Test 11: Empty input expression (should return empty)
! (assertEqual (orCut ()) ())

 ;; Test 12: OR with two top-level literals, no transformation
! (assertEqual (orCut (OR a b)) (OR a b))

 ;; Test 13: OR with mixed nested structures, but top-level unchanged
! (assertEqual (orCut (OR (OR a (AND b c)) d (OR e f))) (OR (OR a (AND b c)) d (OR e f)))

 ;; Test 14: OR with multiple AND and OR nodes, top-level transformation
! (assertEqual (orCut (OR ( (AND a b) (OR c d) e))) ( (AND a b) (OR c d) e))
