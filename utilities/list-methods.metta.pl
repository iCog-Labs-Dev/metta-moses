%% Generated from /home/karanos/meTTa-moses/metta-moses/utilities/list-methods.metta at 2025-07-06T01:07:11+03:00
:- style_check(-discontiguous).
:- style_check(-singleton).
:- include(library(metta_lang/metta_transpiled_header)).
:- set_prolog_flag(pfc_term_expansion,true).

%  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%  ;; Definition of a List data structure with various methods for it. ;;
%  ;; Fold a tuple from left to right
%  ;; Fold a tuple from right to left
%  ;; Define List.sum
%  ;; Get an element by index from a list
%  ;; Insert an element to a presumably sorted list, remains sorted.
%  ;; A function that converts a list to an expression
%  ; (: List.toExpr (->(List $a) Expression)
%  ;; A function that converts an expression to a list
%  ; (: List.fromExpr (-> Expression (List $a)))
%  ;;Test for List.fromExpr
%  ;; Sort a List in ascending order
%  ;; helper function to find the length of the list
%  ;; Map a function over a list
%  ;; Filter a list based on a predicate.
%  ;; Convert a list to an expression.
%  ;; defining List.max function with a comparator that compares non-numerical type values
%  ;; Overloading the above List.max with the built in >= comparison operator for operation on List of numbers
%  ;; Checks if an element is member of a list
%  ; Replaces an element at a specific index with another element
%  ;; List.prepend .. adds an element at the beginnig of a list
%  ;; Find an element in a list
%  ;; Params: 
%  ;;  $list: The list to search
%  ;;  $target: The element to find
%  ;; Returns: 
%  ;;  The index of the first found element or
%  ;;  -1 If the element can't be found
%  ;; Return the first element from a list
%  ;; Params:
%  ;;  $list: The list to return from
%  ;; Returns:
%  ;;  The first element of the list
%  ;; Return the list without its first element
%  ;;  The rest of the list
%  ;; Subtract list element wise
%  ;; Temporary flatten function that works only for list of 
%  ;;  lists where the second list has only single elements.
%  ;; Concatenates two lists into a single list, preserving element order.
%  ;;   $list1: First list to concatenate.
%  ;;   $list2: Second list to concatenate.
%  ;;   (List $a) - New list containing all elements of $list1 followed by $list2.
%  ;; Removes the element at the specified index from the list.
%  ;;   $list: Input list.
%  ;;   $idx: Non-negative index of element to remove (0-based).
%  ;;   (List $a) - New list with element at $idx removed, or original list if $idx is invalid.
%  ;; Checks if an element exists in a list.
%  ;;   $elem: Element to search for.
%  ;;   $list: Input list to search in.
%  ;;   Bool - True if $elem is found in $list, False otherwise.
%  ;; List.partialSort -- sorts the top n values in a list and leaves the rest unsorted      
%  ;; Overloading the above partialSort for partial Sorting list of numbers -- decreasing order
%  ;; append a list to a list
%  ;; deletes the first occurence of an item in the list
%  ;; List.takeN -- takes the first N members of a list 
%  ;; List.takeNFrom -- takes N members starting from given start position position 
%  ;; Returns True if any element in the list is True, otherwise False.
%  ;; Generates a list of a given length containing a specified number repeated. 
%% Finished generating /home/karanos/meTTa-moses/metta-moses/utilities/list-methods.metta at 2025-07-06T01:07:12+03:00

:- normal_IO.
:- initialization(transpiled_main, program).
