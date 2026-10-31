;; Candidate reconstruction: builds the program tree for one instance of a
;; representation (getCandidate and its helpers).
;;
;; These functions are in their own file, apart from the representation
;; constructor, because of the import order. hill-climbing-helpers calls them,
;; and the representation constructor calls featureSelector, whose hc selector
;; calls hillClimbing. So moses.metta loads this file before the optimizer and
;; representation.metta after it.

;; Helper function to extract tree from representation
(= (getRepTree (mkRep $knobMapObj $tree)) $tree)

;; Universal getCandidate that works for both boolean and action domains.
;; Candidate finalization keeps strategy trees untouched. Action programs use
;; static action reduction; all other candidates use boolean reduction.
(= (candidateRootSymbol $tree)
   (let $rootValue (getNodeValue $tree)
      (if (== (get-metatype $rootValue) Expression)
          (car-atom (cdr-atom $rootValue))
          $rootValue)))

(= (finalizeCandidateTree $rootSymbol $candidate)
   (if (isActionOperator $rootSymbol)
       (cleanActionTree $candidate)
       (cleanTree $candidate)))

;; Universal getCandidate that works for boolean and action trees.
;; (: getCandidate (-> Representation Instance (Tree $a)))
;; TODO: This should be removed when the game tree has been fixed to match the boolean.
(= (getCandidate $srcid $repObj $id $inst)
   (case (match &treeSpace ($id $inst $tree) $tree)
             (($tree $tree)
             (Empty 
                (let*
                    (
                      ;; ($_ (println! (Here)))
                      ($parentid (mkNodeId (0)))
                      ($srcid (mkNodeId (0)))
                      ;; ($_ (println! ($parentid   $srcid)))
                      ((mkRep $kmo $tr) $repObj)
                      ;; ($_ (println! (Tree: (preOrder $tr))))
                      ($candidate (getCandidateRec $repObj $inst $parentid $srcid $parentid (mkNullVex ())))
                      ;; ($_ (println! (Found candidate: (preOrder $candidate))))
                      ($rootNode (getNodeById (getRepTree $repObj) $srcid))
                      ($rootSymbol (candidateRootSymbol $rootNode))
                      ($finalTree (finalizeCandidateTree $rootSymbol $candidate))

                      ($_ (add-atom &treeSpace ($id $inst $finalTree)))
                      ;; ($_ (println! (Cleaned Tree: $cleanedTree)))
                    )
                    $finalTree)))))
   ; (trace! (Converting instance: $inst to tree) (chain (getCandidateRec $repObj $inst (mkNodeId (0)) (mkNodeId (0)) (mkNullVex ())) $candidate
   ;  (cleanTree $candidate)))
    
    
     ;;((( (trace! (Done converting instance to tree $candidate) $candidate))))


(= (getCandidate $repObj $id $inst)
   (case (match &treeSpace ($id $inst $tree) $tree)
             (($tree $tree)
             (Empty
                (let*
                    ( 
                      ((mkRep $kmo $tr) $repObj)
                      ;; ($_ (println! (Tree: (preOrder $tr))))
                      ;; ($_ (println! (GetCandidateHelper: $inst $tr)))
                      ($candidate (getCandidateHelper $inst $tr))
                      ;; ($_ (println! (Found candidate: (preOrder $candidate))))
                      ($rootNode (getRepTree $repObj))
                      ($rootSymbol (candidateRootSymbol $rootNode))
                      ($finalTree (finalizeCandidateTree $rootSymbol $candidate))

                      ($_ (add-atom &treeSpace ($id $inst $finalTree)))
                      ;; ($_ (println! (Cleaned Tree: $cleanedTree)))
                    )
                    $finalTree)))))


