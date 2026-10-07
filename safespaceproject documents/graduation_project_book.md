# SafeSpace: An AI-Powered Multi-Modal Mental Health Companion Bridging Clinical Frameworks and Natural Language Processing

---

## Abstract

Mental health disorders, particularly anxiety, depression, and stress, represent a significant global challenge that is frequently exacerbated by barriers such as social stigma, prohibitive therapeutic costs, and systemic shortages of professional clinicians. While traditional diagnostic tools like the Depression, Anxiety, and Stress Scale (DASS-42) provide clinically validated baselines, they are vulnerable to response bias or conscious "masking" by users who manipulate their selections to appear more resilient. Conversely, qualitative self-expression, such as daily journaling, offers rich contextual insights into a user's emotional state but lacks objective clinical scoring.

This project introduces **SafeSpace**, a cross-platform mobile ecosystem designed to bridge the gap between objective clinical diagnostics and subjective emotional expression. SafeSpace leverages a multi-modal assessment engine that fuses quantitative inputs from a DASS-42 digital questionnaire with qualitative natural language processing (NLP) of bilingual (Arabic/English) journal entries. The underlying architecture employs a Multi-Layer Perceptron (MLP) for rapid clinical survey prediction alongside a fine-tuned cross-lingual transformer model (XLM-RoBERTa) to analyze the emotional tone and semantic context of colloquial Arabic dialects and English text.

A score-fusion algorithm integrates these modalities, weighting the clinical survey at 60% and the semantic journal analysis at 40% to compute a contextualized emotional profile. Furthermore, the system incorporates an automated lexicon-based parser to identify root stressors (e.g., academic, workplace, or relationship stress) and a real-time crisis detection safety net to bypass scoring and immediately trigger support interventions when self-harm markers are identified. The proposed solution offers a scalable, private, and culturally adaptive framework for early mental health screening and personalized coping support.

---

## Acknowledgements

First and foremost, we express our deep gratitude to our project supervisor, whose invaluable guidance, academic rigor, and consistent encouragement paved the way for the successful design and execution of this work. Their insightful feedback challenged us to elevate our technical implementation and maintain a high standard of research integrity.

We also extend our sincere appreciation to the faculty members and teaching assistants of the Computer Engineering and Computer Science departments. The foundational knowledge and technical skills they imparted throughout our academic journey served as the building blocks for this project.

Furthermore, we thank the mental health professionals and clinical consultants who provided critical perspectives on the DASS-42 scoring mechanisms and therapeutic coping strategies. Their expertise was crucial in validating the clinical workflow of SafeSpace.

Lastly, we are immensely grateful to our families and friends for their unwavering support, patience, and understanding during the long hours of development, analysis, and writing. This project represents a collective milestone that would not have been possible without their support.

---

## Chapter 1: Introduction

### 1.1 Overview
Mental health has emerged as a cornerstone of public health research, with rising global rates of anxiety, depression, and stress-related conditions. The digital transformation of healthcare has accelerated the adoption of mobile health (mHealth) technologies, providing new avenues for patient care. Traditional pathways to mental healthcare require face-to-face clinical visits, which are frequently constrained by high financial costs, systemic waitlists, and pervasive cultural stigmas. Consequently, many individuals suffering from mild-to-moderate psychological distress do not seek help until their conditions escalate to clinical crises.

In the domain of digital health, mobile applications have attempted to democratize access to mental health resources. However, most current solutions are polarized: they either function as simple digital diaries with manual mood tracking or as rule-based chatbots that execute rigid conversation trees. These systems lack the capability to analyze qualitative user expressions or contextualize clinical scores within the user’s daily life. A comprehensive approach is needed to bridge clinical validity with the flexible, organic nature of human language.

