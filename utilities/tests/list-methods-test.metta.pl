%% Generated from /home/karanos/meTTa-moses/metta-moses/utilities/tests/list-methods-test.metta at 2025-06-27T10:53:26+03:00
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




<span class="pl-atom">top_call_7</span>:- <span class="pl-atom">eval_H</span><span class="pl-functor">( [ <span class="pl-atom">'import!'</span>,  <span class="pl-atom">'&amp;self'</span>, <span class="pl-atom">'metta-moses:utilities:stdlib:meTTa-utils:utilities:data-structures:list-methods'</span>], </span>
                                            <span class="pl-var">ExecRes</span>).




top_call :-
    time(top_call_7).




<span class="pl-atom">top_call_8</span>:- <span class="pl-compound pl-level-0"><span class="pl-functor">eval_H</span>(<span class="pl-args"><span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'import!'</span>|<span class="pl-ellipsis">...</span></span>]</span>, <span class="pl-var">ExecRes</span></span>)</span>.




top_call :-
    time(top_call_8).




<span class="pl-atom">top_call_11</span>:- <span class="pl-compound pl-level-0"><span class="pl-functor">eval_H</span>(<span class="pl-args"><span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'import!'</span>|<span class="pl-ellipsis">...</span></span>]</span>, <span class="pl-var">ExecRes</span></span>)</span>.




top_call :-
    time(top_call_11).




<span class="pl-atom">top_call_12</span>:- <span class="pl-compound pl-level-0"><span class="pl-functor">eval_H</span>(<span class="pl-args"><span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'import!'</span>|<span class="pl-ellipsis">...</span></span>]</span>, <span class="pl-var">ExecRes</span></span>)</span>.




top_call :-
    time(top_call_12).


%  ;; Test cases for List.removeAtIdx


<span class="pl-atom">top_call_13</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_1</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">'List.removeAtIdx'</span>, 
                                                       [ <span class="pl-atom">'Cons'</span>, 
                                                         <span class="pl-int">1</span>, 
                                                         [ <span class="pl-atom">'Cons'</span>, 
                                                           <span class="pl-int">2</span>, 
                                                           <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">3</span>|<span class="pl-ellipsis">...</span></span>]</span>]], 
                                                       <span class="pl-int">0</span>], 
                                                     [ <span class="pl-atom">'Cons'</span>, 
                                                       <span class="pl-int">2</span>, 
                                                       <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">3</span>|<span class="pl-ellipsis">...</span></span>]</span>]]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_1</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_1</span>, 
                                                   <span class="pl-var">_FARL_2</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_1</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">3</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">A</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">2</span>, <span class="pl-var">A</span>, <span class="pl-var">B</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">1</span>, <span class="pl-var">B</span>, <span class="pl-var">C</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'List.removeAtIdx'</span>, <span class="pl-var">C</span>, <span class="pl-int">0</span>, <span class="pl-var">_FA_1</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_1</span>)),
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_2</span>, 
                                                         <span class="pl-compound pl-level-0"><span class="pl-atom">true</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span></span></span>, 
                                                         <span class="pl-var">_FARL_2</span>))  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_1</span>, <span class="pl-var">_FARL_2</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_13).


==>arg_type_n(==,2,1,var).
==>arg_type_n(==,2,2,var).


<span class="pl-atom">top_call_14</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_2</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">'List.removeAtIdx'</span>, 
                                                       [ <span class="pl-atom">'Cons'</span>, 
                                                         <span class="pl-int">1</span>, 
                                                         [ <span class="pl-atom">'Cons'</span>, 
                                                           <span class="pl-int">2</span>, 
                                                           <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">3</span>|<span class="pl-ellipsis">...</span></span>]</span>]], 
                                                       <span class="pl-int">1</span>], 
                                                     [ <span class="pl-atom">'Cons'</span>, 
                                                       <span class="pl-int">1</span>, 
                                                       <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">3</span>|<span class="pl-ellipsis">...</span></span>]</span>]]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_2</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_3</span>, 
                                                   <span class="pl-var">_FARL_4</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_3</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">3</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">A</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">2</span>, <span class="pl-var">A</span>, <span class="pl-var">B</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">1</span>, <span class="pl-var">B</span>, <span class="pl-var">C</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'List.removeAtIdx'</span>, <span class="pl-var">C</span>, <span class="pl-int">1</span>, <span class="pl-var">_FA_3</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_3</span>)),
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_4</span>, 
                                                         <span class="pl-compound pl-level-0"><span class="pl-atom">true</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span></span></span>, 
                                                         <span class="pl-var">_FARL_4</span>))  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_3</span>, <span class="pl-var">_FARL_4</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_14).




<span class="pl-atom">top_call_15</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_3</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">'List.removeAtIdx'</span>, 
                                                       [ <span class="pl-atom">'Cons'</span>, 
                                                         <span class="pl-int">1</span>, 
                                                         [ <span class="pl-atom">'Cons'</span>, 
                                                           <span class="pl-int">2</span>, 
                                                           <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">3</span>|<span class="pl-ellipsis">...</span></span>]</span>]], 
                                                       <span class="pl-int">3</span>], 
                                                     [ <span class="pl-atom">'Cons'</span>, 
                                                       <span class="pl-int">1</span>, 
                                                       [ <span class="pl-atom">'Cons'</span>, 
                                                         <span class="pl-int">2</span>, 
                                                         <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">3</span>|<span class="pl-ellipsis">...</span></span>]</span>]]]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_3</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_5</span>, 
                                                   <span class="pl-var">_FARL_6</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_5</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">3</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">A</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">2</span>, <span class="pl-var">A</span>, <span class="pl-var">B</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">1</span>, <span class="pl-var">B</span>, <span class="pl-var">C</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'List.removeAtIdx'</span>, <span class="pl-var">C</span>, <span class="pl-int">3</span>, <span class="pl-var">_FA_5</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_5</span>)),
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_6</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">3</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">D</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">2</span>, <span class="pl-var">D</span>, <span class="pl-var">E</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">1</span>, <span class="pl-var">E</span>, <span class="pl-var">_FA_6</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_6</span>))  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_5</span>, <span class="pl-var">_FARL_6</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_15).


%  ;; Test cases for List.isMember


<span class="pl-atom">top_call_16</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_4</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">'List.isMember'</span>, 
                                                       <span class="pl-int">2</span>, 
                                                       [ <span class="pl-atom">'Cons'</span>, 
                                                         <span class="pl-int">1</span>, 
                                                         [ <span class="pl-atom">'Cons'</span>, 
                                                           <span class="pl-int">2</span>, 
                                                           <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">3</span>|<span class="pl-ellipsis">...</span></span>]</span>]]], 
                                                     <span class="pl-atom">'True'</span>]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_4</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_7</span>, 
                                                   <span class="pl-var">_FARL_8</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_7</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">3</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">A</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">2</span>, <span class="pl-var">A</span>, <span class="pl-var">B</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">1</span>, <span class="pl-var">B</span>, <span class="pl-var">C</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'List.isMember'</span>, <span class="pl-int">2</span>, <span class="pl-var">C</span>, <span class="pl-var">_FA_7</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_7</span>)),
                                                      (<span class="pl-compound pl-level-0"><span class="pl-functor">findall_ne</span>(<span class="pl-args"><span class="pl-var">_FA_8</span>, (<span class="pl-compound"><span class="pl-atom">true</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span></span>), <span class="pl-var">_FARL_8</span></span>)</span>)  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_7</span>, <span class="pl-var">_FARL_8</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_16).


==>arg_type_n('List.isMember',2,1,var).


<span class="pl-atom">top_call_17</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_5</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">'List.isMember'</span>, 
                                                       <span class="pl-int">4</span>, 
                                                       [ <span class="pl-atom">'Cons'</span>, 
                                                         <span class="pl-int">1</span>, 
                                                         [ <span class="pl-atom">'Cons'</span>, 
                                                           <span class="pl-int">2</span>, 
                                                           <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">3</span>|<span class="pl-ellipsis">...</span></span>]</span>]]], 
                                                     <span class="pl-atom">'False'</span>]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_5</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_9</span>, 
                                                   <span class="pl-var">_FARL_10</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_9</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">3</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">A</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">2</span>, <span class="pl-var">A</span>, <span class="pl-var">B</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">1</span>, <span class="pl-var">B</span>, <span class="pl-var">C</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'List.isMember'</span>, <span class="pl-int">4</span>, <span class="pl-var">C</span>, <span class="pl-var">_FA_9</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_9</span>)),
                                                      (<span class="pl-compound pl-level-0"><span class="pl-functor">findall_ne</span>(<span class="pl-args"><span class="pl-var">_FA_10</span>, (<span class="pl-compound"><span class="pl-atom">true</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span></span>), <span class="pl-var">_FARL_10</span></span>)</span>)  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_9</span>, <span class="pl-var">_FARL_10</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_17).


