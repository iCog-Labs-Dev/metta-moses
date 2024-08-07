!(import! &self propagate_truth_value)

;;!(propagateTruthValue (buildTree (OR a (AND b c))) True)
;;!(isTreeWellFormed (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value a False LITERAL) Nil Nil) (Cons (TreeNode (Value b False LITERAL) Nil Nil) Nil))))
 
;; !(changeTree (buildTree (OR a (AND b c))) (buildTree (AND a (AND b c))))
;; !(replaceChild (buildTree (OR a (AND b c))) (buildTree (AND a (AND b c))) L)
;; !(getNodeType (buildTree (OR a (AND b c))))
;;!(propagateTruthValue (buildTree (OR a (AND b c))) True)
