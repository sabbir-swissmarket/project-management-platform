from fastapi import FastAPI
from app.core.database import engine, Base
from app.models import user
from backend.app.routes import auths

app = FastAPI(title="Project Management Platform")

@app.get("/")
def root():
    return {"message": "API is running"}

Base.metadata.create_all(bind=engine)

app.include_router(auths.router)