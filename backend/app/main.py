from fastapi import FastAPI
from app.core.database import engine, Base
from app.models import user
from app.routes import auth

app = FastAPI(title="Project Management Platform")

@app.get("/")
def root():
    return {"message": "API is running"}

Base.metadata.create_all(bind=engine)

app.include_router(auth.router)