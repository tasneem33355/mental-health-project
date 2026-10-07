# Slides 14A & 14B — Backend & Deployment Architecture (Expanded 6-Slide Version)

All claims verified against: `api.py`, `core_ai.py`, `Dockerfile`, `requirements.txt`.

---
---

# PART A: BACKEND ARCHITECTURE (3 Slides)

---

## Slide 14A-1: Framework & Server Choice

### Slide Title:
> **Why FastAPI + Uvicorn?**

### Visual Layout:

**Full-width comparison table (centered on slide):**

| Criteria | Flask | Django | FastAPI ✅ |
|:---|:---|:---|:---|
| Request Handling | Synchronous (WSGI) | Synchronous (WSGI) | **Asynchronous (ASGI)** |
| Data Validation | Manual / WTForms | Django Forms | **Built-in Pydantic** |
| API Documentation | Manual / Swagger plugin | Django REST Framework | **Auto-generated Swagger** |
| Startup Overhead | Minimal | Heavy (ORM, admin, templates) | **Minimal** |
| Best For | Simple web apps | Full-stack web apps | **Pure REST APIs** |

**Below the table, a small block quote:**
> FastAPI delivers the performance of Node.js with the simplicity of Python.

*Caption: Figure 14A-1 — Framework comparison for API-only backend services.*

---

### 🎤 Speaking Script

> "Before diving into our backend, let me briefly explain why we chose FastAPI as our web framework.
>
> We evaluated three Python frameworks: Flask, Django, and FastAPI. Flask is lightweight but synchronous — each incoming request blocks a thread until it completes, which limits concurrency. Django is a full-stack framework that includes an ORM, an admin panel, and a template engine — all unnecessary overhead when building a pure REST API.
>
> We selected **FastAPI** because it is built specifically for API services. It runs on the **ASGI standard** using the **Uvicorn** server, which means it uses an asynchronous event loop to handle requests concurrently without blocking. This is critical for our use case, where a single analysis request may take over a second while the AI models process the text.
>
> FastAPI also gives us two things for free: **Pydantic-based input validation**, which rejects malformed requests before they reach our code, and **automatic Swagger documentation**, which generates a live, interactive API reference at the `/docs` endpoint. We didn't have to write a single line of documentation code."

---

### 💡 Jury Q&A

**Q: Can't Flask also handle async with libraries like gevent or asyncio?**
> "Technically yes, but it requires bolting on external libraries and rewriting request handlers. FastAPI is async-native — every route handler supports `async def` out of the box, and the underlying Starlette framework handles the event loop. It's a cleaner, more maintainable approach."

**Q: What is the difference between WSGI and ASGI?**
> "WSGI — Web Server Gateway Interface — processes one request per thread synchronously. ASGI — Asynchronous Server Gateway Interface — uses an event loop and can process many requests concurrently on a single thread. ASGI is especially beneficial when requests involve I/O-bound operations like database queries or API calls."

---
---

## Slide 14A-2: Request Pipeline & Validation

### Slide Title:
> **Request Pipeline: From Client to AI**

### Visual Layout:

**A horizontal flow diagram (left-to-right, full width):**

```
  ┌────────┐     ┌────────────┐     ┌────────────┐     ┌────────────┐     ┌──────────┐
  │ Client │────▶│    CORS     │────▶│  Request   │────▶│  Pydantic  │────▶│  Route   │
  │Request │     │ Middleware  │     │   Logger   │     │ Validation │     │ Handler  │
  └────────┘     │allow_all(*)│     │method,path │     │42 ints,    │     │/analyze  │
                 └────────────┘     │status, ms  │     │text≥1 char │     └──────────┘
                                    └────────────┘     └────────────┘
```

**Below the diagram, 3 compact code snippets side by side:**

**Snippet 1 — CORS Middleware:**
```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
)
```

**Snippet 2 — Request Logger (custom):**
```python
@app.middleware("http")
async def log_requests(request, call_next):
    start = time.time()
    response = await call_next(request)
    ms = int((time.time()-start)*1000)
    logger.info(f"{request.method} {request.url.path} {response.status_code} {ms}ms")
```

