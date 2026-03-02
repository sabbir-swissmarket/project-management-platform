from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.core.database import SessionLocal
from app.models.task import Task
from app.schemas.task import TaskCreate
from app.core.dependencies import require_role, get_current_user
from app.services.task_service import validate_status_transition

router = APIRouter(prefix="/tasks", tags=["Tasks"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/")
def create_task(
    task: TaskCreate,
    project_id: str,
    db: Session = Depends(get_db),
    user = Depends(require_role("buyer"))
):
    new_task = Task(
        title=task.title,
        description=task.description,
        project_id=project_id,
        hourly_rate=task.hourly_rate,
        assigned_developer_id=task.assigned_developer_id,
        status="todo"
    )

    db.add(new_task)
    db.commit()
    db.refresh(new_task)

    return new_task

@router.get("/my-tasks")
def get_my_tasks(
    db: Session = Depends(get_db),
    user = Depends(require_role("developer"))
):
    tasks = db.query(Task).filter(Task.assigned_developer_id == user.id).all()
    return tasks

@router.patch("/{task_id}/status")
def update_task_status(
    task_id: str,
    new_status: str,
    db: Session = Depends(get_db),
    user = Depends(get_current_user)
):
    task = db.query(Task).filter(Task.id == task_id).first()

    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    
    if user.role == "developer":
        if task.assigned_developer_id != user.id:
            raise HTTPException(status_code=403, detail="Not your task")

    # Validate transition
    try:
        validate_status_transition(task.status, new_status)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

    task.status = new_status
    db.commit()
    db.refresh(task)

    return task