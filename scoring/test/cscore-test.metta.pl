%% Generated from /home/karanos/meTTa-moses/metta-moses/scoring/test/cscore-test.metta at 2025-07-06T01:07:09+03:00
:- style_check(-discontiguous).
:- style_check(-singleton).
:- include(library(metta_lang/metta_transpiled_header)).
:- set_prolog_flag(pfc_term_expansion,true).



<span class="pl-atom">top_call_5</span>:- <span class="pl-compound pl-level-0"><span class="pl-functor">do_metta_runtime</span>(<span class="pl-args"><span class="pl-var">ExecRes</span>, (<span class="pl-compound"><span class="pl-atom">true</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span></span>)</span>)</span>.




top_call :-
    time(top_call_5).




<span class="pl-atom">top_call_6</span>:- <span class="pl-compound pl-level-0"><span class="pl-functor">eval_H</span>(<span class="pl-args"><span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'import!'</span>|<span class="pl-ellipsis">...</span></span>]</span>, <span class="pl-var">ExecRes</span></span>)</span>.




top_call :-
    time(top_call_6).




<span class="pl-atom">top_call_7</span>:- <span class="pl-compound pl-level-0"><span class="pl-functor">eval_H</span>(<span class="pl-args"><span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'import!'</span>|<span class="pl-ellipsis">...</span></span>]</span>, <span class="pl-var">ExecRes</span></span>)</span>.




top_call :-
    time(top_call_7).




<span class="pl-atom">top_call_9</span>:- <span class="pl-compound pl-level-0"><span class="pl-functor">eval_H</span>(<span class="pl-args"><span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'import!'</span>|<span class="pl-ellipsis">...</span></span>]</span>, <span class="pl-var">ExecRes</span></span>)</span>.




top_call :-
    time(top_call_9).




<span class="pl-atom">top_call_10</span>:- <span class="pl-compound pl-level-0"><span class="pl-functor">eval_H</span>(<span class="pl-args"><span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'import!'</span>|<span class="pl-ellipsis">...</span></span>]</span>, <span class="pl-var">ExecRes</span></span>)</span>.




top_call :-
    time(top_call_10).




<span class="pl-atom">top_call_12</span>:- <span class="pl-compound pl-level-0"><span class="pl-functor">eval_H</span>(<span class="pl-args"><span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'import!'</span>|<span class="pl-ellipsis">...</span></span>]</span>, <span class="pl-var">ExecRes</span></span>)</span>.




top_call :-
    time(top_call_12).




<span class="pl-atom">top_call_13</span>:- <span class="pl-compound pl-level-0"><span class="pl-functor">eval_H</span>(<span class="pl-args"><span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'import!'</span>|<span class="pl-ellipsis">...</span></span>]</span>, <span class="pl-var">ExecRes</span></span>)</span>.




top_call :-
    time(top_call_13).




<span class="pl-atom">top_call_14</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                             <span class="pl-compound pl-level-0"><span class="pl-atom">true</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span></span></span>).




top_call :-
    time(top_call_14).


%  ;; Tests for cScoreToExpr


