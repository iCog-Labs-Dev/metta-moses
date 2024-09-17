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
;;!(let (TreeNode $nodeValue $guardSet $children) (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value Y True LITERAL) Nil Nil) Nil) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil) Nil) Nil))) $children)
;; remainingChildren
;; (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil) Nil) Nil)
;; localCommandSet
;; Nil

;;To Debug phase Two

; (if False 
;     ((TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value Y True LITERAL) Nil Nil) Nil) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) DELETE) 
;     (let 
;         ($finTree#418 $action#419) (iterator (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value Y True LITERAL) Nil Nil) Nil) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) Nil Nil) 
;         (if (not (== $action#419 NONE)) ($finTree#418 $action#419) (if (and (== (length (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value Y True LITERAL) Nil Nil) Nil) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) 0) (== (length Nil) 0)) ($finTree#418 DISCONNECT) ($finTree#418 KEEP)))
;
;     )
; )
; ((TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) Nil))) DISCONNECT)
; ;;; Inside Iterator problem
; ;; (let* (
; ;;     (($signal#209 $fstupdatedcurrent#210) 
; ;;         (andSubTreeIterator 
; ;;             (getChildren (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) Nil)))) 
; ;;                 (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) Nil))) Nil Nil))) 
; ;;                 (let () (println! 
; ;;                     (Inside Iterator after andSubTreeIterator call)) 
; ;;                     (if (not (isConsistent Nil)) 
; ;;                     ((TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) Nil))) DELETE) 
; ;;                     (let () (println! (handle_set is Nil current is 
; ;;                                 (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) Nil)))) 
; ;;                                 (if (not (== $signal#209 NONE)) 
; ;;                                     ($signal#209 $fstupdatedcurrent#210) 
; ;;                                     (let* (($sndupdatedcurrent#211 (applyOrCutToChildren $fstupdatedcurrent#210 (getChildren $fstupdatedcurrent#210))) ($setsAreIdentical#212 (compareSets Nil (getGuardSet $sndupdatedcurrent#211)))) (let () (println! (secondUpdatedCurrent is $sndupdatedcurrent#211 setsAreIdentical is $setsAreIdentical#212)) (if (not $setsAreIdentical#212) (iterator $sndupdatedcurrent#211 Nil Nil) ($sndupdatedcurrent#211 NONE))))))))))
;
; (if False 
;     ((TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil) DELETE) 
;     (let () 
;         (println! (handle_set is (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) current is (TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil)) 
;             (if (not (== NONE NONE)) 
;                 (NONE (TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil)) 
;                 (let* (
;                         ($sndupdatedcurrent#3904 (applyOrCutToChildren (TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil) (getChildren (TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil)))) 
;                         ($setsAreIdentical#3905 (compareSets (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) (getGuardSet $sndupdatedcurrent#3904)))
;                     ) 
;                     (let () (println! 
;                                 (secondUpdatedCurrent is $sndupdatedcurrent#3904 setsAreIdentical is $setsAreIdentical#3905)
;                             ) (if (not $setsAreIdentical#3905) 
;                                     (iterator $sndupdatedcurrent#3904 Nil Nil) 
;                                     ($sndupdatedcurrent#3904 NONE)
;                                 )
;                     )
;         (println! (handle_set is (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) current is (TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil)) (if (not (== NONE NONE)) (NONE (TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil)) (let* (($sndupdatedcurrent#3904 (applyOrCutToChildren (TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil) (getChildren (TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil)))) ($setsAreIdentical#3905 (compareSets (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) (getGuardSet $sndupdatedcurrent#3904)))) (let () (println! (secondUpdatedCurrent is $sndupdatedcurrent#3904 setsAreIdentical is $setsAreIdentical#3905)) (if (not $setsAreIdentical#3905) (iterator $sndupdatedcurrent#3904 Nil Nil) ($sndupdatedcurrent#3904 NONE)))))
;         )))
;                 )
;             )
;         )
;     )
; ), 
; (if False 
;     ((TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil) DELETE) 
;     (let () (println! 
;                 (handle_set is (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) current is (TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil)) 
;                 (if (not (== NONE NONE)) 
;                 (NONE (TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil)) 
;                 (let* (
;                     ($sndupdatedcurrent#3904 (applyOrCutToChildren (TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil) (getChildren (TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil)))) 
;                     ($setsAreIdentical#3905 (compareSets (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) (getGuardSet $sndupdatedcurrent#3904)))
;                     ) 
;                 (let () (println! (secondUpdatedCurrent is $sndupdatedcurrent#3904 setsAreIdentical is $setsAreIdentical#3905)) 
;                     (if (not $setsAreIdentical#3905) 
;                         (iterator $sndupdatedcurrent#3904 Nil Nil) 
;                         ($sndupdatedcurrent#3904 NONE)
;                     )
;                 )
;             )
;         )
;     )
; )
; ), 
; (if False 
; ((TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil) DELETE) 
; (let () 
;     (println! (handle_set is (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) current is (TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil)) 
;         (if (not (== NONE NONE)) 
;         (NONE (TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil)) 
;         (let* (
;                 ($sndupdatedcurrent#3904 (applyOrCutToChildren (TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil) (getChildren (TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil)))) 
;                 ($setsAreIdentical#3905 (compareSets (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) (getGuardSet $sndupdatedcurrent#3904)))
;             ) (let () (println! (secondUpdatedCurrent is $sndupdatedcurrent#3904 setsAreIdentical is $setsAreIdentical#3905)) 
;                         (if (not $setsAreIdentical#3905) 
;                             (iterator $sndupdatedcurrent#3904 Nil Nil) 
;                             ($sndupdatedcurrent#3904 NONE)
;                         )
;                 )
;         )
;     )
;     )
; )
; ), 
; (if False 
;     ((TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil) DELETE) 
;     (let () 
;         (println! 
;             (handle_set is (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) current is (TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil)) 
;             (if (not (== NONE NONE)) 
;                 (NONE (TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil)) 
;                 (let* (
;                     ($sndupdatedcurrent#3904 (applyOrCutToChildren (TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil) (getChildren (TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil)))) 
;                     ($setsAreIdentical#3905 (compareSets (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) (getGuardSet $sndupdatedcurrent#3904)))
;                     ) (let () (println! 
;                                 (secondUpdatedCurrent is $sndupdatedcurrent#3904 setsAreIdentical is $setsAreIdentical#3905)
;                             ) (if (not $setsAreIdentical#3905) 
;                                     (iterator $sndupdatedcurrent#3904 Nil Nil) 
;                                     ($sndupdatedcurrent#3904 NONE)
;                             )
;                     )
;                 )
;             )
;         )
;     )
; )
; ;; (TreeNode 
; ;;     (Value Nil False AND) 
; ;;         Nil 
; ;;         (Cons 
; ;;             (TreeNode (Value Nil False OR) Nil 
; ;;                 (Cons 
; ;;                     (TreeNode (Value Nil False AND) 
; ;;                             (Cons (TreeNode (Value Y True LITERAL) Nil Nil) Nil) 
; ;;                             (Cons (TreeNode (Value Nil False OR) Nil 
; ;;                                 (Cons 
; ;;                                     (TreeNode (Value Nil False AND) 
; ;;                                         (Cons (TreeNode (Value D True LITERAL) Nil Nil) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil)) 
; ;;                                     Nil) 
; ;;                                         (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) 
; ;;                                 Nil))
; ;;                                 ) Nil)) 
; ;;                                     (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil) Nil) 
; ;;                                 Nil))) 
; ;; Nil))
; ;; ;;!(let (TreeNode $nodeValue $guardSet $children) (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value Y True LITERAL) Nil Nil) Nil) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil) Nil) Nil))) $children)
; ;; ;; remainingChildren
; ;; (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil) Nil) Nil)
; ;; ;; localCommandSet
; ;; Nil
; ;;
; ;; ;;To Debug phase Two
; ;;
; ;; (if False 
; ;;     ((TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value Y True LITERAL) Nil Nil) Nil) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) DELETE) 
; ;;     (let 
; ;;         ($finTree#418 $action#419) (iterator (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value Y True LITERAL) Nil Nil) Nil) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) Nil Nil) 
; ;;         (if (not (== $action#419 NONE)) ($finTree#418 $action#419) (if (and (== (length (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value Y True LITERAL) Nil Nil) Nil) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) 0) (== (length Nil) 0)) ($finTree#418 DISCONNECT) ($finTree#418 KEEP)))
; ;;     )
; ;; )
; ;; ((TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) Nil))) DISCONNECT)
