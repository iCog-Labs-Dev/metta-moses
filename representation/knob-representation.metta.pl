%% Generated from /home/karanos/meTTa-moses/metta-moses/representation/knob-representation.metta at 2025-06-27T10:49:06+03:00
:- style_check(-discontiguous).
:- style_check(-singleton).
:- include(library(metta_lang/metta_transpiled_header)).
:- set_prolog_flag(pfc_term_expansion,true).

%  ;;;knob base representation
%  ;      Tree: a tree reference
%  ;      NodeId: a position pointing to current position in the tree
%  ;;; Discrete knob representation
%  ;      Multiplicity: number of possible distinct states/settings a knob can have
%  ;      DiscSpec: Disc specification containing the states
%  ;; Logical subtree knob representation
%  ;Subtree: represents a portion of the tree that will be controlled by the knob
%  ;; Checks if a DiscreteKnob is considered part of the exemplar based on its default specifier.
%  ;; Params:
%  ;;   $discKnob: DiscreteKnob
%  ;; Return: True if the default specifier is non-zero (not in exemplar), False otherwise.
%  ;; Extracts the DiscreteKnob component from a LogicalSubtreeKnob (mkLSK).
%  ;;   $lsk: LogicalSubtreeKnob
%  ;; Return: The extracted DiscKnob
%  ;; Extracts the Tree component from a LogicalSubtreeKnob (mkLSK).
%  ;; Return: The extracted Tree
%  ;; Extracts the multiplicity from a discrete or a logical subtree knob.
%  ;;  $knob: Either discrete or logical subtree knob
%  ;; Returns: The multiplicity of the knob.
%  ;; Calculates the knob Specification of an LSK
%  ;; Extracts the location from a discrete or a logical subtree knob.
%  ;; Returns: The location of the knob.
%  ;; A comparison function for discSpec 
%  ;; (used as a $compFunc to insert knobSpec and knob pairs into a multimap ) 
%  ;; Checks of nodeId1 is lessthan nodeId2.
%  ;; Params: $id1 & $id2
%  ;; Returns: True/False
%% Finished generating /home/karanos/meTTa-moses/metta-moses/representation/knob-representation.metta at 2025-06-27T10:49:07+03:00

:- normal_IO.
:- initialization(transpiled_main, program).