;; Assumes the reverseLookupTable's order never changes during this call.
;; (: getCandidateRec (-> Representation Instance NodeId NodeId (Tree $a) (Tree $a)))
; (= (getCandidateRec (mkRep $knobMapObj $tree) (mkInst $inst) $parentId $srcId $candidate)
;    ;; Find the knob associated with src (if any)
;    (chain (findDiscKnob $knobMapObj $srcId) $knobIdxPair
;       (if (~= (second $knobIdxPair) -1)
;           (chain (List.getByIdx $inst (second $knobIdxPair)) $d
;           (chain (appendTo $tree (first $knobIdxPair) $candidate $parentId $d) $updatedCnd

;           ;; The C++ version needs to call the getCandidateRec 
;           ;;  on the newly added node of the candidate but we 
;           ;;  already took care of that addition using the appendTo
;           ;;  function. Therefore that part is ommited here.
;           $updatedCnd))

;          ;; No knob found. Just copy.
;          (chain (getNodeById $tree $srcId) $src ;; Get node value using id
;          (chain (appendChild $candidate $parentId (mkTree (getNodeValue $src) ())) $cndChIdPair ;; AppendChild returns a pair of tree and appended child Id
;          (chain (getChildren $src) $srcChildren
;          (chain (List.foldl applyGetCandidateRec ((mkRep $knobMapObj $tree) (mkInst $inst) (second $cndChIdPair) (first $cndChIdPair) 1) $srcChildren) $state
;             (let ((mkRep $knobMapObj $tree) (mkInst $inst) $newParentId $finalCnd $_) $state $finalCnd)))))))
; )

(= (getCandidateRec (mkRep $knobMapObj $tree) (mkInst $inst) $parentId $srcId $dstId $candidate)
   (let $knobIdxPair (findDiscKnob $knobMapObj $srcId) 
      (if (not (== (second $knobIdxPair) -1))
         (let*
            (          
               ;; ($_ (println! (KnobBuilding 1)))
               ($d (List.getByIdx $inst (second $knobIdxPair)))
               ;; ($_ (println! (KnobBuilding 2)))
               ($result  (appendTo $tree (first $knobIdxPair) $candidate $dstId $d))
               ;; ($_ (println! (KnobBuilding 3)))
               ;; ($_ (println! (Result: $result)))
               (($updatedCnd $newSrcId $newDstId) $result)
               ;; ($_ (println! (Candidate 3: (preOrder $updatedCnd))))
               ;; ($_ (println! (KnobBuilding 4: NothingChanged: (== $dstId $newDstId))))
               ;; ($_ (println! ""))
            )
            (if (== $updatedCnd $candidate)
                $updatedCnd
                (let*
                   (
                      ($src1 (getNodeById $tree $newSrcId))
                      ;; ($_ (println! (KnobBuilding 5)))

                      ($srcchildren1 (getChildren $src1))
                      ;; ($_ (println! (KnobBuilding 6: Cnd: (preOrder $updatedCnd) newSrcId: $newSrcId newDstId: $newDstId)))
                      ($state1 (List.foldl applyGetCandidateRec ((mkRep $knobMapObj $tree) (mkInst $inst) $newSrcId $newDstId $updatedCnd 1) $srcchildren1))
                      ;; ($_ (println! (KnobBuilding 7)))
                      (((mkRep $knobmapobj1 $tree1) (mkInst $inst1) $newparentid1 $newdstId1 $finalcnd1 $d1) $state1)
                      ;; ($_ (println! (KnobBuilding 8: $newparentid1 $newdstId1)))
                      ;; ($_ (println! ""))
                   )
                   $finalcnd1
                )
            )
         )
         (let*
            (
               ;; ($_ (println! (Inside getCandidateRec with parentId: $parentId , srcId: $srcId)))
               ;; ($_ (println! ""))
               ;; ($_ (println! (No Knob found just copy...)))
               ;; ($_ (println! (Copying 1)))
               ;; ($_ (println! (Getting: $srcId from (preOrderDebug $tree))))
               ($src (getNodeById $tree $srcId))
               ;; ($_ (println! (Copying 2)))
               ($dstValue (getNodeById $candidate $dstId))
               ;; ($_ (println! (Copying 3:  appending child: (getNodeValue $src) on (preOrder $candidate) at $dstId)))

               ($cndchidpair (appendChild $candidate $dstId (mkTree (getNodeValue $src) ())))
               ;; ($_ (println! (Copying 4)))
               ($srcchildren (getChildren $src))
               ;; ($_ (println! (Copying 5: Candidate5 (preOrder (first $cndchidpair)))))
               ($state (List.foldl applyGetCandidateRec ((mkRep $knobMapObj $tree) (mkInst $inst) $srcId (second $cndchidpair) (first $cndchidpair) 1) $srcchildren))
               ;; ($_ (println! (Copying 6)))
               (((mkRep $knobmapobj $tree) (mkInst $inst) $newparentid $newdstId $finalcnd $d) $state)
               ;; ($_ (println! (Copying 7)))
               ;; ($_ (println! (FinalCandidate: (preOrder $finalcnd))))
               ;; ($_ (println! (FinalCandidate: $finalcnd)))
               ;; ($_ (println! ""))
            )
              $finalcnd
          )
      )
   )
)

