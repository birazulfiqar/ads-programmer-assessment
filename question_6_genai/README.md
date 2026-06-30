\# Question 6: GenAI Clinical Data Assistant (LLM-style Agent)



\# Overview



This project implements a lightweight GenAI-style Clinical Data Assistant using FastAPI. It translates natural language clinical safety questions into structured queries over the AE dataset (`adae.csv` from `pharmaversesdtm::ae`). The system simulates an LLM using a rule-based mapping layer that converts user intent into dataset column filters and executes pandas-based analysis.



The workflow follows a simple AI pipeline:

\- User natural language question

\- Intent parsing (mock LLM)

\- Mapping to clinical variables (AESEV, AETERM, AESOC)

\- Pandas filtering

\- JSON response generation



\# Objective



To enable dynamic querying of adverse event data using natural language without requiring users to know dataset column names.



Example mappings:

\- Severity/intensity → AESEV

\- Specific condition (e.g. headache) → AETERM

\- Body system (e.g. cardiac, skin) → AESOC



\# Packages Used



fastapi           : API framework for building endpoints  

uvicorn           : ASGI server to run FastAPI application  

pandas            : Data loading and filtering  

pydantic          : Request body validation  

requests          : API testing via test script  



\# Input Data



adae.csv : Adverse events dataset exported from pharmaverseadam::adae



\# API Structure



\## GET /



Returns API health status.



Response:

{

&#x20; "message": "Clinical Trial Data API is running"

}



\## POST /ae-agent



Accepts a natural language question and returns filtered AE results.



Request Body:

{

&#x20; "question": "Show me moderate severity adverse events"

}



Response:

{

&#x20; "target\_column": "AESEV",

&#x20; "filter\_value": "MODERATE",

&#x20; "count": 136,

&#x20; "subjects": \["01-701-..."]

}



\# LLM Logic (Mock Implementation)



A simple rule-based function simulates LLM behaviour:



\- Keywords in question are mapped to:

&#x20; - AESEV → severity-related terms

&#x20; - AETERM → specific AE terms (e.g. headache)

&#x20; - AESOC → system organ class (e.g. cardiac, skin)



This produces a structured JSON object:

{

&#x20; "target\_column": "...",

&#x20; "filter\_value": "..."

}



which is then used for pandas filtering.



\# Execution Logic



1\. Receive user question via API

2\. Convert question into structured JSON (mock LLM)

3\. Apply pandas filter on AE dataset

4\. Extract matching records

5\. Return:

&#x20;  - count of unique subjects (USUBJID)

&#x20;  - list of matching subject IDs



\# How to Run



Install dependencies:

pip install -r requirements.txt



Start API server:

uvicorn clinical\_agent:app --reload



Run test script (new terminal):

python test\_agent.py



Open API documentation:

http://127.0.0.1:8000/docs



\# Example Test Queries



\- Show moderate severity adverse events

\- Find subjects with headache

\- Give me cardiac related events

\- Show mild adverse events

\- Skin disorders cases



\# Notes



\- This implementation simulates LLM behaviour using deterministic rule-based mapping.

\- Designed to demonstrate NLP-to-structured-query translation for clinical AE analysis.

\- Follows a clean separation of concerns: intent parsing → filtering → response generation.

\- All outputs are reproducible and based on pandas filtering logic over adae.csv.

