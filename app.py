"""
app.py
======
Mental Health AI — Full Pipeline
Files needed:
  mental_xlmr_final/   ← XLM-R model folder
  mental_model.h5      ← Survey Keras model
  scaler.pkl           ← Survey scaler
  recommendations.py   ← same directory

Install:
  pip install streamlit transformers torch tensorflow scikit-learn deep-translator
"""
import sys, os
sys.path.append(os.path.dirname(__file__))
import re, pickle, warnings
import numpy as np
import streamlit as st
import torch
from transformers import AutoTokenizer, AutoModelForSequenceClassification
@st.cache_resource
def load_model():
    tokenizer = AutoTokenizer.from_pretrained("tasneem33355/mental-xlmr")
    model = AutoModelForSequenceClassification.from_pretrained("tasneem33355/mental-xlmr")
    return tokenizer, model

tokenizer, model = load_model()
from deep_translator import GoogleTranslator
import sys, os
sys.path.insert(0, os.path.dirname(__file__))
from recommendations import get_recommendations

warnings.filterwarnings("ignore")

# ── PAGE CONFIG ───────────────────────────────────────────────────────────────
st.set_page_config(page_title="Mental Health AI", page_icon="🧠", layout="wide")

st.markdown("""
<style>
.stApp { background: linear-gradient(135deg, #0d1117, #161b22, #0d1117); color: #e6edf3; }
h1 { text-align: center; color: #58a6ff; font-size: 36px; margin-bottom: 4px; }
h2, h3 { color: #c9d1d9; }
.section-card {
    background: rgba(22,27,34,0.9);
    border: 1px solid #30363d;
    border-radius: 14px;
    padding: 22px 26px;
    margin-bottom: 18px;
}
.result-card {
    background: #161b22;
    border: 1px solid #30363d;
    border-radius: 12px;
    padding: 20px;
    text-align: center;
    margin-bottom: 8px;
}
.result-card.primary { border: 2px solid #58a6ff; }
.result-label { font-size: 15px; color: #8b949e; margin-bottom: 6px; }
.result-value { font-size: 44px; font-weight: 700; }
.severity-badge {
    display: inline-block;
    padding: 3px 12px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 600;
    margin-top: 6px;
}
.rec-block {
    background: #161b22;
    border: 1px solid #30363d;
    border-radius: 12px;
    padding: 18px 22px;
    margin-bottom: 14px;
}
.rec-title { font-size: 15px; font-weight: 700; margin-bottom: 10px; }
.rec-item { font-size: 14px; color: #c9d1d9; padding: 4px 0; border-bottom: 1px solid #21262d; }
.rec-item:last-child { border-bottom: none; }
.ar-text { font-size: 13px; color: #8b949e; margin-top: 3px; direction: rtl; }
.referral-box {
    background: rgba(248,81,73,0.1);
    border: 1px solid rgba(248,81,73,0.4);
    border-radius: 10px;
    padding: 14px 18px;
    margin-top: 12px;
}
.crisis-box {
    background: rgba(248,81,73,0.2);
    border: 2px solid #f85149;
    border-radius: 12px;
    padding: 20px 24px;
    margin: 16px 0;
}
div.stButton > button {
    background: linear-gradient(90deg, #1f6feb, #58a6ff);
    color: white; font-size: 17px; font-weight: 700;
    border-radius: 10px; height: 52px; width: 100%; border: none;
}
div.stSlider > label { color: #c9d1d9 !important; font-size: 13px; }
.stTextArea textarea {
    background: #0d1117 !important;
    color: #e6edf3 !important;
    border: 1px solid #30363d !important;
    border-radius: 8px !important;
}
</style>
""", unsafe_allow_html=True)