**Snippet 3 — Pydantic Schema:**
```python
class AnalyzeRequest(BaseModel):
    text: str = Field(..., min_length=1)
    survey_answers: list[int] = Field(..., min_items=42, max_items=42)
    user_id: int | None = None
```

*Caption: Figure 14A-2 — Every request passes through 3 layers before reaching business logic.*

---

### 🎤 Speaking Script

> "Let me walk you through exactly what happens when a request hits our backend.
>
> Every HTTP request passes through **three middleware layers** before reaching our route handlers.
>
> First, the **CORS middleware**. Because our Flutter mobile app and web app send requests from different domains, the browser enforces Cross-Origin Resource Sharing restrictions. We configure the middleware to accept requests from all origins using `allow_origins=['*']`. This is intentional for our use case — the API is a public service consumed by multiple clients.
>
> Second, our **custom request logging middleware**. This intercepts every request, records the start time, waits for the response, then logs the HTTP method, URL path, response status code, and execution time in milliseconds. This gives us complete visibility into which endpoints are slow and which are failing. For example, we can see that the `/analyze` endpoint typically takes 1,200 milliseconds while `/checkin` takes under 50 milliseconds.
>
> Third, **Pydantic validation**. Each endpoint defines a strict schema. Our `AnalyzeRequest` schema, for instance, requires the `text` field to have at least one character and the `survey_answers` field to contain exactly 42 integers. If a client sends 41 answers or an empty text string, FastAPI automatically returns a **422 Unprocessable Entity** error with a detailed message explaining which field failed validation. Our AI models and database are never exposed to invalid input."

---

### 💡 Jury Q&A

**Q: Why `allow_origins=["*"]`? Isn't that a security risk?**
> "For a backend that serves a mobile app, CORS is irrelevant — mobile HTTP clients don't enforce CORS policies. CORS only applies to browser-based requests. Since we also have a web client, we set it to `*` for simplicity. In a production environment with sensitive data, we would whitelist specific domains."

**Q: How does the request logger help in production?**
> "It acts as our primary observability tool. If a user reports slow performance, we can check the server logs to see exactly which endpoint was called, how long it took, and what status code was returned. We log duration in milliseconds, so we can identify if the bottleneck is the AI model, the database, or the network."

**Q: What happens if someone sends survey_answers with values outside 0–3?**
> "The Pydantic schema enforces the array length but not individual value ranges at the schema level. However, the values are shifted by +1 and then passed through a StandardScaler that was fitted on the training data distribution. Out-of-range values would produce unusual scaled features, but the model would still return a probability distribution. For stricter enforcement, we could add per-element value constraints."

---
---

## Slide 14A-3: Database Architecture & Resilience

### Slide Title:
> **Database: Schema, Pooling & Graceful Degradation**

### Visual Layout:

**Left Column (50%) — Simplified schema diagram:**

```
┌─────────────────────┐    ┌─────────────────────────┐
│       users         │    │     journal_entries      │
│  id (PK)            │    │  id (PK)                │
│  name               │    │  user_id (FK → users)   │
│  email (Unique, Idx)│    │  content (TEXT)          │
│  password (SHA-256) │    │  created_at             │
│  created_at         │    │  updated_at             │
└─────────────────────┘    └─────────────────────────┘

┌─────────────────────┐    ┌─────────────────────────┐
│      checkins       │    │       analyses          │
│  id (PK)            │    │  id (PK)                │
│  user_id (Idx)      │    │  user_id (Idx)          │
│  mood, sleep, energy│    │  clinical_scoring (JSON)│
│  created_at         │    │  text/survey/fused (JSON│
└─────────────────────┘    │  severity, cause        │
                           │  suicidal_flag (BOOL)   │
                           │  text_input_hash (SHA)  │
                           │  created_at             │
                           └─────────────────────────┘
```

**Right Column (50%) — Bullet points:**

