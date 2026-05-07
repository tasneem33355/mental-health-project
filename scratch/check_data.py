from sqlalchemy import create_engine, text
import json

DATABASE_URL = "postgresql://safespace:AdminAdmin@postgresql-208383-0.cloudclusters.net:19712/safespace"
engine = create_engine(DATABASE_URL)

with engine.connect() as conn:
    result = conn.execute(text("SELECT id, user_id, primary_condition, clinical_scoring, created_at FROM analyses WHERE user_id = 102 ORDER BY created_at DESC LIMIT 10"))
    rows = [dict(row._mapping) for row in result]
    
    print(f"Found {len(rows)} records for user 102")
    for r in rows:
        print(f"ID: {r['id']}, Date: {r['created_at']}, Primary: {r['primary_condition']}, Scores: {r['clinical_scoring']}")