%  ;; List.partialSort -- for list of Scored instances


<span class="pl-atom">top_call_18</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_6</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">'List.partialSort'</span>, 
                                                       <span class="pl-atom">'instance&gt;='</span>, 
                                                       [ <span class="pl-atom">'Cons'</span>, 
                                                         [ <span class="pl-atom">mkSInst</span>, 
                                                           [ <span class="pl-atom">mkPair</span>, 
                                                             <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span></span>]</span>, 
                                                             [ <span class="pl-atom">mkCscore</span>, <span class="pl-int">1</span>, <span class="pl-int">2</span>, <span class="pl-int">3</span>, <span class="pl-int">4</span>, <span class="pl-int">15</span>]]], 
                                                         [ <span class="pl-atom">'Cons'</span>, 
                                                           [ <span class="pl-atom">mkSInst</span>, 
                                                             [ <span class="pl-atom">mkPair</span>, 
                                                               [ <span class="pl-atom">mkInst</span>, 
                                                                 <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">1</span>|<span class="pl-ellipsis">...</span></span>]</span>], 
                                                               [ <span class="pl-atom">mkCscore</span>, <span class="pl-int">1</span>, <span class="pl-int">2</span>, <span class="pl-int">3</span>, <span class="pl-int">4</span>, <span class="pl-int">5</span>]]], 
                                                           [ <span class="pl-atom">'Cons'</span>, 
                                                             [ <span class="pl-atom">mkSInst</span>, 
                                                               [ <span class="pl-atom">mkPair</span>, 
                                                                 [ <span class="pl-atom">mkInst</span>, 
                                                                   <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">1</span>|<span class="pl-ellipsis">...</span></span>]</span>], 
                                                                 [ <span class="pl-atom">mkCscore</span>, <span class="pl-int">1</span>, <span class="pl-int">2</span>, <span class="pl-int">3</span>, <span class="pl-int">4</span>, <span class="pl-float">0.5</span>]]], 
                                                             <span class="pl-atom">'Nil'</span>]]], <span class="pl-int">2</span>, <span class="pl-atom">'Nil'</span>], 
                                                     [ <span class="pl-atom">'Cons'</span>, 
                                                       [ <span class="pl-atom">mkSInst</span>, 
                                                         [ <span class="pl-atom">mkPair</span>, 
                                                           <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span></span>]</span>, 
                                                           [ <span class="pl-atom">mkCscore</span>, <span class="pl-int">1</span>, <span class="pl-int">2</span>, <span class="pl-int">3</span>, <span class="pl-int">4</span>, <span class="pl-int">15</span>]]], 
                                                       [ <span class="pl-atom">'Cons'</span>, 
                                                         [ <span class="pl-atom">mkSInst</span>, 
                                                           [ <span class="pl-atom">mkPair</span>, 
                                                             [ <span class="pl-atom">mkInst</span>, 
                                                               <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">1</span>|<span class="pl-ellipsis">...</span></span>]</span>], 
                                                             [ <span class="pl-atom">mkCscore</span>, <span class="pl-int">1</span>, <span class="pl-int">2</span>, <span class="pl-int">3</span>, <span class="pl-int">4</span>, <span class="pl-int">5</span>]]], 
                                                         [ <span class="pl-atom">'Cons'</span>, 
                                                           [ <span class="pl-atom">mkSInst</span>, 
                                                             [ <span class="pl-atom">mkPair</span>, 
                                                               [ <span class="pl-atom">mkInst</span>, 
                                                                 <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">1</span>|<span class="pl-ellipsis">...</span></span>]</span>], 
                                                               [ <span class="pl-atom">mkCscore</span>, <span class="pl-int">1</span>, <span class="pl-int">2</span>, <span class="pl-int">3</span>, <span class="pl-int">4</span>, <span class="pl-float">0.5</span>]]], 
                                                           <span class="pl-atom">'Nil'</span>]]]]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_6</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_11</span>, 
                                                   <span class="pl-var">_FARL_12</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_11</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">A</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkCscore</span>, <span class="pl-int">1</span>, <span class="pl-int">2</span>, <span class="pl-int">3</span>, <span class="pl-int">4</span>, <span class="pl-int">15</span>, <span class="pl-var">B</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkPair</span>, <span class="pl-var">A</span>, <span class="pl-var">B</span>, <span class="pl-var">C</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkSInst</span>, <span class="pl-var">C</span>, <span class="pl-var">D</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">1</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">E</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-var">E</span>, <span class="pl-var">F</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkCscore</span>, <span class="pl-int">1</span>, <span class="pl-int">2</span>, <span class="pl-int">3</span>, <span class="pl-int">4</span>, <span class="pl-int">5</span>, <span class="pl-var">G</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkPair</span>, <span class="pl-var">F</span>, <span class="pl-var">G</span>, <span class="pl-var">H</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkSInst</span>, <span class="pl-var">H</span>, <span class="pl-var">I</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">1</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">J</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-var">J</span>, <span class="pl-var">K</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkCscore</span>, <span class="pl-int">1</span>, <span class="pl-int">2</span>, <span class="pl-int">3</span>, <span class="pl-int">4</span>, <span class="pl-float">0.5</span>, <span class="pl-var">L</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkPair</span>, <span class="pl-var">K</span>, <span class="pl-var">L</span>, <span class="pl-var">M</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkSInst</span>, <span class="pl-var">M</span>, <span class="pl-var">N</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-var">N</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">O</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-var">I</span>, <span class="pl-var">O</span>, <span class="pl-var">P</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-var">D</span>, <span class="pl-var">P</span>, <span class="pl-var">Q</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'List.partialSort'</span>, <span class="pl-atom">'instance&gt;='</span>, <span class="pl-var">Q</span>, <span class="pl-int">2</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">_FA_11</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_11</span>)),
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_12</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">R</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkCscore</span>, <span class="pl-int">1</span>, <span class="pl-int">2</span>, <span class="pl-int">3</span>, <span class="pl-int">4</span>, <span class="pl-int">15</span>, <span class="pl-var">S</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkPair</span>, <span class="pl-var">R</span>, <span class="pl-var">S</span>, <span class="pl-var">T</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkSInst</span>, <span class="pl-var">T</span>, <span class="pl-var">U</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">1</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">V</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-var">V</span>, <span class="pl-var">W</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkCscore</span>, <span class="pl-int">1</span>, <span class="pl-int">2</span>, <span class="pl-int">3</span>, <span class="pl-int">4</span>, <span class="pl-int">5</span>, <span class="pl-var">X</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkPair</span>, <span class="pl-var">W</span>, <span class="pl-var">X</span>, <span class="pl-var">Y</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkSInst</span>, <span class="pl-var">Y</span>, <span class="pl-var">Z</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">1</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">A1</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-var">A1</span>, <span class="pl-var">B1</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkCscore</span>, <span class="pl-int">1</span>, <span class="pl-int">2</span>, <span class="pl-int">3</span>, <span class="pl-int">4</span>, <span class="pl-float">0.5</span>, <span class="pl-var">C1</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkPair</span>, <span class="pl-var">B1</span>, <span class="pl-var">C1</span>, <span class="pl-var">D1</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkSInst</span>, <span class="pl-var">D1</span>, <span class="pl-var">E1</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-var">E1</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">F1</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-var">Z</span>, <span class="pl-var">F1</span>, <span class="pl-var">G1</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-var">U</span>, <span class="pl-var">G1</span>, <span class="pl-var">_FA_12</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_12</span>))  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_11</span>, <span class="pl-var">_FARL_12</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_18).




