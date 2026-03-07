import os
import sys

# make sure the `app` package is importable when running this script
# running from backend/ or anywhere as long as we add the package root
script_dir = os.path.dirname(os.path.abspath(__file__))
# backend/app/scripts -> want backend on sys.path so that "import app..." works
project_root = os.path.abspath(os.path.join(script_dir, '..', '..'))
if project_root not in sys.path:
    sys.path.insert(0, project_root)

from app.core.database import SessionLocal
from app.models.user import User
import bcrypt
from typing import Optional

# direct bcrypt hashing avoids passlib backend/version issues
# and allows explicit truncation to 72 bytes, which bcrypt requires

def hash_password(password: str) -> str:
    if isinstance(password, str):
        password = password.encode('utf-8')
    # bcrypt hashes only the first 72 bytes of the password; older
    # passlib versions flagged this as an error. truncate here to be safe.
    if len(password) > 72:
        password = password[:72]
    hashed = bcrypt.hashpw(password, bcrypt.gensalt())
    # store as utf-8 string for convenience
    return hashed.decode('utf-8')

db = SessionLocal()

def create_user(email: str, password: str, role: str, name: Optional[str] = None):
    existing = db.query(User).filter(User.email == email).first()

    # derive a default name from the email if not supplied
    if not name:
        name = email.split("@")[0]

    if existing:
        # update missing name if necessary and return
        if not existing.name:
            existing.name = name
            db.commit()
            print(f"{email} existed but name was empty; set to '{name}'")
        else:
            print(f"{email} already exists")
        return

    user = User(
        email=email,
        name=name,
        password_hash=hash_password(password),
        role=role
    )

    db.add(user)
    db.commit()

    print(f"{email} created successfully")

create_user(
    email="admin@test.com",
    password="123456",
    role="admin",
    name="Administrator"
)

create_user(
    email="buyer@test.com",
    password="123456",
    role="buyer",
    name="Buyer"
)

create_user(
    email="dev@test.com",
    password="123456",
    role="developer",
    name="Developer"
)