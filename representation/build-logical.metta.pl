%% Generated from /home/karanos/meTTa-moses/metta-moses/representation/build-logical.metta at 2025-06-27T10:49:07+03:00
:- style_check(-discontiguous).
:- style_check(-singleton).
:- include(library(metta_lang/metta_transpiled_header)).
:- set_prolog_flag(pfc_term_expansion,true).

%  ;; siblingit => Itreate over list of Tree childrens and build logical knobs for each node
%  ;;params:
%  ;;       $tree: The tree being updated
%  ;;       $childrens: List of children to iterate over.
%  ;;       $parentId: ID of the parent node.
%  ;;       $childNum: Current child number.
%  ;;       $swapedOp: Swapped operator symbol.
%  ;;       $MMap: Multimap to store disc_pec and knobs.
%  ;; Return: Updated tree and multimap.
%  ;; buildLogical => Build logical knobs for a given NodeId and its children
%  ;;       $nodeId: ID of the node to build logical knobs for.
%% Finished generating /home/karanos/meTTa-moses/metta-moses/representation/build-logical.metta at 2025-06-27T10:49:08+03:00

:- normal_IO.
:- initialization(transpiled_main, program).
