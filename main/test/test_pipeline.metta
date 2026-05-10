
; End-to-end MeTTa pipeline test:
;   Setup -> Context -> Appraisal -> Goal Weighting -> Action Selection
;
; Uses hardcoded context signals (bypassing the LLM API).
; Each test section uses !(test ...) for hard assertions where safe,
; and !(println! ...) to inspect computed values.



; ── imports ──────────────────────────────────────────────────
!(import! &self ../../utils/general-helper)
!(import! &self ../../operators/appraisal)
!(import! &self ../../operators/decision)
!(import! &self ../../operators/action)
!(import! &self ../../operators/routing)


; ═══════════════════════════════════════════════════════════════
; TEST 1 — Utility helpers (_clamp01, _clamp11, replaceByIndex)
; ═══════════════════════════════════════════════════════════════
!(println! "=== TEST 1: Utility Helpers ===")

; --- _clamp01 ---
!(test (_clamp01 0.5)   0.5)       ; in range -> unchanged
!(test (_clamp01 -0.3)  0)         ; below   -> floor at 0
!(test (_clamp01 1.5)   1)         ; above   -> cap at 1
!(test (_clamp01 0.01)  0.01)      ; near-zero in range
!(test (_clamp01 0.99)  0.99)      ; near-one in range

; --- _clamp11 ---
!(test (_clamp11 0.5)   0.5)       ; in range -> unchanged
!(test (_clamp11 -0.5)  -0.5)      ; in range -> unchanged
!(test (_clamp11 -1.5)  -1)        ; below   -> floor at -1
!(test (_clamp11 1.5)   1)         ; above   -> cap at 1

; --- replaceByIndex ---
!(test (replaceByIndex (a b c) 0 x)   (x b c))   ; first element
!(test (replaceByIndex (a b c) 1 x)   (a x c))   ; middle element
!(test (replaceByIndex (a b c) 2 x)   (a b x))   ; last element

; --- find_by_key ---
!(test (find_by_key color ((color red) (size 10)))    red)
!(test (find_by_key size  ((color red) (size 10)))    10)

!(println! "TEST 1 passed - Utility helpers")


; ═══════════════════════════════════════════════════════════════
; TEST 2 — Space setup: create space, add alpha + initial state
; ═══════════════════════════════════════════════════════════════
!(println! "=== TEST 2: Space Setup ===")

!(bind! &space (new-space))
!(addAlpha &space (alpha))
!(addState &space (state (turn 0) (default-goals) (default-mods) (default-anti-goals) (alpha)))

; Verify state is retrievable via getState (inspected, not compared
; against the full symbolic literal to avoid nondeterminism issues)
!(let $s (getState &space)
    (println! ("  State retrieved OK:" $s))
)

!(println! "TEST 2 passed - Space setup")


; ═══════════════════════════════════════════════════════════════
; TEST 3 — Alpha hyper-parameter retrieval
; ═══════════════════════════════════════════════════════════════
!(println! "=== TEST 3: Alpha Retrieval ===")

!(test (getAlpha &space urgency_alpha)             0.60)
!(test (getAlpha &space resolution_alpha)          0.45)
!(test (getAlpha &space expertise_alpha)           0.45)
!(test (getAlpha &space threshold_alpha)           0.40)
!(test (getAlpha &space familiarity_alpha)         0.35)
!(test (getAlpha &space failure_decay)             0.20)
!(test (getAlpha &space securing_alpha)            0.45)
!(test (getAlpha &space approach_alpha)            0.40)
!(test (getAlpha &space arousal_alpha)             0.40)
!(test (getAlpha &space risk_aversion_alpha)       0.45)
!(test (getAlpha &space error_tolerance_alpha)     0.40)
!(test (getAlpha &space creativity_alpha)          0.40)
!(test (getAlpha &space valence_alpha)             0.40)
!(test (getAlpha &space cold_start_horizon)        2.0)
!(test (getAlpha &space cold_start_strength)       0.70)
!(test (getAlpha &space goal_alpha)                0.18)
!(test (getAlpha &space anti_goal_alpha)           0.16)
!(test (getAlpha &space reflective_think_bonus)    0.14)
!(test (getAlpha &space reflective_search_penalty) 0.10)
!(test (getAlpha &space intent_margin)             0.12)