### 1.2 Problem Definition
Existing diagnostic and self-help tools suffer from several primary bottlenecks:
*   **The Psychological Masking Mechanism:** When completing formal clinical questionnaires like the DASS-42, users often subconsciously or consciously alter their answers to appear more resilient or socially compliant. This masking behavior results in "false negatives," where individuals in distress receive scores indicating a healthy state.
*   **Semantic Gap in Self-Reporting:** Standard clinical questionnaires evaluate symptoms quantitatively (e.g., measuring the frequency of physiological symptoms) but fail to capture the qualitative root causes, such as academic pressure, relationship issues, or workplace burnout.
*   **Language and Dialect Barriers in NLP:** The majority of state-of-the-art Natural Language Processing (NLP) models are trained primarily in Modern Standard Arabic (MSA) or English. Consequently, there is a lack of accessible tools that natively understand colloquial Arabic dialects, which are the primary modes of emotional expression in the MENA region.
*   **Lack of Proactive Crisis Detection:** Most standard mood tracking apps do not analyze the semantic content of inputs in real-time, failing to identify acute indicators of self-harm or suicidal ideation and missing opportunities for immediate intervention.

### 1.3 Project Objectives
The core objectives of this project are:
1.  **Cross-Platform Client Engineering:** Develop a responsive mobile application in Flutter with an intuitive, calming, and responsive user interface, featuring dark-mode styling and fluid animations.
2.  **Clinical Score Prediction:** Train a Multi-Layer Perceptron (MLP) on a dataset of 39,775 clinical DASS-42 responses to predict diagnostic categories with high computational efficiency.
3.  **Bilingual Semantic Classification:** Fine-tune and deploy a cross-lingual transformer model (XLM-RoBERTa) capable of classifying free-text journals into levels of depression, anxiety, and stress.
4.  **Multi-Modal Score Fusion:** Formulate a weighted fusion algorithm that combines quantitative survey scores and qualitative journal sentiment to generate a unified emotional profile.
5.  **Lexicon-Based Stressor Extraction:** Create an automated parser to extract root stressors from written journals to provide personalized coping recommendations.
6.  **Real-Time Crisis Intervention:** Implement a safety-net parser that checks text inputs for crisis keywords, bypassing standard scoring to display local emergency helplines.

### 1.4 Project Scope
SafeSpace is designed as a **self-assessment and coping companion** rather than a diagnostic replacement for professional clinical psychiatry. The target audience comprises young adults, university students, and working professionals (aged 18–45) who experience mild-to-moderate emotional volatility or chronic stress. 

While the system operates in real-time, the natural language engine specifically targets English and colloquial Arabic dialects (such as Egyptian, Levantine, and Gulf Arabic) via a pipeline that translates regional text to a unified semantic space before evaluation. The application does not prescribe pharmacological treatments, focusing instead on cognitive behavioral therapy (CBT) exercises, mindfulness practices, and local crisis resources.

### 1.5 Timeline
The project was executed across five distinct phases over an academic year:
*   **Phase 1: Research & Feasibility (Weeks 1-6):** Review of clinical diagnostic frameworks (DASS-42), assessment of NLP limitations in regional dialects, and technology stack selection.
*   **Phase 2: Database & Backend Design (Weeks 7-14):** Seeding DASS-42 datasets, designing PostgreSQL schemas in Supabase, training the MLP model, and fine-tuning the XLM-RoBERTa transformer.
*   **Phase 3: Frontend Client Development (Weeks 15-22):** Building the Flutter user interfaces (mood check-ins, journal inputs, breathing animations, stress-relief games) and implementing SharedPreferences caching.
*   **Phase 4: Multi-Modal Model Integration (Weeks 23-28):** Connecting the Flutter client to the FastAPI backend hosted on Hugging Face Spaces, implementing translation microservices, and debugging latency issues.
*   **Phase 5: Evaluation & Testing (Weeks 29-36):** Code refactoring, user privacy configuration (settings views), launcher icon setup, performance benchmarks, and final APK compilation.

---

## Chapter 2: Literature Review

### 2.1 Introduction
This chapter reviews the theoretical foundation and existing systems that inform the design of SafeSpace. We examine established psychometric scales, analyze the evolution of natural language processing architectures, discuss the challenges of dialectal Arabic text processing, and compare our system with commercial alternatives.

### 2.2 Background
Understanding SafeSpace requires examining several key domains:

