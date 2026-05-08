import os
import random
from datetime import datetime, timedelta
from sqlalchemy import create_engine, Column, Integer, String, DateTime, JSON
from sqlalchemy.orm import declarative_base, sessionmaker

print("="*50)
print("SafeSpace MVP Database Seeder (45 Days)")
print("="*50)

DATABASE_URL = "REMOVED_SECRET"

try:
    engine = create_engine(DATABASE_URL, connect_args={'connect_timeout': 10})
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    Base = declarative_base()

    class DBUser(Base):
        __tablename__ = "users"
        id = Column(Integer, primary_key=True, index=True)
        email = Column(String, unique=True, index=True)
        password = Column(String)
        created_at = Column(DateTime, default=datetime.utcnow)

    class DBAnalysis(Base):
        __tablename__ = "analyses"
        id = Column(Integer, primary_key=True, index=True)
        user_id = Column(Integer, index=True, nullable=True)
        primary_condition = Column(String)
        clinical_scoring = Column(JSON)
        created_at = Column(DateTime, default=datetime.utcnow)

    print("\nConnecting to database and ensuring tables exist...")
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()

    print("Creating dummy user (test@example.com)...")
    user = db.query(DBUser).filter_by(email="test@example.com").first()
    if not user:
        user = DBUser(email="test@example.com", password="hashed_password_123")
        db.add(user)
        db.commit()
        db.refresh(user)

    print("\nGenerating 45 days of realistic DASS-42 mood history...")
    
    # Clear old dummy data for this user to avoid duplicates if run multiple times
    db.query(DBAnalysis).filter(DBAnalysis.user_id == user.id).delete()
    db.commit()

    # Generate 45 days of data
    # We will simulate a healing journey over 45 days, with occasional bad days.
    scores_history = []
    
    dep, anx, str_score = 30, 26, 34 # Start high (Severe)
    
    for day in range(45):
        # Gradual improvement (scores drop over time)
        dep = max(2, dep - random.uniform(0, 1.2))
        anx = max(2, anx - random.uniform(0, 1.0))
        str_score = max(4, str_score - random.uniform(0, 1.4))
        
        # Add random "bad days" spikes (e.g. panic attacks or stressful events)
        if day in [12, 25, 38]:
            dep += random.randint(4, 10)
            anx += random.randint(8, 14)
            str_score += random.randint(6, 12)
            
        # Ensure scores don't exceed DASS-42 maximums (42)
        dep = min(42, int(dep))
        anx = min(42, int(anx))
        str_score = min(42, int(str_score))
        
        scores_history.append((dep, anx, str_score))
    
    for i, (d, a, s) in enumerate(scores_history):
        record_date = datetime.utcnow() - timedelta(days=44 - i)
        
        max_score = max(d, a, s)
        primary = "depression" if max_score == d else ("anxiety" if max_score == a else "stress")
        
        clinical_data = {
            "depression": {"score": d, "severity": "Moderate"},
            "anxiety": {"score": a, "severity": "Mild"},
            "stress": {"score": s, "severity": "Moderate"}
        }
        
        analysis = DBAnalysis(
            user_id=user.id,
            primary_condition=primary,
            clinical_scoring=clinical_data,
            created_at=record_date
        )
        db.add(analysis)

    db.commit()
    print("\nSuccessfully seeded the database! 45 days of data added.")
    print("Refresh your Flutter app to see the beautiful new Mood Graph!")
    db.close()

except Exception as e:
    print(f"\nError connecting or seeding database: {e}")
