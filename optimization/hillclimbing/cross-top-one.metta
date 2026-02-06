;; crossTopOne --       Cross the single top-scoring instance against the next-highest scorers.
;;                      As arguments, accepts a range of scored instances ("the sample"),
;;                      and a single instance from which these were all derived ("the base"
;;                      or center instance). This will create a number of new instances,
;;                      which will be a cross of the highest-scoring instance with the
;;                      next-highest scoring instances.

; (: crossTopOne (-> Deme Number Number Number Instance Deme))
;; TODO: Make use of the $sampleStart 
;; This is how the openCog classic does it but the reason isn't yet clear but 
;;   I suspect it is to prevent crossovering over an already crossed over 
;;   population and focus on newly generated instances only.
(= (crossTopOne $deme $nToMake $sampleStart $sampleSize $baseInstance)
   ; (trace! (Inside crossTopOne: $nToMake $sampleStart $sampleSize) 
            (let* (
                    ((mkDeme (mkRep (mkKbMap $dscKbMp (mkDscMp $dscMp)) $tree) (mkSInstSet $instSet) $demeId) $deme)
                    ;; ($_ (println! (Inside crossTopOne)))
                    ($nToMakeNew (if (< (- $sampleSize 1) $nToMake) (- $sampleSize 1) $nToMake))
                    ;; ($_ (println! (SampleSize: $sampleSize NToMake: $nToMakeNew SampleStart: $sampleStart totalSize: (eval (List.length $instSet)))))
                    (($prevInst $newInst) (List.splitAt $sampleStart $instSet))
                    ($list (List.partialSort instance>= $newInst $nToMakeNew Nil)) ;; deconstruct the partial sorted set of instances into the reference and the rest and take the next N values from the rest for crossover
                  )
                  (if (== $list Nil)
                      (mkDeme (mkRep (mkKbMap $dscKbMp (mkDscMp $dscMp)) $tree) (mkSInstSet $instSet) $demeId)
                      (let*
                        (
                          ((Cons $reference $rest) $list)
                          ($targetInstances (List.takeN (- $nToMake 1) $rest))
                          ($targetExpr (List.listToExpr $targetInstances))

                          ((mkSInst (mkPair $referenceInst $referenceScore)) $reference)
                          ($newInstances (eval (merger $targetExpr $baseInstance $referenceInst)))
                          ($uniqueInstances (unique-atom $newInstances))
                          ;; ($_ (println! (NewInstances: (length $newInstances) UniqueInstances: (length $uniqueInstances))))
                          ;; ($__ (println! (New instances After merging: $newInstances)))
                          ;; ($_ (println! ""))
                          ;; ($_ (println! (PrevInst: $prevInst)))
                        )
                        (mkDeme (mkRep (mkKbMap $dscKbMp (mkDscMp $dscMp)) $tree) (mkSInstSet (List.appendList (exprToList $newInstances) $newInst)) $demeId)))))

;; similar to the above 'crossTopOne' but with slight changes on the comparison function that is passed to the Lost.partialSort to compare the mutualInformation based scores
; (: crossTopOneFs (-> (InstanceSet $a) Number Number Number Instance (InstanceSet $a)))
(= (crossTopOneFs (mkSInstSet $instSet) $nToMake $sampleStart $sampleSize $baseInstance)
   ; (trace! (Inside crossTopOne: $nToMake $sampleStart $sampleSize) 
            (let* (
                    ;; ($_ (println! (Inside crossTopOneFs)))
                    ($nToMakeNew (if (< (- $sampleSize 1) $nToMake) (- $sampleSize 1) $nToMake))
                    ;; ($_ (println! (NToMake: $nToMakeNew)))
                    (($prevInst $newInst) (List.splitAt $sampleStart $instSet))
                    ((Cons $reference $rest) (eval (List.partialSort instanceFs>= $newInst $nToMakeNew Nil))) ;; deconstruct the partial sorted set of instances into the reference and the rest and take the next N values from the rest for crossover
                    ($targetInstances (eval (List.takeN (- $nToMake 1) $rest)))
                    ($targetExpr (eval (List.listToExpr $targetInstances)))

                    ((mkSInst (mkPair $referenceInst $referenceScore)) $reference)
                    ($newInstances (eval (mergerFs $targetExpr $baseInstance $referenceInst)))
                    ;; ($_ (println! (New instances After merging: $newInstances)))
                    ;; ($_ (println! ""))
                    )
                (mkSInstSet (eval (List.appendList (eval (exprToList $newInstances)) $instSet)))))
; ) )