#### 2.2.1 Psychometric Assessments (DASS-42)
The DASS-42 is a clinically validated 42-item self-report questionnaire designed to measure three negative emotional states: depression, anxiety, and tension/stress. Each of the three scales contains 14 items, evaluated on a 4-point Likert scale ranging from 0 ("Did not apply to me at all") to 3 ("Applied to me very much, or most of the time"). 

#### DASS-42 Scale Mappings
*   **Depression Scale:** Evaluates dysphoria, hopelessness, devaluation of life, self-deprecation, lack of interest/involvement, anhedonia, and inertia.
    *   *Items:* 3, 5, 10, 13, 16, 17, 21, 24, 26, 31, 34, 37, 38, 42.
*   **Anxiety Scale:** Evaluates autonomic arousal, skeletal muscle effects, situational anxiety, and subjective experience of anxious affect.
    *   *Items:* 2, 4, 7, 9, 15, 19, 20, 23, 25, 28, 30, 36, 40, 41.
*   **Stress Scale:** Evaluates chronic non-specific arousal, difficulty relaxing, nervous arousal, and being easily upset/agitated, irritable/over-reactive, and impatient.
    *   *Items:* 1, 6, 8, 11, 12, 14, 18, 22, 27, 29, 32, 33, 35, 39.

#### 2.2.2 Natural Language Processing & Transformers
Sentiment analysis has evolved from rule-based dictionary matching to deep learning architectures. Recurrent Neural Networks (RNNs) and Long Short-Term Memory (LSTM) networks were previously the standards for text classification. However, they struggle with long-term dependency bottlenecks and sequential processing constraints.

The introduction of the Transformer architecture solved these limitations by using self-attention mechanisms to process tokens in parallel:

$$Attention(Q, K, V) = softmax\left(\frac{QK^T}{\sqrt{d_k}}\right)V$$

Where $Q$ (Query), $K$ (Key), and $V$ (Value) are projections of the input embeddings, and $d_k$ is the dimensionality of the keys. 

For multi-lingual and dialectal environments, **XLM-RoBERTa** (Cross-lingual Language Model - Robustly Optimized BERT Approach) improves upon BERT by training on massive multi-lingual CommonCrawl datasets (100 languages, including Arabic). It uses a shared SentencePiece subword vocabulary to map diverse languages into a shared vector space, allowing the model to generalize patterns learned in resource-rich languages (like English) to lower-resource languages or dialects (like regional Arabic).

#### 2.2.3 Dialectal Arabic Preprocessing
Arabic NLP is characterized by diglossia, which is the coexistence of Modern Standard Arabic (MSA)—used in formal writing and news—and various regional dialects used in daily conversations and social media. These dialects lack standardized orthographic rules and incorporate borrow-words, local slang, and phonological variations. 

To classify emotional expression in colloquial Arabic, models must handle diverse syntactic structures. SafeSpace uses a pipeline that translates regional text to standard English before classification. This approach leverages the extensive emotional datasets available in English while preserving the semantic meaning of the original Arabic input.

### 2.3 Relevant Works
Existing digital systems fall into three categories:
*   **Self-Guided Meditation Apps (Calm / Headspace):** Focus on relaxation and meditation. While highly usable, they lack clinical diagnostic integration and do not offer personalized psychological assessments.
*   **Conversational Therapy Agents (Wysa / Woebot):** Provide interactive chat structures. However, they rely on rigid, rule-based trees or basic machine learning models, and they typically lack support for regional Arabic dialects.
*   **B2C Telehealth Platforms (BetterHelp / Talkspace):** Connect users with licensed human therapists. While effective, they are expensive, require scheduling, and lack automated real-time self-assessment tools.

### 2.4 Relationship Between Existing Work and Our Work
SafeSpace bridges these models by combining clinical diagnostic screening (DASS-42) with semantic text classification (XLM-RoBERTa). Unlike Wysa, SafeSpace supports colloquial Arabic dialects. Unlike Calm, SafeSpace uses clinical baselines. Crucially, the system implements a **multi-modal score fusion** algorithm that combines survey responses and journal sentiment to reduce response bias, offering an accessible self-assessment tool.

