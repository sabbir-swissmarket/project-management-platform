from sqlalchemy import Column, String, ForeignKey, Float, DateTime
from sqlalchemy.orm import relationship
from app.core.database import Base
import uuid
from datetime import datetime

class Task(Base):
    __tablename__ = "tasks"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    project_id = Column(String, ForeignKey("projects.id"), nullable=False)

    title = Column(String, nullable=False)
    description = Column(String)

    assigned_developer_id = Column(String, ForeignKey("users.id"))
    hourly_rate = Column(Float, nullable=False)

    status = Column(String, default="todo")  # todo, in_progress, submitted, paid
    hours_logged = Column(Float, default=0)

    created_at = Column(DateTime, default=datetime.utcnow)

    project = relationship("Project")
    developer = relationship("User")

    solution_file_path = Column(String, nullable=True)