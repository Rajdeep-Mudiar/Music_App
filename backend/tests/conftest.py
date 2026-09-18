import pytest_asyncio
import sys
import os

# Ensure backend root is in python path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from app.database import connect_to_mongo, close_mongo_connection

@pytest_asyncio.fixture(autouse=True)
async def setup_db():
    await connect_to_mongo()
    yield
    await close_mongo_connection()
