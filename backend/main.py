from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import create_engine, Column, Integer, String, DateTime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
from pydantic import BaseModel
from datetime import datetime
import os

# Database configuration
DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://ideaboard:ideaboard@localhost:5432/ideaboard"
)

# SQLAlchemy setup
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


# Database Models
class Idea(Base):
    __tablename__ = "ideas"
    
    id = Column(Integer, primary_key=True, index=True)
    content = Column(String, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)


# Create tables
Base.metadata.create_all(bind=engine)


# Pydantic Models
class IdeaCreate(BaseModel):
    content: str


class IdeaResponse(BaseModel):
    id: int
    content: str
    created_at: datetime
    
    class Config:
        from_attributes = True


# FastAPI app
app = FastAPI(
    title="Idea Board API",
    description="A simple API for managing ideas",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "*"],  # In production, specify exact origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Dependency to get DB session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@app.get("/")
def root():
    return {"message": "Idea Board API is running"}


@app.get("/api/ideas", response_model=list[IdeaResponse])
def get_ideas(db: Session = Depends(get_db)):
    """Get all ideas"""
    ideas = db.query(Idea).order_by(Idea.created_at.desc()).all()
    return ideas


@app.post("/api/ideas", response_model=IdeaResponse, status_code=201)
def create_idea(idea: IdeaCreate, db: Session = Depends(get_db)):
    """Create a new idea"""
    if not idea.content or not idea.content.strip():
        raise HTTPException(status_code=400, detail="Content cannot be empty")
    
    db_idea = Idea(content=idea.content.strip())
    db.add(db_idea)
    db.commit()
    db.refresh(db_idea)
    return db_idea


@app.get("/health")
def health_check():
    """Health check endpoint"""
    return {"status": "healthy"}