<span class="pl-atom">top_call_19</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_7</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">'List.partialSort'</span>, 
                                                       <span class="pl-atom">'instance&gt;='</span>, 
                                                       [ <span class="pl-atom">'Cons'</span>, 
                                                         [ <span class="pl-atom">mkSInst</span>, 
                                                           [ <span class="pl-atom">mkPair</span>, 
                                                             <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span></span>]</span>, 
                                                             [ <span class="pl-atom">mkCscore</span>, <span class="pl-float">-2.0</span>, <span class="pl-int">1</span>, <span class="pl-float">1.0</span>, <span class="pl-float">0.5</span>, <span class="pl-float">-3.5</span>]]], 
                                                         [ <span class="pl-atom">'Cons'</span>, 
                                                           [ <span class="pl-atom">mkSInst</span>, 
                                                             [ <span class="pl-atom">mkPair</span>, 
                                                               <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span></span>]</span>, 
                                                               [ <span class="pl-atom">mkCscore</span>, <span class="pl-float">-1.0</span>, <span class="pl-int">2</span>, <span class="pl-float">1.0</span>, <span class="pl-float">0.5</span>, <span class="pl-float">-2.5</span>]]], 
                                                           [ <span class="pl-atom">'Cons'</span>, 
                                                             [ <span class="pl-atom">mkSInst</span>, 
                                                               [ <span class="pl-atom">mkPair</span>, 
                                                                 <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span></span>]</span>, 
                                                                 [ <span class="pl-atom">mkCscore</span>, <span class="pl-float">-3.0</span>, <span class="pl-int">3</span>, <span class="pl-float">1.0</span>, <span class="pl-float">0.5</span>, <span class="pl-float">-4.5</span>]]], 
                                                             <span class="pl-atom">'Nil'</span>]]], <span class="pl-int">2</span>, <span class="pl-atom">'Nil'</span>], 
                                                     [ <span class="pl-atom">'Cons'</span>, 
                                                       [ <span class="pl-atom">mkSInst</span>, 
                                                         [ <span class="pl-atom">mkPair</span>, 
                                                           <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span></span>]</span>, 
                                                           [ <span class="pl-atom">mkCscore</span>, <span class="pl-float">-1.0</span>, <span class="pl-int">2</span>, <span class="pl-float">1.0</span>, <span class="pl-float">0.5</span>, <span class="pl-float">-2.5</span>]]], 
                                                       [ <span class="pl-atom">'Cons'</span>, 
                                                         [ <span class="pl-atom">mkSInst</span>, 
                                                           [ <span class="pl-atom">mkPair</span>, 
                                                             <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span></span>]</span>, 
                                                             [ <span class="pl-atom">mkCscore</span>, <span class="pl-float">-2.0</span>, <span class="pl-int">1</span>, <span class="pl-float">1.0</span>, <span class="pl-float">0.5</span>, <span class="pl-float">-3.5</span>]]], 
                                                         [ <span class="pl-atom">'Cons'</span>, 
                                                           [ <span class="pl-atom">mkSInst</span>, 
                                                             [ <span class="pl-atom">mkPair</span>, 
                                                               <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span></span>]</span>, 
                                                               [ <span class="pl-atom">mkCscore</span>, <span class="pl-float">-3.0</span>, <span class="pl-int">3</span>, <span class="pl-float">1.0</span>, <span class="pl-float">0.5</span>, <span class="pl-float">-4.5</span>]]], 
                                                           <span class="pl-atom">'Nil'</span>]]]]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_7</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_13</span>, 
                                                   <span class="pl-var">_FARL_14</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_13</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">A</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkCscore</span>, <span class="pl-float">-2.0</span>, <span class="pl-int">1</span>, <span class="pl-float">1.0</span>, <span class="pl-float">0.5</span>, <span class="pl-float">-3.5</span>, <span class="pl-var">B</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkPair</span>, <span class="pl-var">A</span>, <span class="pl-var">B</span>, <span class="pl-var">C</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkSInst</span>, <span class="pl-var">C</span>, <span class="pl-var">D</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">E</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkCscore</span>, <span class="pl-float">-1.0</span>, <span class="pl-int">2</span>, <span class="pl-float">1.0</span>, <span class="pl-float">0.5</span>, <span class="pl-float">-2.5</span>, <span class="pl-var">F</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkPair</span>, <span class="pl-var">E</span>, <span class="pl-var">F</span>, <span class="pl-var">G</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkSInst</span>, <span class="pl-var">G</span>, <span class="pl-var">H</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">I</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkCscore</span>, <span class="pl-float">-3.0</span>, <span class="pl-int">3</span>, <span class="pl-float">1.0</span>, <span class="pl-float">0.5</span>, <span class="pl-float">-4.5</span>, <span class="pl-var">J</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkPair</span>, <span class="pl-var">I</span>, <span class="pl-var">J</span>, <span class="pl-var">K</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkSInst</span>, <span class="pl-var">K</span>, <span class="pl-var">L</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-var">L</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">M</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-var">H</span>, <span class="pl-var">M</span>, <span class="pl-var">N</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-var">D</span>, <span class="pl-var">N</span>, <span class="pl-var">O</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'List.partialSort'</span>, <span class="pl-atom">'instance&gt;='</span>, <span class="pl-var">O</span>, <span class="pl-int">2</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">_FA_13</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_13</span>)),
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_14</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">P</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkCscore</span>, <span class="pl-float">-1.0</span>, <span class="pl-int">2</span>, <span class="pl-float">1.0</span>, <span class="pl-float">0.5</span>, <span class="pl-float">-2.5</span>, <span class="pl-var">Q</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkPair</span>, <span class="pl-var">P</span>, <span class="pl-var">Q</span>, <span class="pl-var">R</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkSInst</span>, <span class="pl-var">R</span>, <span class="pl-var">S</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">T</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkCscore</span>, <span class="pl-float">-2.0</span>, <span class="pl-int">1</span>, <span class="pl-float">1.0</span>, <span class="pl-float">0.5</span>, <span class="pl-float">-3.5</span>, <span class="pl-var">U</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkPair</span>, <span class="pl-var">T</span>, <span class="pl-var">U</span>, <span class="pl-var">V</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkSInst</span>, <span class="pl-var">V</span>, <span class="pl-var">W</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">X</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkCscore</span>, <span class="pl-float">-3.0</span>, <span class="pl-int">3</span>, <span class="pl-float">1.0</span>, <span class="pl-float">0.5</span>, <span class="pl-float">-4.5</span>, <span class="pl-var">Y</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkPair</span>, <span class="pl-var">X</span>, <span class="pl-var">Y</span>, <span class="pl-var">Z</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkSInst</span>, <span class="pl-var">Z</span>, <span class="pl-var">A1</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-var">A1</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">B1</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-var">W</span>, <span class="pl-var">B1</span>, <span class="pl-var">C1</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-var">S</span>, <span class="pl-var">C1</span>, <span class="pl-var">_FA_14</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_14</span>))  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_13</span>, <span class="pl-var">_FARL_14</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_19).