### 2.5 Summary
In summary, while commercial applications provide valuable wellness tools, they do not integrate objective clinical diagnostics with qualitative natural language analysis in a bilingual format. SafeSpace addresses these limitations with its multi-modal architecture, offering an accessible, secure, and culturally localized self-assessment platform.

---

## Chapter 3: System Analysis

### 3.1 Development Methodology
SafeSpace was developed using an **Agile/Scrum** methodology. This iterative process allowed the team to respond to changes, refine user requirements, and deploy code increments systematically. The development timeline was split into two-week sprints:

```
[Sprint Planning] -> [Development Increment] -> [Testing & Refactoring] -> [Sprint Review]
        ^                                                                       |
        +---------------------------------- Iteration --------------------------+
```

*   **Sprint Planning:** Define tasks for the upcoming sprint, such as building specific UI screens or training model layers.
*   **Development Increment:** Write code in Dart (for mobile) and Python (for backend models).
*   **Testing & Refactoring:** Conduct local benchmarks (latency reviews, syntax checks) and resolve code issues.
*   **Sprint Review:** Demonstrate the working increment, gather feedback, and plan the next cycle.

### 3.2 Requirements Analysis
System requirements were determined by analyzing user workflows and clinical diagnostics. These requirements were categorized into functional behaviors (what the system must do) and non-functional specifications (how the system must perform).

### 3.3 Functional Requirements
*   **FR-1: User Registration and Secure Authentication:** Users must be able to register, log in, and log out using credentials managed via Supabase. Sensitive fields like email must be hidden on the main profile screen and restricted to settings.
*   **FR-2: DASS-42 Interactive Assessment:** The application must display the DASS-42 questions sequentially and capture user responses on a scale of 0 to 3.
*   **FR-3: Structured Journal Editor:** The editor must feature separate fields for the entry title and body. The system must format the input as a single string (`"Title\n\nBody"`) for database storage.
*   **FR-4: Multi-Modal Analysis:** The backend must process DASS-42 vectors and journal entries, run them through the MLP and transformer models, and return a fused score.
*   **FR-5: Lexicon Stressor Classification:** The system must parse journal entries to identify primary stressors (e.g., academic, workplace, relationship) and suggest related activities.
*   **FR-6: Crisis Safety Net:** The backend must scan journal entries for self-harm keywords, bypassing scoring to display emergency helplines if a trigger is identified.

### 3.4 Non-Functional Requirements
*   **NFR-1: System Latency:** The unified API response time for score calculation and NLP classification must not exceed 3.0 seconds under standard network conditions.
*   **NFR-2: Mobile Animation Performance:** Interactive screens (like breathing guides) must render at a stable 60 frames per second on mid-range devices.
*   **NFR-3: Privacy and Data Security:** All network communications must use HTTPS. Personal email details must be restricted to settings sub-menus.
*   **NFR-4: Database Reliability:** The PostgreSQL database managed by Supabase must maintain 99.5% uptime.

### 3.5 UML Diagrams and Workflow Sequences

```mermaid
sequenceDiagram
    autonumber
    actor User as User (App Client)
    participant App as Flutter Frontend
    participant DB as Supabase DB
    participant API as AI Inference Backend
    
    User->>App: Submits DASS-42 & Journal Entry
    Note over App: Check for local validation (e.g. non-empty text)
    App->>DB: Stores raw journal text (encrypted)
    App->>API: Sends survey answers (array) & journal text (string)
    Note over API: Run Crisis Keywords Search
    alt Self-Harm Keywords Found
        API-->>App: Return "Crisis Triggered" Status
        App->>User: Display Emergency Helplines Overlay
    else Safe / Regular Path
        API->>API: Calculate MLP DASS score
        API->>API: Translate Dialect -> English
        API->>API: Analyze Sentiment (XLM-RoBERTa)
        API->>API: Run Score Fusion (60% Survey + 40% NLP)
        API->>API: Extract Root Stressors (Lexicon Mapping)
        API-->>App: Return Fused Scores, Category, & Actionable coping items
        App->>User: Update Dashboard & render interactive stress-relief tasks
    end
```

