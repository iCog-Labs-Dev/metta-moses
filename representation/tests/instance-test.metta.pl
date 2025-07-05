%% Generated from /home/karanos/meTTa-moses/metta-moses/representation/tests/instance-test.metta at 2025-07-06T00:45:18+03:00
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




<span class="pl-atom">top_call_11</span>:- <span class="pl-compound pl-level-0"><span class="pl-functor">eval_H</span>(<span class="pl-args"><span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'import!'</span>|<span class="pl-ellipsis">...</span></span>]</span>, <span class="pl-var">ExecRes</span></span>)</span>.




top_call :-
    time(top_call_11).


%  ;; --- Tests for conversion helpers ---
%  ;; Test instToExpr and exprToInst


<span class="pl-atom">top_call_12</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_1</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">instToExpr</span>, 
                                                       <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span></span>]</span>], 
                                                     []]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_1</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_1</span>, 
                                                   <span class="pl-var">_FARL_2</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_1</span>, 
                                                         <span class="pl-compound pl-level-0"><span class="pl-atom">true</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span></span></span>, 
                                                         <span class="pl-var">_FARL_1</span>)),
                                                      (<span class="pl-compound pl-level-0"><span class="pl-functor">findall_ne</span>(<span class="pl-args">[], <span class="pl-atom">true</span>, <span class="pl-var">_FARL_2</span></span>)</span>)  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_1</span>, <span class="pl-var">_FARL_2</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_12).




<span class="pl-atom">top_call_13</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_2</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">instToExpr</span>, 
                                                       [ <span class="pl-atom">mkInst</span>, 
                                                         [ <span class="pl-atom">'Cons'</span>, 
                                                           <span class="pl-int">1</span>, 
                                                           [ <span class="pl-atom">'Cons'</span>, 
                                                             <span class="pl-int">2</span>, 
                                                             <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">3</span>|<span class="pl-ellipsis">...</span></span>]</span>]]]], 
                                                     <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-int">1</span>, <span class="pl-int">2</span>|<span class="pl-ellipsis">...</span></span>]</span>]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_2</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_3</span>, 
                                                   <span class="pl-var">_FARL_4</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_3</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">3</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">A</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">2</span>, <span class="pl-var">A</span>, <span class="pl-var">B</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">1</span>, <span class="pl-var">B</span>, <span class="pl-var">C</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-var">C</span>, <span class="pl-var">D</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">instToExpr</span>, <span class="pl-var">D</span>, <span class="pl-var">_FA_3</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_3</span>)),
                                                      (<span class="pl-compound pl-level-0"><span class="pl-functor">findall_ne</span>(<span class="pl-args"><span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-int">1</span>|<span class="pl-ellipsis">...</span></span>]</span>, <span class="pl-atom">true</span>, <span class="pl-var">_FARL_4</span></span>)</span>)  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_3</span>, <span class="pl-var">_FARL_4</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_13).


==>arg_type_n('Cons',2,1,var).


<span class="pl-atom">top_call_14</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_3</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">exprToInst</span>, []</span>]</span>, 
                                                     <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span></span>]</span>]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_3</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_5</span>, 
                                                   <span class="pl-var">_FARL_6</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-compound pl-level-0"><span class="pl-functor">findall_ne</span>(<span class="pl-args"><span class="pl-var">_FA_5</span>, (<span class="pl-compound"><span class="pl-atom">true</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span></span>), <span class="pl-var">_FARL_5</span></span>)</span>),
                                                      (<span class="pl-compound pl-level-0"><span class="pl-functor">findall_ne</span>(<span class="pl-args"><span class="pl-var">_FA_6</span>, (<span class="pl-compound"><span class="pl-atom">true</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span></span>), <span class="pl-var">_FARL_6</span></span>)</span>)  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_5</span>, <span class="pl-var">_FARL_6</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_14).


==>arg_type_n(exprToInst,1,1,non_eval('Expression')).