<span class="pl-atom">top_call_15</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_1</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">cScoreToExpr</span>, 
                                                       [ <span class="pl-atom">mkCscore</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>]], 
                                                     [ [ 0.0,0.0,0.0,0.0,0.0]]]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_1</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_1</span>, 
                                                   <span class="pl-var">_FARL_2</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_1</span>, 
                                                         <span class="pl-compound pl-level-0"><span class="pl-atom">true</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span></span></span>, 
                                                         <span class="pl-var">_FARL_1</span>)),
                                                      (<span class="pl-compound pl-level-0"><span class="pl-functor">findall_ne</span>(<span class="pl-args"><span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-ellipsis">...</span>|<span class="pl-ellipsis">...</span></span>]</span></span>]</span>, <span class="pl-atom">true</span>, <span class="pl-var">_FARL_2</span></span>)</span>)  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_1</span>, <span class="pl-var">_FARL_2</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_15).




<span class="pl-atom">top_call_16</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_2</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">cScoreToExpr</span>, 
                                                       [ <span class="pl-atom">mkCscore</span>, <span class="pl-float">1.0</span>, <span class="pl-float">2.0</span>, <span class="pl-float">0.5</span>, <span class="pl-float">0.5</span>, <span class="pl-float">0.0</span>]], 
                                                     [ [ 1.0,2.0,0.5,0.5,0.0]]]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_2</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_3</span>, 
                                                   <span class="pl-var">_FARL_4</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_3</span>, 
                                                         <span class="pl-compound pl-level-0"><span class="pl-atom">true</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span></span></span>, 
                                                         <span class="pl-var">_FARL_3</span>)),
                                                      (<span class="pl-compound pl-level-0"><span class="pl-functor">findall_ne</span>(<span class="pl-args"><span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-ellipsis">...</span>|<span class="pl-ellipsis">...</span></span>]</span></span>]</span>, <span class="pl-atom">true</span>, <span class="pl-var">_FARL_4</span></span>)</span>)  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_3</span>, <span class="pl-var">_FARL_4</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_16).




<span class="pl-atom">top_call_17</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_3</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">cScoreToExpr</span>, 
                                                       [ <span class="pl-atom">mkCscore</span>, <span class="pl-float">-1.0</span>, <span class="pl-float">3.0</span>, <span class="pl-float">0.2</span>, <span class="pl-float">0.4</span>, <span class="pl-float">-0.8</span>]], 
                                                     [ [ -1.0,3.0 ,0.2 ,0.4 ,-0.8]]]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_3</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_5</span>, 
                                                   <span class="pl-var">_FARL_6</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_5</span>, 
                                                         <span class="pl-compound pl-level-0"><span class="pl-atom">true</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span></span></span>, 
                                                         <span class="pl-var">_FARL_5</span>)),
                                                      (<span class="pl-compound pl-level-0"><span class="pl-functor">findall_ne</span>(<span class="pl-args"><span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-ellipsis">...</span>|<span class="pl-ellipsis">...</span></span>]</span></span>]</span>, <span class="pl-atom">true</span>, <span class="pl-var">_FARL_6</span></span>)</span>)  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_5</span>, <span class="pl-var">_FARL_6</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_17).


%  ; ;; Test cases for updatePenalizedScore


<span class="pl-atom">top_call_18</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_4</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">updatePenalizedScore</span>, 
                                                       [ <span class="pl-atom">mkCscore</span>, <span class="pl-int">0</span>, <span class="pl-int">2</span>, <span class="pl-float">0.3</span>, <span class="pl-float">0.5</span>, 
                                                         [ <span class="pl-atom">*</span>, 
                                                           <span class="pl-int">-1</span>, 
                                                           <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'pow-math'</span>, <span class="pl-int">10</span>|<span class="pl-ellipsis">...</span></span>]</span>]], 
                                                       <span class="pl-atom">'False'</span>], 
                                                     [ <span class="pl-atom">mkCscore</span>, <span class="pl-int">0</span>, <span class="pl-int">2</span>, <span class="pl-float">0.3</span>, <span class="pl-float">0.5</span>, <span class="pl-float">-0.8</span>]]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_4</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_7</span>, 
                                                   <span class="pl-var">_FARL_8</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_7</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'pow-math'</span>, <span class="pl-int">10</span>, <span class="pl-int">308</span>, <span class="pl-var">A</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">mi</span>(<span class="pl-args"><span class="pl-atom">*</span>, <span class="pl-int">-1</span>, <span class="pl-var">A</span>, <span class="pl-var">B</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkCscore</span>, <span class="pl-int">0</span>, <span class="pl-int">2</span>, <span class="pl-float">0.3</span>, <span class="pl-float">0.5</span>, <span class="pl-var">B</span>, <span class="pl-var">C</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">updatePenalizedScore</span>, <span class="pl-var">C</span>, <span class="pl-atom">'False'</span>, <span class="pl-var">_FA_7</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_7</span>)),
                                                      (<span class="pl-compound pl-level-0"><span class="pl-functor">findall_ne</span>(<span class="pl-args"><span class="pl-var">_FA_8</span>, (<span class="pl-compound"><span class="pl-atom">true</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span></span>), <span class="pl-var">_FARL_8</span></span>)</span>)  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_7</span>, <span class="pl-var">_FARL_8</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_18).




