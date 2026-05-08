from sqlalchemy import create_engine, text
from datetime import datetime

DATABASE_URL = "postgresql://safespace:AdminAdmin@postgresql-208383-0.cloudclusters.net:19712/safespace"

print("="*50)
print("Database Connection Test (No AI)")
print("="*50)

try:
    print("\n[1] Creating engine with 10s timeout...")
    engine = create_engine(DATABASE_URL, connect_args={'connect_timeout': 10})

    print("[2] Attempting connection...")
    with engine.connect() as conn:
        # Test basic connectivity
        result = conn.execute(text("SELECT 1"))
        print("[3] SELECT 1 = OK")

        # Check what tables exist
        tables = conn.execute(text(
            "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'"
        )).fetchall()
        print(f"\n--- Tables in database ---")
        for t in tables:
            print(f"  - {t[0]}")

        # Count rows in each table
        for t in tables:
            count = conn.execute(text(f"SELECT COUNT(*) FROM {t[0]}")).scalar()
            print(f"    {t[0]}: {count} rows")

        # Show last 5 analyses
        try:
            rows = conn.execute(text(
                "SELECT id, primary_condition, created_at FROM analyses ORDER BY created_at DESC LIMIT 5"
            )).fetchall()
            print(f"\n--- Last 5 Analyses ---")
            for r in rows:
                print(f"  ID={r[0]}  condition={r[1]}  date={r[2]}")
        except Exception:
            print("  (analyses table not found or empty)")

        # Show users
        try:
            users = conn.execute(text("SELECT id, email, created_at FROM users")).fetchall()
            print(f"\n--- Users ---")
            for u in users:
                print(f"  ID={u[0]}  email={u[1]}  created={u[2]}")
        except Exception:
            print("  (users table not found or empty)")

    print("\n" + "="*50)
    print("CONNECTION SUCCESSFUL")
    print("="*50)

except Exception as e:
    print(f"\nCONNECTION FAILED: {e}")