# ── CONSTANTS ─────────────────────────────────────────────────────────────────
CLASSES = ["anxiety", "depression", "stress"]
ARABIC_LABELS = {"anxiety": "القلق", "depression": "الاكتئاب", "stress": "الضغط النفسي"}
COLORS = {"anxiety": "#ffa657", "depression": "#79c0ff", "stress": "#56d364"}
SEVERITY_AR = {
    "normal": "طبيعي", "mild": "خفيف", "moderate": "متوسط",
    "severe": "شديد", "extremely_severe": "شديد جداً", "crisis": "أزمة",
}
SEVERITY_COLORS = {
    "normal": "#56d364", "mild": "#e3b341", "moderate": "#ffa657",
    "severe": "#f85149", "extremely_severe": "#ff0000", "crisis": "#ff0000",
}

CAUSE_AR = {
    "work": "ضغط العمل", "relationships": "العلاقات", "financial": "الضغط المالي",
    "academic": "الضغط الأكاديمي", "health": "المخاوف الصحية", "social": "القلق الاجتماعي",
    "self_worth": "الثقة بالنفس", "trauma": "الصدمة النفسية", "general": "عام",
}

# ── LOAD MODELS ───────────────────────────────────────────────────────────────
@st.cache_resource
def load_xlmr():
    import pickle, os
    token = st.secrets["HF_TOKEN"]
    tokenizer = AutoTokenizer.from_pretrained(
        "tasneem33355/mental-xlmr", token=token
    )
    model = AutoModelForSequenceClassification.from_pretrained(
        "tasneem33355/mental-xlmr", token=token
    )
    le_path = os.path.join(os.path.dirname(__file__), "mental_xlmr_final", "label_encoder.pkl")
    with open(le_path, "rb") as f:
        le = pickle.load(f)
    model.eval()
    return tokenizer, model, le

@st.cache_resource
def load_survey():
    import pickle, numpy as np
    scaler  = pickle.load(open(os.path.join(os.path.dirname(__file__), "scaler.pkl"), "rb"))
    weights = pickle.load(open(os.path.join(os.path.dirname(__file__), "model_weights.pkl"), "rb"))

    def predict(x):
        for w in weights:
            if len(w) == 2:
                x = np.dot(x, w[0]) + w[1]
                x = np.maximum(0, x)  # ReLU
        x = np.exp(x) / np.sum(np.exp(x))  # Softmax
        return x

    return scaler, predict

tokenizer, xlmr_model, le = load_xlmr()
scaler, survey_predict = load_survey()

# ── HELPERS ───────────────────────────────────────────────────────────────────
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
    cleaned  = clean_text(text)
    text_en  = translate_to_en(cleaned)
    combined = (text_en + " [SEP] " + cleaned) if text_en else cleaned
    inputs   = tokenizer(combined, return_tensors="pt",
                         truncation=True, max_length=192, padding=True)
    with torch.no_grad():
        probs = torch.softmax(xlmr_model(**inputs).logits, dim=-1).squeeze().numpy()
    return {c: round(float(p), 4) for c, p in zip(le.classes_, probs)}

def predict_survey(answers: list) -> dict:
    data = scaler.transform(np.array(answers).reshape(1, -1))
    pred = survey_predict(data)[0]
    return {
        "depression": round(float(pred[0]), 4),
        "anxiety":    round(float(pred[1]), 4),
        "stress":     round(float(pred[2]), 4),
    }

def fuse_scores(text_s, survey_s, w_text=0.4, w_survey=0.6):
    return {c: round(w_text * text_s[c] + w_survey * survey_s[c], 4) for c in CLASSES}

