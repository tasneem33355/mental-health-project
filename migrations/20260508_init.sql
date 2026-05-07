-- Initial schema and indexes for production (Postgres compatible)

CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255),
  password VARCHAR(255),
  created_at TIMESTAMP WITHOUT TIME ZONE,
  name TEXT
);

CREATE TABLE IF NOT EXISTS analyses (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NULL,
  primary_condition VARCHAR(255),
  clinical_scoring JSON,
  created_at TIMESTAMP WITHOUT TIME ZONE,
  text_input TEXT,
  text_input_hash TEXT,
  text_scores JSONB,
  survey_scores JSONB,
  fused_scores JSONB,
  severity TEXT,
  cause TEXT,
  suicidal_flag BOOLEAN DEFAULT FALSE,
  model_version TEXT,
  app_version TEXT,
  locale TEXT
);

CREATE TABLE IF NOT EXISTS checkins (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL,
  mood INTEGER NOT NULL,
  sleep INTEGER NOT NULL,
  energy DOUBLE PRECISION NOT NULL,
  created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS journal_entries (
  id SERIAL PRIMARY KEY,
  user_id INTEGER,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITHOUT TIME ZONE
);

CREATE TABLE IF NOT EXISTS user_preferences (
  user_id INTEGER PRIMARY KEY,
  theme TEXT DEFAULT 'dark',
  language TEXT DEFAULT 'en',
  notifications_enabled BOOLEAN DEFAULT TRUE,
  crisis_locale TEXT
);

CREATE TABLE IF NOT EXISTS consents (
  id SERIAL PRIMARY KEY,
  user_id INTEGER,
  consent_type TEXT NOT NULL,
  granted BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS ix_analyses_user_id_created_at ON analyses (user_id, created_at);
CREATE INDEX IF NOT EXISTS ix_checkins_user_id_created_at ON checkins (user_id, created_at);

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'fk_analyses_user'
  ) THEN
    ALTER TABLE analyses
      ADD CONSTRAINT fk_analyses_user
      FOREIGN KEY (user_id) REFERENCES users(id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'fk_checkins_user'
  ) THEN
    ALTER TABLE checkins
      ADD CONSTRAINT fk_checkins_user
      FOREIGN KEY (user_id) REFERENCES users(id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'fk_journal_entries_user'
  ) THEN
    ALTER TABLE journal_entries
      ADD CONSTRAINT fk_journal_entries_user
      FOREIGN KEY (user_id) REFERENCES users(id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'fk_consents_user'
  ) THEN
    ALTER TABLE consents
      ADD CONSTRAINT fk_consents_user
      FOREIGN KEY (user_id) REFERENCES users(id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'fk_user_preferences_user'
  ) THEN
    ALTER TABLE user_preferences
      ADD CONSTRAINT fk_user_preferences_user
      FOREIGN KEY (user_id) REFERENCES users(id);
  END IF;
END $$;