!(println! "TEST 3 passed - Alpha retrieval")


; ═══════════════════════════════════════════════════════════════
; TEST 4 — Default modulator retrieval (individual fields)
; ═══════════════════════════════════════════════════════════════
!(println! "=== TEST 4: Default Modulator Retrieval ===")

!(test (getMod &space m_urgency)           0.20)
!(test (getMod &space m_resolution)        0.40)
!(test (getMod &space m_user_expertise)    0.50)
!(test (getMod &space m_threshold)         0.30)
!(test (getMod &space m_topic_familiarity) 0.50)
!(test (getMod &space m_failure_wariness)  0.10)
!(test (getMod &space m_securing)          0.10)
!(test (getMod &space m_approach)          0.40)
!(test (getMod &space m_arousal)           0.40)
!(test (getMod &space m_risk_aversion)     0.40)
!(test (getMod &space m_error_tolerance)   0.45)
!(test (getMod &space m_creativity)        0.45)
!(test (getMod &space m_valence)           0.00)

; Full modulator vector comparison (safe: only one getMods definition)
!(test (getMods &space) (default-mods))

!(println! "TEST 4 passed - Default modulator retrieval")


; ═══════════════════════════════════════════════════════════════
; TEST 5 — Default goal retrieval (individual fields only) because there is 2 (getGoals)functions inside
;decision L49 and appraisal L15 
; ═══════════════════════════════════════════════════════════════
!(println! "=== TEST 5: Default Goal Retrieval ===")

!(test (getGoal &space efficiency)           0.60)
!(test (getGoal &space accuracy)             0.70)
!(test (getGoal &space success_moderate)     0.62)
!(test (getGoal &space knowledge)            0.52)
!(test (getGoal &space novelty)              0.46)
!(test (getGoal &space success_breakthrough) 0.44)
!(test (getGoal &space coherence)            0.58)
!(test (getGoal &space originality)          0.48)
!(test (getGoal &space social)               0.58)
!(test (getGoal &space help_short)           0.55)
!(test (getGoal &space help_long)            0.45)
!(test (getGoal &space over_beneficial)      0.60)
!(test (getGoal &space over_safety)          0.65)
!(test (getGoal &space over_honesty)         0.65)

!(println! "TEST 5 passed - Default goal retrieval")


; ═══════════════════════════════════════════════════════════════
; TEST 6 — Anti-goal retrieval
; ═══════════════════════════════════════════════════════════════
!(println! "=== TEST 6: Anti-Goal Retrieval ===")

!(test (getAntiGoals &space) (default-anti-goals))

!(println! "TEST 6 passed - Anti-goal retrieval")


; ═══════════════════════════════════════════════════════════════
; TEST 7 — Context storage and retrieval (14 signals)
; ═══════════════════════════════════════════════════════════════
!(println! "=== TEST 7: Context Storage and Retrieval ===")

!(add-context &space (
   (complexity              0.70)
   (threshold               0.80)
   (ambiguity               0.30)
   (urgent                  0)
   (intent_type             factual)
   (expertise               0.60)
   (topic_familiarity       0.40)
   (failure_signal          0.00)
   (verify_request          1)
   (reflective_intent       0.30)
   (needs_external_evidence 0.90)
   (needs_task_plan         0.20)
   (needs_multi_source_integration 0.80)
   (valence                 0.00)
))

