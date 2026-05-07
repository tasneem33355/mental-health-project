# Production Readiness Audit

Scope: frontend, database, features, and user experience.

## High Priority Gaps
- Auth is not secure or enforced: APIs accept `user_id` from client and return user history without verifying identity. Any client can access other users' data. Implement token-based auth and derive user_id server-side.
- Passwords stored insecurely: client stores plaintext password in SharedPreferences; server allows plaintext fallback and uses unsalted SHA-256. Use bcrypt/argon2; remove plaintext fallback; store tokens in secure storage only.
- Check-ins not persisted in DB: daily check-ins stored locally only. Add a `checkins` table and persist via API.
- Database schema incomplete for core features: missing tables for check-ins, goals, sessions, etc. Add required tables and foreign keys.

## Medium Priority Gaps
- Hardcoded API base URL: no staging/production environment separation. Move to environment config.
- Logout does not clear stored user state: it navigates without clearing saved data. Call a clear/reset routine on logout.
- DASS scale mismatch risk: UI uses 0-4 while DASS-42 is typically 0-3. Align scale or adjust scoring logic.
- Error handling is weak: network failures often return empty lists or generic errors. Add timeouts, retries, and user-friendly error states.

## UX and Feature Completeness
- Auto-login missing: splash always routes to onboarding even if user is logged in. Route based on `AppState.isLoggedIn`.
- Placeholder actions: "Forgot Password", social login, profile edits are non-functional. Implement or remove until ready.

## Data and Analytics Limitations
- Analyses not fully stored: minimal fields saved; missing detailed scores/recommendations and client timestamps. Persist full output fields for analytics and debugging.
- Indexing missing: no indexes on `created_at`/`user_id` for history queries. Add indexes for performance.

## Backend Gaps
- No auth enforcement: endpoints accept user_id from clients and return data without verifying identity. Add JWT/session auth and authorization checks.
- Password handling is weak: unsalted SHA-256 and plaintext fallback. Move to bcrypt/argon2 and remove plaintext path.
- CORS is wide open: `allow_origins=["*"]` with credentials. Restrict origins and limit credentials.
- No rate limiting or abuse protection: add per-IP/user throttling on auth and analysis endpoints.
- Error handling leaks details: raw exceptions are returned. Normalize error responses and hide internals.
- No database migrations: relies on `create_all`. Introduce Alembic migrations and schema versioning.
- Missing structured logging/monitoring: add request logs, tracing, and health checks.
