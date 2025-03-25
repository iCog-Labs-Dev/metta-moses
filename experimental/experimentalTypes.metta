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
