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
    return {
        "analysis_id": None,
        "primary": primary,
        "scores": final_scores,
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
        "created_at": datetime.utcnow().isoformat() + "Z",
    }
