import os
from sqlalchemy import create_engine, Column, Integer, String, DateTime
from sqlalchemy.orm import declarative_base, sessionmaker

DATABASE_URL = "postgresql://safespace:AdminAdmin@postgresql-208383-0.cloudclusters.net:19712/safespace"

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

class DBUser(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=True)
    email = Column(String, unique=True, index=True)
    password = Column(String)

db = SessionLocal()
users = db.query(DBUser).all()
print(f"Total users: {len(users)}")
for u in users:
    print(f"ID: {u.id}, Email: {u.email}, Password Hash: {u.password}")
db.close()