<span class="pl-atom">top_call_15</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_4</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">exprToInst</span>, 
                                                       <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-int">1</span>, <span class="pl-int">2</span>|<span class="pl-ellipsis">...</span></span>]</span>], 
                                                     [ <span class="pl-atom">mkInst</span>, 
                                                       [ <span class="pl-atom">'Cons'</span>, 
                                                         <span class="pl-int">1</span>, 
                                                         [ <span class="pl-atom">'Cons'</span>, 
                                                           <span class="pl-int">2</span>, 
                                                           <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">3</span>|<span class="pl-ellipsis">...</span></span>]</span>]]]]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_4</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_7</span>, 
                                                   <span class="pl-var">_FARL_8</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_7</span>, 
                                                         <span class="pl-compound pl-level-0"><span class="pl-compound"><span class="pl-functor">info</span>(<span class="pl-args"><span class="pl-compound"><span class="pl-functor">is_non_eval_kind</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span></span>)</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">exprToInst</span>, <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-ellipsis">...</span>|<span class="pl-ellipsis">...</span></span>]</span>, <span class="pl-var">_FA_7</span></span>)</span></span>, 
                                                         <span class="pl-var">_FARL_7</span>)),
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_8</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">3</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">A</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">2</span>, <span class="pl-var">A</span>, <span class="pl-var">B</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">1</span>, <span class="pl-var">B</span>, <span class="pl-var">C</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-var">C</span>, <span class="pl-var">_FA_8</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_8</span>))  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_7</span>, <span class="pl-var">_FARL_8</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_15).


%  ;; Test round-trip conversion for instances


<span class="pl-atom">top_call_16</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_5</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">exprToInst</span>, 
                                                       [ <span class="pl-atom">instToExpr</span>, 
                                                         <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span></span>]</span>]], 
                                                     <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span></span>]</span>]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_5</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_9</span>, 
                                                   <span class="pl-var">_FARL_10</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_9</span>, 
                                                           ((&#13;&#10; 
                                                            (<span class="pl-compound pl-level-0"><span class="pl-functor">info</span>(<span class="pl-args"><span class="pl-compound"><span class="pl-functor">is_non_eval_kind</span>(<span class="pl-args"><span class="pl-atom">exprToInst</span>, <span class="pl-int">1</span>, <span class="pl-atom">'Expression'</span></span>)</span></span>)</span>),
                                                            (<span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">exprToInst</span>, <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">instToExpr</span>|<span class="pl-ellipsis">...</span></span>]</span>, <span class="pl-var">_FA_9</span></span>)</span>)  )), 
                                                         <span class="pl-var">_FARL_9</span>)),
                                                      (<span class="pl-compound pl-level-0"><span class="pl-functor">findall_ne</span>(<span class="pl-args"><span class="pl-var">_FA_10</span>, (<span class="pl-compound"><span class="pl-atom">true</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span></span>), <span class="pl-var">_FARL_10</span></span>)</span>)  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_9</span>, <span class="pl-var">_FARL_10</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_16).