!(test (getContext &space complexity)              0.70)
!(test (getContext &space threshold)               0.80)
!(test (getContext &space ambiguity)               0.30)
!(test (getContext &space urgent)                  0)
!(test (getContext &space intent_type)             factual)
!(test (getContext &space expertise)               0.60)
!(test (getContext &space topic_familiarity)       0.40)
!(test (getContext &space failure_signal)          0.00)
!(test (getContext &space verify_request)          1)
!(test (getContext &space reflective_intent)       0.30)
!(test (getContext &space needs_external_evidence) 0.90)
!(test (getContext &space needs_task_plan)         0.20)
!(test (getContext &space needs_multi_source_integration) 0.80)
!(test (getContext &space valence)                 0.00)

!(println! "TEST 7 passed - Context storage and retrieval")


; ═══════════════════════════════════════════════════════════════
; TEST 8 — Goal update (single field via updateGoal)
; ═══════════════════════════════════════════════════════════════
!(println! "=== TEST 8: Goal Update ===")

!(updateGoal &space knowledge 0.80)
!(test (getGoal &space knowledge) 0.80)

; Other goals remain unchanged
!(test (getGoal &space efficiency) 0.60)
!(test (getGoal &space accuracy)   0.70)

; Restore
!(updateGoal &space knowledge 0.52)
!(test (getGoal &space knowledge) 0.52)

!(println! "TEST 8 passed - Goal update")


; ═══════════════════════════════════════════════════════════════
; TEST 9 — Modulator batch update (update-mods)
; ═══════════════════════════════════════════════════════════════
!(println! "=== TEST 9: Modulator Batch Update ===")

!(update-mods &space (
   (m_urgency           0.10)
   (m_resolution        0.55)
   (m_user_expertise    0.50)
   (m_threshold         0.50)
   (m_topic_familiarity 0.60)
   (m_failure_wariness  0.10)
   (m_securing          0.20)
   (m_approach          0.50)
   (m_arousal           0.45)
   (m_risk_aversion     0.35)
   (m_error_tolerance   0.45)
   (m_creativity        0.50)
   (m_valence           -0.10)
))

!(test (getMod &space m_urgency)           0.10)
!(test (getMod &space m_resolution)        0.55)
!(test (getMod &space m_threshold)         0.50)
!(test (getMod &space m_topic_familiarity) 0.60)
!(test (getMod &space m_securing)          0.20)
!(test (getMod &space m_approach)          0.50)
!(test (getMod &space m_valence)          -0.10)

; Restore defaults for next tests
!(update-mods &space (
   (m_urgency           0.20)
   (m_resolution        0.40)
   (m_user_expertise    0.50)
   (m_threshold         0.30)
   (m_topic_familiarity 0.50)
   (m_failure_wariness  0.10)
   (m_securing          0.10)
   (m_approach          0.40)
   (m_arousal           0.40)
   (m_risk_aversion     0.40)
   (m_error_tolerance   0.45)
   (m_creativity        0.45)
   (m_valence           0.00)
))
!(test (getMod &space m_urgency) 0.20)

!(println! "TEST 9 passed - Modulator batch update")


; ═══════════════════════════════════════════════════════════════
; TEST 10 — State removal and re-addition
; ═══════════════════════════════════════════════════════════════
!(println! "=== TEST 10: State Remove and Re-add ===")

!(remove-state &space)

; After removal: state match returns empty
!(test (let $s (getState &space) $s) ())

; Add state back
!(addState &space (state (turn 0) (default-goals) (default-mods) (default-anti-goals) (alpha)))

; Verify it came back via field checks
!(test (getMod &space m_urgency)   0.20)
!(test (getGoal &space accuracy)   0.70)

!(println! "TEST 10 passed - State remove and re-add")


; ═══════════════════════════════════════════════════════════════
; TEST 11 — Appraisal computation (appraisalModulator)
;   Core EMA test: given context signals + default state,
;   run the full appraisal and verify modulators shifted.
;   Expected EMA results (turn=0, cold-start active):
;     m_urgency:    (1-0.60)*0.20 + 0.60*0.0  = 0.08
;     m_resolution: (1-0.45)*0.40 + 0.45*0.70 = 0.535
;     m_threshold:  (1-0.40)*0.30 + 0.40*0.80 = 0.50
; ═══════════════════════════════════════════════════════════════
!(println! "=== TEST 11: Appraisal Computation ===")

