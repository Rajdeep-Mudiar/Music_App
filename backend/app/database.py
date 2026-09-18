import logging
from motor.motor_asyncio import AsyncIOMotorClient, AsyncIOMotorDatabase
from app.config import settings

logger = logging.getLogger("resonance.database")

class Database:
    client: AsyncIOMotorClient = None
    db: AsyncIOMotorDatabase = None

db_instance = Database()

async def connect_to_mongo():
    logger.info(f"Connecting to MongoDB at {settings.MONGO_URI}...")
    db_instance.client = AsyncIOMotorClient(settings.MONGO_URI)
    db_instance.db = db_instance.client[settings.MONGO_DB_NAME]
    
    # Initialize indexes
    try:
        # Users indexes
        await db_instance.db.users.create_index("email", unique=True)
        await db_instance.db.users.create_index("google_id", sparse=True)
        await db_instance.db.users.create_index("university")
        
        # Playlists indexes
        await db_instance.db.playlists.create_index("creator_id")
        await db_instance.db.playlists.create_index("university")
        await db_instance.db.playlists.create_index("type")
        
        # Songs cache indexes
        await db_instance.db.songs_cache.create_index("track_id", unique=True)
        await db_instance.db.songs_cache.create_index("genre")
        
        # Study sessions indexes
        await db_instance.db.study_sessions.create_index("user_id")
        await db_instance.db.study_sessions.create_index("created_at")
        
        # Posts & Comments indexes
        await db_instance.db.posts.create_index("university")
        await db_instance.db.posts.create_index("community_id")
        await db_instance.db.posts.create_index("created_at")
        
        # Events
        await db_instance.db.events.create_index("university")
        await db_instance.db.events.create_index("date")
        
        logger.info("MongoDB connection and indexes initialized successfully.")
    except Exception as e:
        logger.warning(f"Indexes initialization note: {e}")

async def close_mongo_connection():
    if db_instance.client:
        logger.info("Closing MongoDB connection...")
        db_instance.client.close()
        logger.info("MongoDB connection closed.")

def get_database() -> AsyncIOMotorDatabase:
    return db_instance.db