<span class="pl-atom">top_call_19</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_5</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">updatePenalizedScore</span>, 
                                                       [ <span class="pl-atom">mkCscore</span>, <span class="pl-int">-1</span>, <span class="pl-int">3</span>, <span class="pl-float">0.2</span>, <span class="pl-float">0.4</span>, 
                                                         [ <span class="pl-atom">*</span>, 
                                                           <span class="pl-int">-1</span>, 
                                                           <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'pow-math'</span>, <span class="pl-int">10</span>|<span class="pl-ellipsis">...</span></span>]</span>]], 
                                                       <span class="pl-atom">'True'</span>], 
                                                     [ <span class="pl-atom">mkCscore</span>, <span class="pl-int">-1</span>, <span class="pl-int">3</span>, <span class="pl-float">0.2</span>, <span class="pl-float">0.4</span>, <span class="pl-float">-0.48</span>]]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_5</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_9</span>, 
                                                   <span class="pl-var">_FARL_10</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_9</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'pow-math'</span>, <span class="pl-int">10</span>, <span class="pl-int">308</span>, <span class="pl-var">A</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">mi</span>(<span class="pl-args"><span class="pl-atom">*</span>, <span class="pl-int">-1</span>, <span class="pl-var">A</span>, <span class="pl-var">B</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkCscore</span>, <span class="pl-int">-1</span>, <span class="pl-int">3</span>, <span class="pl-float">0.2</span>, <span class="pl-float">0.4</span>, <span class="pl-var">B</span>, <span class="pl-var">C</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">updatePenalizedScore</span>, <span class="pl-var">C</span>, <span class="pl-atom">'True'</span>, <span class="pl-var">_FA_9</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_9</span>)),
                                                      (<span class="pl-compound pl-level-0"><span class="pl-functor">findall_ne</span>(<span class="pl-args"><span class="pl-var">_FA_10</span>, (<span class="pl-compound"><span class="pl-atom">true</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span></span>), <span class="pl-var">_FARL_10</span></span>)</span>)  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_9</span>, <span class="pl-var">_FARL_10</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_19).




<span class="pl-atom">top_call_20</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_6</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">updatePenalizedScore</span>, 
                                                       [ <span class="pl-atom">mkCscore</span>, <span class="pl-int">0</span>, <span class="pl-int">5</span>, <span class="pl-float">0.1</span>, <span class="pl-float">0.9</span>, 
                                                         [ <span class="pl-atom">*</span>, 
                                                           <span class="pl-int">-1</span>, 
                                                           <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'pow-math'</span>, <span class="pl-int">10</span>|<span class="pl-ellipsis">...</span></span>]</span>]], 
                                                       <span class="pl-atom">'False'</span>], 
                                                     [ <span class="pl-atom">mkCscore</span>, <span class="pl-int">0</span>, <span class="pl-int">5</span>, <span class="pl-float">0.1</span>, <span class="pl-float">0.9</span>, <span class="pl-float">-1.0</span>]]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_6</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_11</span>, 
                                                   <span class="pl-var">_FARL_12</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_11</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'pow-math'</span>, <span class="pl-int">10</span>, <span class="pl-int">308</span>, <span class="pl-var">A</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">mi</span>(<span class="pl-args"><span class="pl-atom">*</span>, <span class="pl-int">-1</span>, <span class="pl-var">A</span>, <span class="pl-var">B</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkCscore</span>, <span class="pl-int">0</span>, <span class="pl-int">5</span>, <span class="pl-float">0.1</span>, <span class="pl-float">0.9</span>, <span class="pl-var">B</span>, <span class="pl-var">C</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">updatePenalizedScore</span>, <span class="pl-var">C</span>, <span class="pl-atom">'False'</span>, <span class="pl-var">_FA_11</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_11</span>)),
                                                      (<span class="pl-compound pl-level-0"><span class="pl-functor">findall_ne</span>(<span class="pl-args"><span class="pl-var">_FA_12</span>, (<span class="pl-compound"><span class="pl-atom">true</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span></span>), <span class="pl-var">_FARL_12</span></span>)</span>)  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_11</span>, <span class="pl-var">_FARL_12</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_20).




