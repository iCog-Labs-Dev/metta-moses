;; TreeNodes to be reused. There are literal nodes only defined from a - f both with positive and negative constraint.
;; i.e.,:
      ;; a' means a tree node that has 'NodeType' of 'LITERAL', Value of 'A' and Constraint of 'False'.
      ;; a means a tree node that has 'NodeType' of 'LITERAL', Value of 'A' and Constraint of 'True'.

(: a Tree)
(= (a) (TreeNode (Value A True LITERAL) Nil Nil))
(: b Tree)
(= (b) (TreeNode (Value B True LITERAL) Nil Nil))
(: c Tree)
(= (c) (TreeNode (Value C True LITERAL) Nil Nil))
(: d Tree)
(= (d) (TreeNode (Value D True LITERAL) Nil Nil))
(: e Tree)
(= (e) (TreeNode (Value E True LITERAL) Nil Nil))
(: f Tree)
(= (f) (TreeNode (Value F True LITERAL) Nil Nil))
(: g Tree)
(= (g) (TreeNode (Value G True LITERAL) Nil Nil))

(: a' Tree)
(= (a') (TreeNode (Value A False LITERAL) Nil Nil))
(: b' Tree)
(= (b') (TreeNode (Value B False LITERAL) Nil Nil))
(: c' Tree)
(= (c') (TreeNode (Value C False LITERAL) Nil Nil))
(: d' Tree)
(= (d') (TreeNode (Value D False LITERAL) Nil Nil))
(: e' Tree)
(= (e') (TreeNode (Value E False LITERAL) Nil Nil))
(: f' Tree)
(= (f') (TreeNode (Value F False LITERAL) Nil Nil))
(: g' Tree)
(= (g') (TreeNode (Value G False LITERAL) Nil Nil))

;; NodeValues that are reused. These are AND and OR node value to be reused
(: And NodeValue)
(= (And) (Value Nil False AND))
(: Or NodeValue)
(= (Or) (Value Nil False OR))