# ── SURVEY QUESTIONS ─────────────────────────────────────────────────────────
SURVEY_Q = [
    ("I found it hard to wind down", "وجدت صعوبة في الاسترخاء"),
    ("I was aware of dryness of my mouth", "لاحظت جفافاً في فمي"),
    ("I couldn't seem to experience any positive feeling at all", "لم أستطع الشعور بأي مشاعر إيجابية"),
    ("I experienced breathing difficulty", "أحسست بصعوبة في التنفس"),
    ("I found it difficult to work up the initiative to do things", "وجدت صعوبة في اتخاذ المبادرة للقيام بالأشياء"),
    ("I tended to over-react to situations", "كنت أبالغ في ردود أفعالي تجاه المواقف"),
    ("I experienced trembling", "شعرت بالرعشة"),
    ("I felt that I was using a lot of nervous energy", "شعرت أنني أستهلك الكثير من الطاقة العصبية"),
    ("I was worried about situations in which I might panic", "كنت قلقاً من مواقف قد أصاب فيها بالذعر"),
    ("I felt that I had nothing to look forward to", "شعرت أنه لا يوجد شيء أتطلع إليه"),
    ("I found myself getting agitated", "وجدت نفسي أشعر بالانفعال"),
    ("I found it difficult to relax", "وجدت صعوبة في الاسترخاء"),
    ("I felt down-hearted and blue", "شعرت بالإحباط والكآبة"),
    ("I was intolerant of anything that kept me from getting on", "كنت غير متسامح مع أي شيء يعيقني"),
    ("I felt I was close to panic", "شعرت أنني على وشك الذعر"),
    ("I was unable to become enthusiastic", "لم أستطع أن أتحمس لأي شيء"),
    ("I felt I wasn't worth much as a person", "شعرت أنني لست شخصاً ذا قيمة"),
    ("I felt that I was rather touchy", "شعرت أنني متقلب المزاج"),
    ("I was aware of the action of my heart", "كنت واعياً لنبضات قلبي"),
    ("I felt scared without any good reason", "شعرت بالخوف دون سبب واضح"),
    ("I felt that life was meaningless", "شعرت أن الحياة بلا معنى"),
    ("I found it hard to calm down", "وجدت صعوبة في التهدئة"),
    ("I felt nervous", "شعرت بالتوتر"),
    ("I felt sad and depressed", "شعرت بالحزن والاكتئاب"),
    ("I found myself getting impatient", "وجدت نفسي أشعر بنفاد الصبر"),
    ("I felt that I was rather emotional", "شعرت أنني عاطفي بشكل مفرط"),
    ("I felt restless", "شعرت بعدم الهدوء"),
    ("I had difficulty concentrating", "وجدت صعوبة في التركيز"),
    ("I felt lonely", "شعرت بالوحدة"),
    ("I found it difficult to relax", "وجدت صعوبة في الاسترخاء"),
    ("I felt hopeless", "شعرت باليأس"),
    ("I felt worried about many things", "كنت قلقاً بشأن أشياء كثيرة"),
    ("I felt that I had no energy", "شعرت بعدم وجود طاقة"),
    ("I felt tense", "شعرت بالتوتر والضيق"),
    ("I felt tired for no reason", "شعرت بالتعب دون سبب"),
    ("I felt uneasy", "شعرت بعدم الارتياح"),
    ("I felt worthless", "شعرت بأنني لا قيمة لي"),
    ("I felt anxious", "شعرت بالقلق"),
    ("I felt discouraged", "شعرت بالإحباط"),
    ("I felt stressed", "شعرت بالضغط"),
    ("I felt overwhelmed", "شعرت بالإرهاق"),
    ("I felt emotionally exhausted", "شعرت بالإنهاك العاطفي"),
]

# ── UI ────────────────────────────────────────────────────────────────────────
st.title("🧠 Mental Health AI")
st.markdown(
    "<p style='text-align:center;color:#8b949e;font-size:15px;'>"
    "Write how you feel and answer the survey for a complete assessment"
    "<br><span dir='rtl'>اكتب ما تشعر به وأجب على الأسئلة للحصول على تقييم شامل</span></p>",
    unsafe_allow_html=True,
)
st.markdown("---")

