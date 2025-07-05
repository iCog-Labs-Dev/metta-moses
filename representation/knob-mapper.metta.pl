%% Generated from /home/karanos/meTTa-moses/metta-moses/representation/knob-mapper.metta at 2025-06-27T10:49:04+03:00
:- style_check(-discontiguous).
:- style_check(-singleton).
:- include(library(metta_lang/metta_transpiled_header)).
:- set_prolog_flag(pfc_term_expansion,true).

%  ;; Knob Mapper
%  ;; Finds all knobs associated with a given node id and returns them as a list.
%  ;; the MultiMap is used to store the association between node ids and a tuple of disc specification and knob.
%  ;; TODO: Give specific type for key and value
%% Finished generating /home/karanos/meTTa-moses/metta-moses/representation/knob-mapper.metta at 2025-06-27T10:49:04+03:00

:- normal_IO.
:- initialization(transpiled_main, program).