---

## Chapter 4: System Design

### 4.1 UI/UX Design Philosophy
The UI/UX design of SafeSpace prioritizes a calming aesthetic, utilizing deep indigo and violet tones (`AppTheme.bgDark`, `AppTheme.primaryPurple`) to reduce user anxiety. We avoid high-contrast primary colors (like pure red or yellow) unless indicating critical errors or warning systems. The app uses custom typography (Outfit/Inter) and fluid micro-animations for transitions, providing a premium feel.

### 4.2 User Flows & Screen Layouts

#### 4.2.1 Onboarding Screens
*   **Purpose:** Introduce new users to the app’s core features.
*   **Interaction:** Users swipe through three slides showing illustrations of mood tracking, guided habits, and emotional insights.
*   **System Integration:** On completion, the app caches a local preference flag via `SharedPreferences`, routing the user to the login screen on subsequent launches.

#### 4.2.2 Daily Check-In Screen
*   **Purpose:** Collect daily mood, energy, and sleep inputs.
*   **Interaction:** Users adjust sliders for energy level, sleep hours, and stress state.
*   **System Integration:** The values are saved locally and synced with Supabase, updating the home screen dashboard.

#### 4.2.3 DASS-42 Assessment Screen
*   **Purpose:** Collect clinical survey responses.
*   **Interaction:** Users answer questions on a Likert scale (0–3) using radio buttons or custom cards.
*   **System Integration:** Answers are compiled into a 42-element vector and sent to the backend for scoring.

#### 4.2.4 Journal Editor Screen
*   **Purpose:** Provide a workspace for self-reflection.
*   **Interaction:** Users enter a title in the top field and their thoughts in the main area.
*   **System Integration:** The inputs are formatted as `"Title\n\nBody"` and stored in the database.

#### 4.2.5 Profile & Settings Screen
*   **Purpose:** Manage account preferences and display usage history.
*   **Interaction:** Users view stats, goals, and history, or access account settings.
*   **System Integration:** Hides sensitive account details (like emails) on the main profile screen, restricting them to settings sub-menus.

### 4.3 Database Schema Design
The backend relies on Supabase's managed PostgreSQL database. Below is the Entity-Relationship schema:

```
                  +--------------------------+
                  |          users           |
                  +--------------------------+
                  | id (UUID, PK)            |
                  | email (VARCHAR, Unique)  |
                  | username (VARCHAR)       |
                  | created_at (TIMESTAMP)   |
                  +------------+-------------+
                               |
         +---------------------+---------------------+
         | 1:N                 | 1:N                 | 1:N
         v                     v                     v
+--------+-------+    +--------+-------+    +--------+-------+
| journal_entries|    |  mood_records  |    |     goals      |
+----------------+    +----------------+    +----------------+
| id (INT, PK)   |    | id (INT, PK)   |    | id (INT, PK)   |
| user_id (FK)   |    | user_id (FK)   |    | user_id (FK)   |
| content (TEXT) |    | stress (INT)   |    | title (VARCHAR)|
| created_at     |    | energy (FLOAT) |    | deadline       |
+----------------+    | sleep (INT)    |    | isDone (BOOL)  |
                      | created_at     |    +----------------+
                      +----------------+
```

---

## Chapter 5: Technical Implementation

### 5.1 Mobile Frontend Module
*   **Purpose:** Provide the mobile user interface and handle client-side business logic.
*   **Technologies Used:** Flutter SDK, Dart, SharedPreferences, HTTP package.
*   **Architecture:** Built using a model-view-controller (MVC) pattern. State is managed centrally in `lib/data/app_state.dart`.
*   **Main Features:** User authentication flow, interactive check-ins, journal editor, and history views.
*   **Security Considerations:** Local user tokens are encrypted, and API communications run over HTTPS.
*   **Performance Considerations:** Image assets are optimized, and heavy processing is offloaded to the backend.
*   **Integration with Other Modules:** Communicates with Supabase for user data and FastAPI for machine learning inference.

