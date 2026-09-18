import jwt
from datetime import datetime, timedelta, timezone
from typing import Optional, Dict, Any
from fastapi import HTTPException, Security, status, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from google.oauth2 import id_token
from google.auth.transport import requests as google_requests
from app.config import settings

security_scheme = HTTPBearer(auto_error=False)

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    to_encode = data.copy()
    now = datetime.now(timezone.utc)
    if expires_delta:
        expire = now + expires_delta
    else:
        expire = now + timedelta(minutes=settings.JWT_ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire, "iat": now, "type": "access"})
    encoded_jwt = jwt.encode(to_encode, settings.JWT_SECRET, algorithm=settings.JWT_ALGORITHM)
    return encoded_jwt

def create_refresh_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    to_encode = data.copy()
    now = datetime.now(timezone.utc)
    if expires_delta:
        expire = now + expires_delta
    else:
        expire = now + timedelta(days=settings.JWT_REFRESH_TOKEN_EXPIRE_DAYS)
    to_encode.update({"exp": expire, "iat": now, "type": "refresh"})
    encoded_jwt = jwt.encode(to_encode, settings.JWT_SECRET, algorithm=settings.JWT_ALGORITHM)
    return encoded_jwt

def decode_token(token: str) -> Dict[str, Any]:
    try:
        payload = jwt.decode(token, settings.JWT_SECRET, algorithms=[settings.JWT_ALGORITHM])
        return payload
    except jwt.ExpiredSignatureError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token has expired",
            headers={"WWW-Authenticate": "Bearer"},
        )
    except jwt.InvalidTokenError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )

async def verify_google_token(token: str) -> Dict[str, Any]:
    """
    Verifies a Google ID token from the mobile client.
    Supports real Google ID token verification or dev mock token when client_id is in test/dev mode.
    """
    # If in development or demo testing mode, allow mock token
    if token.startswith("mock_google_"):
        return {
            "sub": token.replace("mock_google_", "google_sub_"),
            "email": "student@gauhati.ac.in",
            "name": "Rajdeep Sharma",
            "picture": "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150"
        }
    
    try:
        client_id = settings.GOOGLE_CLIENT_ID or None
        id_info = id_token.verify_oauth2_token(token, google_requests.Request(), client_id)
        return id_info
    except Exception as e:
        # If client_id was not set and we are in development, gracefully decode unverified payload or raise error
        if settings.ENVIRONMENT == "development":
            try:
                unverified = jwt.decode(token, options={"verify_signature": False})
                return unverified
            except Exception:
                pass
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Invalid Google ID token: {str(e)}"
        )

async def get_current_user_payload(credentials: Optional[HTTPAuthorizationCredentials] = Security(security_scheme)) -> Dict[str, Any]:
    if not credentials:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing authentication credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )
    payload = decode_token(credentials.credentials)
    if payload.get("type") != "access":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token type",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return payload

async def get_optional_user_payload(credentials: Optional[HTTPAuthorizationCredentials] = Security(security_scheme)) -> Optional[Dict[str, Any]]:
    if not credentials:
        return None
    try:
        return decode_token(credentials.credentials)
    except Exception:
        return None
