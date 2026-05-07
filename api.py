import os
from datetime import datetime
import hashlib
import logging
import time

import httpx
from fastapi import FastAPI, HTTPException, Depends, Request
from fastapi.responses import HTMLResponse
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import Optional

from core_ai import predict_text, predict_survey, fuse_scores
from recommendations import get_recommendations

# --- DATABASE SETUP ---
from sqlalchemy import create_engine, Column, Integer, String, Float, DateTime, JSON, Text, Boolean, Index
from sqlalchemy.orm import declarative_base, sessionmaker, Session

DATABASE_URL = os.environ.get("DATABASE_URL")
if DATABASE_URL and DATABASE_URL.startswith("postgres://"):
    DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)

engine = create_engine(DATABASE_URL, connect_args={'connect_timeout': 5}, pool_pre_ping=True) if DATABASE_URL else None
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine) if engine else None
Base = declarative_base()

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("safespace.api")


class DBUser(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=True)
    email = Column(String, unique=True, index=True)
    password = Column(String)
    created_at = Column(DateTime, default=datetime.utcnow)


class DBAnalysis(Base):
    __tablename__ = "analyses"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, index=True, nullable=True)
    primary_condition = Column(String)
    clinical_scoring = Column(JSON)
    created_at = Column(DateTime, default=datetime.utcnow)
    text_input = Column(Text, nullable=True)
    text_input_hash = Column(Text, nullable=True)
    text_scores = Column(JSON, nullable=True)
    survey_scores = Column(JSON, nullable=True)
    fused_scores = Column(JSON, nullable=True)
    severity = Column(Text, nullable=True)
    cause = Column(Text, nullable=True)
    suicidal_flag = Column(Boolean, default=False)
    model_version = Column(Text, nullable=True)
    app_version = Column(Text, nullable=True)
    locale = Column(Text, nullable=True)


Index("ix_analyses_user_id_created_at", DBAnalysis.user_id, DBAnalysis.created_at)


class DBCheckin(Base):
    __tablename__ = "checkins"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, index=True, nullable=False)
    mood = Column(Integer, nullable=False)
    sleep = Column(Integer, nullable=False)
    energy = Column(Float, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)


Index("ix_checkins_user_id_created_at", DBCheckin.user_id, DBCheckin.created_at)

# --- APP SETUP ---
app = FastAPI(title="SafeSpace API", version="1.0.0")


@app.middleware("http")
async def log_requests(request: Request, call_next):
    start_time = time.time()
    response = await call_next(request)
    duration_ms = int((time.time() - start_time) * 1000)
    logger.info(
        "%s %s %s %sms",
        request.method,
        request.url.path,
        response.status_code,
        duration_ms,
    )
    return response


@app.on_event("startup")
async def startup_event():
    import asyncio
    if engine:
        try:
            await asyncio.wait_for(
                asyncio.to_thread(Base.metadata.create_all, bind=engine),
                timeout=8.0
            )
            logger.info("Database connected and tables verified.")
        except asyncio.TimeoutError:
            logger.warning("Database connection timed out during startup - server will start without DB verification.")
        except Exception as e:
            logger.exception("Database connection failed during startup: %s", e)
    logger.info("Application startup complete.")


def get_db():
    if not SessionLocal:
        yield None
    else:
        db = SessionLocal()
        try:
            yield db
        finally:
            db.close()

# Add CORS so Flutter app can communicate with it
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- Password Hashing ---
def hash_password(password: str) -> str:
    return hashlib.sha256(password.encode()).hexdigest()

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

# --- API MODELS ---
class AnalysisRequest(BaseModel):
    user_id: str | int = Field(default=None, description="User identifier")
    text: str = Field(..., min_length=1)
    survey_answers: list[int] = Field(..., min_items=42, max_items=42)
    locale: str = Field(default="en")
    client_ts: str | None = None


class AnalyzeRequest(BaseModel):
    text: str = Field(..., description="The user's response in text (Arabic/English)")
    survey_answers: list[int] = Field(..., min_items=42, max_items=42, description="List of 42 integers (0-4) representing DASS-42 survey answers")
    user_id: int | None = Field(default=None, description="Optional user ID to link analysis to a user")
    locale: str = Field(default="en")
    client_ts: str | None = None
    app_version: str | None = None
    model_version: str | None = None


class ChatRequest(BaseModel):
    message: str
    session_id: Optional[str] = "default"


class ChatResponse(BaseModel):
    reply: str


class SignupRequest(BaseModel):
    name: str = Field(..., min_length=1)
    email: str = Field(..., min_length=5)
    password: str = Field(..., min_length=4)


class LoginRequest(BaseModel):
    email: str = Field(..., min_length=5)
    password: str = Field(..., min_length=1)


class CheckinRequest(BaseModel):
    mood: int = Field(..., ge=0, le=10)
    sleep: int = Field(..., ge=0, le=10)
    energy: float = Field(..., ge=0, le=10)
    user_id: int | None = Field(default=None, description="Optional user ID to link check-in to a user")
    client_ts: str | None = None