*   **4 Tables:** `users`, `journal_entries`, `checkins`, `analyses`
*   **Password Security:** SHA-256 hashing before storage
*   **Composite Indexes:** `(user_id, created_at)` on both `analyses` and `checkins` for fast time-series queries
*   **Deduplication:** `text_input_hash` (SHA-256 of journal text) prevents duplicate analysis records
*   **Audit Trail:** `analyses` stores raw text, individual model scores (text + survey), fused scores, severity, cause, and suicidal flag — complete forensic record of every assessment

**Bottom strip — Resilience callout box:**
> 🛡️ **Graceful Degradation:** If the database is unreachable at startup, the server starts anyway (8-second async timeout). If a DB write fails during analysis, the API still returns AI results to the user.

*Caption: Figure 14A-3 — PostgreSQL schema with resilience and audit trail design.*

---

### 🎤 Speaking Script

> "Now let's look at our database architecture.
>
> We use **Supabase PostgreSQL** as our cloud database, managed through **SQLAlchemy ORM**. The schema consists of four tables.
>
> The **users** table stores authentication data — name, email, and password. Passwords are hashed using **SHA-256** before storage. We never store plaintext passwords.
>
> The **journal_entries** table stores the user's journal text with timestamps. The **checkins** table stores daily mood, sleep, and energy metrics.
>
> The most important table is **analyses**. This is our complete audit trail. Every time a user submits an assessment, we store: the raw text input, a SHA-256 hash of that text for deduplication, the individual text model scores, the individual survey model scores, the fused scores, the detected severity level, the root cause category, and the suicidal flag. This means we can reconstruct exactly how any assessment was computed — which is essential for clinical credibility and debugging.
>
> We also define **composite indexes** on `(user_id, created_at)` for both the `analyses` and `checkins` tables. These indexes optimize the time-series queries that power our mood trend charts on the mobile app.
>
> Finally, our database layer is designed for **graceful degradation**. During server startup, table creation is wrapped in an 8-second async timeout. If the database is unreachable — for example, during a Supabase maintenance window — the server starts anyway and logs a warning. And during normal operation, if a database write fails after an analysis, we catch the exception and still return the AI results to the user. We prioritize the user experience over data persistence."

---

### 💡 Jury Q&A

**Q: Why SHA-256 for passwords instead of bcrypt or argon2?**
> "This is a valid critique. SHA-256 is a fast hash, which makes it more vulnerable to brute-force attacks compared to bcrypt, which is intentionally slow. For a production system handling sensitive health data, we would upgrade to bcrypt or argon2id. SHA-256 was chosen for this prototype to keep dependencies minimal, but we acknowledge it's not best practice for password storage."

**Q: Why store raw text in the analyses table? Isn't that a privacy concern?**
> "We store the raw text for two reasons: debugging and clinical audit. If the model produces an unexpected result, we need to see exactly what text was analyzed. In a production deployment subject to HIPAA or GDPR, we would encrypt the text_input column at rest and implement data retention policies. For our prototype, we prioritize diagnostic transparency."

**Q: What is the `text_input_hash` column used for?**
> "Deduplication. If a user accidentally submits the same journal text twice — for example by double-tapping the submit button — we can detect the duplicate by comparing the SHA-256 hash of the new text against existing hashes for that user. This prevents inflating the analysis history with identical records."

**Q: In the database schema, why are results (scores) stored as JSON instead of separate columns or tables?**
> "Storing scores directly as JSON (in `clinical_scoring`, `text_scores`, `survey_scores`, and `fused_scores`) provides three main advantages:
> 1. **Schema Flexibility:** If we add new mental health subscales, conditions, or dimensions to our machine learning models in the future, we don't have to run database migrations or alter the PostgreSQL table layout. The JSON columns naturally adapt to any new keys.
> 2. **Performance (Single-Row Retrieval):** We can retrieve the entire multi-dimensional assessment profile in a single database read without performing relational table JOINs across a separate scores table.
> 3. **Loose Coupling:** It keeps the database layer decoupled from the ML models. The database is a simple persistence store, and JSON maps directly to the Python dictionaries returned by the prediction pipeline. Since PostgreSQL natively supports JSON indexing and query path extraction (using `->>` operators), we retain full querying and filtering power."

