%% Generated from /home/karanos/meTTa-moses/metta-moses/representation/logical-probe.metta at 2025-06-27T10:49:07+03:00
:- style_check(-discontiguous).
:- style_check(-singleton).
:- include(library(metta_lang/metta_transpiled_header)).
:- set_prolog_flag(pfc_term_expansion,true).

%  ;;;;;;;;;; Logical Probe ;;;;;;;;;;;
%  ;; logicalProbe builds LSKs by processing the sampleLogicalPerms 
%  ;; Params:
%  ;;      $exemplar: Reference tree containing the target node.
%  ;;      (mkNodeId $targetId): ID of the target node in the exemplar.
%  ;;      $perms: Tuple of trees
%  ;;      $addIfInExemplar: If true, include knobs even if in exemplar.
%  ;;      $knobs: the list of knobs at each iteration, () at the start
%  ;; Return: a tuple containing a tuple of LSKs and the final updated tree
%  ;; a helper to logicalProbe
%  ;; Param:
%  ;;   $perms: a tuple of Expressions (output of sampleLogicalPerms) 
%  ;; Return: a tuple of Trees
%  ;; logicalProbe
%% Finished generating /home/karanos/meTTa-moses/metta-moses/representation/logical-probe.metta at 2025-06-27T10:49:07+03:00

:- normal_IO.
:- initialization(transpiled_main, program).
