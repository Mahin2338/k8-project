from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import hashlib
import base64
import uuid
from datetime import datetime

app = FastAPI(
    title="DevOps Tools API",
    description="Simple utility API for demonstrations",
    version="1.0.0"
)

class TextInput(BaseModel):
    text: str

class URLInput(BaseModel):
    url: str

# In-memory storage
urls = {}

@app.get("/")
def home():
    return {
        "name": "DevOps Tools API",
        "version": "1.0.0",
        "endpoints": {
            "health": "GET /health",
            "hash_md5": "POST /hash/md5",
            "hash_sha256": "POST /hash/sha256",
            "encode_base64": "POST /encode/base64",
            "decode_base64": "POST /decode/base64",
            "shorten_url": "POST /shorten",
            "get_url": "GET /s/{code}",
            "stats": "GET /stats",
            "docs": "GET /docs"
        }
    }

@app.get("/health")
def health():
    return {
        "status": "healthy",
        "timestamp": datetime.now().isoformat()
    }

@app.post("/hash/md5")
def hash_md5(data: TextInput):
    result = hashlib.md5(data.text.encode()).hexdigest()
    return {"input": data.text, "md5": result}

@app.post("/hash/sha256")
def hash_sha256(data: TextInput):
    result = hashlib.sha256(data.text.encode()).hexdigest()
    return {"input": data.text, "sha256": result}

@app.post("/encode/base64")
def encode_base64(data: TextInput):
    result = base64.b64encode(data.text.encode()).decode()
    return {"input": data.text, "base64": result}

@app.post("/decode/base64")
def decode_base64(data: TextInput):
    try:
        result = base64.b64decode(data.text).decode()
        return {"input": data.text, "decoded": result}
    except Exception as e:
        raise HTTPException(400, f"Invalid base64: {str(e)}")

@app.post("/shorten")
def shorten_url(data: URLInput):
    code = str(uuid.uuid4())[:8]
    urls[code] = data.url
    return {
        "original": data.url,
        "code": code,
        "short_url": f"/s/{code}"
    }

@app.get("/s/{code}")
def get_url(code: str):
    if code not in urls:
        raise HTTPException(404, "URL not found")
    return {"code": code, "url": urls[code]}

@app.get("/stats")
def stats():
    return {
        "total_urls": len(urls),
        "total_endpoints": 9
    }

echo "testing CIcd"