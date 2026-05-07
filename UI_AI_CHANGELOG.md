# SafeSpace UI + AI Changes

This document captures required changes, requested edits, database improvements, and feature ideas for the SafeSpace app.

## Required Changes (Current Gaps)

- API path mismatch: Flutter uses `/api/v1/analyze`, backend also exposes `/v1/analysis`. Ensure Flutter targets `/api/v1/analyze` consistently and backend contract is aligned.
- Response shape mismatch: Flutter `NlpPredictionScreen` reads `text_scores`, but some endpoints return `scores` or `fused_scores`. Standardize response fields.
- Model logic mismatch: Streamlit `app.py` applies keyword boost; `core_ai.py` (API) does not. Align logic so UI and API produce consistent results.
- NLP-only analysis currently sends dummy survey answers, which pollutes the fused score. Must combine NLP + survey in one flow.
- Journal lock uses fallback password `123456` (security risk). Remove fallback and rely on real auth.
- Speech-to-text errors/permission handling missing. Add clear UX for unavailable STT.
- DASS results show tips but do not show primary condition/cause when API provides it.
- Mood questionnaire copy has truncated/awkward strings. Fix text.

## Requested Edit 1: One Combined Tab (Survey + NLP)

Goal: merge DASS survey and text analysis into one unified screen so AI receives both signals.

Changes:
- Remove separate NLP-only screen or demote it to a section within the combined tab.
- Create a new combined screen (e.g., `AssessmentScreen`) with:
  - Text input (and optional speech-to-text)
  - DASS-42 questionnaire (paged or collapsible groups)
  - Single submit button calling `/api/v1/analyze`
  - Results view showing fused scores, severity, cause, and recommendations
- Update navigation: replace `NLP AI` and `DASS 42 Assessment` actions with a single entry point.

## Requested Edit 2: Update Flutter Logic to Match AI

Standardize the API contract and UI expectations:
- API response should always include:
  - `primary_condition`
  - `fused_scores` (final)
  - `text_scores`
  - `survey_scores`
  - `clinical_scoring`
  - `recommendations`
- Flutter should render:
  - fused scores as the main result
  - optional drill-down for text vs survey contributions
  - recommendations using the API response, not local hardcoded logic

Align AI logic:
- Move keyword boost logic into `core_ai.py` (or remove it from Streamlit) so API and UI match.
- Ensure severity mapping in Flutter uses the same DASS cutoffs as backend.

## Database Improvements

Current DB tables in `updated_backend`:
- `users` (id, name, email, password, created_at)
- `analyses` (id, user_id, primary_condition, clinical_scoring, created_at)

Recommended changes:
- Add columns to `analyses`:
  - `text_input` (TEXT) or `text_input_hash` (if privacy concerns)
  - `text_scores` (JSON)
  - `survey_scores` (JSON)
  - `fused_scores` (JSON)
  - `severity` (STRING)
  - `cause` (STRING)
  - `suicidal_flag` (BOOLEAN)
  - `model_version` (STRING)
  - `app_version` (STRING)
  - `locale` (STRING)
- Add a `consents` table to track data usage permission:
  - `user_id`, `consent_type`, `granted`, `timestamp`
- Add `user_preferences` table:
  - theme, language, notification settings, crisis locale
- Add `journal_entries` table if journal should be stored server-side.

If you do not want to store raw text, use hashing + client-side encryption or store only embeddings.

## UI Screen Edits (High Priority)

- Home: replace separate DASS/NLP buttons with single “Assessment” entry.
- DASS results: show `primary_condition`, `cause`, `recommendations` (tips/resources/referral) from API response.
- NLP text area: add safety disclaimer and “not a diagnosis” note.
- Crisis UX: if `suicidal_flag` is true, show a dedicated crisis card with hotline links.
- Remove “Morning/Night Recommendations” if it conflicts with AI recs, or replace with API-based routine suggestions.

## Feature Ideas (AI and Non-AI)

AI-related:
- Longitudinal insights: show trends across analyses with model confidence changes.
- Personalized interventions: recommendations that adapt based on past responses.
- Multilingual sentiment summary for the user to review.
- Risk monitoring: detect sustained high risk and prompt professional help.

Non-AI:
- Habit tracking (sleep, exercise, hydration) tied to mood trends.
- Crisis resources directory by country + local emergency numbers.
- Offline mode for journaling and check-ins.
- Weekly summary report (PDF export).
- Guided routines (morning, focus, sleep) with scheduling.
- Secure vault mode for journal with biometric lock.

## Notes

- Combine survey + NLP before sending to AI to avoid skewed fused scores.
- Remove hardcoded passwords and use actual auth.
- Keep API and UI contract strictly aligned.
