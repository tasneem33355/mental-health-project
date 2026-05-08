import os
import re
import pickle
import warnings
import numpy as np
import torch
import httpx
from datetime import datetime
from fastapi import FastAPI, HTTPException, Depends
from fastapi.responses import HTMLResponse
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import List, Dict, Optional
from transformers import AutoTokenizer, AutoModelForSequenceClassification
from tensorflow.keras.models import load_model
from deep_translator import GoogleTranslator
from recommendations import get_recommendations

# --- DATABASE SETUP ---
from sqlalchemy import create_engine, Column, Integer, String, Float, DateTime, JSON
from sqlalchemy.orm import declarative_base, sessionmaker, Session

DATABASE_URL = os.environ.get("DATABASE_URL")
if DATABASE_URL and DATABASE_URL.startswith("postgres://"):
    DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)

engine = create_engine(DATABASE_URL, connect_args={'connect_timeout': 5}) if DATABASE_URL else None
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine) if engine else None
Base = declarative_base()

class DBUser(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
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

app = FastAPI(title="Mental Health AI API", description="Backend API for Mental Health Analysis")

@app.on_event("startup")
async def startup_event():
    import asyncio
    if engine:
        try:
            await asyncio.wait_for(
                asyncio.to_thread(Base.metadata.create_all, bind=engine),
                timeout=8.0
            )
            print("Database connected and tables verified.")
        except asyncio.TimeoutError:
            print("Database connection timed out during startup - server will start without DB verification.")
        except Exception as e:
            print(f"Database connection failed during startup: {e}")
    print("Application startup complete.")

def get_db():
    if not SessionLocal: yield None
    else:
        db = SessionLocal()
        try:
            yield db
        finally:
            db.close()



# Add CORS so Flutter app can communicate with it if on web, or external apps
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- MODEL LOADING ---
BASE_DIR = os.path.dirname(__file__)

def load_xlmr():
    # Fetch from the new Hugging Face model repository instead of storing locally!
    repo_id = "AliSakr9997/Mental-XLMR-Model"
    tokenizer = AutoTokenizer.from_pretrained(repo_id)
    model = AutoModelForSequenceClassification.from_pretrained(repo_id)
    model.eval()
    
    # Download the label encoder pkl
    from huggingface_hub import hf_hub_download
    le_path = hf_hub_download(repo_id=repo_id, filename="label_encoder.pkl")
    with open(le_path, "rb") as f:
        le = pickle.load(f)
        
    return tokenizer, model, le

def load_survey():
    model = load_model(os.path.join(BASE_DIR, "mental_model.h5"), compile=False)
    with open(os.path.join(BASE_DIR, "scaler.pkl"), "rb") as f:
        scaler = pickle.load(f)
    return model, scaler

tokenizer, xlmr_model, le = load_xlmr()
survey_model, scaler = load_survey()

CLASSES = ["anxiety", "depression", "stress"]

def clean_text(text):
    text = re.sub(r'(.)\1{2,}', r'\1\1', text)
    text = re.sub(r'[^\w\s\u0600-\u06FF\[\]]', ' ', text)
    return re.sub(r'\s+', ' ', text).strip()

def translate_to_en(text):
    try:
        return GoogleTranslator(source="auto", target="en").translate(text)
    except Exception:
        return ""

def predict_text(text: str) -> dict:
    cleaned = clean_text(text)
    text_en = translate_to_en(cleaned)
    combined = (text_en + " [SEP] " + cleaned) if text_en else cleaned
    inputs = tokenizer(combined, return_tensors="pt", truncation=True, max_length=192, padding=True)
    with torch.no_grad():
        probs = torch.softmax(xlmr_model(**inputs).logits, dim=-1).squeeze().numpy()
    return {c: round(float(p), 4) for c, p in zip(le.classes_, probs)}

def predict_survey(answers: list) -> dict:
    data = scaler.transform(np.array(answers).reshape(1, -1))
    pred = survey_model.predict(data, verbose=0)[0]
    return {
        "depression": round(float(pred[0]), 4),
        "anxiety": round(float(pred[1]), 4),
        "stress": round(float(pred[2]), 4),
    }

def calculate_dass_clinical_score(answers: list) -> dict:
    # 0-indexed mappings from the 1-indexed manual
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

def fuse_scores(text_s, survey_s, w_text=0.4, w_survey=0.6):
    return {c: round(w_text * text_s[c] + w_survey * survey_s[c], 4) for c in CLASSES}

# --- API MODELS ---
class AnalyzeRequest(BaseModel):
    text: str = Field(..., description="The user's response in text (Arabic/English)")
    survey_answers: List[int] = Field(..., min_items=42, max_items=42, description="List of 42 integers (0-4) representing DASS-42 survey answers")

class AnalyzeResponse(BaseModel):
    primary_condition: str
    fused_scores: Dict[str, float]
    text_scores: Dict[str, float]
    survey_scores: Dict[str, float]
    clinical_scoring: dict
    recommendations: dict

# --- ENDPOINTS ---
# --- CHAT API MODELS ---
class ChatRequest(BaseModel):
    message: str
    session_id: Optional[str] = "default"

class ChatResponse(BaseModel):
    reply: str

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

@app.post("/api/v1/analyze", response_model=AnalyzeResponse)
async def analyze_mental_health(request: AnalyzeRequest, db: Session = Depends(get_db)):
    try:
        text_scores = predict_text(request.text)
        survey_scores = predict_survey(request.survey_answers)
        final_scores = fuse_scores(text_scores, survey_scores)
        primary = max(final_scores, key=final_scores.get)
        clinical = calculate_dass_clinical_score(request.survey_answers)
        rec = get_recommendations(primary, final_scores[primary], request.text)

        # Save to PostgreSQL if DB is connected
        if db:
            new_analysis = DBAnalysis(
                primary_condition=primary,
                clinical_scoring=clinical
            )
            db.add(new_analysis)
            db.commit()

        return AnalyzeResponse(
            primary_condition=primary,
            fused_scores=final_scores,
            text_scores=text_scores,
            survey_scores=survey_scores,
            clinical_scoring=clinical,
            recommendations=rec
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/v1/analyses/history")
async def get_analyses_history(db: Session = Depends(get_db)):
    try:
        if not db:
            return []
        
        # Get the 10 most recent analyses, sorted by created_at ascending (oldest first for graphing)
        records = db.query(DBAnalysis).order_by(DBAnalysis.created_at.desc()).limit(10).all()
        
        history = []
        for r in reversed(records): # Reverse so oldest is first
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
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/", response_class=HTMLResponse)
async def read_root():
    html_content = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Mental Health AI API Testing</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 40px; background-color: #f4f4f9; }
            h1, h3 { color: #333; }
            .container { background-color: white; padding: 20px; border-radius: 8px; box-shadow: 0 0 10px rgba(0,0,0,0.1); max-width: 800px; margin: auto; }
            textarea { width: 100%; height: 100px; padding: 10px; margin-bottom: 20px; border-radius: 5px; border: 1px solid #ccc; font-size: 16px; box-sizing: border-box; }
            button { padding: 10px 20px; background-color: #007bff; color: white; border: none; border-radius: 5px; cursor: pointer; font-size: 16px; font-weight: bold; width: 100%; }
            button:hover { background-color: #0056b3; }
            pre { background-color: #2b2b2b; color: #a9b7c6; padding: 15px; border-radius: 5px; overflow-x: auto; white-space: pre-wrap; word-wrap: break-word;}
            .survey-grid { display: grid; grid-template-columns: repeat(7, 1fr); gap: 10px; margin-bottom: 20px; }
            .q-box { text-align: center; background: #f9f9f9; padding: 5px; border-radius: 5px; border: 1px solid #eee; }
            .q-box input { width: 40px; text-align: center; padding: 4px; border: 1px solid #ccc; border-radius: 3px; font-weight: bold;}
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🧠 Test Mental Health API</h1>
            <p>Write how you feel (Arabic/English) and optionally tweak the 42 specific survey answers to test the `<b>/api/v1/analyze</b>` endpoint properly.</p>
            
            <textarea id="text-input" placeholder="e.g. I was very anxious today and could not sleep well... \nمثال: كنت قلقا جدا اليوم ولم أستطع النوم بشكل جيد"></textarea>
            
            <h3>DASS-42 Survey Answers (0-3)</h3>
            <p style="font-size: 13px; color: #666; margin-top: -10px;">0 = Did not apply to me at all | 3 = Applied to me very much</p>
            <div id="survey-inputs" class="survey-grid"></div>

            <button onclick="analyzeText()">Analyze / تحليل</button>
            <p style="margin-top: 15px; text-align: center;">View detailed <a href="/docs">Swagger Documentation (OpenAPI)</a> payload shapes for your Flutter app.</p>
            
            <h3>Result:</h3>
            <pre id="result">Awaiting input...</pre>
        </div>

        <script>
            // Generate 42 inputs dynamically
            const surveyContainer = document.getElementById("survey-inputs");
            for(let i = 1; i <= 42; i++) {
                surveyContainer.innerHTML += `
                    <div class="q-box">
                        <label style="font-size: 12px; color: #666;">Q${i}</label><br>
                        <input type="number" id="q${i}" min="0" max="3" value="1">
                    </div>`;
            }

            async function analyzeText() {
                const text = document.getElementById("text-input").value;
                if (!text || text.trim() === "") {
                    alert("Please enter some text.");
                    return;
                }
                
                // Collect the 42 survey answers
                let surveyAnswers = [];
                for(let i = 1; i <= 42; i++) {
                    surveyAnswers.push(parseInt(document.getElementById(`q${i}`).value) || 0);
                }
                
                document.getElementById("result").innerText = "Analyzing with AI models... please wait.";
                
                try {
                    const response = await fetch("/api/v1/analyze", {
                        method: "POST",
                        headers: {
                            "Content-Type": "application/json"
                        },
                        body: JSON.stringify({
                            text: text,
                            survey_answers: surveyAnswers
                        })
                    });
                    
                    const data = await response.json();
                    document.getElementById("result").innerText = JSON.stringify(data, null, 4);
                } catch (error) {
                    document.getElementById("result").innerText = "Error: " + error;
                }
            }
        </script>
    </body>
    </html>
    """
    return html_content