<span class="pl-atom">top_call_21</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_7</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">updatePenalizedScore</span>, 
                                                       [ <span class="pl-atom">mkCscore</span>, <span class="pl-int">-3</span>, <span class="pl-int">1</span>, <span class="pl-float">0.7</span>, <span class="pl-float">1.0</span>, 
                                                         [ <span class="pl-atom">*</span>, 
                                                           <span class="pl-int">-1</span>, 
                                                           <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'pow-math'</span>, <span class="pl-int">10</span>|<span class="pl-ellipsis">...</span></span>]</span>]], 
                                                       <span class="pl-atom">'False'</span>], 
                                                     [ <span class="pl-atom">mkCscore</span>, <span class="pl-int">-3</span>, <span class="pl-int">1</span>, <span class="pl-float">0.7</span>, <span class="pl-float">1.0</span>, <span class="pl-float">-4.7</span>]]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_7</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_13</span>, 
                                                   <span class="pl-var">_FARL_14</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_13</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'pow-math'</span>, <span class="pl-int">10</span>, <span class="pl-int">308</span>, <span class="pl-var">A</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">mi</span>(<span class="pl-args"><span class="pl-atom">*</span>, <span class="pl-int">-1</span>, <span class="pl-var">A</span>, <span class="pl-var">B</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkCscore</span>, <span class="pl-int">-3</span>, <span class="pl-int">1</span>, <span class="pl-float">0.7</span>, <span class="pl-float">1.0</span>, <span class="pl-var">B</span>, <span class="pl-var">C</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">updatePenalizedScore</span>, <span class="pl-var">C</span>, <span class="pl-atom">'False'</span>, <span class="pl-var">_FA_13</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_13</span>)),
                                                      (<span class="pl-compound pl-level-0"><span class="pl-functor">findall_ne</span>(<span class="pl-args"><span class="pl-var">_FA_14</span>, (<span class="pl-compound"><span class="pl-atom">true</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span></span>), <span class="pl-var">_FARL_14</span></span>)</span>)  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_13</span>, <span class="pl-var">_FARL_14</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_21).




<span class="pl-atom">top_call_22</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                             ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-atom">'True'</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">A</span></span>)</span>  ,
                                               <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-atom">'False'</span>, <span class="pl-var">A</span>, <span class="pl-var">B</span></span>)</span> , 
                                               <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-atom">'True'</span>, <span class="pl-var">B</span>, <span class="pl-var">C</span></span>)</span> , 
                                               <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-atom">'True'</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">D</span></span>)</span> , 
                                               <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-atom">'True'</span>, <span class="pl-var">D</span>, <span class="pl-var">E</span></span>)</span> , 
                                               <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-atom">'True'</span>, <span class="pl-var">E</span>, <span class="pl-var">F</span></span>)</span> , 
                                               <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-var">F</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">G</span></span>)</span> , 
                                               <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-var">C</span>, <span class="pl-var">G</span>, <span class="pl-var">H</span></span>)</span> , 
                                               <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-atom">'O'</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">I</span></span>)</span> , 
                                               <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-atom">'B'</span>, <span class="pl-var">I</span>, <span class="pl-var">J</span></span>)</span> , 
                                               <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-atom">'A'</span>, <span class="pl-var">J</span>, <span class="pl-var">K</span></span>)</span> , 
                                               <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkITable</span>, <span class="pl-var">H</span>, <span class="pl-var">K</span>, <span class="pl-var">L</span></span>)</span> , 
                                               <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'bind!'</span>, <span class="pl-atom">ttable1</span>, <span class="pl-var">L</span>, <span class="pl-var">ExecRes</span></span>)</span>)).




top_call :-
    time(top_call_22).


==>arg_type_n('Cons',2,1,var).


<span class="pl-atom">top_call_23</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                             ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-atom">'True'</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">A</span></span>)</span>  ,
                                               <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-atom">'True'</span>, <span class="pl-var">A</span>, <span class="pl-var">B</span></span>)</span> , 
                                               <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-atom">'True'</span>, <span class="pl-var">B</span>, <span class="pl-var">C</span></span>)</span> , 
                                               <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-atom">'False'</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">D</span></span>)</span> , 
                                               <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-atom">'False'</span>, <span class="pl-var">D</span>, <span class="pl-var">E</span></span>)</span> , 
                                               <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-atom">'True'</span>, <span class="pl-var">E</span>, <span class="pl-var">F</span></span>)</span> , 
                                               <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-atom">'False'</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">G</span></span>)</span> , 
                                               <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-atom">'True'</span>, <span class="pl-var">G</span>, <span class="pl-var">H</span></span>)</span> , 
                                               <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-atom">'False'</span>, <span class="pl-var">H</span>, <span class="pl-var">I</span></span>)</span> , 
                                               <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-atom">'False'</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">J</span></span>)</span> , 
                                               <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-atom">'False'</span>, <span class="pl-var">J</span>, <span class="pl-var">K</span></span>)</span> , 
                                               <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-atom">'False'</span>, <span class="pl-var">K</span>, <span class="pl-var">L</span></span>)</span> , 
                                               <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-var">L</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">M</span></span>)</span> , 
                                               <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-var">I</span>, <span class="pl-var">M</span>, <span class="pl-var">N</span></span>)</span> , 
                                               <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-var">F</span>, <span class="pl-var">N</span>, <span class="pl-var">O</span></span>)</span> , 
                                               <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-var">C</span>, <span class="pl-var">O</span>, <span class="pl-var">P</span></span>)</span> , 
                                               <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-atom">'Output'</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">Q</span></span>)</span> , 
                                               <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-atom">'B'</span>, <span class="pl-var">Q</span>, <span class="pl-var">R</span></span>)</span> , 
                                               <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-atom">'A'</span>, <span class="pl-var">R</span>, <span class="pl-var">S</span></span>)</span> , 
                                               <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkITable</span>, <span class="pl-var">P</span>, <span class="pl-var">S</span>, <span class="pl-var">T</span></span>)</span> , 
                                               <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'bind!'</span>, <span class="pl-atom">ttable2</span>, <span class="pl-var">T</span>, <span class="pl-var">ExecRes</span></span>)</span>)).




