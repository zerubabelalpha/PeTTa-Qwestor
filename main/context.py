import math
import requests
import json
from typing import Any, Optional,Dict
from dotenv import load_dotenv
import re
import os

def _clamp01(x: float) -> float:
    return max(0.0, min(1.0, x))

def _clamp11(x: float) -> float:
    return max(-1.0, min(1.0, x))


def _coerce_bool(value: Any) -> Optional[bool]:
    if isinstance(value, bool):
        return value
    if isinstance(value, str):
        return value.strip().lower() in {"true", "yes", "y", "1"}
    if isinstance(value, (int, float)):
        return bool(value)
    return None

def _extract_json(text: str) -> dict:
    """Extract JSON from text, handling markdown code blocks."""
    if not isinstance(text, str):
        print(f"Warning: _extract_json received non-string: {type(text)}")
        return {}
        
    print(f"Attempting to extract JSON from: {text[:200]}...")  # Debug print
    
    # Try to find JSON in ```json ... ``` blocks
    json_pattern = r'```(?:json)?\s*(\{.*?\})\s*```'
    matches = re.findall(json_pattern, text, re.DOTALL)
    if matches:
        try:
            return json.loads(matches[0])
        except json.JSONDecodeError as e:
            print(f"Failed to parse JSON from code block: {e}")
    
    # Try to find JSON in { ... } directly
    brace_pattern = r'(\{.*\})'
    matches = re.findall(brace_pattern, text, re.DOTALL)
    if matches:
        try:
            return json.loads(matches[0])
        except json.JSONDecodeError as e:
            print(f"Failed to parse JSON from braces: {e}")
    
    # Try to find anything that looks like key-value pairs
    try:
        # Look for patterns like "key": value
        possible_json = re.search(r'\{[^}]+\}', text)
        if possible_json:
            return json.loads(possible_json.group())
    except:
        pass
    
    # Last resort: try to parse the whole text
    try:
        return json.loads(text)
    except json.JSONDecodeError:
        print(f"Could not parse as JSON: {text[:200]}")
        return {}

def _calibrate_action_signals(
    needs_external_evidence: float,
    needs_task_plan: float,
    needs_multi_source_integration: float,
    ambiguity: float,
    intent_type: str,
    reflective_intent: float,
) -> tuple[float, float, float]:
    """Calibrate action signals based on context."""
    # Your existing calibration logic here
    return (
        needs_external_evidence,
        needs_task_plan,
        needs_multi_source_integration,
    )

