import os
from datetime import datetime

from fastapi import FastAPI, HTTPException
from fastapi.responses import HTMLResponse
from pydantic import BaseModel, Field

from core_ai import predict_text, predict_survey, fuse_scores
from recommendations import get_recommendations

app = FastAPI(title="SafeSpace API", version="1.0.0")


class AnalysisRequest(BaseModel):
    user_id: str | int = Field(..., description="User identifier")
    text: str = Field(..., min_length=1)
    survey_answers: list[int] = Field(..., min_items=42, max_items=42)
    locale: str = Field(default="en")
    client_ts: str | None = None

# --- DASS-42 Clinical Scoring ---

def calculate_dass_clinical_score(answers: list) -> dict:

    dep_idx = [2, 4, 9, 12, 15, 16, 20, 23, 25, 30, 33, 36, 37, 41]

    anx_idx = [1, 3, 6, 8, 14, 18, 19, 22, 24, 27, 29, 35, 39, 40]

    str_idx = [0, 5, 7, 10, 11, 13, 17, 21, 26, 28, 31, 32, 34, 38]

    dep_score = sum(answers[i] for i in dep_idx)

    anx_score = sum(answers[i] for i in anx_idx)

    str_score = sum(answers[i] for i in str_idx)

    def get_severity(score, bounds):

        if score <= bounds[0]: return "Normal"

        if score <= bounds[1]: return "Mild"

        if score <= bounds[2]: return "Moderate"

        if score <= bounds[3]: return "Severe"

        return "Extremely Severe"

    return {

        "depression": {"score": dep_score, "severity": get_severity(dep_score, [9, 13, 20, 27])},

        "anxiety": {"score": anx_score, "severity": get_severity(anx_score, [7, 9, 14, 19])},

        "stress": {"score": str_score, "severity": get_severity(str_score, [14, 18, 25, 33])}

    }

@app.get("/")
def root():
    return {"status": "ok", "message": "SafeSpace API"}


@app.get("/test", response_class=HTMLResponse)
def test_page():
    html_path = os.path.join(os.path.dirname(__file__), "index.html")
    if not os.path.exists(html_path):
        raise HTTPException(status_code=404, detail="index.html not found")
    with open(html_path, "r", encoding="utf-8") as f:
        return f.read()


@app.post("/v1/analysis")
def analyze(payload: AnalysisRequest):
    text_scores = predict_text(payload.text)
    survey_scores = predict_survey(payload.survey_answers)
    final_scores = fuse_scores(text_scores, survey_scores)
    primary = max(final_scores, key=final_scores.get)
    rec = get_recommendations(primary, final_scores[primary], payload.text)

    clinical = calculate_dass_clinical_score(payload.survey_answers)

    created_at = datetime.utcnow().isoformat() + "Z"

    return {

        "analysis_id": None,

        "primary_condition": primary,

        "fused_scores": final_scores,

        "text_scores": text_scores,

        "survey_scores": survey_scores,

        "clinical_scoring": clinical,

        "severity": rec.get("severity"),

        "cause": rec.get("cause"),

        "recommendations": {

            "tips_en": rec.get("tips_en", []),

            "tips_ar": rec.get("tips_ar", []),

            "resources_en": rec.get("resources_en", []),

            "resources_ar": rec.get("resources_ar", []),

            "referral_en": rec.get("referral_en", ""),

            "referral_ar": rec.get("referral_ar", ""),

        },

        "suicidal_flag": rec.get("suicidal_flag", False),

        "created_at": created_at,

    }