!(let $r (appraisalModulator &space)
    (println! ("  Appraisal returned:" $r))
)

; Hard assertions
; All values confirmed analytically and from a reference run (turn=0, coldWeight=0.70)
!(test (getMod &space m_urgency)          0.08000000000000002)   ; (1-0.60)×0.20 + 0.60×0.0
!(test (getMod &space m_resolution)       0.535)                 ; (1-0.45)×0.40 + 0.45×0.70
!(test (getMod &space m_user_expertise)   0.545)                 ; (1-0.45)×0.50 + 0.45×0.60
!(test (getMod &space m_threshold)        0.5)                   ; (1-0.40)×0.30 + 0.40×0.80
!(test (getMod &space m_topic_familiarity) 0.46499999999999997)  ; (1-0.35)×0.50 + 0.35×0.40
!(test (getMod &space m_failure_wariness) 0.08000000000000002)   ; (1-0.20)×0.10 + 0.20×0.00
!(test (getMod &space m_securing)         0.262)                 ; target=0.46, (1-0.45)×0.10 + 0.45×0.46
!(test (getMod &space m_approach)         0.492)                 ; target=0.63
!(test (getMod &space m_arousal)          0.4851)                ; target=~0.6128
!(test (getMod &space m_risk_aversion)    0.39100000000000007)   ; target=0.38
!(test (getMod &space m_error_tolerance)  0.538)                 ; target=0.67
!(test (getMod &space m_creativity)       0.554)                 ; target=0.71
!(test (getMod &space m_valence)          0.0)                   ; target=0.00

!(println! "TEST 11 passed - Appraisal computation ran successfully")


; ═══════════════════════════════════════════════════════════════
; ROUTING PIPELINE TEST SUITE (Symbols Refactor)
; ═══════════════════════════════════════════════════════════════

!(println! "=== ROUTING PIPELINE TEST SUITE START ===")

;; TEST HELPERS & INITIALIZATION
;; ============================================================

;; Standard baseline scores for all actions
(= (init-scores)
   ((Score act_decompose 0.5)
    (Score act_search 0.5)
    (Score act_synthesize 0.5)
    (Score act_verify 0.5)
    (Score act_clarify 0.5)
    (Score act_think 0.5)
    (Score act_respond 0.5)))

;; A complete default context to avoid KeyNotFound errors during tests
(= (full-ctx)
   ((complexity 0.5)
    (ambiguity 0.1)
    (urgent_flag false)
    (reflective_intent 0.1)
    (needs_external_evidence 0.1)
    (needs_task_plan 0.1)
    (needs_multi_source_integration 0.1)
    (decompose_min_complexity 0.4)
    (decompose_urgent_min_complexity 0.3)
    (decompose_max_ambiguity 0.6)
    (verify_request false)
    (intent_type factual)
    (threshold 0.5)
    (low_confidence 0.1)
    (failure_wariness 0.1)
    (approach 0.5)
    (threshold_signal 0.1)
    (failure_signal 0.1)
    (familiarity_signal 0.5)
    (help_short 0.5)))

;; Helper to update context keys for specific test cases
(= (update-ctx () $key $val) (($key $val)))
(= (update-ctx (($k $v) $rest) $key $val)
   (if (== $k $key)
       (($key $val) $rest)
       (($k $v) (update-ctx $rest $key $val))))

;; Helper to extract a single score value for assertions
(= (check-score $scores $act) (get-action-score $scores $act))

;; ============================================================
;; TEST CASE 1: DECOMPOSE GUARD (BLOCKING)
;; Goal: Verify decompose is blocked when complexity (complexity) is too low.
;; ============================================================
!(println! "Running Test 1: Decompose Logic...")
!(let* (
    ($ctx (update-ctx (full-ctx) complexity 0.1))
    ($result (guard-decompose (init-scores) $ctx))
) (test (check-score $result act_decompose) (ACTION_BLOCKED_SCORE)))

