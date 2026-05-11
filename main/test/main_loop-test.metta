; !(addContext (context)) 
; !(+ (* (- 1.0 (get-alpha resolution_alpha)) (getMod m_resolution)) (* (getAlpha resolution_alpha) (get-context complexity)))
; !(_clamp01 (+ (* (- 1.0 (get-alpha resolution_alpha)) (getMod m_resolution)) (* (getAlpha resolution_alpha) (getContext complexity))))
; !(getMods &sp)
; !(update-modulator &sp m_resolution 0.9)
; !(updateGoal &sp energy 0.8)
; !(get_state &sp)
; !(update-mods &sp ((m_urgency 0.0) (m_resolution 0.9) (m_user_expertise 0.5) (m_threshold 0.3) (m_topic_familiarity 0.5) (m_failure_wariness 0.1) (m_securing 0.1) (m_approach 0.4) (m_arousal 0.4) (m_risk_aversion 0.4) (m_error_tolerance 0.45) (m_creativity 0.45) (m_valence 0)))
; !(get_state &sp)



!(import! &self ../../utils/general-helper)
!(import! &self ../../operators/appraisal)
!(import! &self ../../operators/decision)

!(import! &self ../context.py)

(= (addContexts $space $context)
   (if (== $context ())
        (add-context $space (context))
        (add-context $space $context)
    )
)

;  Space init 
!(bind! &space (new-space))
!(addAlpha &space (alpha))
!(addState &space (state (turn 0) (default-goals) (default-mods) (default-anti-goals) (alpha)))
!(println! "Space ready.")

; ======================================================
; TURN 0 — High complexity, factual, multi-source query
; ======================================================
!(println! "")
!(println! "=== TURN 0: High-complexity query ===")

; Step 1: add context atoms
!(addContexts &space (py-call (context.wrap_parser "Can you verify if the quantum computing breakthrough is real? I need detailed analysis comparing expert opinions.")))

!(println! "--- Step 1: context stored ---")

; Step 2: appraisal — EMA modulator update
!(println! "--- Step 2: appraisalModulator ---")
!(appraisalModulator &space)
!(println! ("  m_urgency           =" (getMod &space m_urgency)))
!(println! ("  m_resolution        =" (getMod &space m_resolution)))
!(println! ("  m_valence           =" (getMod &space m_valence)))

; Step 3: goal weighting
!(println! "--- Step 3: goalWeight ---")
!(println! ("  weighted goals:" (goalWeight &space)))
!(println! "Turn 0 complete.")

; =================================
; TURN 1 — Urgent, simple follow-up
; =================================
!(println! "")
!(println! "=== TURN 1: Urgent simple query ===")

; Clear old context
!(clear-context &space)

; Add Turn-1 context
!(addContexts &space (py-call (context.wrap_parser "Quick, I need the answer right now!")))

!(println! "--- Step 1: context stored ---")

; Step 2: appraisal
!(println! "--- Step 2: appraisalModulator ---")
!(appraisalModulator &space)
!(println! ("  m_urgency           =" (getMod &space m_urgency)))
!(println! ("  m_resolution        =" (getMod &space m_resolution)))
!(println! ("  m_valence           =" (getMod &space m_valence)))

; Step 3: goal weighting
!(println! "--- Step 3: goalWeight ---")
!(println! ("  weighted goals:" (goalWeight &space)))
!(println! "Turn 1 complete.")

!(println! "")
!(println! "=== SIMULATION END ===")
