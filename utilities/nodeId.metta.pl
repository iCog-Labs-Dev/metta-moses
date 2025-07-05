%% Generated from /home/karanos/meTTa-moses/metta-moses/utilities/nodeId.metta at 2025-06-27T10:49:11+03:00
:- style_check(-discontiguous).
:- style_check(-singleton).
:- include(library(metta_lang/metta_transpiled_header)).
:- set_prolog_flag(pfc_term_expansion,true).

%  ;;;;;;;;;;;;;;;;;;; ID System ;;;;;;;;;;;;;;;;;;;;
%  ;; Uses indices to identify nodes in a tree. 
%  ;; Example: (AND A (OR B C))
%  ;; AND : (0)
%  ;; A : (1) or (0 1)
%  ;; (OR B C) : (2) or (0 2)
%  ;; B : (2 1)
%  ;; C : (2 2)
%  ;; Finds a subtree at a specific level in the tree.
%  ;; Params:
%  ;;   $tree: - The input tree (mkTree, mkNullVex, or Nil).
%  ;;   $levelId: - index indicating the level (0 for root, 1 for first child, etc.).
%  ;; Returns:
%  ;;   (Tree $a) - The subtree at the specified level, or Nil if out of bounds.
%  ;; Traverses a tree to find a node by its ID path.
%  ;; Parameters:
%  ;;   $id: - A mkNodeId-wrapped tuple of indices (e.g., (mkNodeId (2 1))) representing the path.
%  ;;   (Tree $a) - The subtree at the specified ID path, or an error if invalid.
%% Finished generating /home/karanos/meTTa-moses/metta-moses/utilities/nodeId.metta at 2025-06-27T10:49:12+03:00

:- normal_IO.
:- initialization(transpiled_main, program).
