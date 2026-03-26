;; Represents a population of program instances with the same representation 
;; but different knob settings, along with their scores
; (: Deme Type)
; (: mkDeme (-> Representation (InstanceSet $score) DemeId Deme))
;; createDeme create demes with empty instance set -- appends deme ID's to them as well
;;             $demeIds --    list of deme ids (Cons ...)
;;             $exemplar --   the exemplar tree which the demes are going to be based on 
;;             $table    --   table of input data 
;;             $algo     --   the chosen feature selection algo
;;             $prune-exemplar     --   bool shall we prune the exemplar or not?
;;             $enforced-features  --   tuple of enorced features to be sample during feature selection, if any, in the form of arg selection-probabality pair
;;             returns ↠ tuple of demes
; (: createDeme (-> Number (List DemeId) (Tree $a) (ITable $a) Symbol Bool Expression Symbol Expression)) 
(= (createDeme $nDeme $demeIds $exemplar (mkITable $table $labels) $algo $prune-exemplar $enforced-fts $scorerType)
      (let* 
            (
                  ;; ($_ (println! "creating representations ...."))
                  ($reps (createRepresentation $nDeme $exemplar (mkITable $table $labels) $algo $prune-exemplar $enforced-fts  $scorerType))
                  ;; ($_ (println! (done making representations ... $reps)))
            ) 
            (loopCreateDeme $demeIds $reps ())
      ) 
)
;; Game strategy createDeme - creates demes with empty instance sets for game strategies
;;             $nDeme --      number of demes to create
;;             $demeIds --    list of deme ids (Cons ...)
;;             $exemplar --   the exemplar tree which the demes are going to be based on 
;;             returns ↠ tuple of demes
; (: createDeme (-> Number (List DemeId) (Tree $a) Expression))
(= (createDeme $nDeme $demeIds $exemplar)
      (let* 
            (
                  ;; ($_ (println! "creating game representations ...."))
                  ($reps (createRepresentation $nDeme $exemplar))
                  ;; ($_ (println! ("done making representations ..." $reps)))
            )  
            (loopCreateDeme $demeIds $reps ())
      ) 
)


(= (loopCreateDeme $demeIds $reps $acc)
(if (== $reps ()) 
    $acc
    (let* (
            ($h (car-atom $reps))
            ($t (cdr-atom $reps)))
         (let* (
                 ($demeId (List.head $demeIds)) 
                 ($deme (mkDeme $h (mkSInstSet Nil) $demeId))
                 ($new-acc (union-atom $acc ($deme))))     
               (loopCreateDeme (List.tail $demeIds) $t $new-acc)))))
;; previous version of loopCreateDeme using if-decons-expr-custom
;       (if-decons-expr-custom $reps $h $t
;             (let* (($demeId (List.head $demeIds)) 
;                    ($deme (mkDeme $h (mkSInstSet Nil) $demeId))
;                    ($new-acc (union-atom $acc ($deme))))
                  
;                   (loopCreateDeme (List.tail $demeIds) $t $new-acc))
;                $acc))    
