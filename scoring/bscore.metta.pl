%% Generated from /home/karanos/meTTa-moses/metta-moses/scoring/bscore.metta at 2025-07-06T01:07:12+03:00
:- style_check(-discontiguous).
:- style_check(-singleton).
:- include(library(metta_lang/metta_transpiled_header)).
:- set_prolog_flag(pfc_term_expansion,true).

%  ;; Type definitions and functions related to beahvioral socre, behavioral complexity score and turth table behavioral score.
%  ;; Behavioral score is a list of numbers, where each number represents the score of a particular output. 
%  ;; For boolean expressions, the score is either 0 or -1. Therefore, this behavioral score is a list of 0s and -1s.
%  ;; In the C++ version, floating point scores and numbers different than -1 and 0 are used as a result of table compression 
%  ;;  and weighting options. However, we don't have that yet.
%  ;; Subtrace two behavioral scores
%  ;; Sums the behavioral score to get a single number.
%  ;; Input table with rows, columns and labels of the columns
%  ;; An Input Table is just a list of lists.
%  ;; TruthTableBScore is a type that contains the complexity coefficient, size of the table and the input table itself.
%  ;; Using this type we can get behavioral score and behavioral complexity score.
%  ;; This table is the cTruthTableBScore in the C++. The C stands for compressed. But omitted here since the table won't be compressed during this version.
%  ;;  It is left as future work.
%  ;; A constuctor for truthTableBScore to assign the size of the table on it's own.
%  ;; INFO: This could have been done by overloading the mkTruthTableBScore function, but
%  ;;  that has shown to be problematic for certain cases. Best to avoid it whenever we can.
%  ;; Return the table from truth table bscore
%  ;; Function to give a behavioral score for a given tree.
%  ;; It takes the Input table and the tree then scores the input table on each row. After which it builds the behavioral score.
%  ;;
%  ;; Params: $table - Input table
%  ;;         $labels - Column labels
%  ;;         $tree - The tree to be scored
%  ;; Returns: Beahvioral score for the given tree.
%  ;; Return the best possible BehavioralScore given the size of the table.
%  ;;  Altohugh the whole table is given for consistency and to distinguish 
%  ;;  from the same function that works on BehavioralCScore, it uses only the size of the table.
%  ;; Return the worst possible BehavioralScore given the size of the table.
%  ;; When we have a compressed tree, the min improvement 
%  ;;  will be calculated. For now it's fixed.
%  ;; Score tree helepr function that compares two values and returns a number instead of a bool.
%  ;; It returns 0 if the values are equal, -1 they're not equal.
%  ;; A wrapper function to return the complexity a tree.
%  ;; Replace every occurence of a lable inside an expression with a truth value.
%  ;; Params: $boolExpr - The expression to be modified
%  ;;         $b - The truth value to replace with
%  ;;         $l - The variable to be replaced
%  ;; Returns: Modified version of the boolean expression.
%  ;; Replace ever occurence of all labels (boolean variables) 
%  ;;  inside an expression with their corresponding truth values.
%  ;;         $lList - list of variables to be replaced
%  ;;         $bList - list of the corresponding truth values to replace the variables with
%  ;; Behavioral complexity score. Although this type adds no additional atttributes to the truth table bscore,
%  ;;  It is used to distinguish between the two types. The behavioral complexity score is treated differently than the latter one.
%  ;;  Instead of a list of scores in the BehavioralScore this type deals with a single score values.
%  ;; Return the best possible Behavioral composite score given the table. 
%  ;;  Although the whole table is given for consistency and to distinguish 
%  ;;  from the same function that works on BehavioralScore, it only needs the size of the table.
%  ;; Return the worst possible Behavioral composite score given the table.
%  ;;  Although the whole table is given for consistency and to distinguish
%  ;; When we have a compressed tree, the min improvement
%% Finished generating /home/karanos/meTTa-moses/metta-moses/scoring/bscore.metta at 2025-07-06T01:07:12+03:00

:- normal_IO.
:- initialization(transpiled_main, program).
