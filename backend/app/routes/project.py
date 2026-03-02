from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.database import SessionLocal
from app.models.project import Project
from app.schemas.project import ProjectCreate
from app.core.dependencies import require_role

router = APIRouter(prefix="/projects", tags=["Projects"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/")
def create_project(
    project: ProjectCreate,
    db: Session = Depends(get_db),
    user = Depends(require_role("buyer"))
):
    new_project = Project(
        title=project.title,
        description=project.description,
        buyer_id=user.id
    )

    db.add(new_project)
    db.commit()
    db.refresh(new_project)

    return new_project