<span class="pl-atom">top_call_17</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_6</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">exprToInst</span>, 
                                                       [ <span class="pl-atom">instToExpr</span>, 
                                                         [ <span class="pl-atom">mkInst</span>, 
                                                           [ <span class="pl-atom">'Cons'</span>, 
                                                             <span class="pl-int">1</span>, 
                                                             <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">2</span>|<span class="pl-ellipsis">...</span></span>]</span>]]]], 
                                                     [ <span class="pl-atom">mkInst</span>, 
                                                       [ <span class="pl-atom">'Cons'</span>, 
                                                         <span class="pl-int">1</span>, 
                                                         <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">2</span>|<span class="pl-ellipsis">...</span></span>]</span>]]]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_6</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_11</span>, 
                                                   <span class="pl-var">_FARL_12</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_11</span>, 
                                                           ((&#13;&#10; 
                                                            (<span class="pl-compound pl-level-0"><span class="pl-functor">info</span>(<span class="pl-args"><span class="pl-compound"><span class="pl-functor">is_non_eval_kind</span>(<span class="pl-args"><span class="pl-atom">exprToInst</span>, <span class="pl-int">1</span>, <span class="pl-atom">'Expression'</span></span>)</span></span>)</span>),
                                                            (<span class="pl-atom">me</span>( <span class="pl-atom">exprToInst</span>, 
                                                               [ <span class="pl-atom">instToExpr</span>, 
                                                                 [ <span class="pl-atom">mkInst</span>, 
                                                                   [ <span class="pl-atom">'Cons'</span>, 
                                                                     <span class="pl-int">1</span>, 
                                                                     <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">2</span>|<span class="pl-ellipsis">...</span></span>]</span>]]], 
                                                               <span class="pl-var">_FA_11</span>))  )), 
                                                         <span class="pl-var">_FARL_11</span>)),
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_12</span>, 
                                                         <span class="pl-compound pl-level-0"><span class="pl-atom">true</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-ellipsis">...</span><span class="pl-infix">,</span><span class="pl-ellipsis">...</span></span></span></span>, 
                                                         <span class="pl-var">_FARL_12</span>))  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_11</span>, <span class="pl-var">_FARL_12</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_17).


%  ;; Test sInstToExpr and exprToSInst


<span class="pl-atom">top_call_18</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_7</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">sInstToExpr</span>, 
                                                       [ <span class="pl-atom">mkSInst</span>, 
                                                         [ <span class="pl-atom">mkPair</span>, 
                                                           <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span></span>]</span>, 
                                                           [ <span class="pl-atom">mkCscore</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>]]]], 
                                                     [ 
                                                     [ 
                                                     [ 
                                                     [ 
                                                     [ 
                                                     [ 
                                                     [ 
                                                     [ 
                                                     [ 
                                                     [ 
                                                     [ 
                                                     [ 
                                                     [ 
                                                     [ 
                                                     [ 
                                                     [ 
                                                     [ 
                                                     [ 
                                                     [ 
                                                     [ 
                                                     [ 
                                                     [ 
                                                     [ 
                                                     [ 
                                                     [ 
                                                     [ 
                                                     [ 
                                                     [ 
                                                     [ 
                                                     [ 
                                                     [ 
                                                     [ 
                                                     [ [], 
                                                       [ <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>]]]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_7</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_13</span>, 
                                                   <span class="pl-var">_FARL_14</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_13</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">A</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkCscore</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-var">B</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkPair</span>, <span class="pl-var">A</span>, <span class="pl-var">B</span>, <span class="pl-var">C</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkSInst</span>, <span class="pl-var">C</span>, <span class="pl-var">D</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">sInstToExpr</span>, <span class="pl-var">D</span>, <span class="pl-var">_FA_13</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_13</span>)),
                                                      (<span class="pl-atom">findall_ne</span>( 
                                                          [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ 
                                                            [], 
                                                            [ <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>]], <span class="pl-atom">true</span>, <span class="pl-var">_FARL_14</span>))  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_13</span>, <span class="pl-var">_FARL_14</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_18).


==>arg_type_n(mkPair,2,1,var).
==>arg_type_n(mkPair,2,2,var).


<span class="pl-atom">top_call_19</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_8</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">sInstToExpr</span>, 
                                                       [ <span class="pl-atom">mkSInst</span>, 
                                                         [ <span class="pl-atom">mkPair</span>, 
                                                           [ <span class="pl-atom">mkInst</span>, 
                                                             [ <span class="pl-atom">'Cons'</span>, 
                                                               <span class="pl-int">1</span>, 
                                                               <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">2</span>|<span class="pl-ellipsis">...</span></span>]</span>]], 
                                                           [ <span class="pl-atom">mkCscore</span>, <span class="pl-float">100.0</span>, <span class="pl-float">5.0</span>, <span class="pl-float">10.0</span>, <span class="pl-float">2.0</span>, <span class="pl-float">88.0</span>]]]], 
                                                     [ [   1  ,  2  ],
                                                       [ 100.0, 5.0 ,10.0 , 2.0 ,88.0 ]]]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_8</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_15</span>, 
                                                   <span class="pl-var">_FARL_16</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_15</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">2</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">A</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">1</span>, <span class="pl-var">A</span>, <span class="pl-var">B</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-var">B</span>, <span class="pl-var">C</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkCscore</span>, <span class="pl-float">100.0</span>, <span class="pl-float">5.0</span>, <span class="pl-float">10.0</span>, <span class="pl-float">2.0</span>, <span class="pl-float">88.0</span>, <span class="pl-var">D</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkPair</span>, <span class="pl-var">C</span>, <span class="pl-var">D</span>, <span class="pl-var">E</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkSInst</span>, <span class="pl-var">E</span>, <span class="pl-var">F</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">sInstToExpr</span>, <span class="pl-var">F</span>, <span class="pl-var">_FA_15</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_15</span>)),
                                                      (<span class="pl-atom">findall_ne</span>( 
                                                          [ [   1  ,  2  ],
                                                            [ 100.0, 5.0 ,10.0 , 2.0 ,88.0 ]], <span class="pl-atom">true</span>, <span class="pl-var">_FARL_16</span>))  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_15</span>, <span class="pl-var">_FARL_16</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_19).


%  ;; Test round-trip conversion for scored instances


<span class="pl-atom">top_call_20</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_9</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">exprToSInst</span>, 
                                                       [ <span class="pl-atom">sInstToExpr</span>, 
                                                         [ <span class="pl-atom">mkSInst</span>, 
                                                           [ <span class="pl-atom">mkPair</span>, 
                                                             <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span></span>]</span>, 
                                                             [ <span class="pl-atom">mkCscore</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>]]]]], 
                                                     [ <span class="pl-atom">mkSInst</span>, 
                                                       [ <span class="pl-atom">mkPair</span>, 
                                                         <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span></span>]</span>, 
                                                         [ <span class="pl-atom">mkCscore</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>]]]]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_9</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_17</span>, 
                                                   <span class="pl-var">_FARL_18</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_17</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">A</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkCscore</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-var">B</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkPair</span>, <span class="pl-var">A</span>, <span class="pl-var">B</span>, <span class="pl-var">C</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkSInst</span>, <span class="pl-var">C</span>, <span class="pl-var">D</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">sInstToExpr</span>, <span class="pl-var">D</span>, <span class="pl-var">E</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">exprToSInst</span>, <span class="pl-var">E</span>, <span class="pl-var">_FA_17</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_17</span>)),
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_18</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">F</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkCscore</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-var">G</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkPair</span>, <span class="pl-var">F</span>, <span class="pl-var">G</span>, <span class="pl-var">H</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkSInst</span>, <span class="pl-var">H</span>, <span class="pl-var">_FA_18</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_18</span>))  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_17</span>, <span class="pl-var">_FARL_18</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_20).




<span class="pl-atom">top_call_21</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_10</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">exprToSInst</span>, 
                                                       [ <span class="pl-atom">sInstToExpr</span>, 
                                                         [ <span class="pl-atom">mkSInst</span>, 
                                                           [ <span class="pl-atom">mkPair</span>, 
                                                             [ <span class="pl-atom">mkInst</span>, 
                                                               [ <span class="pl-atom">'Cons'</span>, 
                                                                 <span class="pl-int">1</span>, 
                                                                 <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">2</span>|<span class="pl-ellipsis">...</span></span>]</span>]], 
                                                             [ <span class="pl-atom">mkCscore</span>, <span class="pl-float">100.0</span>, <span class="pl-float">5.0</span>, <span class="pl-float">10.0</span>, <span class="pl-float">2.0</span>, <span class="pl-float">88.0</span>]]]]], 
                                                     [ <span class="pl-atom">mkSInst</span>, 
                                                       [ <span class="pl-atom">mkPair</span>, 
                                                         [ <span class="pl-atom">mkInst</span>, 
                                                           [ <span class="pl-atom">'Cons'</span>, 
                                                             <span class="pl-int">1</span>, 
                                                             <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">2</span>|<span class="pl-ellipsis">...</span></span>]</span>]], 
                                                         [ <span class="pl-atom">mkCscore</span>, <span class="pl-float">100.0</span>, <span class="pl-float">5.0</span>, <span class="pl-float">10.0</span>, <span class="pl-float">2.0</span>, <span class="pl-float">88.0</span>]]]]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_10</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_19</span>, 
                                                   <span class="pl-var">_FARL_20</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_19</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">2</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">A</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">1</span>, <span class="pl-var">A</span>, <span class="pl-var">B</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-var">B</span>, <span class="pl-var">C</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkCscore</span>, <span class="pl-float">100.0</span>, <span class="pl-float">5.0</span>, <span class="pl-float">10.0</span>, <span class="pl-float">2.0</span>, <span class="pl-float">88.0</span>, <span class="pl-var">D</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkPair</span>, <span class="pl-var">C</span>, <span class="pl-var">D</span>, <span class="pl-var">E</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkSInst</span>, <span class="pl-var">E</span>, <span class="pl-var">F</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">sInstToExpr</span>, <span class="pl-var">F</span>, <span class="pl-var">G</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">exprToSInst</span>, <span class="pl-var">G</span>, <span class="pl-var">_FA_19</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_19</span>)),
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_20</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">2</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">H</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">1</span>, <span class="pl-var">H</span>, <span class="pl-var">I</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-var">I</span>, <span class="pl-var">J</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkCscore</span>, <span class="pl-float">100.0</span>, <span class="pl-float">5.0</span>, <span class="pl-float">10.0</span>, <span class="pl-float">2.0</span>, <span class="pl-float">88.0</span>, <span class="pl-var">K</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkPair</span>, <span class="pl-var">J</span>, <span class="pl-var">K</span>, <span class="pl-var">L</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkSInst</span>, <span class="pl-var">L</span>, <span class="pl-var">_FA_20</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_20</span>))  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_19</span>, <span class="pl-var">_FARL_20</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_21).


%  ;; Test sInstSetToExpr and exprToSInstSet


<span class="pl-atom">top_call_22</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_11</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">sInstSetToExpr</span>, 
                                                       <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">mkSInstSet</span>, <span class="pl-atom">'Nil'</span></span>]</span>], 
                                                     []]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_11</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_21</span>, 
                                                   <span class="pl-var">_FARL_22</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_21</span>, 
                                                         <span class="pl-compound pl-level-0"><span class="pl-atom">true</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span></span></span>, 
                                                         <span class="pl-var">_FARL_21</span>)),
                                                      (<span class="pl-compound pl-level-0"><span class="pl-functor">findall_ne</span>(<span class="pl-args">[], <span class="pl-atom">true</span>, <span class="pl-var">_FARL_22</span></span>)</span>)  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_21</span>, <span class="pl-var">_FARL_22</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_22).




<span class="pl-atom">top_call_23</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_12</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">sInstSetToExpr</span>, 
                                                       [ <span class="pl-atom">mkSInstSet</span>, 
                                                         [ <span class="pl-atom">'Cons'</span>, 
                                                           [ <span class="pl-atom">mkSInst</span>, 
                                                             [ <span class="pl-atom">mkPair</span>, 
                                                               <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span></span>]</span>, 
                                                               [ <span class="pl-atom">mkCscore</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>]]], 
                                                           <span class="pl-atom">'Nil'</span>]]], 
                                                     [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ 
                                                         [], 
                                                         [ <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>]]]]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_12</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_23</span>, 
                                                   <span class="pl-var">_FARL_24</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_23</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">A</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkCscore</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-var">B</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkPair</span>, <span class="pl-var">A</span>, <span class="pl-var">B</span>, <span class="pl-var">C</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkSInst</span>, <span class="pl-var">C</span>, <span class="pl-var">D</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-var">D</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">E</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkSInstSet</span>, <span class="pl-var">E</span>, <span class="pl-var">F</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">sInstSetToExpr</span>, <span class="pl-var">F</span>, <span class="pl-var">_FA_23</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_23</span>)),
                                                      (<span class="pl-atom">findall_ne</span>( 
                                                          [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ 
                                                              [], 
                                                              [ <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>]]], <span class="pl-atom">true</span>, <span class="pl-var">_FARL_24</span>))  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_23</span>, <span class="pl-var">_FARL_24</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_23).




<span class="pl-atom">top_call_24</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_13</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">sInstSetToExpr</span>, 
                                                       [ <span class="pl-atom">mkSInstSet</span>, 
                                                         [ <span class="pl-atom">'Cons'</span>, 
                                                           [ <span class="pl-atom">mkSInst</span>, 
                                                             [ <span class="pl-atom">mkPair</span>, 
                                                               [ <span class="pl-atom">mkInst</span>, 
                                                                 [ <span class="pl-atom">'Cons'</span>, 
                                                                   <span class="pl-int">1</span>, 
                                                                   <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">2</span>|<span class="pl-ellipsis">...</span></span>]</span>]], 
                                                               [ <span class="pl-atom">mkCscore</span>, <span class="pl-float">100.0</span>, <span class="pl-float">5.0</span>, <span class="pl-float">10.0</span>, <span class="pl-float">2.0</span>, <span class="pl-float">88.0</span>]]], 
                                                           <span class="pl-atom">'Nil'</span>]]], 
                                                     [ [ [   1  ,  2  ],
                                                         [ 100.0, 5.0 ,10.0 , 2.0 ,88.0 ]]]]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_13</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_25</span>, 
                                                   <span class="pl-var">_FARL_26</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_25</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">2</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">A</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">1</span>, <span class="pl-var">A</span>, <span class="pl-var">B</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-var">B</span>, <span class="pl-var">C</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkCscore</span>, <span class="pl-float">100.0</span>, <span class="pl-float">5.0</span>, <span class="pl-float">10.0</span>, <span class="pl-float">2.0</span>, <span class="pl-float">88.0</span>, <span class="pl-var">D</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkPair</span>, <span class="pl-var">C</span>, <span class="pl-var">D</span>, <span class="pl-var">E</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkSInst</span>, <span class="pl-var">E</span>, <span class="pl-var">F</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-var">F</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">G</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkSInstSet</span>, <span class="pl-var">G</span>, <span class="pl-var">H</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">sInstSetToExpr</span>, <span class="pl-var">H</span>, <span class="pl-var">_FA_25</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_25</span>)),
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_26</span>, 
                                                           ((&#13;&#10; 
                                                            (<span class="pl-atom">true</span>),
                                                            (<span class="pl-atom">u_assign</span>( <span class="pl-int">13</span>, 
                                                               [ [ [   1  ,  2  ],
                                                                   [ 100.0, 5.0 ,10.0 , 2.0 ,88.0 ]]], 
                                                               <span class="pl-var">_FA_26</span>))  )), 
                                                         <span class="pl-var">_FARL_26</span>))  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_25</span>, <span class="pl-var">_FARL_26</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_24).


%  ;; Test round-trip conversion for instance sets


<span class="pl-atom">top_call_25</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_14</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">exprToSInstSet</span>, 
                                                       [ <span class="pl-atom">sInstSetToExpr</span>, 
                                                         <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">mkSInstSet</span>, <span class="pl-atom">'Nil'</span></span>]</span>]], 
                                                     <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">mkSInstSet</span>, <span class="pl-atom">'Nil'</span></span>]</span>]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_14</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_27</span>, 
                                                   <span class="pl-var">_FARL_28</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_27</span>, 
                                                           ((&#13;&#10; 
                                                            (<span class="pl-compound pl-level-0"><span class="pl-functor">info</span>(<span class="pl-args"><span class="pl-compound"><span class="pl-functor">is_non_eval_kind</span>(<span class="pl-args"><span class="pl-atom">exprToSInstSet</span>, <span class="pl-int">1</span>, <span class="pl-atom">'Expression'</span></span>)</span></span>)</span>),
                                                            (<span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">exprToSInstSet</span>, <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">sInstSetToExpr</span>|<span class="pl-ellipsis">...</span></span>]</span>, <span class="pl-var">_FA_27</span></span>)</span>)  )), 
                                                         <span class="pl-var">_FARL_27</span>)),
                                                      (<span class="pl-compound pl-level-0"><span class="pl-functor">findall_ne</span>(<span class="pl-args"><span class="pl-var">_FA_28</span>, (<span class="pl-compound"><span class="pl-atom">true</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span></span>), <span class="pl-var">_FARL_28</span></span>)</span>)  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_27</span>, <span class="pl-var">_FARL_28</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_25).


==>arg_type_n(exprToSInstSet,1,1,non_eval('Expression')).


<span class="pl-atom">top_call_26</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_15</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">exprToSInstSet</span>, 
                                                       [ <span class="pl-atom">sInstSetToExpr</span>, 
                                                         [ <span class="pl-atom">mkSInstSet</span>, 
                                                           [ <span class="pl-atom">'Cons'</span>, 
                                                             [ <span class="pl-atom">mkSInst</span>, 
                                                               [ <span class="pl-atom">mkPair</span>, 
                                                                 <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span></span>]</span>, 
                                                                 [ <span class="pl-atom">mkCscore</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>]]], 
                                                             <span class="pl-atom">'Nil'</span>]]]], 
                                                     [ <span class="pl-atom">mkSInstSet</span>, 
                                                       [ <span class="pl-atom">'Cons'</span>, 
                                                         [ <span class="pl-atom">mkSInst</span>, 
                                                           [ <span class="pl-atom">mkPair</span>, 
                                                             <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span></span>]</span>, 
                                                             [ <span class="pl-atom">mkCscore</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>]]], 
                                                         <span class="pl-atom">'Nil'</span>]]]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_15</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_29</span>, 
                                                   <span class="pl-var">_FARL_30</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_29</span>, 
                                                           ((&#13;&#10; 
                                                            (<span class="pl-compound pl-level-0"><span class="pl-functor">info</span>(<span class="pl-args"><span class="pl-compound"><span class="pl-functor">is_non_eval_kind</span>(<span class="pl-args"><span class="pl-atom">exprToSInstSet</span>, <span class="pl-int">1</span>, <span class="pl-atom">'Expression'</span></span>)</span></span>)</span>),
                                                            (<span class="pl-atom">me</span>( <span class="pl-atom">exprToSInstSet</span>, 
                                                               [ <span class="pl-atom">sInstSetToExpr</span>, 
                                                                 [ <span class="pl-atom">mkSInstSet</span>, 
                                                                   [ <span class="pl-atom">'Cons'</span>, 
                                                                     [ <span class="pl-atom">mkSInst</span>, 
                                                                       [ <span class="pl-atom">mkPair</span>, 
                                                                         <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span></span>]</span>, 
                                                                         [ <span class="pl-atom">mkCscore</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>]]], 
                                                                     <span class="pl-atom">'Nil'</span>]]], 
                                                               <span class="pl-var">_FA_29</span>))  )), 
                                                         <span class="pl-var">_FARL_29</span>)),
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_30</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">A</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkCscore</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-float">0.0</span>, <span class="pl-var">B</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkPair</span>, <span class="pl-var">A</span>, <span class="pl-var">B</span>, <span class="pl-var">C</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkSInst</span>, <span class="pl-var">C</span>, <span class="pl-var">D</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-var">D</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">E</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkSInstSet</span>, <span class="pl-var">E</span>, <span class="pl-var">_FA_30</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_30</span>))  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_29</span>, <span class="pl-var">_FARL_30</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_26).