<span class="pl-atom">top_call_20</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_8</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">'List.partialSort'</span>, 
                                                       <span class="pl-atom">'instance&gt;='</span>, 
                                                       [ <span class="pl-atom">'Cons'</span>, 
                                                         [ <span class="pl-atom">mkSInst</span>, 
                                                           [ <span class="pl-atom">mkPair</span>, 
                                                             <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span></span>]</span>, 
                                                             [ <span class="pl-atom">mkCscore</span>, <span class="pl-float">-2.0</span>, <span class="pl-int">3</span>, <span class="pl-float">1.0</span>, <span class="pl-float">0.5</span>, <span class="pl-float">-3.5</span>]]], 
                                                         [ <span class="pl-atom">'Cons'</span>, 
                                                           [ <span class="pl-atom">mkSInst</span>, 
                                                             [ <span class="pl-atom">mkPair</span>, 
                                                               <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span></span>]</span>, 
                                                               [ <span class="pl-atom">mkCscore</span>, <span class="pl-float">-2.0</span>, <span class="pl-int">2</span>, <span class="pl-float">1.0</span>, <span class="pl-float">0.5</span>, <span class="pl-float">-3.5</span>]]], 
                                                           [ <span class="pl-atom">'Cons'</span>, 
                                                             [ <span class="pl-atom">mkSInst</span>, 
                                                               [ <span class="pl-atom">mkPair</span>, 
                                                                 <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span></span>]</span>, 
                                                                 [ <span class="pl-atom">mkCscore</span>, <span class="pl-float">-2.0</span>, <span class="pl-int">1</span>, <span class="pl-float">1.0</span>, <span class="pl-float">0.5</span>, <span class="pl-float">-3.5</span>]]], 
                                                             <span class="pl-atom">'Nil'</span>]]], <span class="pl-int">2</span>, <span class="pl-atom">'Nil'</span>], 
                                                     [ <span class="pl-atom">'Cons'</span>, 
                                                       [ <span class="pl-atom">mkSInst</span>, 
                                                         [ <span class="pl-atom">mkPair</span>, 
                                                           <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span></span>]</span>, 
                                                           [ <span class="pl-atom">mkCscore</span>, <span class="pl-float">-2.0</span>, <span class="pl-int">1</span>, <span class="pl-float">1.0</span>, <span class="pl-float">0.5</span>, <span class="pl-float">-3.5</span>]]], 
                                                       [ <span class="pl-atom">'Cons'</span>, 
                                                         [ <span class="pl-atom">mkSInst</span>, 
                                                           [ <span class="pl-atom">mkPair</span>, 
                                                             <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span></span>]</span>, 
                                                             [ <span class="pl-atom">mkCscore</span>, <span class="pl-float">-2.0</span>, <span class="pl-int">2</span>, <span class="pl-float">1.0</span>, <span class="pl-float">0.5</span>, <span class="pl-float">-3.5</span>]]], 
                                                         [ <span class="pl-atom">'Cons'</span>, 
                                                           [ <span class="pl-atom">mkSInst</span>, 
                                                             [ <span class="pl-atom">mkPair</span>, 
                                                               <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span></span>]</span>, 
                                                               [ <span class="pl-atom">mkCscore</span>, <span class="pl-float">-2.0</span>, <span class="pl-int">3</span>, <span class="pl-float">1.0</span>, <span class="pl-float">0.5</span>, <span class="pl-float">-3.5</span>]]], 
                                                           <span class="pl-atom">'Nil'</span>]]]]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_8</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_15</span>, 
                                                   <span class="pl-var">_FARL_16</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_15</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">A</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkCscore</span>, <span class="pl-float">-2.0</span>, <span class="pl-int">3</span>, <span class="pl-float">1.0</span>, <span class="pl-float">0.5</span>, <span class="pl-float">-3.5</span>, <span class="pl-var">B</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkPair</span>, <span class="pl-var">A</span>, <span class="pl-var">B</span>, <span class="pl-var">C</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkSInst</span>, <span class="pl-var">C</span>, <span class="pl-var">D</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">E</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkCscore</span>, <span class="pl-float">-2.0</span>, <span class="pl-int">2</span>, <span class="pl-float">1.0</span>, <span class="pl-float">0.5</span>, <span class="pl-float">-3.5</span>, <span class="pl-var">F</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkPair</span>, <span class="pl-var">E</span>, <span class="pl-var">F</span>, <span class="pl-var">G</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkSInst</span>, <span class="pl-var">G</span>, <span class="pl-var">H</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">I</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkCscore</span>, <span class="pl-float">-2.0</span>, <span class="pl-int">1</span>, <span class="pl-float">1.0</span>, <span class="pl-float">0.5</span>, <span class="pl-float">-3.5</span>, <span class="pl-var">J</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkPair</span>, <span class="pl-var">I</span>, <span class="pl-var">J</span>, <span class="pl-var">K</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkSInst</span>, <span class="pl-var">K</span>, <span class="pl-var">L</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-var">L</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">M</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-var">H</span>, <span class="pl-var">M</span>, <span class="pl-var">N</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-var">D</span>, <span class="pl-var">N</span>, <span class="pl-var">O</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'List.partialSort'</span>, <span class="pl-atom">'instance&gt;='</span>, <span class="pl-var">O</span>, <span class="pl-int">2</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">_FA_15</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_15</span>)),
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_16</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">P</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkCscore</span>, <span class="pl-float">-2.0</span>, <span class="pl-int">1</span>, <span class="pl-float">1.0</span>, <span class="pl-float">0.5</span>, <span class="pl-float">-3.5</span>, <span class="pl-var">Q</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkPair</span>, <span class="pl-var">P</span>, <span class="pl-var">Q</span>, <span class="pl-var">R</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkSInst</span>, <span class="pl-var">R</span>, <span class="pl-var">S</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">T</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkCscore</span>, <span class="pl-float">-2.0</span>, <span class="pl-int">2</span>, <span class="pl-float">1.0</span>, <span class="pl-float">0.5</span>, <span class="pl-float">-3.5</span>, <span class="pl-var">U</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkPair</span>, <span class="pl-var">T</span>, <span class="pl-var">U</span>, <span class="pl-var">V</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkSInst</span>, <span class="pl-var">V</span>, <span class="pl-var">W</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">X</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkCscore</span>, <span class="pl-float">-2.0</span>, <span class="pl-int">3</span>, <span class="pl-float">1.0</span>, <span class="pl-float">0.5</span>, <span class="pl-float">-3.5</span>, <span class="pl-var">Y</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkPair</span>, <span class="pl-var">X</span>, <span class="pl-var">Y</span>, <span class="pl-var">Z</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkSInst</span>, <span class="pl-var">Z</span>, <span class="pl-var">A1</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-var">A1</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">B1</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-var">W</span>, <span class="pl-var">B1</span>, <span class="pl-var">C1</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-var">S</span>, <span class="pl-var">C1</span>, <span class="pl-var">_FA_16</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_16</span>))  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_15</span>, <span class="pl-var">_FARL_16</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_20).




