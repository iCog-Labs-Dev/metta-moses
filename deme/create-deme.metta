;; Represents a population of program instances with the same representation 
;; but different knob settings, along with their scores
; (: Deme Type)
; (: mkDeme (-> Representation (InstanceSet $score) DemeId Deme))
;; createDeme create demes with empty instance set -- appends deme ID's to them as well
;;             $demeIds --    list of deme ids (cons ...)
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
            (loopCreateDeme $demeIds $reps ()) ;; FIX: Optimize this using zip implementation in PeTTa. It can be faster.
      ) 
)
;; Game strategy createDeme - creates demes with empty instance sets for game strategies
;;             $nDeme --      number of demes to create
;;             $demeIds --    list of deme ids (cons ...)
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

;; Action createDeme - the action/perception vocabularies ride as ARGUMENTS
;; (5-ary: no collision with the 3-arg game clause above or the 8-arg
;; boolean clause below); same body shape. This layer just forwards them --
;; the one params read happens at the deme boundary in expand-deme.metta.
;;             $nDeme --       number of demes to create
;;             $demeIds --     list of deme ids (cons ...)
;;             $exemplar --    the exemplar tree which the demes are going to be based on
;;             $actions --     tuple of domain action symbols (knob vocabulary)
;;             $perceptions -- tuple of perception symbols (may be ())
;;             returns ↠ tuple of demes
; (: createDeme (-> Number (List DemeId) (Tree $a) Expression Expression Expression))
(= (createDeme $nDeme $demeIds $exemplar $actions $perceptions)
      (let $reps (createRepresentation $nDeme $exemplar $actions $perceptions)
            (loopCreateDeme $demeIds $reps ())))


(= (loopCreateDeme $demeIds $reps $acc)
(if (== $reps ()) 
    $acc
    (let* (
            ($h (car-atom $reps))
            ($t (cdr-atom $reps)))
         (let* (
                 ($demeId (List.head $demeIds))
                 ($deme (mkDeme $h (mkSInstSet ()) $demeId))
                 ($new-acc (union-atom $acc ($deme))))
               (loopCreateDeme (List.tail $demeIds) $t $new-acc)))))
;; previous version of loopCreateDeme using if-decons-expr-custom
;       (if-decons-expr-custom $reps $h $t
;             (let* (($demeId (List.head $demeIds)) 
;                    ($deme (mkDeme $h (mkSInstSet ()) $demeId))
;                    ($new-acc (union-atom $acc ($deme))))
                  
;                   (loopCreateDeme (List.tail $demeIds) $t $new-acc))
;                $acc))    
