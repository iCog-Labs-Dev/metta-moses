%% Generated from /home/karanos/meTTa-moses/metta-moses/utilities/tree.metta at 2025-07-06T01:07:09+03:00
:- style_check(-discontiguous).
:- style_check(-singleton).
:- include(library(metta_lang/metta_transpiled_header)).
:- set_prolog_flag(pfc_term_expansion,true).

%  ;; TODO: Remove when REDUCE is implemented.
%  ;; (buildTree $reduced)))
%  ;; Get an id of a certain node. And (0) if the root node.
%  ;; Example:
%  ;;    Id of A in the (AND (OR (AND A B))) => (1 1 1)
%  ;;    Id of (AND A B) in the (AND (OR (AND A B))) => (1 1)
%  ;; Params:
%  ;;   $tree: The full tree to search
%  ;;   $targetTree: The target tree to find the ID of.
%  ;; Returns:
%  ;;   NodeId: The id of the targetTree if found.
%  ;; Helper function for the getNodeId function.
%  ;;   The function's sole purpose is to make the
%  ;;   getNodeById compatible for the foldr function call.
%  ;; Finds the NodeId of a subtree within the children of a target node.
%  ;;   $tree: - The full tree to search.
%  ;;   $targetId: - ID of the target node.
%  ;;   $subtree: - The subtree to locate among the target node's children.
%  ;;   $iter: - index to check children, increments recursively.
%  ;;   NodeId - The NodeId of the Subtree
%  ;; Retrieves the children list of a node identified by its NodeId.
%  ;;   $id: - ID of the target node.
%  ;;   (List (Tree $a)) - The list of children of the target node.
%  ;; Creates a new tree with a node inserted above the given tree as its parent.
%  ;;   $tree: - The original tree to be placed as a child.
%  ;;   $node: - The new node to become the root, wrapping $tree.
%  ;;   (Tree $a) - A new mkTree with $node as the root and $tree as its only child.
%  ;; Replaces a subtree at a specific NodeId with a new subtree.
%  ;;   $tree: - The tree to modify.
%  ;;   $id: - ID of the node to be replace.
%  ;;   $newSubtree: - The new subtree to insert.
%  ;;   (Tree $a) - The updated tree with $newSubtree at $id.
%  ;; Appends a child to a target node's children and returns the updated tree and child's NodeId.
%  ;; Parameters:
%  ;;   $target: - ID of the target node
%  ;;   $child: - The new child to append.
%  ;;   ((Tree $a) NodeId) - Tuple of updated tree and NodeId of the new child.
%  ;; getChildrenByIdx -- retrieve children of a tree using index values
%  ;; check if tree is empty
%  ;; check if tree is null vertex 
%  ;; Takes a tree and decides if the node is an argument or not.
%  ;; An argument is anything that's not an operator or a null vertex.
%  ;; A function to calculate the complexity of a tree.
%  ;;  The complexity of a tree is the number of arguments it contains.
%  ;;  That means, ANDs, ORs and NOTs have no complexity. 
%  ;; Knobs, or null vetices aren't included in the complexity calculatio.
%  ;; NOTE: for future use -- a function to determine the alphabet size of a given tree for computation of complexity ratio
%  ;; takes a truth table and adds 3 (for AND,. OR and NOT) to the number of input labels
%% Finished generating /home/karanos/meTTa-moses/metta-moses/utilities/tree.metta at 2025-07-06T01:07:09+03:00

:- normal_IO.
:- initialization(transpiled_main, program).