<span class="pl-atom">top_call_21</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_9</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">'List.partialSort'</span>, 
                                                       <span class="pl-atom">'instance&gt;='</span>, 
                                                       [ <span class="pl-atom">'Cons'</span>, 
                                                         [ <span class="pl-atom">mkSInst</span>, 
                                                           [ <span class="pl-atom">mkPair</span>, 
                                                             <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span></span>]</span>, 
                                                             [ <span class="pl-atom">mkCscore</span>, <span class="pl-float">-3.0</span>, <span class="pl-int">2</span>, <span class="pl-float">1.0</span>, <span class="pl-float">0.5</span>, <span class="pl-float">-4.5</span>]]], 
                                                         [ <span class="pl-atom">'Cons'</span>, 
                                                           [ <span class="pl-atom">mkSInst</span>, 
                                                             [ <span class="pl-atom">mkPair</span>, 
                                                               <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span></span>]</span>, 
                                                               [ <span class="pl-atom">mkCscore</span>, <span class="pl-float">-1.0</span>, <span class="pl-int">3</span>, <span class="pl-float">1.0</span>, <span class="pl-float">0.5</span>, <span class="pl-float">-2.5</span>]]], 
                                                           [ <span class="pl-atom">'Cons'</span>, 
                                                             [ <span class="pl-atom">mkSInst</span>, 
                                                               [ <span class="pl-atom">mkPair</span>, 
                                                                 <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span></span>]</span>, 
                                                                 [ <span class="pl-atom">mkCscore</span>, <span class="pl-float">-2.0</span>, <span class="pl-int">1</span>, <span class="pl-float">1.0</span>, <span class="pl-float">0.5</span>, <span class="pl-float">-3.5</span>]]], 
                                                             <span class="pl-atom">'Nil'</span>]]], <span class="pl-int">2</span>, <span class="pl-atom">'Nil'</span>], 
                                                     [ <span class="pl-atom">'Cons'</span>, 
                                                       [ <span class="pl-atom">mkSInst</span>, 
                                                         [ <span class="pl-atom">mkPair</span>, 
                                                           <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span></span>]</span>, 
                                                           [ <span class="pl-atom">mkCscore</span>, <span class="pl-float">-1.0</span>, <span class="pl-int">3</span>, <span class="pl-float">1.0</span>, <span class="pl-float">0.5</span>, <span class="pl-float">-2.5</span>]]], 
                                                       [ <span class="pl-atom">'Cons'</span>, 
                                                         [ <span class="pl-atom">mkSInst</span>, 
                                                           [ <span class="pl-atom">mkPair</span>, 
                                                             <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span></span>]</span>, 
                                                             [ <span class="pl-atom">mkCscore</span>, <span class="pl-float">-2.0</span>, <span class="pl-int">1</span>, <span class="pl-float">1.0</span>, <span class="pl-float">0.5</span>, <span class="pl-float">-3.5</span>]]], 
                                                         [ <span class="pl-atom">'Cons'</span>, 
                                                           [ <span class="pl-atom">mkSInst</span>, 
                                                             [ <span class="pl-atom">mkPair</span>, 
                                                               <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span></span>]</span>, 
                                                               [ <span class="pl-atom">mkCscore</span>, <span class="pl-float">-3.0</span>, <span class="pl-int">2</span>, <span class="pl-float">1.0</span>, <span class="pl-float">0.5</span>, <span class="pl-float">-4.5</span>]]], 
                                                           <span class="pl-atom">'Nil'</span>]]]]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_9</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_17</span>, 
                                                   <span class="pl-var">_FARL_18</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_17</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">A</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkCscore</span>, <span class="pl-float">-3.0</span>, <span class="pl-int">2</span>, <span class="pl-float">1.0</span>, <span class="pl-float">0.5</span>, <span class="pl-float">-4.5</span>, <span class="pl-var">B</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkPair</span>, <span class="pl-var">A</span>, <span class="pl-var">B</span>, <span class="pl-var">C</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkSInst</span>, <span class="pl-var">C</span>, <span class="pl-var">D</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">E</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkCscore</span>, <span class="pl-float">-1.0</span>, <span class="pl-int">3</span>, <span class="pl-float">1.0</span>, <span class="pl-float">0.5</span>, <span class="pl-float">-2.5</span>, <span class="pl-var">F</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkPair</span>, <span class="pl-var">E</span>, <span class="pl-var">F</span>, <span class="pl-var">G</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkSInst</span>, <span class="pl-var">G</span>, <span class="pl-var">H</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">I</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkCscore</span>, <span class="pl-float">-2.0</span>, <span class="pl-int">1</span>, <span class="pl-float">1.0</span>, <span class="pl-float">0.5</span>, <span class="pl-float">-3.5</span>, <span class="pl-var">J</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkPair</span>, <span class="pl-var">I</span>, <span class="pl-var">J</span>, <span class="pl-var">K</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkSInst</span>, <span class="pl-var">K</span>, <span class="pl-var">L</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-var">L</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">M</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-var">H</span>, <span class="pl-var">M</span>, <span class="pl-var">N</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-var">D</span>, <span class="pl-var">N</span>, <span class="pl-var">O</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'List.partialSort'</span>, <span class="pl-atom">'instance&gt;='</span>, <span class="pl-var">O</span>, <span class="pl-int">2</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">_FA_17</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_17</span>)),
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_18</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">P</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkCscore</span>, <span class="pl-float">-1.0</span>, <span class="pl-int">3</span>, <span class="pl-float">1.0</span>, <span class="pl-float">0.5</span>, <span class="pl-float">-2.5</span>, <span class="pl-var">Q</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkPair</span>, <span class="pl-var">P</span>, <span class="pl-var">Q</span>, <span class="pl-var">R</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkSInst</span>, <span class="pl-var">R</span>, <span class="pl-var">S</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">T</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkCscore</span>, <span class="pl-float">-2.0</span>, <span class="pl-int">1</span>, <span class="pl-float">1.0</span>, <span class="pl-float">0.5</span>, <span class="pl-float">-3.5</span>, <span class="pl-var">U</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkPair</span>, <span class="pl-var">T</span>, <span class="pl-var">U</span>, <span class="pl-var">V</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkSInst</span>, <span class="pl-var">V</span>, <span class="pl-var">W</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkInst</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">X</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkCscore</span>, <span class="pl-float">-3.0</span>, <span class="pl-int">2</span>, <span class="pl-float">1.0</span>, <span class="pl-float">0.5</span>, <span class="pl-float">-4.5</span>, <span class="pl-var">Y</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkPair</span>, <span class="pl-var">X</span>, <span class="pl-var">Y</span>, <span class="pl-var">Z</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">mkSInst</span>, <span class="pl-var">Z</span>, <span class="pl-var">A1</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-var">A1</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">B1</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-var">W</span>, <span class="pl-var">B1</span>, <span class="pl-var">C1</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-var">S</span>, <span class="pl-var">C1</span>, <span class="pl-var">_FA_18</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_18</span>))  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_17</span>, <span class="pl-var">_FARL_18</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_21).


%  ;; For list of numbers             