# --- ENDPOINTS ---
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


# --- AUTH ENDPOINTS ---
@app.post("/api/v1/auth/signup")
async def signup(request: SignupRequest, db: Session = Depends(get_db)):
    if not db:
        raise HTTPException(status_code=500, detail="Database not available")

    # Check if email already exists
    existing = db.query(DBUser).filter(DBUser.email == request.email).first()
    if existing:
        raise HTTPException(status_code=400, detail="Email already registered")

    # Create new user
    try:
        new_user = DBUser(
            name=request.name,
            email=request.email,
            password=hash_password(request.password),
        )
        db.add(new_user)
        db.commit()
        db.refresh(new_user)

        return {
            "user_id": new_user.id,
            "email": new_user.email,
            "name": new_user.name,
            "message": "Account created successfully"
        }
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Failed to create account: {str(e)}")


@app.post("/api/v1/auth/login")
async def login(request: LoginRequest, db: Session = Depends(get_db)):
    if not db:
        raise HTTPException(status_code=500, detail="Database not available")

    user = db.query(DBUser).filter(DBUser.email == request.email).first()
    if not user:
        raise HTTPException(status_code=401, detail="Email not found")

    if user.password != hash_password(request.password):
        # Also try plain-text match for legacy users who signed up before hashing
        if user.password != request.password:
            raise HTTPException(status_code=401, detail="Incorrect password")

    return {
        "user_id": user.id,
        "email": user.email,
        "name": user.name or "",
        "message": "Login successful"
    }


# New-style endpoint (used by index.html test page)
@app.post("/v1/analysis")
def analyze(payload: AnalysisRequest, db: Session = Depends(get_db)):
    # Shift 0-3 UI scale to 1-4 for the AI model (trained on data.csv)
    shifted_answers = [a + 1 for a in payload.survey_answers]
    text_scores = predict_text(payload.text)
    survey_scores = predict_survey(shifted_answers)
    
    final_scores = fuse_scores(text_scores, survey_scores)
    primary = max(final_scores, key=final_scores.get)
    clinical = calculate_dass_clinical_score(payload.survey_answers)
    rec = get_recommendations(primary, final_scores[primary], payload.text)
    created_at_dt = datetime.utcnow()
    if payload.client_ts:
        try:
            created_at_dt = datetime.fromisoformat(payload.client_ts.replace("Z", "+00:00")).replace(tzinfo=None)
        except ValueError:
            pass
    created_at = created_at_dt.isoformat() + "Z"

    # Save to PostgreSQL if DB is connected
    if db:
        try:
            text_input_hash = hashlib.sha256(payload.text.encode()).hexdigest()
            new_analysis = DBAnalysis(
                user_id=payload.user_id,
                primary_condition=primary,
                clinical_scoring=clinical,
                created_at=created_at_dt,
                text_input=payload.text,
                text_input_hash=text_input_hash,
                text_scores=text_scores,
                survey_scores=survey_scores,
                fused_scores=final_scores,
                severity=rec.get("severity"),
                cause=rec.get("cause"),
                suicidal_flag=rec.get("suicidal_flag", False),
                model_version=None,
                app_version=None,
                locale=payload.locale,
            )
            db.add(new_analysis)
            db.commit()
        except Exception as e:
            logger.exception("DB save error: %s", e)

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

# Flutter-compatible endpoint (used by api_service.dart)
@app.post("/api/v1/analyze")
async def analyze_mental_health(request: AnalyzeRequest, db: Session = Depends(get_db)):
    try:
        start_time = time.time()
        # Shift 0-3 UI scale to 1-4 for the AI model (trained on data.csv)
        shifted_answers = [a + 1 for a in request.survey_answers]
        text_scores = predict_text(request.text)
        survey_scores = predict_survey(shifted_answers)
        
        final_scores = fuse_scores(text_scores, survey_scores)
        primary = max(final_scores, key=final_scores.get)
        clinical = calculate_dass_clinical_score(request.survey_answers)
        rec = get_recommendations(primary, final_scores[primary], request.text)
        created_at_dt = datetime.utcnow()
        if request.client_ts:
            try:
                created_at_dt = datetime.fromisoformat(request.client_ts.replace("Z", "+00:00")).replace(tzinfo=None)
            except ValueError:
                pass
        created_at = created_at_dt.isoformat() + "Z"

        # Save to PostgreSQL if DB is connected
        if db:
            try:
                text_input_hash = hashlib.sha256(request.text.encode()).hexdigest()
                new_analysis = DBAnalysis(
                    user_id=request.user_id,
                    primary_condition=primary,
                    clinical_scoring=clinical,
                    created_at=created_at_dt,
                    text_input=request.text,
                    text_input_hash=text_input_hash,
                    text_scores=text_scores,
                    survey_scores=survey_scores,
                    fused_scores=final_scores,
                    severity=rec.get("severity"),
                    cause=rec.get("cause"),
                    suicidal_flag=rec.get("suicidal_flag", False),
                    model_version=request.model_version,
                    app_version=request.app_version,
                    locale=request.locale,
                )
                db.add(new_analysis)
                db.commit()
            except Exception as e:
                logger.exception("DB save error: %s", e)

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
            "duration_ms": int((time.time() - start_time) * 1000),
        }
    except Exception as e:
        logger.exception("Analyze request failed: %s", e)
        raise HTTPException(status_code=500, detail="Failed to analyze")

