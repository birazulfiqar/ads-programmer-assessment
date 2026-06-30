# ADS Programmer Assessment

# Overview

This repository contains solutions to the DSX Data Scientist Coding Assessment covering:
- R package development
- SDTM/ADaM clinical data programming using Pharmaverse tools
- Clinical reporting (TLGs)
- Python API development (FastAPI)
- Generative AI clinical data assistant (LangChain-style agent)

The work demonstrates proficiency in clinical data standards (CDISC), reproducible R workflows, and applied Python for healthcare analytics.

---

# Repository Structure

Each question is implemented in its own folder:

question_1                       : R package development (descriptive statistics functions)
question_2_sdtm                  : SDTM DS domain creation using sdtm.oak
question_3_adam                  : ADaM ADSL dataset creation using admiral
question_4_tlg_                  : AE TLG reporting using gtsummary and ggplot2
question_5_api/                  : Clinical Data API (FastAPI)
question_6_genai                 : GenAI Clinical Data Assistant (LLM + Pandas agent)

Each folder contains:
- Source code scripts
- Supporting utilities (if applicable)
- Output files (tables/plots where required)
- A local README describing implementation details

---

# Assessment Scope

The project evaluates the following competencies:

- R Package Development (structure, documentation, testing)
- CDISC SDTM & ADaM programming using Pharmaverse ecosystem
- Clinical reporting (Tables, Listings, Graphs)
- Python backend development (FastAPI)
- LLM-based reasoning over structured clinical datasets
- Clean, reproducible, production-style code

---

# Tools & Technologies Used

## R Ecosystem
- sdtm.oak
- admiral
- pharmaversesdtm
- pharmaverseraw
- pharmaverseadam
- here
- labelled
- lubridate
- haven
- gtsummary
- ggplot2
- dplyr, tidyr
- gt
- scales

## Python Ecosystem
- FastAPI
- pandas
- uvicorn
- pydantic
- typing

## AI / LLM
- OpenAI-compatible LLM interface (or mocked fallback)
- LangChain-style structured prompting
- JSON-based structured output parsing

---

# How to Run

## R Projects

For any R-based question:

install above packages

Then run scripts inside each folder, e.g.:

source("question_3_adam/create_adsl.R")

For packages (Question 1):

devtools::install("question_1/descriptiveStats")
library(descriptiveStats)

---

## Python API (Question 5)

Navigate to:

question_5_api/

Install dependencies:

pip install fastapi uvicorn pandas pydantic

Run server:

uvicorn main:app --reload

---

## GenAI Agent (Question 6)

Navigate to:

question_6_genai

Install dependencies:

pip install fastapi uvicorn requests pydantic

Run:

python test_agent.py

This will execute sample queries demonstrating:
- Column mapping via LLM/logic layer
- Filtering logic over AE dataset
- Subject-level aggregation outputs

---

# Example Output Behavior

## GenAI Agent

Example queries tested:
- Severity-based filtering (AESEV)
- Symptom-based filtering (AETERM)
- System organ class filtering (AESOC)

Output format:

{
  "target_column": "...",
  "filter_value": "...",
  "count": ...,
  "subjects": [...]
}

---

# Data Standards Followed

All clinical data work follows CDISC principles:

- SDTM (Study Data Tabulation Model)
- ADaM (Analysis Data Model)
- Controlled terminology mapping
- Traceable derivations
- Reproducible transformations

---

# Testing & Validation

Each component has been validated as follows:

- R scripts execute without runtime errors
- SDTM/ADaM derivations match specification logic
- FastAPI endpoints return expected JSON structures
- GenAI agent correctly maps natural language to dataset columns
- Test scripts included for all Python components

---

# Notes

- AI tools were used to assist development but all logic is implemented and validated manually.
- All code is structured to be reproducible and runnable from scratch.
- Folder separation ensures modular review per question.
- Outputs are deterministic given the same input datasets.

---

# Submission

- GitHub repository link
- Screen-recorded walkthrough (2 minutes)
- All code + outputs included per question folder

---