def parse_with_openrouter(
    query: str, 
    api_key: str, 
    model: str = "openai/gpt-4o-mini"
) -> dict[str, Any] | None:
    """
    Parse a user query using OpenRouter API.
    """
    try:
        url = "https://openrouter.ai/api/v1/chat/completions"
        
        headers = {
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
            "HTTP-Referer": "http://localhost",
            "X-Title": "Qwestor Context Parser"
        }
        
        system_prompt = (
            "You are a JSON-only response bot. Return ONLY valid JSON, no other text, no markdown, no explanation. "
            "The JSON must exactly match this schema: "
            '{"urgent": integer, "complexity": number, "ambiguity": number, "expertise": number, "threshold": number, "topic_familiarity": number, "failure_signal": number, "intent_type": string, "reflective_intent": number, "verify_request": integer, "needs_external_evidence": number, "needs_task_plan": number, "needs_multi_source_integration": number, "valence": number}. '
            "Rules: "
            "- urgent"
            "- complexity, ambiguity, expertise, threshold, topic_familiarity, failure_signal are each 0..1. "
            "- valence is in [-1,1] (-1=negative, +1=positive, 0=neutral). "
            "- intent_type must be one of: reflective, factual, mixed. "
            "- reflective_intent is 0..1 (how much internal reasoning needed). "
            "- verify_request is true ONLY if user explicitly asks to verify/fact-check. "
            "- needs_external_evidence is 0..1 (need for external search). "
            "- needs_task_plan is 0..1 (need for step-by-step plan). "
            "- needs_multi_source_integration is 0..1 (need to synthesize multiple sources). "
            "Interpretation guidelines: "
            "- expertise 0 = novice language, 1 = expert language. "
            "- threshold high = need caution. "
            "- topic_familiarity high = assistant likely knows this well. "
            "- failure_signal high = user indicates previous problem. "
            "IMPORTANT: Return ONLY the JSON object, no other text."
        )
        
        payload = {
            "model": model,
            "messages": [
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": query}
            ],
            "temperature": 0,
            "max_tokens": 500
        }
        
        print(f"Sending request to OpenRouter with model: {model}")
        response = requests.post(url, headers=headers, json=payload, timeout=30)
        
        # Print response status for debugging
        print(f"Response status: {response.status_code}")
        
        if response.status_code != 200:
            print(f"Error response: {response.text}")
            response.raise_for_status()
        
        data = response.json()
        
        # Debug: print the full response structure
        print("Response received, extracting content...")
        
        # Extract the response content safely
        if "choices" not in data:
            print(f"Unexpected response structure: {json.dumps(data, indent=2)[:500]}")
            return None
            
        if not data["choices"]:
            print("No choices in response")
            return None
            
        message = data["choices"][0].get("message", {})
        raw_content = message.get("content", "")
        
        if not raw_content:
            print("Empty content in response")
            return None
            
        print(f"Raw content received: {raw_content[:500]}")  # Debug first 500 chars
        
        # Parse JSON from response
        payload = _extract_json(raw_content)
        
        if not payload:
            print(f"Failed to extract JSON from response")
            print(f"Full response content: {raw_content}")
            return None
        
        print(f"Successfully parsed JSON: {json.dumps(payload, indent=2)[:500]}")
        
        # Extract fields with defaults
        urgent_raw = payload.get("urgent", None)
        complexity_raw = payload.get("complexity", None)
        ambiguity_raw = payload.get("ambiguity", None)
        expertise_raw = payload.get("expertise", None)
        threshold_raw = payload.get("threshold", 0.3)
        topic_familiarity_raw = payload.get("topic_familiarity", 0.5)
        failure_signal_raw = payload.get("failure_signal", 0.0)
        intent_type_raw = str(payload.get("intent_type", "mixed")).strip().lower()
        reflective_intent_raw = payload.get("reflective_intent", 0.5)
        verify_request_raw = payload.get("verify_request", False)
        needs_external_evidence_raw = payload.get("needs_external_evidence", 0.3)
        needs_task_plan_raw = payload.get("needs_task_plan", 0.2)
        needs_multi_source_integration_raw = payload.get(
            "needs_multi_source_integration", 0.3
        )
        valence_raw = payload.get("valence", 0.0)
        
        # Coerce boolean values
        urgent = _coerce_bool(urgent_raw)
        if urgent is None:
            urgent = False
            print("Warning: urgent defaulted to False")
        
        verify_request = _coerce_bool(verify_request_raw)
        if verify_request is None:
            verify_request = False
            print("Warning: verify_request defaulted to False")
        
        # Convert and clamp numerical values
        try:
            complexity = _clamp01(float(complexity_raw)) if complexity_raw is not None else 0.3
            ambiguity = _clamp01(float(ambiguity_raw)) if ambiguity_raw is not None else 0.0
            expertise = _clamp01(float(expertise_raw)) if expertise_raw is not None else 0.5
            threshold = _clamp01(float(threshold_raw))
            topic_familiarity = _clamp01(float(topic_familiarity_raw))
            failure_signal = _clamp01(float(failure_signal_raw))
            reflective_intent = _clamp01(float(reflective_intent_raw))
            needs_external_evidence = _clamp01(float(needs_external_evidence_raw))
            needs_task_plan = _clamp01(float(needs_task_plan_raw))
            needs_multi_source_integration = _clamp01(
                float(needs_multi_source_integration_raw)
            )
            valence = _clamp11(float(valence_raw))
        except (ValueError, TypeError) as e:
            print(f"Error converting numerical values: {e}")
            print(f"Raw values: {payload}")
            return None
        
        # Validate intent_type
        if intent_type_raw not in {"reflective", "factual", "mixed"}:
            print(f"Warning: invalid intent_type '{intent_type_raw}', defaulting to 'mixed'")
            intent_type_raw = "mixed"
        
        result = {
            "urgent": urgent,
            "complexity": complexity,
            "ambiguity": ambiguity,
            "expertise": expertise,
            "threshold": threshold,
            "topic_familiarity": topic_familiarity,
            "failure_signal": failure_signal,
            "intent_type": intent_type_raw,
            "reflective_intent": reflective_intent,
            "verify_request": verify_request,
            "needs_external_evidence": needs_external_evidence,
            "needs_task_plan": needs_task_plan,
            "needs_multi_source_integration": needs_multi_source_integration,
            "valence": valence,
        }
        
        print("Successfully parsed context!")
        return result
        
    except requests.exceptions.RequestException as e:
        print(f"Request error: {e}")
        return None
    except Exception as e:
        print(f"Error in parse_with_openrouter: {e}")
        import traceback
        traceback.print_exc()
        return None
