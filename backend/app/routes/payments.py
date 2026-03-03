from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.core.database import SessionLocal
from app.models.task import Task
from app.models.payment import Payment
from app.core.dependencies import require_role

router = APIRouter(prefix="/payments", tags=["Payments"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/{task_id}")
def pay_for_task(
    task_id: str,
    db: Session = Depends(get_db),
    user = Depends(require_role("buyer"))
):
    task = db.query(Task).filter(Task.id == task_id).first()

    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    
    if task.project.buyer_id != user.id:
        raise HTTPException(status_code=403, detail="Not your task")
    
    if task.status != "submitted":
        raise HTTPException(status_code=400, detail="Task not ready for payment")

    existing_payment = db.query(Payment).filter(Payment.task_id == task.id).first()
    if existing_payment:
        raise HTTPException(status_code=400, detail="Task already paid")
    
    amount = task.hourly_rate * task.hours_logged

    payment = Payment(
        task_id=task.id,
        buyer_id=user.id,
        amount=amount,
        status="completed"
    )

    db.add(payment)

    task.status = "paid"
    db.commit()
    db.refresh(task)

    return {
        "message": "Payment successful",
        "amount_paid": amount,
        "task_status": task.status
    }