# ── PART 1: TEXT ─────────────────────────────────────────────────────────────
st.markdown("<div class='section-card'>", unsafe_allow_html=True)
st.markdown("### 💬 How are you feeling? / كيف تشعر؟")
st.markdown(
    "<p style='color:#8b949e;font-size:13px;'>"
    "Write in any language — Arabic (any dialect), English, or both<br>"
    "<span dir='rtl'>اكتب بأي لغة — عربي (أي لهجة)، إنجليزي، أو الاتنين</span></p>",
    unsafe_allow_html=True,
)
user_text = st.text_area(
    label="",
    placeholder="e.g. I've been feeling very overwhelmed at work and can't sleep...\nمثال: أنا تعبان جداً من الشغل ومش قادر أنام...",
    height=120,
    label_visibility="collapsed",
)
st.markdown("</div>", unsafe_allow_html=True)

# ── PART 2: SURVEY ────────────────────────────────────────────────────────────
st.markdown("<div class='section-card'>", unsafe_allow_html=True)
st.markdown("### 📋 DASS-42 Survey / استبيان DASS-42")
st.markdown(
    "<p style='color:#8b949e;font-size:13px;'>"
    "0 = Never &nbsp;|&nbsp; 1 = Sometimes &nbsp;|&nbsp; 2 = Often &nbsp;|&nbsp; "
    "3 = Most of the time &nbsp;|&nbsp; 4 = Always<br>"
    "<span dir='rtl'>0 = لم يحدث أبداً | 1 = أحياناً | 2 = كثيراً | 3 = معظم الوقت | 4 = دائماً</span></p>",
    unsafe_allow_html=True,
)

survey_answers = []
for i in range(0, len(SURVEY_Q), 2):
    cols = st.columns(2)
    for j, (en, ar) in enumerate(SURVEY_Q[i:i+2]):
        with cols[j]:
            val = st.slider(
                f"{i+j+1}. {en}\n{ar}",
                min_value=0, max_value=4, value=0,
                key=f"q_{i+j}",
            )
            survey_answers.append(val)

st.markdown("</div>", unsafe_allow_html=True)

# ── PREDICT BUTTON ────────────────────────────────────────────────────────────
_, col_btn, _ = st.columns([1, 2, 1])
with col_btn:
    predict_btn = st.button("🔍 Analyze / تحليل")

