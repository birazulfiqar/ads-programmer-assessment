# Imports
from fastapi import FastAPI
from pydantic import BaseModel
from typing import Optional
import pandas as pd

# Create app
app = FastAPI()


# Load data
ae = pd.read_csv("data/adae.csv")


# Schema definition (LLM context)
schema = {
    "AESEV": "Severity of adverse event (MILD, MODERATE, SEVERE)",
    "AETERM": "Adverse event preferred term (e.g. Headache)",
    "AESOC": "System organ class (e.g. CARDIAC DISORDERS, SKIN DISORDERS)"
}


# Request model
class Question(BaseModel):
    question: str


# Mock LLM (replaceable with OpenAI later)
def mock_llm(question: str):

    q = question.lower()

    if "severity" in q or "moderate" in q or "mild" in q or "severe" in q:
        return {"target_column": "AESEV", "filter_value": "MODERATE"}

    if "headache" in q:
        return {"target_column": "AETERM", "filter_value": "HEADACHE"}

    if "cardiac" in q:
        return {"target_column": "AESOC", "filter_value": "CARDIAC DISORDERS"}

    if "skin" in q:
        return {"target_column": "AESOC", "filter_value": "SKIN DISORDERS"}

    return {"target_column": "AESEV", "filter_value": "MILD"}


# Root endpoint
@app.get("/")
def home():
    return {
        "message": "GenAI Clinical Data Assistant is running"
    }


# Main AI endpoint
@app.post("/ae-agent")
def ae_agent(payload: Question):

    # Step 1: LLM interprets question
    parsed = mock_llm(payload.question)

    col = parsed["target_column"]
    value = parsed["filter_value"]

    # Step 2: Apply pandas filter
    df = ae.copy()
    filtered = df[df[col].astype(str).str.upper() == value.upper()]

    # Step 3: Output result
    return {
        "target_column": col,
        "filter_value": value,
        "count": filtered["USUBJID"].nunique(),
        "subjects": filtered["USUBJID"].unique().tolist()
    }