;; (TreeNode 
;;     (Value Nil False AND) 
;;         Nil 
;;         (Cons 
;;             (TreeNode (Value Nil False OR) Nil 
;;                 (Cons 
;;                     (TreeNode (Value Nil False AND) 
;;                             (Cons (TreeNode (Value Y True LITERAL) Nil Nil) Nil) 
;;                             (Cons (TreeNode (Value Nil False OR) Nil 
;;                                 (Cons 
;;                                     (TreeNode (Value Nil False AND) 
;;                                         (Cons (TreeNode (Value D True LITERAL) Nil Nil) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil)) 
;;                                     Nil) 
;;                                         (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) 
;;                                 Nil))
;;                                 ) Nil)) 
;;                                     (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil) Nil) 
;;                                 Nil))) 
;; Nil))
;; ;;!(let (TreeNode $nodeValue $guardSet $children) (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value Y True LITERAL) Nil Nil) Nil) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil) Nil) Nil))) $children)
;; ;; remainingChildren
;; (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil) Nil) Nil)
;; ;; localCommandSet
;; Nil
;;
;; ;;To Debug phase Two
;;
;; (if False 
;;     ((TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value Y True LITERAL) Nil Nil) Nil) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) DELETE) 
;;     (let 
;;         ($finTree#418 $action#419) (iterator (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value Y True LITERAL) Nil Nil) Nil) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) Nil Nil) 
;;         (if (not (== $action#419 NONE)) ($finTree#418 $action#419) (if (and (== (length (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value Y True LITERAL) Nil Nil) Nil) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) 0) (== (length Nil) 0)) ($finTree#418 DISCONNECT) ($finTree#418 KEEP)))
;;     )
;; )
;; ((TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) Nil))) DISCONNECT)
