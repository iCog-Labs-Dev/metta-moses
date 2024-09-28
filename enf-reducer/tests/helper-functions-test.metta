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

;Test treeIntersection function

; Test 01 - Test intersection with no common elements
!(assertEqual 
   (treeIntersection 
     (Cons (TreeNode (Value A True LITERAL) Nil Nil) (Cons (TreeNode ( Value B True LITERAL) Nil Nil) Nil) ) 
     (Cons (TreeNode ( Value C True LITERAL) Nil Nil) (Cons (TreeNode ( Value D True LITERAL) Nil Nil) Nil))
   ) 
   Nil
 )

; Test 02 - Test intersection with common elements
!(assertEqual 
   (treeIntersection 
     (Cons (TreeNode (Value A True LITERAL) Nil Nil) (Cons (TreeNode ( Value B True LITERAL) Nil Nil) Nil) )
     (Cons (TreeNode ( Value A True LITERAL) Nil Nil) (Cons (TreeNode ( Value D True LITERAL) Nil Nil) Nil))
   ) 
   (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil)
 )

; Test 03 - Test intersection with empty lists
! (assertEqual (treeIntersection Nil Nil) Nil)

; Test 04 -  Test intersection with one empty list
! (assertEqual 
    (treeIntersection 
      (Cons (TreeNode ( Value A True LITERAL) Nil Nil) (Cons (TreeNode ( Value B True LITERAL) Nil Nil) Nil))
      Nil
    )
    Nil
  )

; Test for detectConsistency

; Test 01
;  Create two TreeNode objects with the same value and same constraint
!(assertEqual 
   (detectConsistency 
     (TreeNode ( Value A True LITERAL) Nil Nil) 
     (Cons (TreeNode ( Value A True LITERAL) Nil Nil) Nil)
   )
   True
 )

; Test 02
;  Create two TreeNode objects with the same value but different constraints
!(assertEqual 
   (detectConsistency 
      (TreeNode ( Value A True LITERAL) Nil Nil) 
      (Cons (TreeNode ( Value A False LITERAL) Nil Nil) Nil)
   )
   False
 )

; Test 03
; Create a TreeNode object and empty list
!(assertEqual 
   (detectConsistency 
      (TreeNode ( Value A True LITERAL) Nil Nil) 
      Nil
   )
   True
 )

; Test for isConsistent

; Test 01
; Create a list of TreeNode objects, all consistent with each other
!(assertEqual 
   (isConsistent 
     (Cons (TreeNode ( Value A True LITERAL) Nil Nil) (Cons (TreeNode ( Value B True LITERAL) Nil Nil) (Cons (TreeNode ( Value C True LITERAL) Nil Nil) (Cons (TreeNode ( Value D True LITERAL) Nil Nil) Nil))))
   ) 
   True
 )

; Test 02
; Create a list of TreeNode objects, with an inconsistency
!(assertEqual 
   (isConsistent 
     (Cons (TreeNode ( Value A True LITERAL) Nil Nil) (Cons (TreeNode ( Value B True LITERAL) Nil Nil) (Cons (TreeNode ( Value A False LITERAL) Nil Nil) (Cons (TreeNode ( Value D True LITERAL) Nil Nil) Nil))))
   )
 False
 )

; Test 03
; Call the function with an empty list and check if it returns True
! (assertEqual (isConsistent Nil) True)

; Test 04
; Create a single TreeNode object
! (assertEqual (isConsistent (Cons (TreeNode ( Value A True LITERAL) Nil Nil) Nil)) True)

; Test for getGuardSetExp

;Test 01 - getGuardSet of an empty set
! (assertEqualToResult (getGuardSetExp () ()) (()))

;Test 02 - getGuardSet of OR and NOT expressions 
! (assertEqualToResult (getGuardSetExp (OR A B (not A)) ()) (()))
! (assertEqualToResult (getGuardSetExp (OR (AND A B) (AND A B) (not A)) ()) (()))
! (assertEqualToResult (getGuardSetExp (NOT (OR A B) (AND A B) A B) ()) (()))

;Test 03 - getGuardSet of AND expressions
! (assertEqualToResult (getGuardSetExp (AND (not A) (not B) A) ()) ((A (not B) (not A))))
! (assertEqualToResult (getGuardSetExp (AND A (AND A B) (OR A B) (not B)) ()) (((not B) A)))
! (assertEqualToResult (getGuardSetExp (AND (AND A B) A) ()) ((A)))
! (assertEqualToResult (getGuardSetExp (AND A B (not B)) ()) (((not B) B A)))
! (assertEqualToResult (getGuardSetExp (AND A (not A) (not B)) ()) (((not B) (not A) A)))
! (assertEqualToResult (getGuardSetExp (AND (not A) A B) ()) ((B A (not A))))