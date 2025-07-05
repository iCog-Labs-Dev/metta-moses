%% Generated from /home/karanos/meTTa-moses/metta-moses/representation/sample-logical-perms.metta at 2025-06-27T10:49:08+03:00
:- style_check(-discontiguous).
:- style_check(-singleton).
:- include(library(metta_lang/metta_transpiled_header)).
:- set_prolog_flag(pfc_term_expansion,true).

%  ;; sampled arguments (inputs)


<span class="pl-atom">top_call_14</span>:- <span class="pl-compound pl-level-0"><span class="pl-functor">do_metta_runtime</span>(<span class="pl-args"><span class="pl-var">ExecRes</span>, (<span class="pl-compound"><span class="pl-atom">true</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-ellipsis">...</span><span class="pl-infix">,</span><span class="pl-ellipsis">...</span></span></span>)</span>)</span>.




top_call :-
    time(top_call_14).


%  ;; A function to generate all pairs of numbers from a list, where a != b
%  ;; getArgs -> generate logical expressions from the list of pairs
%  ;; Parameters:
%  ;;          $swapedOp -> swaped operator
%  ;;          $PermPairs -> list of pairs of idx permutations
%  ;;          $picked -> list of picked idxs
%  ;; sampleLogicalPerms -> generate logical permutations for boolean expressions
%  ;;          $op -> the operator passed from the iterator 
%  ;;          $arity -> the number of arguments in the logical expression
%  ;; Returns:
%  ;;          Union of $perms (the list of logical expressions generated) with args
%  ; (= (sampleLogicalPerms $op $arity) (sampleLogicalPerms $op $arity ()))
%% Finished generating /home/karanos/meTTa-moses/metta-moses/representation/sample-logical-perms.metta at 2025-06-27T10:49:08+03:00

:- normal_IO.
:- initialization(transpiled_main, program).
