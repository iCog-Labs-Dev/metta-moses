! (register-module! ../../../metta-moses)
! (import! &self metta-moses:scoring:ttable-edit)

;; sample truth table 
! (bind! ttable (mkITable  (Cons (Cons True (Cons True (Cons False (Cons True (Cons True Nil)))))
            (Cons (Cons True (Cons False (Cons False (Cons True (Cons True Nil)))))
            (Cons (Cons False (Cons True (Cons False (Cons True (Cons False Nil)))))
            (Cons (Cons False (Cons False (Cons False (Cons True (Cons False Nil))))) Nil))))
            (Cons A (Cons B (Cons C (Cons D (Cons Output Nil)))))))

! (bind! dataRows 
            (Cons (Cons True (Cons True (Cons False (Cons True (Cons True Nil)))))
            (Cons (Cons True (Cons False (Cons False (Cons True (Cons True Nil)))))
            (Cons (Cons False (Cons True (Cons False (Cons True (Cons False Nil)))))
            (Cons (Cons False (Cons False (Cons False (Cons True (Cons False Nil))))) Nil)))))            

;; Test argsFromTableHeader            
! (assertEqual (argsFromTableHeader (Cons B Nil)) ()) 
; ! (assertEqual (argsFromTableHeader (Cons A (Cons B Nil))) (A)) 
; ! (assertEqual (argsFromTableHeader (Cons A (Cons B (Cons C (Cons D (Cons Output Nil)))))) (A B C D))            

! (assertEqual (List.getIndexOf A Nil) (Error A "Not found in label list/Empty list")) 
! (assertEqual (List.getIndexOf A (Cons A (Cons B (Cons C Nil)))) 0) ;; 0
! (assertEqual (List.getIndexOf C (Cons A (Cons B (Cons C Nil)))) 2) ;; 2
! (assertEqual (List.getIndexOf D (Cons A (Cons B (Cons C Nil)))) (Error D "Not found in label list/Empty list")) ;; 
! (assertEqual (List.getIndexOf D (Cons A (Cons B (Cons C (Cons D Nil))))) 3) ;;

! (assertEqual (map-getIndexOf (A) Nil) (Error A "Not found in label list/Empty list"))
! (assertEqual  (map-getIndexOf (A) (Cons A Nil)) (0))
! (assertEqual  (map-getIndexOf (A B) (Cons A (Cons B Nil))) (0 1))

! (assertEqual (List.dropAt (Cons A Nil) (0)) Nil)
! (assertEqual (List.dropAt (Cons A (Cons B Nil)) (0)) (Cons B Nil))
! (assertEqual (List.dropAt (Cons A (Cons B (Cons C Nil))) (0 1)) (Cons C Nil))


! (assertEqual (map-dropAt dataRows (0))
                (Cons (Cons True (Cons False (Cons True (Cons True Nil)))) 
                (Cons (Cons False (Cons False (Cons True (Cons True Nil)))) 
                (Cons (Cons True (Cons False (Cons True (Cons False Nil)))) 
                (Cons (Cons False (Cons False (Cons True (Cons False Nil)))) Nil)))))

! (assertEqual (map-dropAt dataRows (0 1))
        (Cons (Cons False (Cons True (Cons True Nil))) 
        (Cons (Cons False (Cons True (Cons True Nil))) 
        (Cons (Cons False (Cons True (Cons False Nil))) 
        (Cons (Cons False (Cons True (Cons False Nil))) Nil)))))
! (assertEqual (map-dropAt dataRows (0 2))
        (Cons (Cons True (Cons True (Cons True Nil))) 
        (Cons (Cons False (Cons True (Cons True Nil))) 
        (Cons (Cons True (Cons True (Cons False Nil))) 
        (Cons (Cons False (Cons True (Cons False Nil))) Nil)))))
        
;; testing adjustTruthTable -- expected out put
! (assertEqual (adjustTruthTable (A B) ttable) ;; expect ttable with only A, B and Output labels
        (mkITable 
                (Cons (Cons True (Cons True (Cons True Nil))) 
                (Cons (Cons True (Cons False (Cons True Nil))) 
                (Cons (Cons False (Cons True (Cons False Nil))) 
                (Cons (Cons False (Cons False (Cons False Nil))) Nil)))) 
                (Cons A (Cons B (Cons Output Nil)))))    
        
! (assertEqual (adjustTruthTable (A C) ttable) ;; expecting table containing only A and C features
            (mkITable 
                (Cons (Cons True (Cons False (Cons True Nil))) 
                (Cons (Cons True (Cons False (Cons True Nil))) 
                (Cons (Cons False (Cons False (Cons False Nil))) 
                (Cons (Cons False (Cons False (Cons False Nil))) Nil)))) 
                (Cons A (Cons C (Cons Output Nil)))))

! (assertEqual (adjustTruthTable (B C) ttable) ;; ttable with B C features only
                (mkITable 
                    (Cons (Cons True (Cons False (Cons True Nil))) 
                    (Cons (Cons False (Cons False (Cons True Nil))) 
                    (Cons (Cons True (Cons False (Cons False Nil))) 
                    (Cons (Cons False (Cons False (Cons False Nil))) Nil)))) 
                    (Cons B (Cons C (Cons Output Nil)))))

! (assertEqual (adjustTruthTable (C D) ttable) ;; ttbale with only C D features 
                (mkITable 
                    (Cons (Cons False (Cons True (Cons True Nil))) 
                    (Cons (Cons False (Cons True (Cons True Nil))) 
                    (Cons (Cons False (Cons True (Cons False Nil))) 
                    (Cons (Cons False (Cons True (Cons False Nil))) Nil)))) 
                    (Cons C (Cons D (Cons Output Nil)))))