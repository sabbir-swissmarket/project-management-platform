from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.core.database import SessionLocal
from app.models.project import Project
from app.models.task import Task
from app.models.payment import Payment
from app.core.dependencies import require_role

router = APIRouter(prefix="/admin", tags=["Admin"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.get("/stats")
def get_admin_stats(
    db: Session = Depends(get_db),
    user = Depends(require_role("admin"))
):
    total_projects = db.query(Project).count()
    total_tasks = db.query(Task).count()
    completed_tasks = db.query(Task).filter(Task.status == "paid").count()
    total_payments = db.query(Payment).count()
    pending_payments = db.query(Task).filter(Task.status == "submitted").count()
    total_hours = db.query(func.sum(Task.hours_logged)).scalar() or 0
    total_revenue = db.query(func.sum(Payment.amount)).scalar() or 0

    return {
        "total_projects": total_projects,
        "total_tasks": total_tasks,
        "completed_tasks": completed_tasks,
        "total_payments": total_payments,
        "pending_payments": pending_payments,
        "total_developer_hours": total_hours,
        "revenue_generated": total_revenue
    }