top_call :-
    time(top_call_23).




<span class="pl-atom">top_call_24</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_8</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">getCscore</span>, 
                                                       <span class="pl-atom">ttable1</span>, 
                                                       [ <span class="pl-atom">buildTree</span>, 
                                                         <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'AND'</span>, <span class="pl-atom">'A'</span>|<span class="pl-ellipsis">...</span></span>]</span>], 
                                                       <span class="pl-float">2.0</span>], 
                                                     [ <span class="pl-atom">mkCscore</span>, <span class="pl-int">-1</span>, <span class="pl-int">2</span>, <span class="pl-int">1</span>, <span class="pl-int">0</span>, <span class="pl-int">-2</span>]]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_8</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_15</span>, 
                                                   <span class="pl-var">_FARL_16</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_15</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'AND'</span>, <span class="pl-atom">'A'</span>, <span class="pl-atom">'B'</span>, <span class="pl-var">A</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">buildTree</span>, <span class="pl-var">A</span>, <span class="pl-var">B</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">getCscore</span>, <span class="pl-atom">ttable1</span>, <span class="pl-var">B</span>, <span class="pl-float">2.0</span>, <span class="pl-var">_FA_15</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_15</span>)),
                                                      (<span class="pl-compound pl-level-0"><span class="pl-functor">findall_ne</span>(<span class="pl-args"><span class="pl-var">_FA_16</span>, (<span class="pl-compound"><span class="pl-atom">true</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span></span>), <span class="pl-var">_FARL_16</span></span>)</span>)  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_15</span>, <span class="pl-var">_FARL_16</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_24).


==>arg_type_n(buildTree,1,1,var).
==>arg_type_n(==,2,1,var).
==>arg_type_n(==,2,2,var).
==>arg_type_n(mkNode,1,1,var).
==>arg_type_n(map,2,2,var).
==>arg_type_n(isUnit,1,1,non_eval('Atom')).
==>arg_type_n(replaceVarsWithTruth,2,1,non_eval([['List','Symbol'],'Expression'])).
==>arg_type_n('List.foldl',3,2,var).
==>arg_type_n(replaceVarWithTruth,2,2,var).
==>arg_type_n(compareAndScore,2,1,var).
==>arg_type_n(compareAndScore,2,2,var).
==>arg_type_n('if-error',3,1,non_eval('Atom')).
==>arg_type_n('if-error',3,2,non_eval('Atom')).
==>arg_type_n('if-error',3,3,non_eval('Atom')).
==>arg_type_n('List.foldr',3,2,var).
==>arg_type_n(isMember,2,1,var).
==>arg_type_n(isMember,2,2,var).