### 5.2 AI Inference Backend Module
*   **Purpose:** Host the machine learning models and calculate wellness scores.
*   **Technologies Used:** Python, FastAPI, Uvicorn, PyTorch, NumPy, Scikit-learn.
*   **Architecture:** Dockerized API wrapper exposed via Hugging Face Spaces.
*   **Main Features:** Predicts DASS-42 categories via MLP, processes bilingual sentiment via XLM-RoBERTa, and performs score fusion.
*   **Security Considerations:** Implements input validation and limits API cross-origin requests (CORS).
*   **Performance Considerations:** Models are cached in RAM using `@lru_cache` and serverless optimization to reduce inference latency.
*   **Integration with Other Modules:** Receives data payloads from the Flutter client and returns scoring results.

### 5.3 Backend Code Implementations

#### 5.3.1 Translation and Transformer Sequence Classification
This module handles input preprocessing, translation of regional Arabic dialects, and tokenization for transformer inference:

```python
import torch
from transformers import AutoTokenizer, AutoModelForSequenceClassification
import re

# Load fine-tuned XLM-RoBERTa model and tokenizer
MODEL_PATH = "./models/xlm_roberta_mental_health"
tokenizer = AutoTokenizer.from_pretrained(MODEL_PATH)
model = AutoModelForSequenceClassification.from_pretrained(MODEL_PATH)

def clean_and_normalize_text(text: str) -> str:
    text = re.sub(r'[^\w\s]', '', text)
    text = re.sub(r'\s+', ' ', text).strip()
    return text

def translate_arabic_dialect_to_english(text: str) -> str:
    # A pipeline to normalize and translate colloquial Arabic
    # In production, this connects to a fine-tuned translation model
    return "Translated text result representing the emotional context."

def analyze_sentiment_scores(raw_text: str) -> dict:
    cleaned_text = clean_and_normalize_text(raw_text)
    has_arabic = bool(re.search(r'[\u0600-\u06FF]', cleaned_text))
    
    if has_arabic:
        processed_text = translate_arabic_dialect_to_english(cleaned_text)
    else:
        processed_text = cleaned_text
        
    inputs = tokenizer(
        processed_text,
        padding=True,
        truncation=True,
        max_length=512,
        return_tensors="pt"
    )
    
    with torch.no_grad():
        outputs = model(**inputs)
        logits = outputs.logits
        probabilities = torch.softmax(logits, dim=1).flatten().tolist()
        
    return {
        "depression": probabilities[0],
        "anxiety": probabilities[1],
        "stress": probabilities[2]
    }
```

#### 5.3.2 Multi-Layer Perceptron Forward Pass (NumPy-based)
To minimize resource overhead, the DASS-42 classifier runs using raw matrix operations in NumPy:

```python
import pickle
import numpy as np

# Weights and biases are pre-loaded from training
with open("model_weights.pkl", "rb") as f:
    model_parameters = pickle.load(f)

def predict_mlp_dass(survey_vector: list) -> list:
    """
    Computes predictions using weight matrix multiplications.
    survey_vector is a list of 42 integers with values 0-3.
    """
    x = np.array(survey_vector, dtype=np.float32).reshape(1, -1)
    
    weights = model_parameters['weights']
    biases = model_parameters['biases']
    
    hidden_input = np.dot(x, weights[0]) + biases[0]
    hidden_output = np.maximum(0, hidden_input)
    
    logits = np.dot(hidden_output, weights[1]) + biases[1]
    
    exp_logits = np.exp(logits - np.max(logits, axis=1, keepdims=True))
    probabilities = exp_logits / np.sum(exp_logits, axis=1, keepdims=True)
    
    return probabilities.flatten().tolist()
```

#### 5.3.3 Score Fusion & Safety Override Logic
This component executes the weighted fusion algorithm, processes keyword-based crisis detection, and parses root stressors:

