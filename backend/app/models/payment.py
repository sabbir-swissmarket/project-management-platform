from sqlalchemy import Column, String, Float, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from app.core.database import Base
import uuid
from datetime import datetime

class Payment(Base):
    __tablename__ = "payments"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    task_id = Column(String, ForeignKey("tasks.id"), nullable=False)
    buyer_id = Column(String, ForeignKey("users.id"), nullable=False)

    amount = Column(Float, nullable=False)
    status = Column(String, default="completed")

    paid_at = Column(DateTime, default=datetime.utcnow)

    task = relationship("Task")
    buyer = relationship("User")