%  ;; Test getSInstScore and getInst


<span class="pl-atom">top_call_27</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_16</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">getSInstScore</span>, 
                                                       [ <span class="pl-atom">mkSInst</span>, 
                                                         [ <span class="pl-atom">mkPair</span>, 
                                                           [ <span class="pl-atom">mkInst</span>, 
                                                             <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">1</span>|<span class="pl-ellipsis">...</span></span>]</span>], 
                                                           [ <span class="pl-atom">mkCscore</span>, <span class="pl-float">100.0</span>, <span class="pl-float">5.0</span>, <span class="pl-float">10.0</span>, <span class="pl-float">2.0</span>, <span class="pl-float">88.0</span>]]]], 
                                                     [ <span class="pl-atom">mkCscore</span>, <span class="pl-float">100.0</span>, <span class="pl-float">5.0</span>, <span class="pl-float">10.0</span>, <span class="pl-float">2.0</span>, <span class="pl-float">88.0</span>]]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_16</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_31</span>, 
                                                   <span class="pl-var">_FARL_32</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_31</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">1</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">A</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-var">A</span>, <span class="pl-var">B</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkCscore</span>, <span class="pl-float">100.0</span>, <span class="pl-float">5.0</span>, <span class="pl-float">10.0</span>, <span class="pl-float">2.0</span>, <span class="pl-float">88.0</span>, <span class="pl-var">C</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkPair</span>, <span class="pl-var">B</span>, <span class="pl-var">C</span>, <span class="pl-var">D</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkSInst</span>, <span class="pl-var">D</span>, <span class="pl-var">E</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">getSInstScore</span>, <span class="pl-var">E</span>, <span class="pl-var">_FA_31</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_31</span>)),
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_32</span>, 
                                                         <span class="pl-compound pl-level-0"><span class="pl-atom">true</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkCscore</span>, <span class="pl-float">100.0</span>, <span class="pl-float">5.0</span>, <span class="pl-float">10.0</span>, <span class="pl-float">2.0</span>, <span class="pl-float">88.0</span>, <span class="pl-var">_FA_32</span></span>)</span></span>, 
                                                         <span class="pl-var">_FARL_32</span>))  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_31</span>, <span class="pl-var">_FARL_32</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_27).




