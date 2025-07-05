%% Generated from /home/karanos/meTTa-moses/metta-moses/representation/instance.metta at 2025-07-06T00:45:18+03:00
:- style_check(-discontiguous).
:- style_check(-singleton).
:- include(library(metta_lang/metta_transpiled_header)).
:- set_prolog_flag(pfc_term_expansion,true).

%  ;; Types, constructors and functions related to instance.
%  ;; An instance is just a vector of numbers
%  ;; A scored instance is just a pair of instance and it's score.
%  ;; An instance set is a list of scored instances.
%  ;; --- Conversion helpers ---
%  ;; --- Fast selectionSort implementation with conversion ---
%  ;; --- Optimized comparator for selectionSort ---
%  ;; This comparator sorts in DESCENDING order (best scores first)
%  ;; extracts the score of a scored instance object
%  ;; extracts the instance from a scored instance object
%  ;; Scored Instance comparator --> instance>=
%% Finished generating /home/karanos/meTTa-moses/metta-moses/representation/instance.metta at 2025-07-06T00:45:18+03:00

:- normal_IO.
:- initialization(transpiled_main, program).
