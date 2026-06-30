\# Question 5 Clinical Data API (FastAPI)



\# Overview



This project implements a RESTful API using FastAPI to serve clinical trial adverse event (AE) data exported from the ADaM ADAE dataset.



The API enables:

\- Dynamic cohort filtering using JSON request bodies

\- Subject-level safety risk scoring based on AE severity

\- RESTful access to clinical safety data

\- Interactive testing via Swagger UI

\- Temporary public deployment using ngrok



\---



\# Packages Used



fastapi        : Web API framework

uvicorn        : ASGI server for running the application

pandas         : Data manipulation and filtering

pydantic       : Request body validation

typing         : Optional type annotations



\---



\# Input Data



data/adae.csv

Exported from pharmaverseadam::adae in R.



Key variables:

\- USUBJID   : Unique subject identifier

\- AESEV     : Adverse event severity (MILD, MODERATE, SEVERE)

\- ACTARM    : Treatment arm assignment



\---



\# API Endpoints



\## 1. GET /



\### Purpose

Health check endpoint confirming API status.



\### Response

{

&#x20; "message": "Clinical Trial Data API is running"

}



\---



\## 2. POST /ae-query



\### Purpose

Filters AE records dynamically based on severity and/or treatment arm.



\### Request Body (JSON)



{

&#x20; "severity": \["MILD", "MODERATE"],

&#x20; "treatment\_arm": "Placebo"

}



\### Logic

\- Filters by AESEV if provided

\- Filters by ACTARM if provided

\- Ignores missing fields automatically



\### Response



{

&#x20; "count": 25,

&#x20; "subjects": \["01-701-1015", "01-701-1020"]

}



\---



\## 3. GET /subject-risk/{subject\_id}



\### Purpose

Calculates a safety risk score for an individual subject.



\### Scoring System

\- MILD      = 1 point

\- MODERATE  = 3 points

\- SEVERE    = 5 points



\### Risk Categories

\- Low    : score < 5

\- Medium : 5 <= score < 15

\- High   : score >= 15



\### Response



{

&#x20; "subject\_id": "01-701-1015",

&#x20; "risk\_score": 8,

&#x20; "risk\_category": "Medium"

}



\### Error Handling

\- Returns 404 if subject\_id is not found in dataset



\---



\# How to Run Locally



\## Step 1: Install dependencies



pip install -r requirements.txt



\---



\## Step 2: Start the API server



uvicorn main:app --reload



\---



\## Step 3: Open API in browser



http://127.0.0.1:8000/docs

\---



\# Public Access (Temporary Deployment)



The API was exposed using ngrok:



https://empathy-expedited-library.ngrok-free.dev/docs



\---



\# Project Structure



question\_5\_api/

│── main.py

│── requirements.txt

│── data/

│     └── adae.csv

│── .gitignore



\---



\# Notes



\- Built using FastAPI with automatic OpenAPI documentation

\- Implements cohort filtering and subject-level risk scoring

\- Designed for clinical safety data exploration

\- Demonstrates REST API design principles for healthcare datasets

\- Data is read from a local CSV file stored in /data directory

