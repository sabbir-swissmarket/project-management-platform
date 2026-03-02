from pydantic import BaseModel

class TaskCreate(BaseModel):
    title: str
    description: str
    hourly_rate: float
    assigned_developer_id: str