<span class="pl-atom">top_call_28</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_17</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">getInst</span>, 
                                                       [ <span class="pl-atom">mkSInst</span>, 
                                                         [ <span class="pl-atom">mkPair</span>, 
                                                           [ <span class="pl-atom">mkInst</span>, 
                                                             [ <span class="pl-atom">'Cons'</span>, 
                                                               <span class="pl-int">1</span>, 
                                                               <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">2</span>|<span class="pl-ellipsis">...</span></span>]</span>]], 
                                                           [ <span class="pl-atom">mkCscore</span>, <span class="pl-float">100.0</span>, <span class="pl-float">5.0</span>, <span class="pl-float">10.0</span>, <span class="pl-float">2.0</span>, <span class="pl-float">88.0</span>]]]], 
                                                     [ <span class="pl-atom">mkInst</span>, 
                                                       [ <span class="pl-atom">'Cons'</span>, 
                                                         <span class="pl-int">1</span>, 
                                                         <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">2</span>|<span class="pl-ellipsis">...</span></span>]</span>]]]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_17</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_33</span>, 
                                                   <span class="pl-var">_FARL_34</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_33</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">2</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">A</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">1</span>, <span class="pl-var">A</span>, <span class="pl-var">B</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-var">B</span>, <span class="pl-var">C</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkCscore</span>, <span class="pl-float">100.0</span>, <span class="pl-float">5.0</span>, <span class="pl-float">10.0</span>, <span class="pl-float">2.0</span>, <span class="pl-float">88.0</span>, <span class="pl-var">D</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkPair</span>, <span class="pl-var">C</span>, <span class="pl-var">D</span>, <span class="pl-var">E</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkSInst</span>, <span class="pl-var">E</span>, <span class="pl-var">F</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">getInst</span>, <span class="pl-var">F</span>, <span class="pl-var">_FA_33</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_33</span>)),
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_34</span>, 
                                                         <span class="pl-compound pl-level-0"><span class="pl-atom">true</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-ellipsis">...</span><span class="pl-infix">,</span><span class="pl-ellipsis">...</span></span></span></span>, 
                                                         <span class="pl-var">_FARL_34</span>))  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_33</span>, <span class="pl-var">_FARL_34</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_28).


