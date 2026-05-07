import os
import re
import pickle
import warnings
from functools import lru_cache

import numpy as np
import torch
from transformers import AutoTokenizer, AutoModelForSequenceClassification
from deep_translator import GoogleTranslator

warnings.filterwarnings("ignore")

CLASSES = ["anxiety", "depression", "stress"]


# ── KEYWORD OVERRIDE ─────────────────────────────────────────────────────────
DEPRESSION_KEYWORDS = [
    # Arabic (Fusha + dialects)
    "اكتئاب", "مكتئب", "مكتئبة", "حزن", "حزين", "حزينة", "يأس", "يائس", "يائسة",
    "فراغ", "إحساس بالفراغ", "بلا معنى", "لا معنى", "مالهاش معنى", "بلا هدف",
    "لا أمل", "مفيش أمل", "تعبت من الحياة", "زهقت من الحياة",
    "مش لاقي معنى", "مش لاقية معنى", "حاسس بالفراغ", "حاسة بالفراغ",
    "مفيش طاقة", "مفيش رغبة", "بكاء", "عايز أبكي", "عايزة أبكي",
    "وحيد", "وحيدة", "عزلة", "منعزل", "منعزلة",
    "إرهاق نفسي", "إرهاق عاطفي", "مش حاسس بحاجة", "مش حاسة بحاجة",
    "زهقت", "تعبت", "مش طايق", "مش طايقة", "نفسيتي وحشة", "نفسيتي في الأرض",
    "مش قادر أكمل", "مش قادرة أكمل", "مش عايش", "مش قادر أعيش",
    "مش عايز أصحى", "مش عايزة أصحى", "دموع", "بدمع", "قلبي تقيل",
    "مش حاسس بنفسي", "مش حاسة بنفسي", "ما بحس بشي", "ما في فايدة",
    "مافي امل", "ما في امل", "حياتي خربت", "خسرت كل حاجة",
    # English
    "depressed", "depression", "hopeless", "hopelessness", "empty", "emptiness",
    "worthless", "meaningless", "no meaning", "no purpose", "cannot go on",
    "cant go on", "no energy", "no motivation", "crying", "feel nothing",
    "numb", "isolated", "lonely", "loneliness", "sad", "sadness",
    "despair", "grief", "miserable", "broken", "lost all hope",
]

ANXIETY_KEYWORDS = [
    # Arabic
    "قلق", "قلقان", "قلقانة", "خوف", "خايف", "خايفة", "توتر", "متوتر", "متوترة",
    "هلع", "مش مرتاح", "مش مرتاحة", "ذعر", "رهاب", "وسواس",
    # English
    "panic", "anxious", "anxiety", "worried", "worry", "fear",
    "scared", "nervous", "restless", "tense", "phobia", "ocd",
]

STRESS_KEYWORDS = [
    # Arabic
    "ضغط", "ضغوط", "مضغوط", "مضغوطة", "إجهاد", "مجهد", "مجهدة",
    # English
    "overwhelmed", "stressed", "stress", "burnout", "exhausted", "overloaded",
]


def keyword_boost(text: str, scores: dict) -> dict:
    text_lower = text.lower()

    dep_hits = sum(1 for kw in DEPRESSION_KEYWORDS if kw.lower() in text_lower)
    anx_hits = sum(1 for kw in ANXIETY_KEYWORDS if kw.lower() in text_lower)
    str_hits = sum(1 for kw in STRESS_KEYWORDS if kw.lower() in text_lower)

    if dep_hits == 0 and anx_hits == 0 and str_hits == 0:
        return scores

    s = dict(scores)

    if dep_hits > 0 and dep_hits >= anx_hits and dep_hits >= str_hits:
        boost = min(0.55 + dep_hits * 0.10, 0.85)
        s["depression"] = boost
        remaining = 1.0 - boost
        total_rest = s["anxiety"] + s["stress"]
        if total_rest > 0:
            s["anxiety"] = round(remaining * s["anxiety"] / total_rest, 4)
            s["stress"] = round(remaining * s["stress"] / total_rest, 4)
        s["depression"] = round(boost, 4)

    elif anx_hits > 0 and anx_hits >= dep_hits and anx_hits >= str_hits:
        boost = min(0.55 + anx_hits * 0.10, 0.85)
        s["anxiety"] = boost
        remaining = 1.0 - boost
        total_rest = s["depression"] + s["stress"]
        if total_rest > 0:
            s["depression"] = round(remaining * s["depression"] / total_rest, 4)
            s["stress"] = round(remaining * s["stress"] / total_rest, 4)
        s["anxiety"] = round(boost, 4)

    elif str_hits > 0 and str_hits >= dep_hits and str_hits >= anx_hits:
        boost = min(0.55 + str_hits * 0.10, 0.85)
        s["stress"] = boost
        remaining = 1.0 - boost
        total_rest = s["depression"] + s["anxiety"]
        if total_rest > 0:
            s["depression"] = round(remaining * s["depression"] / total_rest, 4)
            s["anxiety"] = round(remaining * s["anxiety"] / total_rest, 4)
        s["stress"] = round(boost, 4)

    total = sum(s.values())
    if total > 0:
        s = {k: round(v / total, 4) for k, v in s.items()}

    return s


