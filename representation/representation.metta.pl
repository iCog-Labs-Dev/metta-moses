%% Generated from /home/karanos/meTTa-moses/metta-moses/representation/representation.metta at 2025-06-27T10:49:05+03:00
:- style_check(-discontiguous).
:- style_check(-singleton).
:- include(library(metta_lang/metta_transpiled_header)).
:- set_prolog_flag(pfc_term_expansion,true).

%  ;; helper function to representation
%  ;; Converts DiscMap (multimap of knobSpec & knob) to DiscKnobMap (map of location & index)
%  ;; Params: DiscMap
%  ;; Returns: DiscKnobMap
%  ;; representation constructor
%  ;; Params: Tree (Exemplar)
%  ;; Returns: Representation
%  ;; (trace! (Done converting instance to tree $candidate) $candidate))))
%  ;; Assumes the reverseLookupTable's order never changes during this call.
%% Finished generating /home/karanos/meTTa-moses/metta-moses/representation/representation.metta at 2025-06-27T10:49:05+03:00

:- normal_IO.
:- initialization(transpiled_main, program).