def wrap_parser(query):
    """
    Parse a query and return results as a list of [key, value] pairs.
    Boolean values are converted to integers 0 or 1.
    """
    load_dotenv()
    api_key = os.getenv("OPENROUTER_API_KEY")
    model_name = "openai/gpt-4o-mini"
    
    # Get the parsed result (dictionary)
    result_dict = parse_with_openrouter(query, api_key, model=model_name)
    
    if result_dict is None:
        print("⚠️ Using fallback context")
        raise RuntimeError("LLM parsing failed - no context generated")
        # return []  # Return empty list if parsing failed
    
    # Define the order you want
    ordered_keys = [
        "urgent",
        "complexity", 
        "ambiguity",
        "expertise",
        "threshold",
        "topic_familiarity",
        "failure_signal",
        "intent_type",
        "reflective_intent",
        "verify_request",
        "needs_external_evidence",
        "needs_task_plan",
        "needs_multi_source_integration",
        "valence"
    ]
    
    # Create list of lists in the specified order
    result_list = []
    for key in ordered_keys:
        if key in result_dict:
            value = result_dict[key]
            # Convert boolean values to integers 0 or 1
            if isinstance(value, bool):
                value = 1 if value else 0
            # Ensure numbers are proper type
            elif isinstance(value, (int, float)):
                value = float(value) if isinstance(value, float) else value
            result_list.append([key, value])
    
    return result_list

# Example usage
if __name__ == "__main__":
    load_dotenv()
    api_key = os.getenv("OPENROUTER_API_KEY")
    model_name = "openai/gpt-4o-mini"

    print(f"Using API key: {api_key[:5]}...{api_key[-5:] if api_key else 'None'}")
    print(f"Using model: {model_name}")
    
    test_queries = [
        "What's the weather today?",
        "Can you verify if the quantum computing breakthrough is real? I need detailed analysis comparing expert opinions.",
        "Explain neural networks to me step by step.",
        "This answer you gave before was wrong. Can you fix it?"
    ]
    
    # for query in test_queries:
    #     print(f"\n{'='*60}")
    #     print(f"Processing query: {query}")
    #     print('='*60)
        
    #     result = parse_with_openrouter(query, api_key, model=model_name)
        
    #     if result:
    #         print(f"\n✅ SUCCESS! Parsed context:")
    #         print(json.dumps(result, indent=2))
    #     else:
    #         print(f"\n❌ FAILED to parse query: {query}")
    # print(wrap_parser(test_queries[1]))















def check():
    return [
        ["urgent", 0.1],
        ["complexity", 0.2],
        ["ambiguity", 0.3],
        ["expertise", 0.4],
        ["threshold", 0.4],
    ]

def trunc(number):
    return math.trunc(number * 100) / 100




# def action_map_tranpiler(metta_text: str) -> dict:
#     actions = {}

#     # Match each (AG action_name ((...)))
#     pattern = r'\(AG\s+(\w+)\s+\(\((.*?)\)\)\)'
#     matches = re.findall(pattern, metta_text, re.DOTALL)

#     for action_name, metrics_block in matches:
#         metrics = {}

#         # Extract (key value) pairs
#         pairs = re.findall(r'\((\w+)\s+([0-9.]+)\)', metrics_block)

#         for key, value in pairs:
#             metrics[key] = float(value)

#         actions[action_name] = metrics

#     return  "ACTIONS = " + json.dumps(actions)



# py_text="""((efficiency 0.44772) (accuracy 0.6256599999999999) (success_moderate 1.02) (knowledge 0.41340000000000005) (novelty 0.3726) (success_breakthrough 0.37839999999999996) (coherence 0.5655) (originality 0.3504) (social 0.43210000000000004) (help_short 0.5142500000000001) (help_long 0.405) (over_beneficial 0.591) (over_safety 0.6174999999999999) (over_honesty 1.1099667))"""
# print(action_map_transpiler(py_text))