@lru_cache(maxsize=1)
def load_xlmr():
    model_id = os.getenv("HF_MODEL_ID", "AliSakr9997/Mental-XLMR-Model")
    token = os.getenv("HF_TOKEN")
    kwargs = {"token": token} if token else {}
    local_dir = os.path.join(os.path.dirname(__file__), "mental_xlmr_final")
    local_weights = any(
        os.path.exists(os.path.join(local_dir, fname))
        for fname in ("pytorch_model.bin", "model.safetensors")
    )
    source = local_dir if local_weights else model_id
    tokenizer = AutoTokenizer.from_pretrained(source, **kwargs)
    model = AutoModelForSequenceClassification.from_pretrained(source, **kwargs)
    le_path = os.path.join(os.path.dirname(__file__), "mental_xlmr_final", "label_encoder.pkl")
    with open(le_path, "rb") as f:
        le = pickle.load(f)
    model.eval()
    return tokenizer, model, le


@lru_cache(maxsize=1)
def load_survey():
    scaler = pickle.load(open(os.path.join(os.path.dirname(__file__), "scaler.pkl"), "rb"))
    weights = pickle.load(open(os.path.join(os.path.dirname(__file__), "model_weights.pkl"), "rb"))

    def predict(x):
        for w in weights:
            if len(w) == 2:
                x = np.dot(x, w[0]) + w[1]
                x = np.maximum(0, x)
        x = np.exp(x) / np.sum(np.exp(x))
        return x

    return scaler, predict


def clean_text(text: str) -> str:
    text = re.sub(r"(.)\1{2,}", r"\1\1", text)
    text = re.sub(r"[^\w\s\u0600-\u06FF\[\]]", " ", text)
    return re.sub(r"\s+", " ", text).strip()


def translate_to_en(text: str) -> str:
    try:
        return GoogleTranslator(source="auto", target="en").translate(text)
    except Exception:
        return ""


def predict_text(text: str) -> dict:
    tokenizer, model, le = load_xlmr()
    cleaned = clean_text(text)
    text_en = translate_to_en(cleaned)
    combined = (text_en + " [SEP] " + cleaned) if text_en else cleaned
    inputs = tokenizer(combined, return_tensors="pt", truncation=True, max_length=192, padding=True)
    with torch.no_grad():
        probs = torch.softmax(model(**inputs).logits, dim=-1).squeeze().numpy()
    raw_scores = {c: round(float(p), 4) for c, p in zip(le.classes_, probs)}
    boosted = keyword_boost(text + " " + text_en, raw_scores)
    return boosted


def predict_survey(answers: list) -> dict:
    scaler, survey_predict = load_survey()
    data = scaler.transform(np.array(answers).reshape(1, -1))
    pred = survey_predict(data)[0]
    return {
        "depression": round(float(pred[0]), 4),
        "anxiety": round(float(pred[1]), 4),
        "stress": round(float(pred[2]), 4),
    }


def fuse_scores(text_s, survey_s, w_text=0.4, w_survey=0.6):
    return {c: round(w_text * text_s[c] + w_survey * survey_s[c], 4) for c in CLASSES}
