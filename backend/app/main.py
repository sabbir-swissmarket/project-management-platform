from fastapi import FastAPI
from app.core.database import engine, Base
from app.models import user, project, task, payment
from app.routes import auths, projects, tasks, payments, admin, developers

app = FastAPI(title="Project Management Platform")

@app.get("/")
def root():
    return {"message": "API is running"}

Base.metadata.create_all(bind=engine)

app.include_router(auths.router)
app.include_router(projects.router)
app.include_router(tasks.router)
app.include_router(payments.router)
app.include_router(admin.router)
app.include_router(developers.router)
