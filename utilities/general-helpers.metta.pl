%% Generated from /home/karanos/meTTa-moses/metta-moses/utilities/general-helpers.metta at 2025-07-06T01:07:10+03:00
:- style_check(-discontiguous).
:- style_check(-singleton).
:- include(library(metta_lang/metta_transpiled_header)).
:- set_prolog_flag(pfc_term_expansion,true).

%  ;; Helper functions that are going to be useful for writing any metta code
%  ;; INFO: Uncomment for the use of MeTTaLog.
%  ;; (: >= (-> Number Number Bool))
%  ;; (= (>= $a $b) (or (== $a $b) (> $a $b)))
%  ;Function to cocatinate two tuples (A B) (C D) ==> (A B C D)
%  ;; (: concatTuple (-> Expression Expression Expression))
%  ;; FIX: No longer working on version 0.2.3
%  ; a helper function to the isConsistentExp function.
%  ; a function which simplifies nested logical negations by reducing them to their simplest form. 
%  ; a function which checks if an element is member of a tuple.
%  ; This function assumes it receives a set1 and set2 expression as parameters.
%  ; It then removes similar elements found in set2 that already exist in set1.
%  ; The function uses isMember from general helpers functions.
%  ;; A helper function for the findAndReplace function.
%  ;; It handles the replacement of a single atom.
%  ;; A function to replace a specific atom
%  ;;    with a new one from a list of atoms.
%  ;; INFO: This function needs to change so that it can preserve the
%  ;;        operator's position when MeTTa version is upgraded.
%  ;; A function that behaves like a do while loop.
%  ;; It executes the functions in the given list and returns the last result.
%  ;; A foldleft function like the implementation in Haskell.
%  ;; It takes a binary function that expects two atoms and
%  ;;    apply it recursively on a nested atom.
%  ;; Fold a tuple from right to left
%  ;; Apply a given function to every element of a tuple
%  ;; Function: wrapper
%  ;; Description: This function applies a predicate to an atom and returns the atom if the predicate is true, otherwise returns an empty expression.
%  ;; Parameters:
%  ;;   - $predicate: A function that takes an atom and returns a boolean value.
%  ;;   - $x: The atom to which the predicate is applied.
%  ;; Returns:
%  ;;   - Expression: Returns the atom if the predicate evaluates to true, otherwise returns an empty expression.
%  ;; Filter function given a predicate ;; FIX: No longer working on version 0.2.3
%  ;; INFO: Uncommnet the following two functions when using MeTTaLog.
%  ;; (:wrapperB (-> (-> $a $b Bool) $a $b $b))
%  ;; A function to remove all elements found in $common from a $tuple
%  ;; A function to remove only one elements from a tuple
%  ; ;; A function that returns True if any of the input atoms are True and False otherwise
%  ; ;; Example: input ==> (True True False), output ==> True
%  ; ;;          input ==> (False False False), output ==> False
%  ; ;;          input ==> (False True False), output ==> True
%  ;; A trick to define `curry` in MeTTa without `lambda`
%  ;; A trick to define `curry2` in MeTTa without `lambda`
%  ; ;; Add numbers in an atom list
%  ;; Function to count atom occrence in a list of atoms.
%  ;; A function to check if a given atom is symbol.
%  ;; A function to check if a given atom is expression.
%  ;; A function to check if a given atom is unit or empty tuple.
%  ;; A function to check if a given atom is an expression 
%  ;;   with has one atom in it.
%  ;; Function to replace a given atom from a space ;; FIX: No longer working on version 0.2.3
%  ;; Function to replace a given atom from a space. ;; FIX: No longer working on version 0.2.3
%  ;; Return the maximum of two numbers.
%  ;; A function to return a tuple of numbers from natural to a given number.
%  ;; $x is the upperbound
%  ;; $acc is the lowerbound wrapped with as a tuple.
%  ;;    Example: (gen 5 (0)) => (5 4 3 2 1 0) ;; FIX: No longer working on version 0.2.3
%  ; ;; A function to return head and tail of an atom in a tuple.
%  ;; Function to create a tuple of tuples given two equal length list of atoms. ;; FIX: No longer working on version 0.2.3
%  ;; Similar to zip but instead of just creating a tuple of atoms,
%  ;;  it performes an operation of $f on them and returns the resulting list of atoms.
%  ;; Finds length of a tuple ;; FIX: No longer working on version 0.2.3
%  ;; A function to replace an atom at a specific index position with $val -- 0 indexed counting is implied
%  ;; Select atom by index and returns
%  ;; TODO: Use zipWith instead
%  ;; A function that compares tuples element by element.
%  ;; Function to empty a space with contents.
%  ;; Function that merges two sorted lists while keeping them sorted.
%  ;; A function to split a list in to two at an index so that everything
%  ;;    until that index without including that index as first tuple and 
%  ;;    the rest as the second.
%  ;; Merge sort function. Takes length to gain 
%  ;;  performance by avoiding recomputation of index.
%  ;; function to partially sort the smallest $n Atoms from an expression
%  ;; Helper function that compare two Atoms based on $op and return the one
%  ;; Helper function that select one atom from the $expr based on the comparation function $op
%  ;; A function to take an atom and repeat it n times.
%  ;; A function to remove the frist n elements of a tuple 
%  ;;   and returns the rest.
%  ;; non-deterministic definitio of length
%  ;; isLiteral -- determines if the given atom is a literal or not
%  ;; minOfTuple -- minimum of tuple of numeric expressions
%  ;; unNest -- extracts elements from nested expressions 
%  ;; flatten -- returns one tuple from a nested tuple of tuple of tuples ...
%  ; ;; maxOfTuple -- finds maximum of tuple of numbers
%  ; ; (= (maxOfTuple $expr)
%  ; ;     (let*
%  ; ;         (
%  ; ;             ($f (car-atom $expr))
%  ; ;             ($t (cdr-atom $expr)))
%  ; ;         (if (== $t ())
%  ; ;             $f
%  ; ;             (max $f (maxOfTuple $t)))))
%  ;; Add numbers in an atom list
%  ; (= (sum $list) (foldr + 0 $list))
%  ; (= (sum $list)
%  ;     (if (== $list ())
%  ;         0
%  ;         (let*
%  ;             (
%  ;                 ($f (car-atom $list))
%  ;                 ($t (cdr-atom $list))
%  ;             )
%  ;             (if (== $t ())
%  ;                 $f
%  ;                 (+ $f (sum $t)) ))))
%  ; (= (getmaxWithKey $tuple)
%  ;     (let $max 
%  ;         (collapse 
%  ;             (let*
%  ;                 (
%  ;                     ($t (superpose $tuple))
%  ;                     ($maxKey (let $keys (collapse (let $el (superpose $tuple) (car-atom $el))) (maxOfTuple $keys)))
%  ;                     ; (() (println! (maxxx $maxKey)))
%  ;                 ) 
%  ;                 (unify $t ($maxKey $genId $iId $i) ($maxKey $genId $iId $i) (empty))))
%  ;         (car-atom $max)))
%  ;; map` -- a modified map functinality with, i.e., a map that takes a function which has two inputs
%  ;; notNt -- check if a symbol is not a member of the non-terminal set
%  ;; isValidExp -- to check if the boolean expression produced by genPhen is a valid bolean expression
%  ;;          $exp -- an expression which is being checked for validity
%  ;;          $parent -- an expression against which the check is being made -- set of non-terminals in this case.
%  ;; This function adds list to space
%  ;; a function that checks that all of the expressions are true.
%  ;; Name:                        ===
%  ;; Description:                 A helper function to evaluate equality of two expressions ignoring ordering of litral children.
%  ;;                              The grounded equality operator, ==, will return `False` when comparing (AND A B) and (AND B A)
%  ;;                              === returns `True`.
%  ;;                              Used when looking for the POA in the parent's list of children.
%  ;; Number compartor
%  ;; an equal to or grearter than comparator that is resopnsible for deconstructing numerical values from the type constructor and compare them 
%  ;; ($ctor $x) ($ctor $y) -- (constructor value) pair                
%  ;; List.Sum for any (List $a) $a of (typeConstructor Number) type
%  ; ;; overloading the above function to work with list of numbers
%  ; (: List.sum (-> (List $a) $a))
%  ; (= (List.sum $list) (List.sum + $list))
%  ;; A function to take any two types which have the same constructor and add them.
%  ;;   params: ($ctor $a): The first argument with a constructor $ctor
%  ;;           ($ctor $b): The second argument with the same constructor as the first
%  ;;   returns: Sum of the types if they both contain numbers
%  ;;            An error if they can't be added together
%  ;; wrapping the built-in ininf-math with custom function because the return type is not bool, it is number
%  ;; using the type-cast function
%  ;; A trick to define composition function.
%  ;; Takes a function and returns another function
%  ;; applying the two functions in sequence.
%  ;; Convert an expression to a list   e.g (A B C) -> (Cons A (Cons B (Cons C Nil)))
%  ;; From a tuple (Pair) return the first element
%  ;; From a tuple (Pair) return the second element
%  ;; Converts a tuple of pairs into ordered multimap
%  ;; Ex: ((k1 v1) (k2 v2)) -> (ConsMMap (k1 v1) (ConsMMap (k2 v2) NilMMap))
%  ;; A trick function to make chain reduce when using union-atom
%  ;; helper function to generate list of numbers ranging from 0 to n
%  ;; swap AND , OR 
%  ;; approximate equality -- takes the relative magnitude of the numbers into consideration


<span class="pl-atom">top_call_8</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                            <span class="pl-compound pl-level-0"><span class="pl-atom">true</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span></span></span>).




top_call :-
    time(top_call_8).


%% Finished generating /home/karanos/meTTa-moses/metta-moses/utilities/general-helpers.metta at 2025-07-06T01:07:11+03:00

:- normal_IO.
:- initialization(transpiled_main, program).
