import shutil
import os
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session
from app.core.database import SessionLocal
from app.models.task import Task
from app.models.user import User
from app.schemas.task import TaskCreate
from app.core.dependencies import require_role, get_current_user
from app.services.task_services import validate_status_transition

# disable slash redirect to avoid 307 responses when client uses exact path
router = APIRouter(prefix="/tasks", tags=["Tasks"], redirect_slashes=False)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("")
def create_task(
    task: TaskCreate,
    db: Session = Depends(get_db),
    user = Depends(require_role("buyer"))
):
    # ensure assigned developer exists and really is a developer
    dev = db.query(User).filter(User.id == task.assigned_developer_id).first()
    if not dev or dev.role != "developer":
        raise HTTPException(status_code=400, detail="Invalid developer id")

    new_task = Task(
        title=task.title,
        description=task.description,
        project_id=task.project_id,
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

@router.patch("/{task_id}/submit")
def submit_task(
    task_id: str,
    hours_logged: float = Form(...),
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    user = Depends(require_role("developer"))
):
    task = db.query(Task).filter(Task.id == task_id).first()

    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    
    if task.assigned_developer_id != user.id:
        raise HTTPException(status_code=403, detail="Not your task")

    if task.status != "in_progress":
        raise HTTPException(status_code=400, detail="Task must be in progress to submit")
    
    validate_status_transition(task.status, "submitted")
    task.hours_logged = hours_logged

    # Save file
    os.makedirs("uploads", exist_ok=True)

    file_location = f"{task.id}_{file.filename}"
    file_path = os.path.join("uploads", file_location)
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    # Update task
    task.status = "submitted"
    task.hours_logged = hours_logged
    task.solution_file_path = file_location
    db.commit()
    db.refresh(task)

    return {
        "message": "Task submitted successfully",
        "hours_logged": task.hours_logged,
        "status": task.status
    }

@router.get("/{task_id}")
def get_task_details(
    task_id: str,
    db: Session = Depends(get_db),
    user = Depends(get_current_user)
):
    task = db.query(Task).filter(Task.id == task_id).first()

    if task.status == "submitted":
        return {
            "title": task.title,
            "hours_logged": task.hours_logged,
            "hourly_rate": task.hourly_rate,
            "total_due": task.hours_logged * task.hourly_rate,
            "status": task.status,
            "download_available": False
        }
    if task.status == "paid":
        return {
            "title": task.title,
            "download_available": True
        }
    
@router.get("/{task_id}/download")
def download_solution(
    task_id: str,
    db: Session = Depends(get_db),
    user = Depends(require_role("buyer"))
):
    task = db.query(Task).filter(Task.id == task_id).first()

    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    
    if task.project.buyer_id != user.id:
        raise HTTPException(status_code=403, detail="Not your project")

    if task.status != "paid":
        raise HTTPException(status_code=400, detail="Payment required to access file")

    if not task.solution_file_path:
        raise HTTPException(status_code=404, detail="File not available")

    file_path = os.path.join("uploads", task.solution_file_path)
    if not os.path.exists(file_path):
        raise HTTPException(status_code=404, detail="File not found")

    return FileResponse(
        path=file_path,
        filename=os.path.basename(file_path),
        media_type="application/zip"
    )