# Flutter-compatible history endpoint
@app.get("/api/v1/analyses/history")
async def get_analyses_history(user_id: int = None, db: Session = Depends(get_db)):
    try:
        if not db:
            return []

        query = db.query(DBAnalysis)

        # Filter by user_id if provided
        if user_id is not None:
            query = query.filter(DBAnalysis.user_id == user_id)

        # Get the 10 most recent analyses, sorted by created_at ascending (oldest first for graphing)
        records = query.order_by(DBAnalysis.created_at.desc()).limit(10).all()

        history = []
        for r in reversed(records):  # Reverse so oldest is first
            if r.clinical_scoring:
                history.append({
                    "id": r.id,
                    "date": r.created_at.strftime("%b %d"),
                    "depression": r.clinical_scoring.get("depression", {}).get("score", 0),
                    "anxiety": r.clinical_scoring.get("anxiety", {}).get("score", 0),
                    "stress": r.clinical_scoring.get("stress", {}).get("score", 0),
                    "primary": r.primary_condition
                })
        return history
    except Exception as e:
        logger.exception("Analyze request failed: %s", e)
        raise HTTPException(status_code=500, detail="Failed to analyze")

@app.post("/api/v1/chat", response_model=ChatResponse)
async def chat_with_ai(request: ChatRequest):
    api_url = os.environ.get("AI_API_URL")
    api_key = os.environ.get("AI_API_KEY")
    chatflow_id = os.environ.get("AI_CHATFLOW_ID")

    if not api_url or not api_key or not chatflow_id:
        raise HTTPException(status_code=500, detail="AI API credentials are not configured in Secrets.")

    endpoint = f"{api_url}/api/v1/prediction/{chatflow_id}"
    headers = {"Authorization": f"Bearer {api_key}"}
    payload = {"question": request.message, "overrideConfig": {"sessionId": request.session_id}}

    async with httpx.AsyncClient() as client:
        try:
            response = await client.post(endpoint, json=payload, headers=headers, timeout=30.0)
            response.raise_for_status()
            data = response.json()
            return ChatResponse(reply=data.get("text") or data.get("answer") or str(data))
        except Exception as e:
            raise HTTPException(status_code=502, detail=f"Failed to communicate with AI API: {str(e)}")


@app.post("/api/v1/checkin")
async def create_checkin(request: CheckinRequest, db: Session = Depends(get_db)):
    if not db:
        raise HTTPException(status_code=500, detail="Database not available")

    if request.user_id is None:
        raise HTTPException(status_code=400, detail="user_id is required")

    created_at = datetime.utcnow()
    if request.client_ts:
        try:
            created_at = datetime.fromisoformat(request.client_ts.replace("Z", "+00:00")).replace(tzinfo=None)
        except ValueError:
            pass

    try:
        new_checkin = DBCheckin(
            user_id=request.user_id,
            mood=request.mood,
            sleep=request.sleep,
            energy=request.energy,
            created_at=created_at,
        )
        db.add(new_checkin)
        db.commit()
        db.refresh(new_checkin)

        return {
            "id": new_checkin.id,
            "user_id": new_checkin.user_id,
            "mood": new_checkin.mood,
            "sleep": new_checkin.sleep,
            "energy": new_checkin.energy,
            "created_at": new_checkin.created_at.isoformat() + "Z",
        }
    except Exception as e:
        db.rollback()
        logger.exception("Failed to save check-in: %s", e)
        raise HTTPException(status_code=500, detail="Failed to save check-in")


@app.get("/api/v1/checkin/history")
async def get_checkin_history(user_id: int | None = None, db: Session = Depends(get_db)):
    try:
        if not db:
            return []

        query = db.query(DBCheckin)
        if user_id is not None:
            query = query.filter(DBCheckin.user_id == user_id)

        records = query.order_by(DBCheckin.created_at.desc()).limit(30).all()
        return [
            {
                "id": r.id,
                "user_id": r.user_id,
                "mood": r.mood,
                "sleep": r.sleep,
                "energy": r.energy,
                "created_at": r.created_at.isoformat() + "Z",
            }
            for r in records
        ]
    except Exception as e:
        logger.exception("Failed to fetch check-in history: %s", e)
        raise HTTPException(status_code=500, detail="Failed to fetch history")
