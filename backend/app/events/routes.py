import uuid
from datetime import datetime, timezone
from typing import List, Optional
from fastapi import APIRouter, HTTPException, Depends, Query
from app.models.schemas import Event, EventCreate
from app.security import get_current_user_payload, get_optional_user_payload
from app.database import get_database

router = APIRouter(prefix="/api/events", tags=["Campus Events"])

STARTER_EVENTS = [
    {
        "id": "event_acoustics_1",
        "university": "Gauhati University",
        "name": "Acoustic Sunset by the Lake",
        "description": "Student singer-songwriters showcase their original indie and acoustic music.",
        "date": "Tomorrow, Oct 24",
        "time": "5:30 PM",
        "location": "Campus Amphitheatre",
        "organizer": "Resonance Music Club",
        "image": "https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=600",
        "attendees": ["student_1", "student_2", "student_3"]
    },
    {
        "id": "event_hack_beats_2",
        "university": "Gauhati University",
        "name": "Hackathon Synth & Beats Night",
        "description": "Live continuous DJ set paired with 24-hour campus hackathon sprint.",
        "date": "Saturday, Nov 02",
        "time": "8:00 PM",
        "location": "CSE Seminar Hall",
        "organizer": "Coding & Tech Society",
        "image": "https://images.unsplash.com/photo-1501386761578-eac5c94b800a?w=600",
        "attendees": ["student_4", "student_5"]
    },
    {
        "id": "event_open_mic_3",
        "university": "Gauhati University",
        "name": "Hostel Open Mic & Poetry",
        "description": "Cozy hostel rooftop music and spoken word open stage.",
        "date": "Friday, Nov 08",
        "time": "7:00 PM",
        "location": "Hostel 3 Common Room",
        "organizer": "Literary & Cultural Board",
        "image": "https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=600",
        "attendees": ["student_6"]
    }
]

@router.get("", response_model=List[Event])
async def get_events(university: Optional[str] = Query(None), user_payload: Optional[dict] = Depends(get_optional_user_payload)):
    db = get_database()
    current_uid = user_payload.get("sub") if user_payload else None
    
    query = {}
    if university:
        query["university"] = university
        
    cursor = db.events.find(query).sort("created_at", -1)
    docs = await cursor.to_list(length=30)
    
    if not docs:
        docs = STARTER_EVENTS

    events = []
    for d in docs:
        attendees = d.get("attendees", [])
        events.append(
            Event(
                id=d["id"],
                university=d.get("university", "Gauhati University"),
                name=d["name"],
                description=d["description"],
                date=d["date"],
                time=d["time"],
                location=d["location"],
                organizer=d["organizer"],
                image=d.get("image"),
                attendees=attendees,
                attendees_count=len(attendees),
                is_attending=current_uid in attendees if current_uid else False
            )
        )
    return events

@router.post("", response_model=Event)
async def create_event(req: EventCreate, payload: dict = Depends(get_current_user_payload)):
    db = get_database()
    user = await db.users.find_one({"user_id": payload["sub"]})
    university = user.get("university", "Gauhati University") if user else "Gauhati University"

    event_id = str(uuid.uuid4())
    doc = {
        "id": event_id,
        "university": university,
        "name": req.name,
        "description": req.description,
        "date": req.date,
        "time": req.time,
        "location": req.location,
        "organizer": req.organizer,
        "image": req.image or "https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=600",
        "attendees": [payload["sub"]],
        "created_at": datetime.now(timezone.utc)
    }
    await db.events.insert_one(doc)

    return Event(
        id=event_id,
        university=university,
        name=req.name,
        description=req.description,
        date=req.date,
        time=req.time,
        location=req.location,
        organizer=req.organizer,
        image=doc["image"],
        attendees=[payload["sub"]],
        attendees_count=1,
        is_attending=True
    )

@router.post("/{event_id}/rsvp")
async def rsvp_event(event_id: str, payload: dict = Depends(get_current_user_payload)):
    db = get_database()
    uid = payload["sub"]
    event = await db.events.find_one({"id": event_id})
    if not event:
        # Check in memory starter events
        for se in STARTER_EVENTS:
            if se["id"] == event_id:
                if uid in se["attendees"]:
                    se["attendees"].remove(uid)
                    return {"status": "unregistered", "attendees_count": len(se["attendees"])}
                else:
                    se["attendees"].append(uid)
                    return {"status": "registered", "attendees_count": len(se["attendees"])}
        raise HTTPException(status_code=404, detail="Event not found")

    attendees = event.get("attendees", [])
    if uid in attendees:
        attendees.remove(uid)
        status_msg = "unregistered"
    else:
        attendees.append(uid)
        status_msg = "registered"

    await db.events.update_one({"id": event_id}, {"$set": {"attendees": attendees}})
    return {"status": status_msg, "attendees_count": len(attendees)}