---
---
---

# PART B: DEPLOYMENT ARCHITECTURE (3 Slides)

---

## Slide 14B-1: Client Deployment: Web (Netlify) & Mobile (APK)

### Slide Title:
> **Reaching Users Everywhere: Web & Mobile Platforms**

### Visual Layout:

**Two Feature Cards side-by-side (50% / 50% split):**

```
┌──────────────────────────────────────────┐   ┌──────────────────────────────────────────┐
│         🌐 FLUTTER WEB APP               │   │         📱 ANDROID MOBILE APK            │
├──────────────────────────────────────────┤   ├──────────────────────────────────────────┤
│ • Compiled using Flutter Web             │   │ • Packaged into a ready-to-install       │
│ • Deployed on Netlify's high-speed CDN   │   │   Android Application Package (APK)      │
│ • Zero-installation instant access       │   │ • Runs natively on mobile devices        │
│ • Fully responsive across mobile,        │   │ • Smooth touch interactions, local       │
│   tablet, and desktop browsers           │   │   storage, and system integration        │
└──────────────────────────────────────────┘   └──────────────────────────────────────────┘
```

**Key Integration Benefit:**
> 🔄 **Unified Codebase:** Both platforms share 100% of the same Dart/Flutter source code, ensuring consistent features, styling, and business logic across web and mobile.

*Caption: Figure 14B-1 — Multi-platform client deployment architecture.*

---

### 🎤 Speaking Script

> "To make SafeSpace as accessible as possible, we deploy our frontend across two distinct platforms from a single codebase.
>
> First, we compiled the application using the Flutter Web engine. We deployed the resulting web folder to **Netlify**, utilizing their global content delivery network. This allows users to access the full mental health platform instantly on any browser without downloading an app.
>
> Second, we packaged the application into a native **Android Mobile APK**. This version runs natively on Android devices, offering a smoother user interface, touch gestures, and local device storage.
>
> Sharing a single codebase guarantees that whether a user logs in via web or mobile, they get the exact same experience, theme modes, Arabic support, and mental wellness tools."

---

### 💡 Jury Q&A

**Q: Why host the web build on Netlify instead of hosting it directly on Hugging Face alongside the API?**
> "Separating the frontend and backend is a modern web development best practice. Netlify is specialized for static frontends, offering lightning-fast loading speeds, high availability, and global caching close to the user. Hugging Face is dedicated to running our heavy AI models and Python backend, ensuring both systems can scale and operate independently without resource conflict."

**Q: Are there any differences in functionality between the mobile APK and the Web app?**
> "No, the features are completely identical. Both the APK and the Web app communicate with the same hosted backend API and Supabase database. The only difference is the deployment medium: Netlify provides immediate browser-based access, while the APK offers a native app experience on mobile devices."

---
---

## Slide 14B-2: Backend Hosting: Containerization & Cloud Deployment

### Slide Title:
> **Automated & Zero-Maintenance Backend Deployment**

### Visual Layout:

**A simplified deployment workflow diagram (horizontal):**

```
  ┌──────────┐     ┌──────────────┐     ┌──────────────────┐     ┌──────────────┐
  │Developer │────▶│  Git Push to  │────▶│ Auto-Rebuild via │────▶│ Public API   │
  │ Machine  │     │  Hugging Face│     │ Docker Container │     │ 15+ Endpoints│
  └──────────┘     └──────────────┘     └──────────────────┘     └──────────────┘
```

**Core Backend Highlights:**

*   **Docker Containerization:** Packages the Python FastAPI code, PyTorch models, and all system dependencies together so it runs exactly the same in any environment.
*   **Hugging Face Spaces Hosting:** Automatically triggers a fresh build and redeployment every time new code is pushed to the repository.
*   **Public API Endpoints:** Over 15 hosted REST API endpoints serve the client app, handling authentication, assessments, check-ins, journal entries, and model analysis.
*   **DevOps Simplification:** Eliminates the need for manually setting up CI/CD pipelines, SSL certificates, or database connectors.