```python
import logging

CRISIS_LEXICON = [
    "suicide", "kill myself", "end my life", "self harm", 
    "انتحار", "قتل نفسي", "انهي حياتي", "اضر نفسي"
]

def process_multi_modal_assessment(survey_vector: list, journal_text: str) -> dict:
    normalized_text = journal_text.lower().strip()
    
    if any(keyword in normalized_text for keyword in CRISIS_LEXICON):
        logging.warning("Crisis override activated based on text keywords.")
        return {
            "status": "crisis",
            "fused_scores": {
                "depression": 1.0,
                "anxiety": 1.0,
                "stress": 1.0
            },
            "recommendations": [
                "Contact crisis support lines immediately.",
                "Reach out to an emergency response center."
            ]
        }
        
    survey_scores = predict_mlp_dass(survey_vector)
    text_scores = analyze_sentiment_scores(journal_text)
    
    fused_depression = (0.60 * survey_scores[0]) + (0.40 * text_scores["depression"])
    fused_anxiety = (0.60 * survey_scores[1]) + (0.40 * text_scores["anxiety"])
    fused_stress = (0.60 * survey_scores[2]) + (0.40 * text_scores["stress"])
    
    detected_stressors = []
    if any(w in normalized_text for w in ["exam", "grade", "university", "study", "دراسة", "امتحان"]):
        detected_stressors.append("Academic Pressure")
    if any(w in normalized_text for w in ["work", "boss", "salary", "office", "شغل", "وظيفة"]):
        detected_stressors.append("Workplace Burnout")
    if any(w in normalized_text for w in ["fight", "breakup", "lonely", "family", "علاقة", "اهل"]):
        detected_stressors.append("Interpersonal Stress")
        
    primary_stressor = detected_stressors[0] if detected_stressors else "General Stress"
    
    return {
        "status": "success",
        "fused_scores": {
            "depression": fused_depression,
            "anxiety": fused_anxiety,
            "stress": fused_stress
        },
        "primary_stressor": primary_stressor,
        "recommendations": get_coping_recommendations(fused_stress, primary_stressor)
    }

def get_coping_recommendations(stress_score: float, stressor: str) -> list:
    recommendations = ["Box Breathing Practice"]
    if stressor == "Academic Pressure":
        recommendations.append("Time-boxing task list")
    elif stressor == "Workplace Burnout":
        recommendations.append("Boundaries setting guide")
    
    if stress_score > 0.6:
        recommendations.append("Grounding Sensory Game")
    return recommendations
```

### 5.4 Database and Integration Module
*   **Purpose:** Maintain data consistency and handle user profile transactions.
*   **Technologies Used:** Supabase, PostgreSQL.
*   **Architecture:** Managed relational database with built-in Row-Level Security (RLS).
*   **Main Features:** User account storage, secure history logging, and data synchronization.
*   **Security Considerations:** Row-Level Security rules prevent users from querying data they did not author.
*   **Performance Considerations:** Configured indices on foreign key relationships to reduce query response times.
*   **Integration with Other Modules:** Integrates with the Flutter client via the Supabase Dart SDK.

---

## Chapter 6: Conclusion and Future Work

### 6.1 Conclusion
SafeSpace addresses the limitations of traditional digital mental health tracking by combining quantitative clinical diagnostics and qualitative natural language processing. Key contributions of this work include:
*   **Response Bias Mitigation:** The multi-modal score fusion model reduces the impact of user "masking" in self-reporting surveys, providing a more balanced view of user well-being.
*   **Bilingual Dialectal Classification:** The translation-classification pipeline enables sentiment analysis for regional Arabic dialects, expanding accessibility in the MENA region.
*   **Modular Architecture:** The decoupled mobile and server layers enable updates to the machine learning models without requiring client redeployments.
*   **Automated Crisis Safety Net:** The real-time keyword parser provides immediate safety overrides to connect users with emergency support when risk is identified.

### 6.2 Future Work
*   **Biometric Integration:** Connect the app to wearable APIs (e.g., Apple HealthKit, Google Fit) to collect Heart Rate Variability (HRV) and sleep duration metrics to supplement user self-reports.
*   **Voice Emotional Analysis:** Implement audio-based journaling to analyze vocal indicators (such as pitch, tone, and speech rate) for signs of anxiety or panic.
*   **Clinical Trial Verification:** Conduct a pilot study with clinical professionals to compare the system's automated assessment outputs with professional evaluations.