<span class="pl-atom">top_call_22</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_10</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">'List.partialSort'</span>, 
                                                       [ <span class="pl-atom">'Cons'</span>, 
                                                         <span class="pl-int">5</span>, 
                                                         [ <span class="pl-atom">'Cons'</span>, 
                                                           <span class="pl-int">1</span>, 
                                                           [ <span class="pl-atom">'Cons'</span>, 
                                                             <span class="pl-int">8</span>, 
                                                             <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">3</span>|<span class="pl-ellipsis">...</span></span>]</span>]]], <span class="pl-int">2</span>, <span class="pl-atom">'Nil'</span>], 
                                                     [ <span class="pl-atom">'Cons'</span>, 
                                                       <span class="pl-int">8</span>, 
                                                       [ <span class="pl-atom">'Cons'</span>, 
                                                         <span class="pl-int">5</span>, 
                                                         [ <span class="pl-atom">'Cons'</span>, 
                                                           <span class="pl-int">1</span>, 
                                                           <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">3</span>|<span class="pl-ellipsis">...</span></span>]</span>]]]]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_10</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_19</span>, 
                                                   <span class="pl-var">_FARL_20</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_19</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">3</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">A</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">8</span>, <span class="pl-var">A</span>, <span class="pl-var">B</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">1</span>, <span class="pl-var">B</span>, <span class="pl-var">C</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">5</span>, <span class="pl-var">C</span>, <span class="pl-var">D</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'List.partialSort'</span>, <span class="pl-var">D</span>, <span class="pl-int">2</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">_FA_19</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_19</span>)),
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_20</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">3</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">E</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">1</span>, <span class="pl-var">E</span>, <span class="pl-var">F</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">5</span>, <span class="pl-var">F</span>, <span class="pl-var">G</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">8</span>, <span class="pl-var">G</span>, <span class="pl-var">_FA_20</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_20</span>))  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_19</span>, <span class="pl-var">_FARL_20</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_22).




<span class="pl-atom">top_call_23</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_11</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">'List.partialSort'</span>, 
                                                       [ <span class="pl-atom">'Cons'</span>, 
                                                         <span class="pl-int">-4</span>, 
                                                         [ <span class="pl-atom">'Cons'</span>, 
                                                           <span class="pl-int">-3</span>, 
                                                           [ <span class="pl-atom">'Cons'</span>, 
                                                             <span class="pl-int">-2</span>, 
                                                             <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">-1</span>|<span class="pl-ellipsis">...</span></span>]</span>]]], <span class="pl-int">2</span>, <span class="pl-atom">'Nil'</span>], 
                                                     [ <span class="pl-atom">'Cons'</span>, 
                                                       <span class="pl-int">-1</span>, 
                                                       [ <span class="pl-atom">'Cons'</span>, 
                                                         <span class="pl-int">-2</span>, 
                                                         [ <span class="pl-atom">'Cons'</span>, 
                                                           <span class="pl-int">-4</span>, 
                                                           <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">-3</span>|<span class="pl-ellipsis">...</span></span>]</span>]]]]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_11</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_21</span>, 
                                                   <span class="pl-var">_FARL_22</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_21</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">-1</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">A</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">-2</span>, <span class="pl-var">A</span>, <span class="pl-var">B</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">-3</span>, <span class="pl-var">B</span>, <span class="pl-var">C</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">-4</span>, <span class="pl-var">C</span>, <span class="pl-var">D</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'List.partialSort'</span>, <span class="pl-var">D</span>, <span class="pl-int">2</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">_FA_21</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_21</span>)),
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_22</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">-3</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">E</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">-4</span>, <span class="pl-var">E</span>, <span class="pl-var">F</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">-2</span>, <span class="pl-var">F</span>, <span class="pl-var">G</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">-1</span>, <span class="pl-var">G</span>, <span class="pl-var">_FA_22</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_22</span>))  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_21</span>, <span class="pl-var">_FARL_22</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_23).




<span class="pl-atom">top_call_24</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_12</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">'List.partialSort'</span>, 
                                                       [ <span class="pl-atom">'Cons'</span>, 
                                                         <span class="pl-int">5</span>, 
                                                         [ <span class="pl-atom">'Cons'</span>, 
                                                           <span class="pl-int">1</span>, 
                                                           [ <span class="pl-atom">'Cons'</span>, 
                                                             <span class="pl-int">8</span>, 
                                                             [ <span class="pl-atom">'Cons'</span>, 
                                                               <span class="pl-int">3</span>, 
                                                               [ <span class="pl-atom">'Cons'</span>, 
                                                                 <span class="pl-int">1</span>, 
                                                                 <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">7</span>|<span class="pl-ellipsis">...</span></span>]</span>]]]]], <span class="pl-int">3</span>, <span class="pl-atom">'Nil'</span>], 
                                                     [ <span class="pl-atom">'Cons'</span>, 
                                                       <span class="pl-int">8</span>, 
                                                       [ <span class="pl-atom">'Cons'</span>, 
                                                         <span class="pl-int">7</span>, 
                                                         [ <span class="pl-atom">'Cons'</span>, 
                                                           <span class="pl-int">5</span>, 
                                                           [ <span class="pl-atom">'Cons'</span>, 
                                                             <span class="pl-int">1</span>, 
                                                             [ <span class="pl-atom">'Cons'</span>, 
                                                               <span class="pl-int">3</span>, 
                                                               <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">1</span>|<span class="pl-ellipsis">...</span></span>]</span>]]]]]]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_12</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_23</span>, 
                                                   <span class="pl-var">_FARL_24</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_23</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">7</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">A</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">1</span>, <span class="pl-var">A</span>, <span class="pl-var">B</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">3</span>, <span class="pl-var">B</span>, <span class="pl-var">C</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">8</span>, <span class="pl-var">C</span>, <span class="pl-var">D</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">1</span>, <span class="pl-var">D</span>, <span class="pl-var">E</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">5</span>, <span class="pl-var">E</span>, <span class="pl-var">F</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'List.partialSort'</span>, <span class="pl-var">F</span>, <span class="pl-int">3</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">_FA_23</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_23</span>)),
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_24</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">1</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">G</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">3</span>, <span class="pl-var">G</span>, <span class="pl-var">H</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">1</span>, <span class="pl-var">H</span>, <span class="pl-var">I</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">5</span>, <span class="pl-var">I</span>, <span class="pl-var">J</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">7</span>, <span class="pl-var">J</span>, <span class="pl-var">K</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">8</span>, <span class="pl-var">K</span>, <span class="pl-var">_FA_24</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_24</span>))  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_23</span>, <span class="pl-var">_FARL_24</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_24).


%  ;; For List.takeN 


<span class="pl-atom">top_call_25</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_13</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">'List.takeN'</span>, 
                                                       <span class="pl-int">2</span>, 
                                                       [ <span class="pl-atom">'Cons'</span>, 
                                                         <span class="pl-int">2</span>, 
                                                         [ <span class="pl-atom">'Cons'</span>, 
                                                           <span class="pl-int">1</span>, 
                                                           <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">3</span>|<span class="pl-ellipsis">...</span></span>]</span>]]], 
                                                     [ <span class="pl-atom">'Cons'</span>, 
                                                       <span class="pl-int">2</span>, 
                                                       <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">1</span>|<span class="pl-ellipsis">...</span></span>]</span>]]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_13</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_25</span>, 
                                                   <span class="pl-var">_FARL_26</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_25</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">3</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">A</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">1</span>, <span class="pl-var">A</span>, <span class="pl-var">B</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">2</span>, <span class="pl-var">B</span>, <span class="pl-var">C</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'List.takeN'</span>, <span class="pl-int">2</span>, <span class="pl-var">C</span>, <span class="pl-var">_FA_25</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_25</span>)),
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_26</span>, 
                                                         <span class="pl-compound pl-level-0"><span class="pl-atom">true</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span></span></span>, 
                                                         <span class="pl-var">_FARL_26</span>))  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_25</span>, <span class="pl-var">_FARL_26</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_25).




<span class="pl-atom">top_call_26</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_14</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">'List.takeN'</span>, 
                                                       <span class="pl-int">0</span>, 
                                                       [ <span class="pl-atom">'Cons'</span>, 
                                                         <span class="pl-int">2</span>, 
                                                         [ <span class="pl-atom">'Cons'</span>, 
                                                           <span class="pl-int">1</span>, 
                                                           <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">3</span>|<span class="pl-ellipsis">...</span></span>]</span>]]], 
                                                     <span class="pl-atom">'Nil'</span>]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_14</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_27</span>, 
                                                   <span class="pl-var">_FARL_28</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_27</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">3</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">A</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">1</span>, <span class="pl-var">A</span>, <span class="pl-var">B</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">2</span>, <span class="pl-var">B</span>, <span class="pl-var">C</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'List.takeN'</span>, <span class="pl-int">0</span>, <span class="pl-var">C</span>, <span class="pl-var">_FA_27</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_27</span>)),
                                                      (<span class="pl-compound pl-level-0"><span class="pl-functor">findall_ne</span>(<span class="pl-args"><span class="pl-var">_FA_28</span>, (<span class="pl-compound"><span class="pl-atom">true</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span></span>), <span class="pl-var">_FARL_28</span></span>)</span>)  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_27</span>, <span class="pl-var">_FARL_28</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_26).


%  ;; List.takeNFrom test cases


<span class="pl-atom">top_call_27</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_15</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">'List.takeNFrom'</span>, <span class="pl-int">2</span>, <span class="pl-int">3</span>, 
                                                       [ <span class="pl-atom">'Cons'</span>, 
                                                         <span class="pl-int">0</span>, 
                                                         [ <span class="pl-atom">'Cons'</span>, 
                                                           <span class="pl-int">1</span>, 
                                                           [ <span class="pl-atom">'Cons'</span>, 
                                                             <span class="pl-int">2</span>, 
                                                             [ <span class="pl-atom">'Cons'</span>, 
                                                               <span class="pl-int">3</span>, 
                                                               [ <span class="pl-atom">'Cons'</span>, 
                                                                 <span class="pl-int">4</span>, 
                                                                 <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">5</span>|<span class="pl-ellipsis">...</span></span>]</span>]]]]]], 
                                                     [ <span class="pl-atom">'Cons'</span>, 
                                                       <span class="pl-int">2</span>, 
                                                       [ <span class="pl-atom">'Cons'</span>, 
                                                         <span class="pl-int">3</span>, 
                                                         <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">4</span>|<span class="pl-ellipsis">...</span></span>]</span>]]]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_15</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_29</span>, 
                                                   <span class="pl-var">_FARL_30</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_29</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">5</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">A</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">4</span>, <span class="pl-var">A</span>, <span class="pl-var">B</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">3</span>, <span class="pl-var">B</span>, <span class="pl-var">C</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">2</span>, <span class="pl-var">C</span>, <span class="pl-var">D</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">1</span>, <span class="pl-var">D</span>, <span class="pl-var">E</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">0</span>, <span class="pl-var">E</span>, <span class="pl-var">F</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'List.takeNFrom'</span>, <span class="pl-int">2</span>, <span class="pl-int">3</span>, <span class="pl-var">F</span>, <span class="pl-var">_FA_29</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_29</span>)),
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_30</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">4</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">G</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">3</span>, <span class="pl-var">G</span>, <span class="pl-var">H</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">2</span>, <span class="pl-var">H</span>, <span class="pl-var">_FA_30</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_30</span>))  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_29</span>, <span class="pl-var">_FARL_30</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_27).




<span class="pl-atom">top_call_28</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_16</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">'List.takeNFrom'</span>, <span class="pl-int">0</span>, <span class="pl-int">3</span>, 
                                                       [ <span class="pl-atom">'Cons'</span>, 
                                                         <span class="pl-int">0</span>, 
                                                         [ <span class="pl-atom">'Cons'</span>, 
                                                           <span class="pl-int">1</span>, 
                                                           [ <span class="pl-atom">'Cons'</span>, 
                                                             <span class="pl-int">2</span>, 
                                                             [ <span class="pl-atom">'Cons'</span>, 
                                                               <span class="pl-int">3</span>, 
                                                               [ <span class="pl-atom">'Cons'</span>, 
                                                                 <span class="pl-int">4</span>, 
                                                                 <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">5</span>|<span class="pl-ellipsis">...</span></span>]</span>]]]]]], 
                                                     [ <span class="pl-atom">'Cons'</span>, 
                                                       <span class="pl-int">0</span>, 
                                                       [ <span class="pl-atom">'Cons'</span>, 
                                                         <span class="pl-int">1</span>, 
                                                         <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">2</span>|<span class="pl-ellipsis">...</span></span>]</span>]]]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_16</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_31</span>, 
                                                   <span class="pl-var">_FARL_32</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_31</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">5</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">A</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">4</span>, <span class="pl-var">A</span>, <span class="pl-var">B</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">3</span>, <span class="pl-var">B</span>, <span class="pl-var">C</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">2</span>, <span class="pl-var">C</span>, <span class="pl-var">D</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">1</span>, <span class="pl-var">D</span>, <span class="pl-var">E</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">0</span>, <span class="pl-var">E</span>, <span class="pl-var">F</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'List.takeNFrom'</span>, <span class="pl-int">0</span>, <span class="pl-int">3</span>, <span class="pl-var">F</span>, <span class="pl-var">_FA_31</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_31</span>)),
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_32</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">2</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">G</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">1</span>, <span class="pl-var">G</span>, <span class="pl-var">H</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">0</span>, <span class="pl-var">H</span>, <span class="pl-var">_FA_32</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_32</span>))  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_31</span>, <span class="pl-var">_FARL_32</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_28).




<span class="pl-atom">top_call_29</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_17</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">'List.takeNFrom'</span>, <span class="pl-int">3</span>, <span class="pl-int">2</span>, 
                                                       [ <span class="pl-atom">'Cons'</span>, 
                                                         <span class="pl-int">0</span>, 
                                                         [ <span class="pl-atom">'Cons'</span>, 
                                                           <span class="pl-int">1</span>, 
                                                           [ <span class="pl-atom">'Cons'</span>, 
                                                             <span class="pl-int">2</span>, 
                                                             [ <span class="pl-atom">'Cons'</span>, 
                                                               <span class="pl-int">3</span>, 
                                                               <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">4</span>|<span class="pl-ellipsis">...</span></span>]</span>]]]]], 
                                                     [ <span class="pl-atom">'Cons'</span>, 
                                                       <span class="pl-int">3</span>, 
                                                       <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">4</span>|<span class="pl-ellipsis">...</span></span>]</span>]]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_17</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_33</span>, 
                                                   <span class="pl-var">_FARL_34</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_33</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">4</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">A</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">3</span>, <span class="pl-var">A</span>, <span class="pl-var">B</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">2</span>, <span class="pl-var">B</span>, <span class="pl-var">C</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">1</span>, <span class="pl-var">C</span>, <span class="pl-var">D</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">0</span>, <span class="pl-var">D</span>, <span class="pl-var">E</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'List.takeNFrom'</span>, <span class="pl-int">3</span>, <span class="pl-int">2</span>, <span class="pl-var">E</span>, <span class="pl-var">_FA_33</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_33</span>)),
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_34</span>, 
                                                         <span class="pl-compound pl-level-0"><span class="pl-atom">true</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span></span></span>, 
                                                         <span class="pl-var">_FARL_34</span>))  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_33</span>, <span class="pl-var">_FARL_34</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_29).




<span class="pl-atom">top_call_30</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_18</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">'List.takeNFrom'</span>, <span class="pl-int">4</span>, <span class="pl-int">3</span>, 
                                                       [ <span class="pl-atom">'Cons'</span>, 
                                                         <span class="pl-int">0</span>, 
                                                         [ <span class="pl-atom">'Cons'</span>, 
                                                           <span class="pl-int">1</span>, 
                                                           [ <span class="pl-atom">'Cons'</span>, 
                                                             <span class="pl-int">2</span>, 
                                                             [ <span class="pl-atom">'Cons'</span>, 
                                                               <span class="pl-int">3</span>, 
                                                               <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">4</span>|<span class="pl-ellipsis">...</span></span>]</span>]]]]], 
                                                     <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">4</span>|<span class="pl-ellipsis">...</span></span>]</span>]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_18</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_35</span>, 
                                                   <span class="pl-var">_FARL_36</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_35</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">4</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">A</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">3</span>, <span class="pl-var">A</span>, <span class="pl-var">B</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">2</span>, <span class="pl-var">B</span>, <span class="pl-var">C</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">1</span>, <span class="pl-var">C</span>, <span class="pl-var">D</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">0</span>, <span class="pl-var">D</span>, <span class="pl-var">E</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'List.takeNFrom'</span>, <span class="pl-int">4</span>, <span class="pl-int">3</span>, <span class="pl-var">E</span>, <span class="pl-var">_FA_35</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_35</span>)),
                                                      (<span class="pl-compound pl-level-0"><span class="pl-functor">findall_ne</span>(<span class="pl-args"><span class="pl-var">_FA_36</span>, (<span class="pl-compound"><span class="pl-atom">true</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span></span>), <span class="pl-var">_FARL_36</span></span>)</span>)  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_35</span>, <span class="pl-var">_FARL_36</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_30).




<span class="pl-atom">top_call_31</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_19</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">'List.takeNFrom'</span>, <span class="pl-int">10</span>, <span class="pl-int">2</span>, 
                                                       [ <span class="pl-atom">'Cons'</span>, 
                                                         <span class="pl-int">0</span>, 
                                                         [ <span class="pl-atom">'Cons'</span>, 
                                                           <span class="pl-int">1</span>, 
                                                           [ <span class="pl-atom">'Cons'</span>, 
                                                             <span class="pl-int">2</span>, 
                                                             <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">3</span>|<span class="pl-ellipsis">...</span></span>]</span>]]]], 
                                                     <span class="pl-atom">'Nil'</span>]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_19</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_37</span>, 
                                                   <span class="pl-var">_FARL_38</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_37</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">3</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">A</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">2</span>, <span class="pl-var">A</span>, <span class="pl-var">B</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">1</span>, <span class="pl-var">B</span>, <span class="pl-var">C</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">0</span>, <span class="pl-var">C</span>, <span class="pl-var">D</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'List.takeNFrom'</span>, <span class="pl-int">10</span>, <span class="pl-int">2</span>, <span class="pl-var">D</span>, <span class="pl-var">_FA_37</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_37</span>)),
                                                      (<span class="pl-compound pl-level-0"><span class="pl-functor">findall_ne</span>(<span class="pl-args"><span class="pl-var">_FA_38</span>, (<span class="pl-compound"><span class="pl-atom">true</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span></span>), <span class="pl-var">_FARL_38</span></span>)</span>)  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_37</span>, <span class="pl-var">_FARL_38</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_31).




<span class="pl-atom">top_call_32</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_20</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">'List.takeNFrom'</span>, <span class="pl-int">2</span>, <span class="pl-int">0</span>, 
                                                       [ <span class="pl-atom">'Cons'</span>, 
                                                         <span class="pl-int">0</span>, 
                                                         [ <span class="pl-atom">'Cons'</span>, 
                                                           <span class="pl-int">1</span>, 
                                                           [ <span class="pl-atom">'Cons'</span>, 
                                                             <span class="pl-int">2</span>, 
                                                             <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">3</span>|<span class="pl-ellipsis">...</span></span>]</span>]]]], 
                                                     <span class="pl-atom">'Nil'</span>]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_20</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_39</span>, 
                                                   <span class="pl-var">_FARL_40</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_39</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">3</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">A</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">2</span>, <span class="pl-var">A</span>, <span class="pl-var">B</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">1</span>, <span class="pl-var">B</span>, <span class="pl-var">C</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">0</span>, <span class="pl-var">C</span>, <span class="pl-var">D</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'List.takeNFrom'</span>, <span class="pl-int">2</span>, <span class="pl-int">0</span>, <span class="pl-var">D</span>, <span class="pl-var">_FA_39</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_39</span>)),
                                                      (<span class="pl-compound pl-level-0"><span class="pl-functor">findall_ne</span>(<span class="pl-args"><span class="pl-var">_FA_40</span>, (<span class="pl-compound"><span class="pl-atom">true</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span></span>), <span class="pl-var">_FARL_40</span></span>)</span>)  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_39</span>, <span class="pl-var">_FARL_40</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_32).




<span class="pl-atom">top_call_33</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_21</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'List.takeNFrom'</span>, <span class="pl-int">0</span>|<span class="pl-ellipsis">...</span></span>]</span>, 
                                                     <span class="pl-atom">'Nil'</span>]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_21</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_41</span>, 
                                                   <span class="pl-var">_FARL_42</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-compound pl-level-0"><span class="pl-functor">findall_ne</span>(<span class="pl-args"><span class="pl-var">_FA_41</span>, (<span class="pl-compound"><span class="pl-atom">true</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span></span>), <span class="pl-var">_FARL_41</span></span>)</span>),
                                                      (<span class="pl-compound pl-level-0"><span class="pl-functor">findall_ne</span>(<span class="pl-args"><span class="pl-var">_FA_42</span>, (<span class="pl-compound"><span class="pl-atom">true</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span></span>), <span class="pl-var">_FARL_42</span></span>)</span>)  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_41</span>, <span class="pl-var">_FARL_42</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_33).




<span class="pl-atom">top_call_34</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_22</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">'List.takeNFrom'</span>, <span class="pl-int">4</span>, <span class="pl-int">1</span>, 
                                                       [ <span class="pl-atom">'Cons'</span>, 
                                                         <span class="pl-int">0</span>, 
                                                         [ <span class="pl-atom">'Cons'</span>, 
                                                           <span class="pl-int">1</span>, 
                                                           [ <span class="pl-atom">'Cons'</span>, 
                                                             <span class="pl-int">2</span>, 
                                                             [ <span class="pl-atom">'Cons'</span>, 
                                                               <span class="pl-int">3</span>, 
                                                               <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">4</span>|<span class="pl-ellipsis">...</span></span>]</span>]]]]], 
                                                     <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">4</span>|<span class="pl-ellipsis">...</span></span>]</span>]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_22</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_43</span>, 
                                                   <span class="pl-var">_FARL_44</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_43</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">4</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">A</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">3</span>, <span class="pl-var">A</span>, <span class="pl-var">B</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">2</span>, <span class="pl-var">B</span>, <span class="pl-var">C</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">1</span>, <span class="pl-var">C</span>, <span class="pl-var">D</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">0</span>, <span class="pl-var">D</span>, <span class="pl-var">E</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'List.takeNFrom'</span>, <span class="pl-int">4</span>, <span class="pl-int">1</span>, <span class="pl-var">E</span>, <span class="pl-var">_FA_43</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_43</span>)),
                                                      (<span class="pl-compound pl-level-0"><span class="pl-functor">findall_ne</span>(<span class="pl-args"><span class="pl-var">_FA_44</span>, (<span class="pl-compound"><span class="pl-atom">true</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span></span>), <span class="pl-var">_FARL_44</span></span>)</span>)  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_43</span>, <span class="pl-var">_FARL_44</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_34).




<span class="pl-atom">top_call_35</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_23</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">'List.takeNFrom'</span>, <span class="pl-int">2</span>, <span class="pl-int">10</span>, 
                                                       [ <span class="pl-atom">'Cons'</span>, 
                                                         <span class="pl-int">0</span>, 
                                                         [ <span class="pl-atom">'Cons'</span>, 
                                                           <span class="pl-int">1</span>, 
                                                           [ <span class="pl-atom">'Cons'</span>, 
                                                             <span class="pl-int">2</span>, 
                                                             <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">3</span>|<span class="pl-ellipsis">...</span></span>]</span>]]]], 
                                                     [ <span class="pl-atom">'Cons'</span>, 
                                                       <span class="pl-int">2</span>, 
                                                       <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">3</span>|<span class="pl-ellipsis">...</span></span>]</span>]]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_23</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_45</span>, 
                                                   <span class="pl-var">_FARL_46</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_45</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">3</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">A</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">2</span>, <span class="pl-var">A</span>, <span class="pl-var">B</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">1</span>, <span class="pl-var">B</span>, <span class="pl-var">C</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">0</span>, <span class="pl-var">C</span>, <span class="pl-var">D</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'List.takeNFrom'</span>, <span class="pl-int">2</span>, <span class="pl-int">10</span>, <span class="pl-var">D</span>, <span class="pl-var">_FA_45</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_45</span>)),
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_46</span>, 
                                                         <span class="pl-compound pl-level-0"><span class="pl-atom">true</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span><span class="pl-infix">,</span><span class="pl-compound"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span>, <span class="pl-ellipsis">...</span></span>)</span></span></span>, 
                                                         <span class="pl-var">_FARL_46</span>))  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_45</span>, <span class="pl-var">_FARL_46</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_35).




<span class="pl-atom">top_call_36</span>:- <span class="pl-atom">do_metta_runtime</span><span class="pl-functor">( <span class="pl-var">ExecRes</span>, </span>
                                               ((&#13;&#10; 
                                                (<span class="pl-var">_Src_24</span> =  
                                                      
                                                   [ <span class="pl-atom">assertEqual</span>, 
                                                     [ <span class="pl-atom">'List.takeNFrom'</span>, <span class="pl-int">2</span>, <span class="pl-int">10</span>, 
                                                       [ <span class="pl-atom">'Cons'</span>, 
                                                         <span class="pl-int">0</span>, 
                                                         [ <span class="pl-atom">'Cons'</span>, 
                                                           <span class="pl-int">1</span>, 
                                                           [ <span class="pl-atom">'Cons'</span>, 
                                                             <span class="pl-int">2</span>, 
                                                             [ <span class="pl-atom">'Cons'</span>, 
                                                               <span class="pl-int">3</span>, 
                                                               <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">4</span>|<span class="pl-ellipsis">...</span></span>]</span>]]]]], 
                                                     [ <span class="pl-atom">'Cons'</span>, 
                                                       <span class="pl-int">2</span>, 
                                                       [ <span class="pl-atom">'Cons'</span>, 
                                                         <span class="pl-int">3</span>, 
                                                         <span class="pl-list"><span class="pl-functor"> [ </span><span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">4</span>|<span class="pl-ellipsis">...</span></span>]</span>]]]),
                                                (<span class="pl-atom">loonit_assert_source_tf_empty</span>( <span class="pl-compound pl-level-0"><span class="pl-functor">src</span>(<span class="pl-args"><span class="pl-var">_Src_24</span></span>)</span>, 
                                                   <span class="pl-var">_FARL_47</span>, 
                                                   <span class="pl-var">_FARL_48</span>, 
                                                     ((&#13;&#10; 
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_47</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">4</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">A</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">3</span>, <span class="pl-var">A</span>, <span class="pl-var">B</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">2</span>, <span class="pl-var">B</span>, <span class="pl-var">C</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">1</span>, <span class="pl-var">C</span>, <span class="pl-var">D</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">0</span>, <span class="pl-var">D</span>, <span class="pl-var">E</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'List.takeNFrom'</span>, <span class="pl-int">2</span>, <span class="pl-int">10</span>, <span class="pl-var">E</span>, <span class="pl-var">_FA_47</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_47</span>)),
                                                      (<span class="pl-atom">findall_ne</span>( <span class="pl-var">_FA_48</span>, 
                                                         ( <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">4</span>, <span class="pl-atom">'Nil'</span>, <span class="pl-var">F</span></span>)</span>  ,
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">3</span>, <span class="pl-var">F</span>, <span class="pl-var">G</span></span>)</span> , 
                                                           <span class="pl-compound pl-level-0"><span class="pl-functor">me</span>(<span class="pl-args"><span class="pl-atom">'Cons'</span>, <span class="pl-int">2</span>, <span class="pl-var">G</span>, <span class="pl-var">_FA_48</span></span>)</span>), 
                                                         <span class="pl-var">_FARL_48</span>))  )), 
                                                   <span class="pl-compound pl-level-0"><span class="pl-functor">equal_enough_for_test</span>(<span class="pl-args"><span class="pl-var">_FARL_47</span>, <span class="pl-var">_FARL_48</span></span>)</span>, 
                                                   <span class="pl-var">ExecRes</span>))  ))).




top_call :-
    time(top_call_36).


%% Finished generating /home/karanos/meTTa-moses/metta-moses/utilities/tests/list-methods-test.metta at 2025-06-27T10:53:40+03:00

:- normal_IO.
:- initialization(transpiled_main, program).