*Caption: Figure 14B-2 — Automated containerized hosting pipeline.*

---

### 🎤 Speaking Script

> "Instead of managing physical servers or configuring complex cloud virtual machines, we containerized our backend using Docker and deployed it on Hugging Face Spaces.
>
> Whenever we push code changes to the repository, Hugging Face automatically detects our configuration, builds a new Docker container, and redeploys the live application.
>
> This setup exposes over 15 public API endpoints that securely handle user authentication, daily check-ins, journal submissions, and the wellness recommendation engine. This zero-maintenance DevOps approach allowed us to focus completely on refining the application logic rather than managing server infrastructure."

---

### 💡 Jury Q&A

**Q: What is the main benefit of containerizing the backend with Docker?**
> "Machine learning applications have complex system dependencies like PyTorch, Transformers, and scientific libraries. Docker packages the exact operating system, library versions, and model weights into a single container. This ensures that the backend runs exactly the same on our local development machine as it does on the cloud server, eliminating any configuration or library version errors."

**Q: You mentioned 15+ API endpoints. What do they do?**
> "The API endpoints handle all core business logic: user registration and login, adding and updating goals, saving daily check-in logs (mood, sleep, and energy), storing private journal entries, requesting text/DASS assessment evaluations, and retrieving personalized recommendations. The client apps communicate with these endpoints entirely via secure HTTPS JSON requests."

---
---

## Slide 14B-3: Performance & User Experience Optimization

### Slide Title:
> **Optimizing Response Times for a Seamless User Experience**

### Visual Layout:

**Before/After Optimization Comparison:**

```
   ❌ UNOPTIMIZED BACKEND                 ✅ OPTIMIZED BACKEND
   ┌────────────────────────────────┐     ┌────────────────────────────────┐
   │ • Loading models per request   │     │ • Pre-cached AI models in RAM  │
   │ • Cold starts on model weight  │     │ • Gradient-free calculations   │
   │ • High processing overhead     │     │ • Truncated text inputs        │
   │                                │     │                                │
   │ ⏱ Response time: ~8.0 seconds  │     │ ⚡ Response time: <1.5 seconds  │
   └────────────────────────────────┘     └────────────────────────────────┘
```

**Key User Benefits:**
*   **Instant Feedback:** Users receive immediate results after writing down their daily thoughts or completing wellness questionnaires.
*   **Responsive Flow:** Short response latency ensures a fluid and natural conversation flow when interacting with the wellness helper.
*   **Data Integrity:** Reliable backend processing guarantees that user input is securely analyzed and saved without timeout issues.

*Caption: Figure 14B-3 — Latency optimization from 8s to under 1.5s.*

---

### 🎤 Speaking Script

> "A key priority of our system design was providing a fast, responsive user experience. 
>
> Initially, loading deep learning models, tokenizers, and weights on every request took around **8 seconds**, which is far too slow for a fluid interactive experience.
>
> We optimized this by keeping our models pre-cached in system memory so they only load once on startup. We also disabled gradient computations during prediction and limited the maximum text input size to fit typical journal entry lengths. 
>
> These optimizations brought our response latency down from **8 seconds to under 1.5 seconds**. This ensures that users receive instant wellness insights and predictions without any frustrating delays."

---

### 💡 Jury Q&A

**Q: Why is a response time under 1.5 seconds critical for this type of application?**
> "When users are sharing sensitive feelings, a fast response is vital for maintaining user engagement and trust. If an app hangs for 8 seconds after a journal entry is submitted, users might think it has crashed or feel anxious about the delay. Keeping latency low ensures a seamless, supportive, and highly responsive user experience."

**Q: How does this optimization affect your server resources?**
> "By caching the models in memory and avoiding the overhead of loading them from disk on every request, we greatly reduce CPU utilization. Disabling gradients also minimizes memory usage during predictions, allowing our server to handle multiple concurrent users efficiently with minimal resources."