%  ;; Test instance>= comparator


<span class="pl-atom">top_call_29</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_18</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">'instance&gt;='</span>, 
                                                       [ <span class="pl-atom">mkSInst</span>, 
                                                         [ <span class="pl-atom">mkPair</span>, 
                                                           <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span></span>]</span>, 
                                                           [ <span class="pl-atom">mkCscore</span>, <span class="pl-float">-2.0</span>, <span class="pl-int">3</span>, <span class="pl-float">1.0</span>, <span class="pl-float">0.5</span>, <span class="pl-float">-3.5</span>]]], 
                                                       [ <span class="pl-atom">mkSInst</span>, 
                                                         [ <span class="pl-atom">mkPair</span>, 
                                                           <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span></span>]</span>, 
                                                           [ <span class="pl-atom">mkCscore</span>, <span class="pl-float">-3.0</span>, <span class="pl-int">2</span>, <span class="pl-float">1.0</span>, <span class="pl-float">0.5</span>, <span class="pl-float">-4.5</span>]]]], 
                                                     <span class="pl-atom">'True'</span>]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_18</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_35</span>, 
                                                   <span class="pl-var">_FARL_36</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_35</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">A</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkCscore</span>, <span class="pl-float">-2.0</span>, <span class="pl-int">3</span>, <span class="pl-float">1.0</span>, <span class="pl-float">0.5</span>, <span class="pl-float">-3.5</span>, <span class="pl-var">B</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkPair</span>, <span class="pl-var">A</span>, <span class="pl-var">B</span>, <span class="pl-var">C</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkSInst</span>, <span class="pl-var">C</span>, <span class="pl-var">D</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">E</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkCscore</span>, <span class="pl-float">-3.0</span>, <span class="pl-int">2</span>, <span class="pl-float">1.0</span>, <span class="pl-float">0.5</span>, <span class="pl-float">-4.5</span>, <span class="pl-var">F</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkPair</span>, <span class="pl-var">E</span>, <span class="pl-var">F</span>, <span class="pl-var">G</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkSInst</span>, <span class="pl-var">G</span>, <span class="pl-var">H</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'instance&gt;='</span>, <span class="pl-var">D</span>, <span class="pl-var">H</span>, <span class="pl-var">_FA_35</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_35</span>)),
                                                      (<span class="pl-compound pl-level-0"><span class="pl-functor">findall_ne</span>(<span class="pl-args"><span class="pl-var">_FA_36</span>, (<span class="pl-compound"><span class="pl-atom">true</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span></span>), <span class="pl-var">_FARL_36</span></span>)</span>)  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_35</span>, <span class="pl-var">_FARL_36</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_29).


