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
    return {c: round(float(p), 4) for c, p in zip(le.classes_, probs)}


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
