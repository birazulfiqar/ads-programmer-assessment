# Imports
from fastapi import FastAPI
from fastapi import HTTPException
from pydantic import BaseModel
from typing import Optional
import pandas as pd

# Create app
app = FastAPI()

# Read data
adae = pd.read_csv("data/adae.csv")


# JSON request model
class AEQuery(BaseModel):
    severity: Optional[list[str]] = None
    treatment_arm: Optional[str] = None

# Endpoint 1
@app.get("/")
def home():
    return {
        "message": "Clinical Trial Data API is running"
    }

# Endpoint 2
@app.post("/ae-query")
def ae_query(query: AEQuery):

    df = adae.copy()

    if query.severity:
        df = df[df["AESEV"].isin(query.severity)]

    if query.treatment_arm:
        df = df[df["ACTARM"] == query.treatment_arm]

    return {
        "count": len(df),
        "subjects": sorted(df["USUBJID"].unique().tolist())
    }

# Endpoint 3
@app.get("/subject-risk/{subject_id}")
def subject_risk(subject_id: str):
    
    df = adae.copy()
    df = df[df["USUBJID"].astype(str) == str(subject_id)]

    if df.empty:
        raise HTTPException(status_code=404, detail="Subject not found")

    severity_map = {
        "MILD": 1,
        "MODERATE": 3,
        "SEVERE": 5
    }

    df["score"] = df["AESEV"].map(severity_map)

    risk_score = df["score"].sum()

    if risk_score < 5:
        risk_category = "Low"
    elif risk_score < 15:
        risk_category = "Medium"
    else:
        risk_category = "High"

    return {
        "subject_id": subject_id,
        "risk_score": int(risk_score),
        "risk_category": risk_category
    }