# ── RESULTS ──────────────────────────────────────────────────────────────────
if predict_btn:
    if not user_text.strip():
        st.warning("Please write how you feel first. / من فضلك اكتب ما تشعر به أولاً.")
        st.stop()

    with st.spinner("Analyzing... / جاري التحليل..."):
        text_scores   = predict_text(user_text)
        survey_scores = predict_survey(survey_answers)
        final_scores  = fuse_scores(text_scores, survey_scores)
        primary       = max(final_scores, key=final_scores.get)
        rec           = get_recommendations(primary, final_scores[primary], user_text)

    st.markdown("---")
    st.markdown("## 📊 Results / النتائج")

    # ── SCORE CARDS ───────────────────────────────────────────────────────────
    cols = st.columns(3)
    for col, cls in zip(cols, CLASSES):
        pct        = int(final_scores[cls] * 100)
        is_primary = cls == primary
        card_class = "result-card primary" if is_primary else "result-card"
        sev        = rec["severity"] if is_primary else ""
        badge      = ""
        if is_primary and sev:
            sev_color = SEVERITY_COLORS.get(sev, "#8b949e")
            badge = (f"<div class='severity-badge' style='background:{sev_color}20;"
                     f"color:{sev_color};border:1px solid {sev_color};'>"
                     f"{sev.replace('_',' ').title()} / {SEVERITY_AR.get(sev,'')}</div>")
        col.markdown(f"""
        <div class='{card_class}'>
            <div class='result-label'>{cls.title()} / {ARABIC_LABELS[cls]}</div>
            <div class='result-value' style='color:{COLORS[cls]}'>{pct}%</div>
            {badge}
        </div>""", unsafe_allow_html=True)

    # ── PRIMARY LABEL ─────────────────────────────────────────────────────────
    if not rec["suicidal_flag"]:
        cause_label = CAUSE_AR.get(rec["cause"], rec["cause"])
        st.markdown(
            f"<p style='text-align:center;margin-top:10px;font-size:17px;color:#8b949e;'>"
            f"Primary: <strong style='color:{COLORS[primary]}'>{primary.title()} / {ARABIC_LABELS[primary]}</strong>"
            f" &nbsp;|&nbsp; Cause detected / السبب المكتشف: "
            f"<strong style='color:#e3b341'>{rec['cause'].replace('_',' ').title()} / {cause_label}</strong></p>",
            unsafe_allow_html=True,
        )

    # ── CRISIS BOX ────────────────────────────────────────────────────────────
    if rec["suicidal_flag"]:
        st.markdown("""
        <div class='crisis-box'>
        <h3 style='color:#f85149;margin-top:0;'>🚨 Crisis Support Needed / مطلوب دعم أزمة</h3>
        </div>""", unsafe_allow_html=True)

    # ── SCORE DETAILS ─────────────────────────────────────────────────────────
    with st.expander("Show score breakdown / عرض تفاصيل النتائج"):
        c1, c2 = st.columns(2)
        c1.markdown("**Text model / موديل النص:**")
        for cls in CLASSES:
            c1.markdown(f"- {cls} / {ARABIC_LABELS[cls]}: **{int(text_scores[cls]*100)}%**")
        c2.markdown("**Survey model / موديل السيرفاي:**")
        for cls in CLASSES:
            c2.markdown(f"- {cls} / {ARABIC_LABELS[cls]}: **{int(survey_scores[cls]*100)}%**")

    # ── RECOMMENDATIONS ───────────────────────────────────────────────────────
    st.markdown("---")
    st.markdown(f"## 💡 Recommendations / التوصيات")

    col_tips, col_res = st.columns(2)

    with col_tips:
        st.markdown("<div class='rec-block'>", unsafe_allow_html=True)
        st.markdown("<div class='rec-title'>✅ Practical Tips / نصائح عملية</div>",
                    unsafe_allow_html=True)
        tips_en = rec.get("tips_en", [])
        tips_ar = rec.get("tips_ar", [])
        for en, ar in zip(tips_en, tips_ar):
            st.markdown(
                f"<div class='rec-item'>{en}"
                f"<div class='ar-text' dir='rtl'>• {ar}</div></div>",
                unsafe_allow_html=True,
            )
        st.markdown("</div>", unsafe_allow_html=True)

    with col_res:
        st.markdown("<div class='rec-block'>", unsafe_allow_html=True)
        st.markdown("<div class='rec-title'>📚 Resources / موارد مفيدة</div>",
                    unsafe_allow_html=True)
        res_en = rec.get("resources_en", [])
        res_ar = rec.get("resources_ar", [])
        for en, ar in zip(res_en, res_ar):
            st.markdown(
                f"<div class='rec-item'>{en}"
                f"<div class='ar-text' dir='rtl'>• {ar}</div></div>",
                unsafe_allow_html=True,
            )
        st.markdown("</div>", unsafe_allow_html=True)

    # ── REFERRAL ──────────────────────────────────────────────────────────────
    ref_en = rec.get("referral_en", "")
    ref_ar = rec.get("referral_ar", "")
    if ref_en:
        box_class = "crisis-box" if rec["suicidal_flag"] else "referral-box"
        st.markdown(
            f"<div class='{box_class}'>"
            f"<strong>🏥 When to seek help / متى تطلب المساعدة:</strong><br>"
            f"{ref_en}<br>"
            f"<span dir='rtl' style='color:#f0a0a0;font-size:13px;'>{ref_ar}</span>"
            f"</div>",
            unsafe_allow_html=True,
        )

    st.markdown(
        "<p style='text-align:center;color:#484f58;font-size:12px;margin-top:20px;'>"
        "⚠️ This system is for awareness only and is not a substitute for professional medical diagnosis.<br>"
        "هذا النظام للتوعية فقط وليس بديلاً عن التشخيص الطبي المتخصص.</p>",
        unsafe_allow_html=True,
    )