;; ============================================================
;; TEST CASE 2: SEARCH & SYNTH LOCAL GUARDS
;; Goal: Verify search is boosted when external evidence needs are high.
;; ============================================================
!(println! "Running Test 2: Search Boosting...")
!(let* (
    ($ctx (update-ctx (update-ctx (full-ctx) needs_external_evidence 0.8) needs_task_plan 0.2))
    ($result (guard-search-synth (init-scores) $ctx))
    ($score (check-score $result act_search))
) (test (== $score 0.92) true)) ;; 0.5 + 0.3 + 0.12

;; ============================================================
;; TEST CASE 3: ARBITRATION (SEARCH VS DECOMPOSE)
;; Goal: Verify Search wins when external evidence dominates task planning.
;; ============================================================
!(println! "Running Test 3: Arbitration Logic...")
!(let* (
    ($ctx (update-ctx (update-ctx (full-ctx) needs_external_evidence 0.9) needs_task_plan 0.1))
    ($result (guard-search-arb (init-scores) $ctx))
) (test (> (check-score $result act_search) (check-score $result act_decompose)) true))

;; ============================================================
;; TEST CASE 4: VERIFY GUARD
;; Goal: Verify act_verify is blocked if not requested and low confidence is low.
;; ============================================================
!(println! "Running Test 4: Verify Blocking...")
!(let* (
    ($ctx (update-ctx (update-ctx (full-ctx) verify_request false) low_confidence 0.1))
    ($result (guard-verify (init-scores) $ctx))
) (test (check-score $result act_verify) (ACTION_BLOCKED_SCORE)))

;; ============================================================
;; TEST CASE 5: FAST LANE (ULTRA FAST)
;; Goal: Verify all complex actions blocked and respond is boosted for simple input.
;; ============================================================
!(println! "Running Test 5: Fast Lane Trigger...")
!(let* (
    ($ctx (update-ctx (update-ctx (update-ctx (update-ctx (update-ctx (update-ctx (full-ctx) 
          complexity 0.1) ambiguity 0.1) familiarity_signal 0.9) 
          threshold_signal 0.1) failure_signal 0.1) 
          low_confidence 0.1))
    ($result (guard-fast-lane (init-scores) $ctx))
) (test (and (== (check-score $result act_search) (ACTION_BLOCKED_SCORE))
             (== (check-score $result act_think) (ACTION_BLOCKED_SCORE))) true))

;; ============================================================
;; TEST CASE 6: TIE-BREAKER (INTENT SELECTION)
;; Goal: Verify act_think is preferred in a tie when intent is reflective.
;; ============================================================
!(println! "Running Test 6: Tie-Breaker Logic...")
!(let* (
    ;; Tie search and think at 0.7
    ($scores ((Score act_search 0.7) (Score act_think 0.7)))
    ($ctx (update-ctx (update-ctx (update-ctx (full-ctx) intent_type reflective) low_confidence 0.1) threshold 0.1))
    ($margin 0.05)
    ((Result $best $top3) (select-action $scores $ctx $margin))
) (test $best (Score act_think 0.7501)))

;; ============================================================
;; TEST CASE 7: FULL PIPELINE INTEGRATION
;; Goal: Ensure the entire chain runs and produces a valid winning Score.
;; ============================================================
!(println! "Running Test 7: Full Pipeline Integration...")
!(let* (
    ($ctx (update-ctx (update-ctx (update-ctx (full-ctx) 
          complexity 0.8) ambiguity 0.1) needs_external_evidence 0.9))
    ($final_scores (apply-routing-guards (init-scores) $ctx))
    ($result (select-action $final_scores $ctx 0.05))
) (println! (format "Final Result: {}" $result)))