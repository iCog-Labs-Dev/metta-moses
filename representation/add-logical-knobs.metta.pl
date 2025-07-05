%% Generated from /home/karanos/meTTa-moses/metta-moses/representation/add-logical-knobs.metta at 2025-06-27T10:49:09+03:00
:- style_check(-discontiguous).
:- style_check(-singleton).
:- include(library(metta_lang/metta_transpiled_header)).
:- set_prolog_flag(pfc_term_expansion,true).

%  ;;;;;;;; addLogicalKnobs ;;;;;;;;;
%  ;; Creates and adds logical subtree knobs in to a multimap
%  ;; Params:
%  ;;   $exemplar: Reference tree containing the target node.
%  ;;   (mkNodeId $targetId): ID of the target node in the exemplar.
%  ;;   $addIfInExemplar: If true, include knobs even if in exemplar.
%  ;;   $map: a multimap to add the new knobs into
%  ;; Return: a multimap of ($knobSpec $knob) and the updated tree
%  ;; helper function to the addLogicalKnobs
%  ;; takes a tuple of knobs and return a tuple of knob and knobSpec pairs
%  ;; addLogicalKnobs
%% Finished generating /home/karanos/meTTa-moses/metta-moses/representation/add-logical-knobs.metta at 2025-06-27T10:49:09+03:00

:- normal_IO.
:- initialization(transpiled_main, program).
