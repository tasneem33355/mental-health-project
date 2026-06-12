# Presentation Script & Slide Structure: Slides 14A & 14B

This guide splits the previous backend slide into two distinct slides: **Backend Architecture** and **Deployment Architecture**.

---

## 🖥️ Slide 14A: Backend Architecture

### Slide Title:
> **Backend Architecture & Database Integration**

### Visual Structure (Split Layout - 50% Left / 50% Right):

*   **Left Column (Visual Diagram / Image):**
    *   **Image/Diagram Description:** Database integration and service architecture diagram.
        *   Show **FastAPI** receiving JSON payloads from client inputs.
        *   Show the internal request routing path passing through validation schemas.
        *   Represent the **SQLAlchemy ORM** connection layer showing a pool of active connection threads (connection pool) pointing to the **Supabase PostgreSQL** cloud instance.
        *   Highlight the **Pool Pre-Ping (`pool_pre_ping=True`)** mechanism testing a connection block before database query execution.
    *   **Caption:** *Figure 14A: FastAPI service architecture with SQL database connection pooling.*

*   **Right Column (Slide Bullet Points):**
    *   **Framework:** **FastAPI** — Modern, high-performance web framework built with native Python asynchronous support.
    *   **Execution Runtime:** **Uvicorn ASGI Server** — Handles high-concurrency requests asynchronously.
    *   **Database ORM:** **SQLAlchemy** — Abstracted database access and session management.
    *   **Resiliency & Pooling:** Connection pool settings configured with a **5-second timeout** and **active pre-ping testing** to prevent connection dropouts.

---

### 🎤 Speaking Script: Slide 14A (Backend Architecture)

*"Let's first look at the backend architecture of SafeSpace, which serves as the core logic hub for all our AI computations and database interactions.*

*We built our backend service using **FastAPI**, a modern and high-performance Python web framework. We selected FastAPI primarily for its native support for asynchronous programming. When paired with **Uvicorn**, which is our asynchronous ASGI server, the backend can handle thousands of concurrent requests from multiple mobile and web clients without blocking or bottlenecking.*

*For data persistence, we integrated **SQLAlchemy ORM** to manage session queries with our cloud-hosted **Supabase PostgreSQL** database. Because cloud database connections can occasionally drop or experience latency, we configured a resilient **connection pool** with a 5-second timeout and enabled `pool_pre_ping=True`. This setting forces SQLAlchemy to perform a lightweight test query before executing any database transaction, automatically recycling stale connections. This ensures that the SafeSpace user experience remains uninterrupted, even during brief cloud database reconnects.*

*Next, let's explore how we package and deploy this engine to production."*

---

## 🖥️ Slide 14B: Deployment Architecture

### Slide Title:
> **Cloud Deployment & Model Optimization**

### Visual Structure (Split Layout - 50% Left / 50% Right):

*   **Left Column (Visual Diagram / Image):**
    *   **Image/Diagram Description:** Deployment and model initialization diagram.
        *   Represent the **Docker Container** wrapper around the API environment (`Dockerfile`).
        *   Show the deployment onto **Hugging Face Spaces**.
        *   Draw a representation of **RAM Memory Caching** showing the **XLM-RoBERTa** model preloaded in RAM.
        *   Contrast the cold start initialization time (**8.0 seconds**) with the warm memory cached execution time (**< 1.5 seconds**).
    *   **Caption:** *Figure 14B: Containerized deployment on Hugging Face with memory-cached transformer inference.*

*   **Right Column (Slide Bullet Points):**
    *   **Containerization:** Fully packaged via a **Docker image** to guarantee exact dependency replication in the cloud.
    *   **Hosting Environment:** Deployed on **Hugging Face Spaces** for serverless, managed container execution.
    *   **Memory Caching:** Uses cache decorators (`@lru_cache` and `@st.cache_resource`) to store transformer weights in RAM.
    *   **Latency Correction:** Drastically reduces model evaluation times from **8.0 seconds** on cold start to **under 1.5 seconds** for active queries.

---

### 🎤 Speaking Script: Slide 14B (Deployment Architecture)

*"Now, looking at our deployment architecture and model performance optimizations.*

*To ensure portability and ease of setup, we containerized the entire backend environment using **Docker**. The container encapsulates our specific versions of **PyTorch**, **NumPy**, and translation utilities, protecting the system from dependency drift. This Docker image is deployed to **Hugging Face Spaces**, which hosts our live API endpoints.*

*Our primary challenge in production was handling model loading times. When a user submits text, loading a complex deep learning model like **XLM-RoBERTa** from disk takes up to eight seconds, which is unacceptable for a real-time mobile app. We solved this by implementing **memory-mapped caching** via Python caching decorators. When the container starts, the model is initialized once and permanently cached in RAM.*

*As you can see, this optimization brought our average prediction latency down from **8.0 seconds to under 1.5 seconds** for active users, delivering an instant, seamless assessment experience. I will now hand over to my colleague to cover the unique value proposition of our crisis override system. Thank you."*
