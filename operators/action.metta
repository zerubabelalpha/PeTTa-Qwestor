!(import! &self appraisal)
!(import! &self "../main/score_action.py")
(= (Actions $space)
 ((AG act_respond (
        (efficiency 1.00)
        (accuracy (eval (_clamp01 (- 1.00 (* 1.10 (getContext $space complexity))))))
        (success_moderate  (eval (_clamp01 (- 0.80 (* 0.20 (getContext $space complexity))))))
        (knowledge  (eval (_clamp01 (+ 0.28 (* 0.18 (getContext $space complexity))))))
        (novelty (eval (_clamp01 (+ 0.18 (* 0.10 (getContext $space complexity))))))
        (success_breakthrough (eval (_clamp01 (+ 0.18  (* 0.12  (getContext $space complexity))))))
        (coherence (eval (_clamp01 (- 0.72 (* 0.10 (getContext $space complexity))))))
        (originality (eval (_clamp01 (+ 0.16 (* 0.10 (getContext $space complexity))))))
        (social (eval (_clamp01 (+ 0.74 (* 0.08 (- 1.0 (getContext $space complexity)))))))
        (help_short (eval (_clamp01 (- 0.95 (* 0.20 (getContext $space complexity))))))
        (help_long (eval (_clamp01 (+ 0.25 (* 0.20 (getContext $space complexity))))))
        (over_beneficial (eval (_clamp01 (- 0.45 (* 0.15 (getContext $space complexity))))))
        (over_safety (eval (_clamp01 (- 0.45 (* 0.20 (getContext $space complexity))))))
        (over_honesty 0.60)

 ))
 (AG act_clarify (
       (efficiency 0.65)
       (accuracy (eval (_clamp01 (+ 0.55 (* 0.25 (getContext $space complexity))))))
       (success_moderate 0.72)
       (knowledge (eval (_clamp01 (+ 0.45 (* 0.20 (getContext $space complexity))))))
       (novelty (eval (_clamp01 (+ 0.28 (* 0.12 (getContext $space complexity))))))
       (success_breakthrough (eval (_clamp01 (+ 0.28 (* 0.12 (getContext $space complexity))))))
       (coherence 0.82)
       (originality (eval (_clamp01 (+ 0.18 (* 0.10 (getContext $space complexity))))))
       (social  0.95)
       (help_short (eval (_clamp01 (+ 0.55 (* 0.10 (- 1.0 (getContext $space complexity)))))))
       (help_long (eval (_clamp01 (+ 0.40 (* 0.20 (getContext $space complexity))))))
       (over_beneficial 0.85)
       (over_safety 0.90)
       (over_honesty 0.95)
 ))

 (AG act_search (
    (efficiency 0.25)
    (accuracy (eval (_clamp01 (+ 0.30 (* 0.90 (getContext $space complexity))))))
    (success_moderate (eval (_clamp01 (+ 0.55 (* 0.20 (getContext $space complexity))))))
    (knowledge (eval (_clamp01 (+ 0.68 (* 0.22 (getContext $space complexity))))))
    (novelty (eval (_clamp01 (+ 0.58 (* 0.18 (getContext $space complexity))))))
    (success_breakthrough (eval (_clamp01 (+ 0.45 (* 0.18 (getContext $space complexity))))))
    (coherence 0.58)
    (originality (eval (_clamp01 (+ 0.48 (* 0.16 (getContext $space complexity))))))
    (social (eval (_clamp01 (+ 0.42 (* 0.12 (- 1.0 (getContext $space complexity)))))))
    (help_short (eval (_clamp01 (+ 0.35 (* 0.10 (- 1.0 (getContext $space complexity)))))))
    (help_long (eval (_clamp01 (+ 0.55 (* 0.35 (getContext $space complexity))))))
    (over_beneficial 0.72)
    (over_safety 0.78)
    (over_honesty 0.82)

 ))
(AG act_verify (
    (efficiency 0.35)
    (accuracy (eval (_clamp01 (+ 0.75 (* 0.20 (getContext $space complexity))))))
    (success_moderate 0.90)
    (knowledge (eval (_clamp01 (+ 0.62 (* 0.15 (getContext $space complexity))))))
    (novelty (eval (_clamp01 (+ 0.25 (* 0.08 (getContext $space complexity))))))
    (success_breakthrough (eval (_clamp01 (+ 0.38 (* 0.10 (getContext $space complexity))))))
    (coherence 0.86)
    (originality (eval (_clamp01 (+ 0.24 (* 0.08 (getContext $space complexity))))))
    (social 0.88)
    (help_short (eval (_clamp01 (+ 0.40 (* 0.10 (- 1.0 (getContext $space complexity)))))))
    (help_long (eval (_clamp01 (+ 0.50 (* 0.20 (getContext $space complexity))))))
    (over_beneficial 0.96)
    (over_safety 0.97)
    (over_honesty 0.97)
))
(AG act_decompose (
    (efficiency 0.45)
    (accuracy (eval (_clamp01 (+ 0.55 (* 0.35 (getContext $space complexity))))))
    (success_moderate (eval (_clamp01 (+ 0.65 (* 0.15 (getContext $space complexity))))))
    (knowledge (eval (_clamp01 (+ 0.72 (* 0.20 (getContext $space complexity))))))
    (novelty (eval (_clamp01 (+ 0.62 (* 0.18 (getContext $space complexity))))))
    (success_breakthrough (eval (_clamp01 (+ 0.62 (* 0.22 (getContext $space complexity))))))
    (coherence 0.80)
    (originality (eval (_clamp01 (+ 0.66 (* 0.18 (getContext $space complexity))))))
    (social 0.72)
    (help_short (eval (_clamp01 (+ 0.30 (* 0.05 (- 1.0 (getContext $space complexity)))))))
    (help_long (eval (_clamp01 (+ 0.70 (* 0.25 (getContext $space complexity))))))
    (over_beneficial 0.70)
    (over_safety 0.76)
    (over_honesty 0.80)
))

(AG act_think (
    (efficiency 0.40)
    (accuracy (eval (_clamp01 (+ 0.60 (* 0.25 (getContext $space complexity))))))
    (success_moderate (eval (_clamp01 (+ 0.45 (* 0.20 (getContext $space complexity))))))
    (knowledge (eval (_clamp01 (+ 0.66 (* 0.18 (getContext $space complexity))))))
    (novelty (eval (_clamp01 (+ 0.70 (* 0.18 (getContext $space complexity))))))
    (success_breakthrough (eval (_clamp01 (+ 0.68 (* 0.20 (getContext $space complexity))))))
    (coherence 0.74)
    (originality (eval (_clamp01 (+ 0.74 (* 0.16 (getContext $space complexity))))))
    (social 0.58)
    (help_short (eval (_clamp01 (+ 0.35 (* 0.10 (- 1.0 (getContext $space complexity)))))))
    (help_long (eval (_clamp01 (+ 0.60 (* 0.25 (getContext $space complexity))))))
    (over_beneficial 0.78)
    (over_safety 0.84)
    (over_honesty 0.90)
))

(AG act_synthesize (
    (efficiency 0.30)
    (accuracy (eval (_clamp01 (+ 0.74 (* 0.12 (getContext $space complexity))))))
    (success_moderate 0.82)
    (knowledge (eval (_clamp01 (+ 0.78 (* 0.16 (getContext $space complexity))))))
    (novelty (eval (_clamp01 (+ 0.56 (* 0.12 (getContext $space complexity))))))
    (success_breakthrough (eval (_clamp01 (+ 0.54 (* 0.14 (getContext $space complexity))))))
    (coherence 0.84)
    (originality (eval (_clamp01 (+ 0.82 (* 0.12 (getContext $space complexity))))))
    (social 0.68)
    (help_short (eval (_clamp01 (+ 0.42 (* 0.08 (- 1.0 (getContext $space complexity)))))))
    (help_long (eval (_clamp01 (+ 0.72 (* 0.18 (getContext $space complexity))))))
    (over_beneficial 0.90)
    (over_safety 0.92)
    (over_honesty 0.95)
 )
 )
 ))


 (= (ActionList $space)
    (collapse (match $space (AG $x $y) $x))
 )
 (= (getAction $space $aciton)
    (match $space (AG $aciton $effects) $effects)
 )
 (= (bindAG $space) 
  (add-atom $space (Actions))
 )

