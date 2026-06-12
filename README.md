---
title: SafeSpace API
emoji: 🧠
colorFrom: blue
colorTo: green
sdk: docker
python_version: "3.11"
pinned: false
---

# 🧠 SafeSpace: AI-Powered Multi-Modal Mental Health Companion

SafeSpace is a cross-platform companion application designed to bridge the gap between clinical psychometric frameworks and modern natural language processing. It combines standard clinical surveys with context-aware dialectal Arabic and English journaling to deliver personalized, root-cause-driven coping recommendations.

---

## 🚀 Key Features

*   **Multi-Modal Score Fusion:** Combines quantitative DASS-42 clinical questionnaire metrics (60% weight) with qualitative NLP journal sentiment scores (40% weight) to reduce self-report masking bias.
*   **Bilingual NLP Text Analysis:** Processes open-ended journal entries in English and colloquial Arabic dialects (Egyptian, Levantine, Gulf) using a fine-tuned XLM-RoBERTa transformer model.
*   **Crisis safety Net:** Scans text in real-time for 28+ self-harm phrases in both languages, bypassing the scoring pipeline to instantly display local and international crisis hotlines.
*   **Root-Cause Stressor Extractor:** Categorizes journaling text into 9 domains (Work, Academic, Financial, Health, Relationships, etc.) using a rule-based lexicon mapper.
*   **Adaptive Recommendation Engine:** Provides 18 bilingual recommendation profiles (tips, referrals, books, and exercises) based on the primary condition and detected stressor.
*   **Mood Trend Analytics:** Renders 7, 14, and 30-day interactive line charts of stress levels, energy, sleep hours, and DASS history.
*   **Cross-Platform Availability:** Native mobile app built with Flutter (iOS & Android) and web browser application hosted on Netlify.

---

## 🛠️ System Architecture

```
                 ┌─────────────────────────────┐
                 │    Flutter Client (Mobile)  │
                 │    or Web App (Netlify)     │
                 └──────────────┬──────────────┘
                                │
                 ┌──────────────┴──────────────┐
                 │       HTTPS API Requests    │
                 ▼                             ▼
   ┌───────────────────────────┐ ┌───────────────────────────┐
   │      FastAPI Backend      │ │      Supabase Cloud       │
   │   (Hugging Face Spaces)   │ │  - User Auth Sessions     │
   │ - MLP Survey Model (NumPy)│ │  - PostgreSQL DB          │
   │ - XLM-RoBERTa NLP (PyTorch│ │  - Row-Level Security     │
   │ - Score Fusion & Lexicon  │ └───────────────────────────┘
   └───────────────────────────┘
```

---

## 📁 Repository Structure

*   `UI/safespace/` — The Flutter frontend codebase (Mobile and Web configurations).
    *   `lib/data/app_state.dart` — Shared client-side data store.
    *   `lib/services/api_service.dart` — REST API integration module.
    *   `lib/screens/` — UI screens including assessment, mood patterns, and journaling.
*   `api.py` — The core FastAPI backend application.
*   `core_ai.py` — Raw MLP forward-pass and XLM-RoBERTa NLP prediction pipeline.
*   `recommendations.py` — Bilingual recommendation mappings, hotlines, and stressor classification.
*   `app.py` — Standalone Streamlit demonstration dashboard.
*   `Dockerfile` — Docker configuration for Hugging Face Space deployments.
*   `graduation_project_book.md` — Comprehensive graduation project book and documentation.

---

## ⚙️ Installation & Setup

### Backend (Python FastAPI)

1. Clone the repository and navigate to the root directory:
   ```bash
   git clone https://github.com/tasneem33355/mental-health-project.git
   cd mental-health-project
   ```
2. Install Python dependencies:
   ```bash
   pip install -r requirements.txt
   ```
3. Run the backend server locally using Uvicorn:
   ```bash
   uvicorn api:app --host 0.0.0.0 --port 7860 --reload
   ```

### Frontend (Flutter Client)

1. Make sure Flutter 3.x is installed. Navigate to the UI directory:
   ```bash
   cd UI/safespace
   ```
2. Retrieve Flutter dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application on your connected mobile device or emulator:
   ```bash
   flutter run
   ```
4. To compile the Flutter app for the Web:
   ```bash
   flutter build web --release
   ```

---

## 📡 Core API Endpoints

The API backend is hosted at: `https://alisakr9997-safespace.hf.space/api/v1`

*   `POST /auth/signup` — Registers a new user account.
*   `POST /auth/login` — Authenticates user credentials.
*   `POST /analyze` — Submits DASS-42 survey answers and journal text for fused multi-modal scoring.
*   `POST /checkin` — Saves daily stress, energy, and sleep check-in metrics.
*   `GET /checkin/history` — Fetches past check-ins for line-chart visualization.
*   `POST /journal` — Logs a new journal entry.
*   `GET /journal/history` — Retrieves a list of user journal entries.
*   `GET /analyses/history` — Returns the user's historical clinical profiles.

---

## 🚢 Deployment

### FastAPI on Hugging Face Spaces
Hugging Face automatically rebuilds the Docker container on push. The server runs via the configuration in the `Dockerfile`:
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY . ./
EXPOSE 7860
CMD ["uvicorn", "api:app", "--host", "0.0.0.0", "--port", "7860"]
```

### Flutter Web on Netlify
Upload the contents of `/UI/safespace/build/web` to Netlify. Create a `_redirects` file in the build root to handle SPA routing:
```text
/*   /index.html   200
```
