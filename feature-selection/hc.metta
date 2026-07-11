;; getHcFtPop -- returns list of (score ft-set pairs) as (cons ..)
;;            -- takes list of scored instances and an empty List () as accumulator
(: getHcFtPop (-> Expression Expression Expression))
(= (getHcFtPop  () $acc) ())
(= (getHcFtPop (cons (mkSInst (mkPair (mkInst $list) $score)) $sInsts) $acc)
  (let* (($new-acc (getHcFtPop $sInsts $acc))
         ;; Reduced on its own line: inside ($score (bitsToIndices ...)) the pair's
         ;; head is a number, so the call would never be evaluated.
         ($ft-set (bitsToIndices $list 0 ()))
         ($score-ft-set-pair (cons-atom $score (cons-atom $ft-set ()))))
    (cons $score-ft-set-pair $new-acc)))

;; hcFtSetPop  -- runs the hill climbing feature selector using a center instance
;;             -- returns tuple of (score ft-set) pairs
;;      $miConfi          -- confidence intensity for the mutual information scorer
;;      $prePenalty       -- activation penalty for the precision scorer
;;      $preMinActivation -- lower bound on the rows the precision scorer selects
;;      $preMaxActivation -- upper bound on the rows the precision scorer selects
;;      $prePositive      -- which output value counts as the positive class
;;      $scorerType       -- mi or pre
;; Commented out: ITable has no type definition, so every call reduces to Empty.
;; (: hcFtSetPop (-> (ITable $a) Instance Number Number Number Number Bool Symbol Expression))
(= (hcFtSetPop $iTable $centerInst $miConfi $prePenalty $preMinActivation $preMaxActivation $prePositive $scorerType)
  (let* (
         ;; ($_ (println! (debug inside hcFtSetPop)))
         ;; Built with cons-atom so the tuple stays data instead of being applied.
         ($fsHyperparams (cons-atom $miConfi (cons-atom $prePenalty (cons-atom $preMinActivation (cons-atom $preMaxActivation (cons-atom $prePositive (cons-atom $scorerType ())))))))
         (((mkInst $inst1) (mkSInstSet $list) $state) (hillClimbing (mkSInstSet ()) $iTable (mkInst $centerInst) (mkParams applyMutualInformationBasedScore $fsHyperparams))) ;; runs the hillclimbing feature selector
         ($list-of-scoreset-pairs (getHcFtPop $list ()))                                                    ;; separates the scores from the the previous output and puts them in a score feature-set pair tuple -- as list of
         ($unique-pairs (List.tFoldl $list-of-scoreset-pairs union-atom toExp ()))                          ;; finds unquie such pairs duplicats removed -- by way of union-atom
         ($size (size-atom $unique-pairs))
        )

         (sortPairs pairMax $unique-pairs $size ())
  )
)                                                       ;; sort using score
