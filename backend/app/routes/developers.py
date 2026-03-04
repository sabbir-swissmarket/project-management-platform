from typing import List

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import SessionLocal
from app.core.dependencies import require_role
from app.models.user import User
from app.schemas.user import UserSummary

router = APIRouter(prefix="/developers", tags=["Developers"], redirect_slashes=False)


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@router.get("", response_model=List[UserSummary])
def list_developers(
    db: Session = Depends(get_db),
    user=Depends(require_role("buyer")),
):
    developers = (
        db.query(User)
            .filter(User.role == "developer")
            .order_by(User.name)
            .all()
    )
    return [
        UserSummary(id=dev.id, name=dev.name, email=dev.email)
        for dev in developers
    ]