<span class="pl-atom">top_call_25</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_9</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">getCscore</span>, 
                                                       <span class="pl-atom">ttable1</span>, 
                                                       [ <span class="pl-atom">buildTree</span>, 
                                                         <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'OR'</span>, <span class="pl-atom">'A'</span>|<span class="pl-ellipsis">...</span></span>]</span>], 
                                                       <span class="pl-int">4</span>], 
                                                     [ <span class="pl-atom">mkCscore</span>, <span class="pl-int">0</span>, <span class="pl-int">2</span>, <span class="pl-float">0.5</span>, <span class="pl-int">0</span>, <span class="pl-float">-0.5</span>]]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_9</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_17</span>, 
                                                   <span class="pl-var">_FARL_18</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_17</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'OR'</span>, <span class="pl-atom">'A'</span>, <span class="pl-atom">'B'</span>, <span class="pl-var">A</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">buildTree</span>, <span class="pl-var">A</span>, <span class="pl-var">B</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">getCscore</span>, <span class="pl-atom">ttable1</span>, <span class="pl-var">B</span>, <span class="pl-int">4</span>, <span class="pl-var">_FA_17</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_17</span>)),
                                                      (<span class="pl-compound pl-level-0"><span class="pl-functor">findall_ne</span>(<span class="pl-args"><span class="pl-var">_FA_18</span>, (<span class="pl-compound"><span class="pl-atom">true</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span></span>), <span class="pl-var">_FARL_18</span></span>)</span>)  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_17</span>, <span class="pl-var">_FARL_18</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_25).




<span class="pl-atom">top_call_26</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_10</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">getCscore</span>, 
                                                       <span class="pl-atom">ttable2</span>, 
                                                       [ <span class="pl-atom">buildTree</span>, 
                                                         <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'AND'</span>, <span class="pl-atom">'A'</span>|<span class="pl-ellipsis">...</span></span>]</span>], 
                                                       <span class="pl-float">2.0</span>], 
                                                     [ <span class="pl-atom">mkCscore</span>, <span class="pl-int">0</span>, <span class="pl-int">2</span>, <span class="pl-float">1.0</span>, <span class="pl-int">0</span>, <span class="pl-float">-1.0</span>]]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_10</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_19</span>, 
                                                   <span class="pl-var">_FARL_20</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_19</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'AND'</span>, <span class="pl-atom">'A'</span>, <span class="pl-atom">'B'</span>, <span class="pl-var">A</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">buildTree</span>, <span class="pl-var">A</span>, <span class="pl-var">B</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">getCscore</span>, <span class="pl-atom">ttable2</span>, <span class="pl-var">B</span>, <span class="pl-float">2.0</span>, <span class="pl-var">_FA_19</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_19</span>)),
                                                      (<span class="pl-compound pl-level-0"><span class="pl-functor">findall_ne</span>(<span class="pl-args"><span class="pl-var">_FA_20</span>, (<span class="pl-compound"><span class="pl-atom">true</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span></span>), <span class="pl-var">_FARL_20</span></span>)</span>)  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_19</span>, <span class="pl-var">_FARL_20</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_26).




<span class="pl-atom">top_call_27</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_11</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">getCscore</span>, 
                                                       <span class="pl-atom">ttable2</span>, 
                                                       [ <span class="pl-atom">buildTree</span>, 
                                                         <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'OR'</span>, <span class="pl-atom">'A'</span>|<span class="pl-ellipsis">...</span></span>]</span>], 
                                                       <span class="pl-int">1</span>], 
                                                     [ <span class="pl-atom">mkCscore</span>, <span class="pl-int">-2</span>, <span class="pl-int">2</span>, <span class="pl-float">2.0</span>, <span class="pl-int">0</span>, <span class="pl-float">-4.0</span>]]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_11</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_21</span>, 
                                                   <span class="pl-var">_FARL_22</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_21</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'OR'</span>, <span class="pl-atom">'A'</span>, <span class="pl-atom">'B'</span>, <span class="pl-var">A</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">buildTree</span>, <span class="pl-var">A</span>, <span class="pl-var">B</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">getCscore</span>, <span class="pl-atom">ttable2</span>, <span class="pl-var">B</span>, <span class="pl-int">1</span>, <span class="pl-var">_FA_21</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_21</span>)),
                                                      (<span class="pl-compound pl-level-0"><span class="pl-functor">findall_ne</span>(<span class="pl-args"><span class="pl-var">_FA_22</span>, (<span class="pl-compound"><span class="pl-atom">true</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span></span>), <span class="pl-var">_FARL_22</span></span>)</span>)  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_21</span>, <span class="pl-var">_FARL_22</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_27).


%  ;; Test cases -- getComplexityCoef