(= (addAction $space $action)
   (trace! "action added into space" (add-atom $space $action))
)
(= (addActions $space $aglist)
(if (== $aglist ())
  (completed)
    (let* (($h (car-atom $aglist))
          ($t (cdr-atom $aglist))
          ($_ (addAction $space $h))
          )
        (addActions $space $t)
            
    )
))


(= (action_score_wraper $space $goalWeight $action_list $scored_action)
 (let* (
   ($appraisal_list (update-mod $space))
   ($ACTIONS (match $space (AG $action_list $effects) (AG $action_list $effects)))
   ($anti_goal (getAntiGoals $space))
   ($cxt_n_alpha (match $space ($x $y) ($x $y)))
   ($goal (getGoals $space))
   ($goalweight (goalWeight $space))

   ($cx (find_by_key cx $appraisal_list))
   ($ambiguity (find_by_key ambiguity $appraisal_list))
   ($ux (find_by_key ux $appraisal_list))
   ($u (find_by_key u $appraisal_list))
   ($res (find_by_key res $appraisal_list))
   ($threshold (find_by_key m_threshold $appraisal_list))
   ($threshold_signal (find_by_key threshold_signal $appraisal_list))
   ($familiarity (find_by_key familiarity $appraisal_list))
   ($failure_wariness (find_by_key failure_wariness $appraisal_list))
   ($urgent_flag (find_by_key urgent_flag $appraisal_list))
   ($familiarity_signal (find_by_key familiarity_signal $appraisal_list))
   ($failure_signal (find_by_key failure_signal $appraisal_list))
   ($securing (find_by_key securing $appraisal_list))
   ($approach (find_by_key approach $appraisal_list))
   ($arousal (find_by_key arousal $appraisal_list))
   ($risk_aversion (find_by_key risk_aversion $appraisal_list))
   ($error_tolerance (find_by_key error_tolerance $appraisal_list))
   ($creativity (find_by_key creativity $appraisal_list))
   ($valence (find_by_key valence $appraisal_list))
   ($low_confidence (_clamp01(- 1.0  $confidence)))
   ($answerability (_clamp01((* (- 1.0 $ambiguity) (* (- 1.0 $threshold_signal)  $familiarity_signal)))))
   ($needs_external_evidence (find_by_key needs_external_evidence $appraisal_list))
   ($needs_task_plan (find_by_key needs_task_plan $appraisal_list))
   ($needs_multi_source_integration (find_by_key needs_task_plan $appraisal_list))
   ($reflective_intent (find_by_key reflective_intent $appraisal_list))
   ($anti_hall (find_by_key hallucinate $anti_goal))
   ($anti_redundant (find_by_key redundant $anti_goal))
   ($anti_redundant (find_by_key redundant $anti_goal))
   ($anti_rabbit_hole (find_by_key rabbit_hole $appraisal_list))
   ($anti_premature (find_by_key premature $appraisal_list))
   ($intent_type (find_by_key intent_type $appraisal_list))
   ($verify_request (find_by_key verify_request $appraisal_list))
   ($coherence (find_by_key conherence $goal))
   ($originality (find_by_key originality $goal))
   ($social (find_by_key social $goal))
   ($help_short (find_by_key help_short $goal))
   ($help_long (find_by_key help_long $goal))
   ($over_beneficial (find_by_key over_beneficial $goal))
   ($over_safety (find_by_key over_safety $goal))
   ($over_honesty (find_by_key over_honesty $goal))
   ($knowledge (find_by_key knowledge $goal))
   ($novelty (find_by_key novelty $goal))
   ($success_breakthrough (find_by_key success_breakthrough $goal))
   ($reflective_think_bonus (find_by_key reflective_think_bonus $ctx_n_alpha))
   ($reflective_search_penalty (find_by_key reflective_search_penalty $ctx_n_alpha))
   
   
 )
 (
 $goalWeight
 $action_list
   $cx
   $ambiguity
   $threshold_signal
   $familiarity_signal
   $failure_signal
   $urgent_flag
   $intent_type
   $verify_request
   $reflective_intent
   $needs_external_evidence
   $needs_task_plan
   $needs_multi_source_integration
   $u
   $res
   $ux
   $threshold
   $familiarity
   $securing
   $approach
   $arousal
   $risk_aversion
   $error_tolerance
   $creativity
   $confidence
   $low_confidence
   $answerability
 )

))