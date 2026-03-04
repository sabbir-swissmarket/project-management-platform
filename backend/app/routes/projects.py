from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.core.database import SessionLocal
from app.models.project import Project
from app.schemas.project import ProjectCreate
from app.core.dependencies import require_role

# turning off automatic trailing‑slash redirects ensures the client
# sees a proper 404 instead of a 307 when they mistype the URL. the
# redirect was responsible for the earlier 307 messages seen by the app.
router = APIRouter(prefix="/projects", tags=["Projects"], redirect_slashes=False)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@router.get("")
def list_projects(
    db: Session = Depends(get_db),
    user = Depends(require_role("buyer"))
):
    # return all projects owned by the authenticated buyer
    return db.query(Project).filter(Project.buyer_id == user.id).all()


@router.get("/{project_id}/tasks")
def list_project_tasks(
    project_id: str,
    db: Session = Depends(get_db),
    user = Depends(require_role("buyer"))
):
    # verify ownership
    project = db.query(Project).filter(Project.id == project_id).first()
    if not project or project.buyer_id != user.id:
        raise HTTPException(status_code=404, detail="Project not found")

    from app.models.task import Task
    tasks = db.query(Task).filter(Task.project_id == project_id).all()
    return tasks

@router.post("")
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