<span class="pl-atom">top_call_28</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_12</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">getComplexityCoef</span>, <span class="pl-float">0.0</span></span>]</span>, 
                                                     <span class="pl-float">0.0</span>]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_12</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_23</span>, 
                                                   <span class="pl-var">_FARL_24</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-compound pl-level-0"><span class="pl-functor">findall_ne</span>(<span class="pl-args"><span class="pl-var">_FA_23</span>, (<span class="pl-compound"><span class="pl-atom">true</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span></span>), <span class="pl-var">_FARL_23</span></span>)</span>),
                                                      (<span class="pl-compound pl-level-0"><span class="pl-functor">findall_ne</span>(<span class="pl-args"><span class="pl-float">0.0</span>, <span class="pl-atom">true</span>, <span class="pl-var">_FARL_24</span></span>)</span>)  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_23</span>, <span class="pl-var">_FARL_24</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_28).




<span class="pl-atom">top_call_29</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_13</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">getComplexityCoef</span>, <span class="pl-float">2.0</span></span>]</span>, 
                                                     <span class="pl-float">0.5</span>]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_13</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_25</span>, 
                                                   <span class="pl-var">_FARL_26</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-compound pl-level-0"><span class="pl-functor">findall_ne</span>(<span class="pl-args"><span class="pl-var">_FA_25</span>, (<span class="pl-compound"><span class="pl-atom">true</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span></span>), <span class="pl-var">_FARL_25</span></span>)</span>),
                                                      (<span class="pl-compound pl-level-0"><span class="pl-functor">findall_ne</span>(<span class="pl-args"><span class="pl-float">0.5</span>, <span class="pl-atom">true</span>, <span class="pl-var">_FARL_26</span></span>)</span>)  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_25</span>, <span class="pl-var">_FARL_26</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_29).




<span class="pl-atom">top_call_30</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_14</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">getComplexityCoef</span>, <span class="pl-int">4</span></span>]</span>, 
                                                     <span class="pl-float">0.25</span>]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_14</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_27</span>, 
                                                   <span class="pl-var">_FARL_28</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-compound pl-level-0"><span class="pl-functor">findall_ne</span>(<span class="pl-args"><span class="pl-var">_FA_27</span>, (<span class="pl-compound"><span class="pl-atom">true</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span></span>), <span class="pl-var">_FARL_27</span></span>)</span>),
                                                      (<span class="pl-compound pl-level-0"><span class="pl-functor">findall_ne</span>(<span class="pl-args"><span class="pl-float">0.25</span>, <span class="pl-atom">true</span>, <span class="pl-var">_FARL_28</span></span>)</span>)  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_27</span>, <span class="pl-var">_FARL_28</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_30).


%  ;; Test cases -- composite score less than comparator


<span class="pl-atom">top_call_31</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_15</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">'cScore&lt;'</span>, 
                                                       [ <span class="pl-atom">mkCscore</span>, <span class="pl-float">-0.1</span>, <span class="pl-int">2</span>, <span class="pl-float">0.1</span>, <span class="pl-float">0.1</span>, <span class="pl-float">-0.3</span>], 
                                                       [ <span class="pl-atom">mkCscore</span>, <span class="pl-float">-0.2</span>, <span class="pl-int">3</span>, <span class="pl-float">0.1</span>, <span class="pl-float">0.1</span>, <span class="pl-float">-0.4</span>]], 
                                                     <span class="pl-atom">'False'</span>]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_15</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_29</span>, 
                                                   <span class="pl-var">_FARL_30</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_29</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkCscore</span>, <span class="pl-float">-0.1</span>, <span class="pl-int">2</span>, <span class="pl-float">0.1</span>, <span class="pl-float">0.1</span>, <span class="pl-float">-0.3</span>, <span class="pl-var">A</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkCscore</span>, <span class="pl-float">-0.2</span>, <span class="pl-int">3</span>, <span class="pl-float">0.1</span>, <span class="pl-float">0.1</span>, <span class="pl-float">-0.4</span>, <span class="pl-var">B</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'cScore&lt;'</span>, <span class="pl-var">A</span>, <span class="pl-var">B</span>, <span class="pl-var">_FA_29</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_29</span>)),
                                                      (<span class="pl-compound pl-level-0"><span class="pl-functor">findall_ne</span>(<span class="pl-args"><span class="pl-var">_FA_30</span>, (<span class="pl-compound"><span class="pl-atom">true</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span></span>), <span class="pl-var">_FARL_30</span></span>)</span>)  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_29</span>, <span class="pl-var">_FARL_30</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_31).


