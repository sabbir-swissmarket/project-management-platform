import os
from datetime import datetime, timedelta
from jose import JWTError, jwt
import bcrypt
#from passlib.context import CryptContext
from dotenv import load_dotenv

load_dotenv()

SECRET_KEY = os.getenv("SECRET_KEY")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60

# keep a placeholder in case other schemes are added later
#pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    if isinstance(password, str):
        password = password.encode("utf-8")
    # bcrypt only considers first 72 bytes
    if len(password) > 72:
        password = password[:72]
    hashed = bcrypt.hashpw(password, bcrypt.gensalt())
    return hashed.decode("utf-8")

def verify_password(plain_password, hashed_password) -> bool:
    if isinstance(plain_password, str):
        plain_password = plain_password.encode("utf-8")
    if len(plain_password) > 72:
        plain_password = plain_password[:72]
    # bcrypt library expects bytes for both arguments
    if isinstance(hashed_password, str):
        hashed_password = hashed_password.encode("utf-8")
    try:
        return bcrypt.checkpw(plain_password, hashed_password)
    except ValueError:
        # if the stored hash is invalid for some reason
        return False

def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

def decode_token(token: str):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except JWTError:
        return None
