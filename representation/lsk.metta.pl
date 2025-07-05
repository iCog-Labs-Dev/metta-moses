%% Generated from /home/karanos/meTTa-moses/metta-moses/representation/lsk.metta at 2025-06-27T10:49:03+03:00
:- style_check(-discontiguous).
:- style_check(-singleton).
:- include(library(metta_lang/metta_transpiled_header)).
:- set_prolog_flag(pfc_term_expansion,true).

%  ;;;;;;;;;;;;;;;;; LSK Constructor ;;;;;;;;;;;;;;;;;;;;;;;;
%  ;; Creates a Logical Subtree Knob (LSK) for a given tree, target node, and subtree.
%  ;; Params:
%  ;;  $tree: The tree structure where the logical subtree knob will be applied.
%  ;;  $target: The parent node to which the LSK's place holder (null vertex) 
%  ;;           will be added is pointed by the target node.
%  ;;  $subtree: The subtree to be appended.
%  ;; Returns:
%  ;;  A LogicalSubtreeKnob (LSK) configured based on the subtree's presence or its appended state.
%  ;; Retrieves the node ID from a Logical Subtree Knob (LSK).
%  ;; Retrieves the current and default disc specifications from an LSK.
%  ;; Retrieves the subtree associated with a Logical Subtree Knob (LSK).
%  ;; Appends a subtree or a null vertex in place of a logical subtree 
%  ;;  using information from the LSK and a knob setting specified.
%  ;;  $lsk: The logical subtree knob containing information on how the subtree is appended to the original tree.
%  ;;  $tree: An incomplete tree. It will be built using the tree with knobs as a
%  ;;            reference and it may also contain knobs if $d is 0
%  ;;  $parentId: The location where the new node will be added.
%  ;;  $d: The current setting of the knob.
%  ;; INFO: Just incase if the append fails and stores the result somewhere else, we need to add a test case here to cmpare between targetNode and appendChild node.
%% Finished generating /home/karanos/meTTa-moses/metta-moses/representation/lsk.metta at 2025-06-27T10:49:04+03:00

:- normal_IO.
:- initialization(transpiled_main, program).
