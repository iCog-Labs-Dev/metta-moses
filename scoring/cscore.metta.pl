%% Generated from /home/karanos/meTTa-moses/metta-moses/scoring/cscore.metta at 2025-07-06T01:07:12+03:00
:- style_check(-discontiguous).
:- style_check(-singleton).
:- include(library(metta_lang/metta_transpiled_header)).
:- set_prolog_flag(pfc_term_expansion,true).

%  ;; The probability parameter p in the scoring represents the assumed probability that the model makes an error on any given data point.
%  ;; If p is small (close to 0), it means the model is expected to be very accurate, making mistakes rarely.
%  ;; If p is large (approaching 0.5), it means the model is expected to be less accurate, making mistakes more often (but still better than random guessing).
%  ;; getComplexityCoef -- calcualtes the complexity coeffient of a tree   
%  ;; takes complexity ratio as input and returns complexity coefficient
%  ;; complexity ratio, unless set by the user, has 3.5 for a default value
%  ;; updatePenalizedScore            
%  ;; by default the worst possible score is set as the penalized score for a tree
%  ;; there is a bool multiply_diversity parameter if set to true the penalized score has to be multiplied with the uniform penalty
%  ;; if not the uniformity penalty is instead subtracted
%  ;; the default thing is to set the parameter to False
%  ;converts a score to an expression
%  ; (: cScoreToExpr (-> Cscore Expression))
%  ; (: exprToCScore (-> Expression Cscore))
%  ;; worstCscore
%  ;; score getters
%  ;; comparing composite scores
%  ;; cScore< -- composite score less than operator
%  ;; uses penalized scores to compare and complexity score to break ties in the penalized score
%  ;; $cs1 -- composite score of the left side instance ..
%  ;; $cs2 -- composite score of the right side instance or whatever
%  ;; the type-cast in the if .. is used because the return type of the built-in isnan-math function is not Bool so it has to be cast in to bool value
%  ;; cScoreExpr< -- composite score less than operator for expressions
%  ;; works directly with expressions using index-atom to extract scores
%  ;; index 4 = penalized score, index 1 = complexity score
%  ;; Check for equality, to within floating-point error, EPSILON
%  ;; Simple test calls for cScoreExpr<
%  ; !(cScoreExpr< (cScoreToExpr (mkCscore 100.0 5.0 10.0 2.0 88.0)) (cScoreToExpr (mkCscore 95.0 3.0 6.0 1.0 88.0)))
%  ; !(cScoreExpr< (90.0 7.0 14.0 3.0 73.0) (95.0 3.0 6.0 1.0 88.0))
%  ; !(cScoreToExpr (mkCscore 100.0 5.0 10.0 2.0 88.0))
%% Finished generating /home/karanos/meTTa-moses/metta-moses/scoring/cscore.metta at 2025-07-06T01:07:13+03:00

:- normal_IO.
:- initialization(transpiled_main, program).
