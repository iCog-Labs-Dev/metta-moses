! (register-module! ../../../../metta-moses) 

! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:reduct:boolean-reduct:redundant)



! (assertEqual (setDifference (a b (NOT a)) (AND a b (NOT a) c (OR a b)) ) (AND c (OR a b)))
! (assertEqual (setDifference (a c (NOT c) (NOT a)) (AND a b (NOT a) c (OR a b)) ) (AND b (OR a b)))
! (assertEqual (setDifference (a) (AND a b (NOT a) c (OR a b)) )  (AND b (NOT a) c (OR a b)))
! (assertEqual (setDifference (b (NOT a) v) (AND a b (NOT a) c (OR a b v) v) ) (AND a c (OR a b v)))
