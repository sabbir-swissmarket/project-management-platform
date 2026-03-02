def validate_status_transition(current: str, new: str):
    allowed = {
        "todo": ["in_progress"],
        "in_progress": ["submitted"],
        "submitted": ["paid"],
        "paid": []
    }

    if current not in allowed:
        raise ValueError("Invalid current status")

    if new not in allowed[current]:
        raise ValueError(f"Cannot move from {current} to {new}")