;; getCandidateRec (mkRep $knobMapObj $tree) (mkInst $inst)

(= (getCandidateHelper (mkInst $inst) (mkKnob $controlledSubtree (mkASK $discKnob $perms) $i))
   (let*
      (
         ($ask (mkASK $discKnob $perms))
         ((mkDiscSpec $defaultSetting) (getKnobDefault $ask))
         ($setting (if (!= (getDisallowedSpecs $ask) ())
                     (mapEffectiveDiscSpec $ask (index-atom $inst $i))
                     (index-atom $inst $i)))
      )
      (if (== $setting 0)
         ()
         (if (== $defaultSetting 0)
             (getCandidateHelper (mkInst $inst) (List.getByIdx $perms (- $setting 1)))
             (getCandidateHelper (mkInst $inst) $controlledSubtree)))))

;; Null-vertex unwrapping for LSK knobs only.
;; mkASK knobs are handled exclusively by the ASK rule above,
;; which reads perms directly from the controlled NullVex.
;; Keeping this generic caused double evaluation whenever the
;; ASK rule (Rule A) and this unwrapping rule both fired on
;; the same (mkKnob (mkNullVex ...) (mkASK ...) $i) expression.
(= (getCandidateHelper $inst (mkKnob (mkNullVex ($child)) (mkLSK $discKnob) $i))
   (getCandidateHelper $inst (mkKnob $child (mkLSK $discKnob) $i)))

;; Specialized fast clause: empty disallowed list means effective settings map
;; one-to-one to actual settings, so we skip mapEffectiveDiscSpec entirely.
;; This is byte-for-byte the pre-merge ref/RepresentationBuilding body.
;; NOTE: This clause assumes MeTTa dispatches the literal-empty `()` disAll
;; pattern in preference to the generic `$lsk` clause below — the same
;; literal-driven dispatch we relied on for $disable-discprobe True/False.
(= (getCandidateHelper (mkInst $inst) (mkKnob (mkTree $node $children) (mkLSK (mkDiscKnob $m $c $d $disAllowed)) $i))
   (let*
     (
       ($setting (if (!= $disAllowed ())
                     (mapEffectiveDiscSpec (mkLSK (mkDiscKnob $m $c $d $disAllowed)) (index-atom $inst $i))
                     (index-atom $inst $i)))
     )
     (if (== $setting 0)
         ()
         (let $newChildren (filter-atom (map-atom $children $ch (getCandidateHelper (mkInst $inst) $ch)) (!= ()))
              (case $setting
                 (
                   (1 (mkTree $node $newChildren))
                   (2 (mkTree (mkNode NOT) ((mkTree $node $newChildren))))))))))

(= (getCandidateHelper $inst (mkTree $node $children))
   (let $newChildren (map-atom $children $ch (getCandidateHelper $inst $ch))
        (mkTree $node (filter-atom $newChildren (!= ())))))

(= (applyGetCandidateRec $tr ($repObj $inst (mkNodeId $parentId) (mkNodeId $dstId) $candidate $chIdx))
   (let*
      (
         ;; ($_ (println! ("applyGetCandidateRec called with parentId:" $parentId , chIdx: $chIdx)))
         ($srcId (if (== $parentId (0)) (mkNodeId ($chIdx)) (mkNodeId (concatT $parentId ($chIdx)))))
         ;; ($_ (println! (srcId: $srcId)))
         ;; ($_ (println! (dstId: $dstId)))
         ($updatedCnd1 (getCandidateRec $repObj $inst (mkNodeId $parentId) $srcId (mkNodeId $dstId) $candidate))
         ($finalResult ($repObj $inst (mkNodeId $parentId) (mkNodeId $dstId) $updatedCnd1 (+ 1 $chIdx)))
         ;; ($_ (println! (FinalResult: (preOrder $updatedCnd1))))
         ;; ($_ (println! ("applyGetCandidateRec returning finalResult:" $finalResult)))
      )
      $finalResult
   )
)
