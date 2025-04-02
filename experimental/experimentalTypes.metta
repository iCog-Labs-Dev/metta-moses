;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;Deme related;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(: List Type)
(: mkList (-> $a List))
;!(get-type (mkList 1))

(: DemeId Type)
(: mkDemeId (-> Number DemeId))

(: NumExp Type)
(: mkNumExp (-> Number NumExp))

(: Deme Type)
(: mkDeme (-> (field_set DemeId) Deme))

(: create_demeIDs (-> NumExp (List DemeId))) 
;!(get-type (create_demeIDs (mkNumExp 5)))

(: Exemplar Type)
(: mkExe (-> $randProg Exemplar))  ;;other attributes of the Exemplar will be added here to make the Exemplar

(: create_deme (-> Exemplar NumExp Deme))   
;!(get-type (create_deme (mkExe $prog1) (mkNumExp 5)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;Knob related;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(: Node Type) ;AND, OR, Predicate, Boolean, Argument
(: mkNode (-> $and Node))

; Takes an exemplar and a node, performs logical canonicalization
; Returns a canonized exemplar for logical operations
(: logical-canonize (-> Exemplar Node Exemplar))
;!(get-type (logical-canonize (mkExe $prog1) (mkNode $and)))

(: Subtree Type) 
(: mkSubtree (-> Exemplar Subtree))
(: Pair Type)
(: mkPair (-> $a $b Pair))

(: KnobSpec Type)   
(: LogicalKnob Type)

; Builds logical knobs for a given exemplar at a specific subtree location
(: build-logical (-> Exemplar Subtree Node (List (Pair KnobSpec LogicalKnob)))) ;;;Orderedmap
;!(get-type (build-logical (mkExe $prog1) (mkSubtree $sub1) (mkNode $and)))

; Adds logical knobs to an exemplar at a specific subtree position
; The bool parameter determines whether to add knobs that are already present in the exemplar
(: add-logical-knobs (-> Exemplar Subtree Node Bool (List (Pair KnobSpec LogicalKnob))))
;!(get-type (add-logical-knobs (mkExe $prog1) (mkSubtree $sub1) (mkNode $and) True))

; Generates a list of possible permutations for a given logical node
(: sample-logical-perms (-> Node () (List Perms)))  
;!(get-type (sample-logical-perms (mkNode $and) ()))          

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;Field/FieldSet realted;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(: Field Type)
; a field has a WIDTH, MAJOR-OFFSET and MINOR-OFFSET
(: mkField (-> (Number Number Number) Field))
(: DiscSpec Type)
; a DiscSpec has MULTIPLICITY and OPERATIONS???
(: mkDiscSpec (-> Number DiscSpec))

; Calculates the total bit offset after the last field in a field list
(: back-offset (-> (List Field) Number))
;!(get-type (back-offset (List Field)))

;;;;build_spec(const spec& s, size_t n)

;Creates discrete specification fields and updates boolean count
;Number param here corresponds to the number of Fields to be created
(: build-disc-spec (-> DiscSpec Number (Pair (List Field) Number)))
;!(get-type (build-disc-spec (mkDiscSpec 6) 8))

;knob mapping.... disc_map(map b/n knob&spec), it_disc_knob_map(map b/n node&knob)
;creates a discrete knob for a given node
(: find-disc-knob (-> Node (Pair DiscSpec DiscKnob)))
;!(get-type (find-disc-knob (mkNode $and)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          ;;;;;;;;;;;;;;;Scoring ;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



(: List (-> $a Type))
(: Nil (List $a))
(: Cons (-> $a (List $a) (List $a)))

(: Distance Type)
(: mkDistance (-> Number Distance))

(: Row (List $a))
(: Table (List Row))
(: LenTable (-> Table Number))

(: mkRow (-> $a Row))
; ! (get-type (mkRow (Cons 2 Nil))) ;; Row

;; raw based score
(: behavioralScore (List $a))           ;; [0,-1,0,0,-1,0,0,]
(: mkBscore (-> $a behavioralScore))
; ! (get-type (mkBscore (Cons 1 (Cons 2 Nil))))


;; all of the output rows are correct 
;; e.g  something like [0,0,0,0,0,0,0,]

(: bestPossibleBscore (-> Number behavioralScore))          
; ! (get-type (bestPossibleBscore 4 )) ;; behaviouralScore

(: worstPossibleBscore (-> Number behavioralScore))          ;; e.g  [-1,-1,-1,-1,-1,-1]

(: minImprov (-> Number)) ;0.5
; ! (get-type (minImprov))

;; Truth Table Scoring
(: completeTruthTableScore
   (-> Expression Number Table))  ;; takes tree and arity

; ! (get-type (completeTruthTableScore $d 3))


;; Logical Scoring
(: logicalBscore (-> Expression behavioralScore))
; ! (get-type (logicalBscore (sadfa)))

;; converts an instance into a combo_tree (Expression)
(: getCandidate (-> instance bool Expression)) ;; () 

;; which counts the number of nodes in the combo tree return tr.size()
(: complexity_t (-> Expression Number))


;; Composite Scoring combines row fitness with complexity        
(: compositeScore (-> (-> behavioralScore Number) Table (-> combo Number) ComplexityPenalty UniformityPenalit Number) ) ;; sumBscore, complexity, complexity-coef, 0.0 by default 
; ! (get-type (compositeScore 10 12 0.4 0.0))

(:WorstCompositeScore (-> Number))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;Metapopulation related ;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; base tree
(: tree Type)
(: mkTree (-> $a tree))

;; scored tree -- xmplr
;; deme ID
(: demeID Type)
(: mkDemeID (-> Number demeID))

;; composite_score
(: cscore Type)
(: getCscore (-> tree cscore))
        
;; composite score components
(: scoreT Type)
(: cpxyT Type)

(: mkScoreT (-> Number scoreT))
(: mkCpxy (-> Number cpxyT))

;; composite score is composed of scor??, comlexity score, a complexity penalty and a uniformity penalty score

(: mkCscore (-> scoreT cpxyT scoreT scoreT cscore))

; ! (get-type (mkCscore (mkScoreT 0.3) (mkCpxy 0.42) (mkScoreT 0.85) (mkScoreT 0.63))) ;; cscore

;; behavioral_score
(: bscore Type)
(: mkBscore (-> Number bscore))
(: getBscore (-> tree bscore))

; ! (get-type (getBscore (mkTree sda))) 

(: Xmplr Type)
(: mkXmplr (-> tree demeID cscore bscore Xmplr))

! (get-type (mkXmplr (mkTree efa) (mkDemeID 56) 
                    (mkCscore (mkScoreT 0.3) (mkCpxy 0.42) (mkScoreT 0.85) (mkScoreT 0.63))
                    (mkBscore 1.12))) ;; xmplr

;; metapopulation --  ordered set containing scored trees
;; represented here as set of scored trees -- sTSet
(: OrdSet (-> $a Type))
(: MP (OrdSet Xmplr)) ;; metapopulation
(: mkMP (-> Xmplr (OrdSet Xmplr) (OrdSet Xmplr)))

(: Nil (OrdSet Xmplr))

; ! (get-type (mkMP 
;                 (mkXmplr (mkTree efa) (mkDemeID 56) 
;                         (mkCscore (mkScoreT 0.3) (mkCpxy 0.42) (mkScoreT 0.85) (mkScoreT 0.63))
;                         (mkBscore 1.12)) 
;                     Nil)) ;; (Set xmplr)

;; visited exemplars -- holds count of number of times an exemplar has been expaned
;; -- assuming correspondence between the scored tree set and this set
;; rather than having a separate structure containig the scored trees themselve

(: Rvst Type)
(: mkRvst (-> Number Rvst))

(: List (-> $a Type))
(: RvstSet (List Rvst))

;; exemplar selection
(: selectExmplr (-> (OrdSet Xmplr) Xmplr))

; ! (get-type (selectExmplr
;                 (mkMP 
;                     (mkXmplr (mkTree efa) (mkDemeID 56) 
;                         (mkCscore (mkScoreT 0.3) (mkCpxy 0.42) (mkScoreT 0.85) (mkScoreT 0.63))
;                         (mkBscore 1.12)) 
;                     Nil))) ;; xmplr
;; roulette_select used to select randomly from set of scored trees that have the same cscore favouring those that have higher penalized scores
;; takes a random number generator
(: mkRnd (-> Number))
(: rultSelect (-> (-> Number) (OrdSet Xmplr) Xmplr))

; ! (get-type (rultSelect mkRnd (mkMP 
;                             (mkXmplr (mkTree efa) (mkDemeID 56) 
;                                     (mkCscore (mkScoreT 0.3) (mkCpxy 0.42) (mkScoreT 0.85) (mkScoreT 0.63))
;                                     (mkBscore 1.12)) 
;                                     Nil))) ;; xmplr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;; Boolean Tree related ;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(: A Bool)
(: B Bool)
(: C Bool)

(: tree Type)
;; AND, OR, NOT with literal inputs

(: AND (-> tree))
(: OR (-> tree))
(: AND (-> Bool tree))
(: OR (-> Bool tree))
(: AND (-> Bool Bool tree))
(: OR (-> Bool Bool tree))
(: NOT (-> Bool tree))

;; AND and OR with tree
(: AND (-> tree tree))
(: OR (-> tree tree))
(: AND (-> tree tree tree))
(: OR (-> tree tree tree))

;; AND and OR with tree and bool
(: AND (-> Bool tree tree))
(: OR (-> Bool tree tree))
(: AND (-> tree Bool tree))
(: OR (-> tree Bool tree))

; (: OP (-> Bool Bool tree))

; (: tree (-> OP tree tree))

! (get-type (AND )) ;; tree
! (get-type (AND A)) ;; tree
! (get-type (AND A B)) ;; tree
! (get-type (AND (OR (NOT C)) B)) ;; tree
! (get-type (AND (OR (NOT C) C) (AND (OR B (NOT C)) B))) ;; tree


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;               Refactored Types                         ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(: List (-> $a Type))
(: Nil (List $a))
(: Cons (-> $a (List $a) (List $a)))

(: Tree Type)
(: mkTree (-> $a (Tree $a)))

(: Map (-> $k $v Type))
(: NilMap (Map $k $v))
(: ConsMap (-> ($k $v) (Map $k $v) (Map $k $v)))


(: MultiMap (-> $k $v Type))
(: NilMMap (MultiMap $k $v))
(: ConsMMap (-> ($k $v) (MultiMap $k $v) (MultiMap $k $v)))

(: mapToList (-> (Map $k $v) (List ($k $v))))
(= (mapToList NilMap) Nil)
(= (mapToList (ConsMap $x $xs)) (Cons $x (mapToList $xs)))

(: Row (-> $a Type))
(: mkRow (-> (List $a) (Row $a)))

(: Table (-> $a (List (Row $a))))
(: sizeTable (-> (Table $a) Number))

(: AND (-> Bool Bool Bool))
; (: AND (-> Bool Bool))
(: OR (-> Bool Bool Bool))
; (: OR (-> Bool Bool))
(: NOT (-> Bool Bool))
(: naryAND (-> (List Bool) Bool))
(: naryOR (-> (List Bool) Bool))

(: Nothing Type)
(: someFunc (-> Bool Nothing))

(: someTreeFunc (-> (Tree Bool) Nothing))

(: someListFunc (-> (List $a) Nothing))
(: someMapFunc (-> (Map $k $v) Nothing))

(: Instance Type)
(: mkInstance (-> (List Number) Instance))

(: ScoredInstance (-> $score Type))
(: mkScoredInstance (-> (Instance $score) (ScoredInstance $score)))

(: InstanceSet (-> $score Type))
(: mkInstanceSet (-> (List ScoredInstance) InstanceSet))

(: DemeId Type)
(: mkDemeId (-> Number DemeId))

(: Deme Type)
(: mkDeme (-> (InstanceSet CompositeScore) Deme))

(: Xmplr (-> $a Type))
(: mkXmplr (-> $a DemeId CompositeScore BehavioralScore (Xmplr $a)))

(: Node Type) ;; AND, OR, Predicate, Boolean, Argument
(: mkNode (-> $and Node))

(: Subtree (-> $a Type))
(: mkSubtree (-> $a (Subtree $a)))

(: Multiplicity Number)
(: mkMulti (-> Number Multiplicity))

(: DiscSpec Type)
(: mkDiscSpec (-> Multiplicity DiscSpec))


(: Knob Type)
(: mkKnob (-> $a Knob))
;
(: DiscKnob Type)
(: mkDiscKnob (-> Knob DiscKnob))
;
(: LogicalKnob Type)
(: mkLogicalKnob (-> DiscKnob LogicalKnob))

(: DiscMap Type)
(: mkDiscMap (-> (MultiMap DiskSpec DiscKnob) DiscMap))

(: Representation Type)
(: mkRep (-> KnobMapper (Xmplr $a) Representation))

(: KnobMapper Type)
(: mkKnobMapper (-> DiscMap KnobMapper))

(: Distance Type)
(: mkDistance (-> Number Distance))

(: BehavioralScore Type)
(: mkBscore (-> (List Number) BehavioralScore)) ;; [0,-1,0,0,-1,0,0,]
(: getBscore (-> (Xmplr $a) BehavioralScore))

(: createDemeIDs (-> Number (List DemeId)))
(: createDeme (-> (Xmplr $a) Number Deme))
(: buildLogical (-> (Xmplr Bool) (Subtree Bool) Node (Map DiscSpec LogicalKnob))) ;;;Orderedmap
(: addLogicalKnobs (-> (Xmplr Bool) (Subtree Bool) Node Bool (Map DiscSpec LogicalKnob)))
(: sampleLogicalPerms (-> Node (List (Subtree Bool))))
(: findDiscKnob (-> KnobMapper Node DiscKnob))
(: bestPossibleBscore (-> Number BehavioralScore))
(: worstPossibleBscore (-> Number BehavioralScore))          ;; e.g  [-1,-1,-1,-1,-1,-1]

!(mkXmplr (AND A B) (mkDemeId 0) (mkCscore 0) (mkBscore (Cons 0 (Cons 1 Nil))))
!(createDeme (mkXmplr (AND A B) (mkDemeId 0) (mkCscore 0) (mkBscore (Cons 0 (Cons 1 Nil)))) 0)
!(buildLogical (mkXmplr (AND A B) (mkDemeId 0) (mkCscore 0) (mkBscore (Cons 0 (Cons 1 Nil)))) (mkSubtree (AND A B)) (mkNode A))
!(addLogicalKnobs (mkXmplr (AND A B) (mkDemeId 0) (mkCscore 0) (mkBscore (Cons 0 (Cons 1 Nil)))) (mkSubtree (AND A B)) (mkNode A) False)
!(sampleLogicalPerms (mkNode A))
!(findDiscKnob (mkKnobMapper (mkDiscMap (ConsMMap ((mkDiskSpec 1) (mkDiscKnob Uu)) NilMMap))) (mkNode A))
!(bestPossibleBscore 0)
!(worstPossibleBscore 0)

!(get-type (mkXmplr (AND A B) (mkDemeId 0) (mkCscore 0) (mkBscore (Cons 0 (Cons 1 Nil)))))
!(get-type (createDeme (mkXmplr (AND A B) (mkDemeId 0) (mkCscore 0) (mkBscore (Cons 0 (Cons 1 Nil)))) 0))
!(get-type (buildLogical (mkXmplr (AND A B) (mkDemeId 0) (mkCscore 0) (mkBscore (Cons 0 (Cons 1 Nil)))) (mkSubtree (AND A B)) (mkNode A)))
!(get-type (addLogicalKnobs (mkXmplr (AND A B) (mkDemeId 0) (mkCscore 0) (mkBscore (Cons 0 (Cons 1 Nil)))) (mkSubtree (AND A B)) (mkNode A) False))
!(get-type (sampleLogicalPerms (mkNode A)))
!(get-type (findDiscKnob (mkKnobMapper (mkDiscMap (ConsMMap ((mkDiskSpec 1) (mkDiscKnob Uu)) NilMMap))) (mkNode A)))

(: Arity Type)
(: mkArity (-> Number Arity))

(: CompleteTruthTable Type)
(: mkCompleteTruthTable (-> (Table Bool) Arity CompleteTruthTable))

(: CompositeScore Type)
(: mkCscore (-> ScoreT ComplexityPenalty UniformityPenalty CompositeScore))

(: ComplexityPenality Type)
(: mkComplexityPenality (-> Number ComplexityPenalty))

(: UniformityPenalty Type)
(: mkUniformityPenalty (-> Number UniformityPenalty))

(: ScoreT Type)
(: mkScoreT (-> Number ScoreT))

;; metapopulation --  ordered set containing scored trees
;; represented here as set of scored trees -- sTSet
(: Set (-> $a Type))
(: NilSet (Set $a))
(: ConsSet (-> $a (Set $a) (Set $a)))

(: MetaPop (Set (Xmplr $a))) ;; metapopulation
(: mkMetaPop (-> (Xmplr $a) (Set (Xmplr $a)) (Set (Xmplr $a))))

;; exemplar selection
(: selectExmplr (-> (Set (Xmplr $a)) (Xmplr $a)))

(: mkRnd (-> Number))
(: rultSelect (-> (-> Number) (Set (Xmplr $a)) (Xmplr $a)))
