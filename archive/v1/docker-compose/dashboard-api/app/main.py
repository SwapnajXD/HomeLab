from pathlib import Path
import json
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="Olympus API", version="4.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

DATA_DIR = Path("/data")


def safe_load(name: str, fallback: dict):
    try:
        with open(DATA_DIR / f"{name}.json", "r") as f:
            return json.load(f)
    except Exception:
        return fallback


@app.get("/pokemon")
def pokemon():
    return safe_load(
        "pokemon",
        {
            "id": 0,
            "name": "unknown",
            "sprite": "",
            "type1": "normal",
            "type2": ""
        }
    )


@app.get("/lastfm")
def lastfm():
    return safe_load(
        "lastfm",
        {
            "track": "N/A",
            "artist": "N/A",
            "album": "N/A",
            "cover": ""
        }
    )


@app.get("/library")
def library():
    return safe_load(
        "library",
        {
            "title": "N/A",
            "progress": "N/A"
        }
    )


@app.get("/prices")
def prices():
    return safe_load(
        "prices",
        {
            "goldbees": {
                "name": "GoldBeES",
                "price": 0
            }
        }
    )


@app.get("/weather")
def weather():
    return safe_load(
        "weather",
        {
            "city": "Unknown",
            "temperature": "--",
            "description": "Unknown"
        }
    )


@app.get("/mal")
def mal():
    return safe_load(
        "anime",
        {
            "username": "StarLordXD",
            "watching": 0,
            "completed": 0,
            "score": 0
        }
    )


@app.get("/media")
def media():
    return safe_load(
        "media",
        {
            "mode": "wallpaper",
            "title": "Olympus",
            "subtitle": "Command Center",
            "url": ""
        }
    )

@app.get("/homelab")
def homelab():
    return safe_load(
        "homelab",
        {
            "cpu": 0,
            "ram": 0,
            "uptime": "-",
            "containers": 0,
            "pods": 0,
            "nodes": {
                "athena": "offline",
                "apollo": "offline",
                "hestia": "offline"
            }
        }
    )

@app.get("/olympus")
def olympus():
    return {
        "pokemon": pokemon(),
        "lastfm": lastfm(),
        "library": library(),
        "prices": prices(),
        "weather": weather(),
        "mal": mal(),
        "media": media(),
        "homelab": safe_load("homelab", {})
    }
