# 🧠 SafeSpace (مساحتك الآمنة)

<div align="center">

![SafeSpace Banner](https://img.shields.io/badge/Platform-Flutter%20%7C%20FastAPI%20%7C%20PyTorch-7b3fe4?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-4fd1a5?style=for-the-badge)
![Status](https://img.shields.io/badge/Graduation%20Project-2026-blue?style=for-the-badge)
![Python](https://img.shields.io/badge/Python-3.11-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)

**An Intelligent, Multi-Modal Bilingual Mental Health Screening & Support Sanctuary**

[Live API Space](https://alisakr9997-safespace.hf.space) • [Web Application](/UI/safespace/build/web) • [Project Documentation](graduation_project_book.md)

</div>

---

## 📖 Executive Summary

**SafeSpace** is an end-to-end, cross-platform mental health screening ecosystem engineered to bridge the gap between clinical psychometric assessment and real-world expression in the **MENA region**. 

Traditional psychological self-reports often suffer from **masking bias** (users deliberately downplaying severity), while generic generative AI systems lack clinical rigor and fail to understand colloquial Arabic dialects (*Aamiya*). SafeSpace solves this by fusing a **clinical DASS-42 deep learning neural network** with a **fine-tuned cross-lingual XLM-RoBERTa transformer**, backed by a deterministic crisis intervention safety net, therapeutic grounding tools, and encrypted local journaling.

---

## 🌟 Key Innovations & Core Features

### 1. 🔄 Multi-Modal Score Fusion Layer
- Combines quantitative **DASS-42 psychometric patterns** with qualitative **free-text linguistic sentiment** (60% clinical survey + 40% NLP text).
- Prevents clinical masking: even if a user selects moderate answers on the questionnaire, high distress expressed in their journal entry dynamically adjusts the predicted risk profile.

### 2. 🌍 Dialect-Aware Arabic & English NLP
- Built on a fine-tuned **XLM-RoBERTa** model (`AliSakr9997/Mental-XLMR-Model`) trained on 51,000+ bilingual dialectal samples (`moujar/MentalHealth-Darija`).
- Understands Arabic regional idioms, code-switching (Arabizi/English), and colloquial expressions across Egyptian, Levantine, and North African phrasing.

### 3. 🛡️ Deterministic Real-Time Crisis Safety Net
- Scans user reflections in real-time for 28+ suicidal ideation and acute self-harm keywords in both Arabic and English.
- Instantly overrides ML pipelines to eliminate latency and false negatives, immediately surfacing verified emergency hotlines (e.g., Egypt *08008880700*, KSA *920033360*, Befrienders International).

### 4. 🔍 Root-Stressor Extraction Engine
- Parses user descriptions using an intelligent semantic lexicon to extract primary underlying life triggers across **8 major domains**:
  - 💼 **Workplace & Career** (`work`)
  - 🎓 **Academic Pressure** (`academic`)
  - 💸 **Financial Distress** (`financial`)
  - 💔 **Relationships & Family** (`relationships`)
  - 🩺 **Physical Health & Insomnia** (`health`)
  - 👥 **Social Anxiety & Isolation** (`social`)
  - 🪞 **Self-Worth & Failure** (`self_worth`)
  - ⚡ **Trauma & Grief** (`trauma`)

### 5. 🧘 Therapeutic Grounding & Coping Suite
- **Box Breathing:** Animated 4-4-4-4 visual pacer to stimulate the parasympathetic nervous system.
- **5-4-3-2-1 Sensory Grounding:** Guided sensory interaction to alleviate acute panic attacks.
- **Dopamine & Retention Games:** Sensory mini-games (*Bubble Pop*, *Color Match*) designed for somatic distraction and cognitive de-escalation.
- **ADHD Deep Focus:** Binaural timer for sustained attention.

### 6. 🔒 Private "Diaries" (Zero-Telemetry Local Journal)
- Password-gated private diary protected with local persistence.
- Complete separation between public assessment text and private notes to preserve absolute patient confidentiality.

---

## 🏗️ System Architecture

```
                                  USER INTERFACE
             ┌────────────────────────────────────────────────────────┐
             │   Flutter Cross-Platform Client (Android / iOS / Web)  │
             └───────────────────────────┬────────────────────────────┘
                                         │ HTTPS / JSON
                                         ▼
                               BACKEND API ENGINE
             ┌────────────────────────────────────────────────────────┐
             │               FastAPI (Uvicorn ASGI)                   │
             │        Hosted on Hugging Face Docker Space             │
             └──────┬────────────────────┬────────────────────┬───────┘
                    │                    │                    │
                    ▼                    ▼                    ▼
          ┌──────────────────┐ ┌──────────────────┐ ┌──────────────────┐
          │  NLP Text Engine │ │  Survey ML Model │ │  Safety Engine   │
          │   XLM-RoBERTa    │ │ 42-Input Dense NN│ │ Crisis Override  │
          │ Dialect Trans.   │ │  Pattern Match   │ │ Lexicon Extractor│
          └─────────┬────────┘ └─────────┬────────┘ └─────────┬────────┘
                    │                    │                    │
                    └────────────┬───────┴────────────────────┘
                                 ▼
                     ┌───────────────────────┐
                     │ Multi-Modal Fusion    │
                     │ 60% Survey + 40% Text │
                     └───────────┬───────────┘
                                 │
                                 ▼
                     ┌───────────────────────┐
                     │ Personalized Guidance │
                     │   Bilingual Rec DB    │
                     └───────────────────────┘
                                 │
                                 ▼
                     ┌───────────────────────┐
                     │ PostgreSQL (Supabase) │
                     │ Encrypted DB History  │
                     └───────────────────────┘
```

---

## 📊 Scientific Foundations: The Dual-Model Approach

SafeSpace deliberately distinguishes between fixed rule-based scoring and machine learning inference:

| Dimension | Classic DASS Scoring (Calculator) | SafeSpace Survey Neural Network | SafeSpace NLP Transformer |
|---|---|---|---|
| **Model Type** | Arithmetic Subscale Sum | Multi-Layer Perceptron (MLP) | XLM-RoBERTa Transformer |
| **Input Data** | 42 Integer Values (0–3) | 42 Scaled Answers (StandardScaler) | Unstructured Arabic/English Text |
| **What It Learns** | None (Deterministic addition) | Non-linear symptom co-occurrences | Linguistic semantics & emotional tone |
| **Output** | Raw score out of 42 per category | 3 Condition Probabilities (D / A / S) | Emotion & Severity Classification |
| **Primary Value** | Clinical baseline matching | Discovers hidden cross-scale patterns | Uncovers unprompted lived distress |

### Severity Scale Cutoffs (Clinical Baseline)
* **Normal:** `< 30%` (Healthy baseline)
* **Mild:** `30% – 45%` (Early tension)
* **Moderate:** `45% – 60%` (Noticeable impairment)
* **Severe:** `60% – 75%` (Significant distress)
* **Extremely Severe:** `> 75%` (Urgent clinical referral recommended)

---

## 📂 Repository Structure

```
safespaceproject/
├── UI/
│   └── safespace/                   # Flutter Frontend Application
│       ├── lib/
│       │   ├── data/                # DASS questions, app state, models
│       │   ├── screens/             # 25+ application screens
│       │   │   ├── assessment_screen.dart       # Multi-modal evaluation flow
│       │   │   ├── dass_results_screen.dart     # AI summary & clinical profile
│       │   │   ├── journal_screen.dart          # Password-protected diaries
│       │   │   ├── mood_patterns_screen.dart    # Streak and history analytics
│       │   │   └── grounding_screen.dart        # Coping exercises & games
│       │   ├── services/            # API integration client (http)
│       │   ├── localization.dart    # Full Arabic / English translation engine
│       │   └── main.dart            # Flutter entry point & theme configuration
│       ├── android/                 # Android native bindings & icon assets
│       └── web/                     # Web assembly configuration
│
├── api.py                           # FastAPI core application (15+ REST routes)
├── core_ai.py                       # PyTorch model loader, translation & forward passes
├── recommendations.py               # Bilingual clinical recommendations database
├── build_web.py                     # Production web compiler & landing page generator
├── push_to_space.py                 # Automated Hugging Face Space deployer
├── Dockerfile                       # Container definition for model hosting
├── requirements.txt                 # Python dependencies
├── graduation_project_book.md       # Full graduation thesis book
├── backend_deployment_slide_script.md # Presentation script & jury Q&A guide
└── safespaceproject documents/      # Presentation decks, diagrams, and video demos
```

---

## ⚡ Quick Start & Installation

### 1. Backend Service (FastAPI)

#### Prerequisites
- Python 3.10 or 3.11
- Git

```bash
# 1. Clone repository
git clone https://github.com/tasneem33355/mental-health-project.git
cd mental-health-project

# 2. Create and activate a virtual environment
python -m venv venv
# On Windows:
.\venv\Scripts\activate
# On Linux/macOS:
source venv/bin/activate

# 3. Install dependencies
pip install -r requirements.txt

# 4. Start API server
uvicorn api:app --host 0.0.0.0 --port 7860 --reload
```
*API docs will be available at:* `http://localhost:7860/docs`

---

### 2. Client Application (Flutter)

#### Prerequisites
- Flutter SDK (v3.19+)
- Android Studio / Xcode / Chrome

```bash
# Navigate to Flutter directory
cd UI/safespace

# Get packages
flutter pub get

# Run on connected device or emulator
flutter run

# Build release APK for Android
flutter build apk --release

# Build production Web Application
python ../../build_web.py
```

---

## 📡 Core API Reference

The live production backend is accessible at:  
`https://alisakr9997-safespace.hf.space/api/v1`

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/auth/signup` | Registers new user account with SHA-256 hashed password |
| `POST` | `/auth/login` | Authenticates user and returns session identity |
| `POST` | `/analyze` | Primary multi-modal evaluation (Text + 42 DASS answers) |
| `POST` | `/checkin` | Records daily mood (0-10), sleep (hrs), and energy metrics |
| `GET` | `/checkin/history` | Retrieves chronologically sorted check-in streak logs |
| `POST` | `/journal` | Securely stores user journal entries |
| `GET` | `/journal/history` | Fetches user's journal entries |
| `GET` | `/analyses/history` | Returns historical clinical score profiles for longitudinal graphing |

### Sample Multi-Modal Assessment Request
```json
POST /api/v1/analyze
Content-Type: application/json

{
  "user_id": 1,
  "text": "مش قادر أركز في دراستي خالص وخايف أسقط في امتحانات الجامعة، الضغط العصبي عالي جداً",
  "survey_answers": [1, 2, 0, 3, 1, 2, 1, 0, 3, 2, 1, 0, 2, 1, 0, 2, 1, 1, 0, 2, 1, 2, 1, 0, 2, 1, 0, 1, 2, 1, 0, 2, 1, 0, 1, 2, 1, 0, 2, 1, 0, 1],
  "locale": "ar"
}
```

---

## 👥 Engineering & Research Team

Developed as a Graduation Project with dedication to mental health technology in the Arab World:

| Name | Role / Focus | LinkedIn |
|---|---|---|
| **Ali Monir Sakr** | Lead AI & Full-Stack Engineer | [![LinkedIn](https://img.shields.io/badge/LinkedIn-Profile-blue?logo=linkedin)](https://www.linkedin.com/in/ali-monir-sakr/) |
| **Mohamed Sabry** | Software & AI Engineer | [![LinkedIn](https://img.shields.io/badge/LinkedIn-Profile-blue?logo=linkedin)](https://www.linkedin.com/in/mohamed-sabry-643643265/) |
| **Tasneem Mohamed** | Software Engineer | — |
| **Mahmoud AboElNaga** | Software Engineer | — |
| **Ahmad Behiry** | Software Engineer | — |
| **Rowayda El-Bayar** | Software Engineer | — |
| **Ali Saad Ali** | Software Engineer | — |
| **Jana Khaled Awad** | Software Engineer | — |
| **Youssef Ehab Gomaa** | Software Engineer | — |

### Academic Supervision
* **Dr. Doaa Adel** — Project Supervisor
* **Eng. Rana Amr Mohy** — Teaching Assistant & Technical Advisor

---

## 📜 Clinical Disclaimer
SafeSpace is an assistive artificial intelligence tool designed for psychological self-awareness, screening, and educational self-care. **It does not replace professional psychiatric diagnosis, clinical therapy, or medical intervention.** If you or someone you know is in crisis, please immediately contact your local emergency services or a certified crisis hotline.

---

<div align="center">
Made with care to make mental health support accessible to everyone. 💜
</div>
