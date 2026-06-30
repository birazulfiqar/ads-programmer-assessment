# Question 3 ADaM ADSL Dataset Creation

# Overview

This script creates the ADaM ADSL (Subject-Level Analysis Dataset) using SDTM datasets
from pharmaversesdtm and derivation functions from the admiral framework.

The workflow follows ADaM principles including:
- Subject-level dataset creation from DM as the base structure
- Treatment derivation from EX
- Safety flag derivations from VS, AE, and DS
- Time-to-event derivation for last known alive date
- Controlled, traceable derivations using admiral functions where applicable


# Packages Used

admiral           : ADaM derivation framework
dplyr             : Data manipulation
pharmaversesdtm   : SDTM input datasets (DM, EX, VS, AE, DS)
lubridate         : Date parsing utilities
stringr           : String handling functions
haven             : XPT export
labelled          : Variable labeling
here              : Reproducible file paths


# Input Data

dm  : Demographics dataset (base for ADSL)
ex  : Exposure dataset (treatment derivation)
vs  : Vital signs dataset (safety flag + LSTALVDT)
ae  : Adverse events dataset (safety flags + LSTALVDT)
ds  : Disposition dataset (LSTALVDT derivation)


# ADaM Base Structure

ADSL is created starting from DM:
- One record per subject
- Subject identifiers retained from DM
- Treatment arm variables (TRT01P, TRT01A) derived from DM.ARM variables


# Demographics Derivations

AGEGR9 / AGEGR9N
Age grouped into:
- "<18"
- "18 - 50"
- ">50"

Numeric mapping:
- 1 = <18
- 2 = 18–50
- 3 = >50


# Treatment Derivations (EX)

EX dataset is converted to datetime format using derive_vars_dtm():

- EXSTDTC → EXSTDTM (treatment start)
- EXENDTC → EXENDTM (treatment end)

Time imputation rules:
- Start time: imputed to earliest possible time (00:00:00)
- End time: imputed to latest possible time (23:59:59)

Valid exposure records are defined as:
- EXDOSE > 0 OR
- EXDOSE = 0 AND EXTRT contains "PLACEBO"


TRTSDTM / TRTSTMF
- First valid exposure record per subject
- Ordered by EXSTDTM and EXSEQ (tie-breaker)

TRTEDTM / TRTETMF
- Last valid exposure record per subject
- Ordered by EXENDTM and EXSEQ


TRTSDT / TRTEDT
- Date-only versions derived from TRTSDTM / TRTEDTM


# Population Flag

ITTFL
- Set to "Y" if ARM is populated
- Otherwise set to "N"


# Safety Flags

ABNSBPFL (Abnormal Systolic Blood Pressure)
- Based on VS where:
  - VSTESTCD = "SYSBP"
  - VSSTRESU = "mmHg"
  - VSSTRESN < 100 or >= 140

CARPOPFL (Cardiac AE Flag)
- Set to "Y" if AE.AESOC = "CARDIAC DISORDERS"
- Otherwise missing


# Last Known Alive Date (LSTALVDT)

Derived using derive_vars_extreme_event():

Candidate sources:
- VS: last valid vital signs record
- AE: last adverse event onset date
- DS: last disposition date
- EX: last valid treatment administration date

Definition:
LSTALVDT is the maximum date across all valid clinical sources
for each subject, representing last known alive contact


# Identifiers

STUDYID : Taken from DM
USUBJID : Subject identifier from DM
SUBJID  : Subject number
SITEID  : Site identifier


# Sequence and Ordering Logic

- TRTSDTM/TRTEDTM are derived using ordering by datetime + EXSEQ
- EXSEQ is required as a tie-breaker when multiple exposure records
  have identical datetime values


# Output Dataset

Final ADSL dataset exported as:

question_3_adam/output/adsl.xpt

Contains:

STUDYID, USUBJID, SUBJID, SITEID,
AGE, AGEU, AGEGR9, AGEGR9N,
SEX, RACE, ETHNIC, COUNTRY,
ARMCD, ARM, ACTARMCD, ACTARM,
TRT01P, TRT01A,
TRTSDTM, TRTSTMF, TRTSDT,
TRTEDTM, TRTETMF, TRTEDT,
ITTFL, ABNSBPFL, CARPOPFL,
LSTALVDT


In addition, the reference ADaM adverse events dataset
(pharmaverseadam::adae) is exported as:

question_3_adam/output/adae.csv

This CSV file is provided as the input dataset for
Question 5 (Clinical Data API).


# Notes

- ADMIRAL functions used for all time derivations and event-based logic
- EXSEQ is essential for deterministic ordering of exposure records
- grepl is used for placebo identification to ensure case-insensitive matching
- Only variables required for the assessment plus essential ADSL identifiers are included
- Missing times in EXSTDTC/EXENDTC are imputed according to ADaM rules
- The reference ADAE dataset from the pharmaverseadam package is also
  exported as a CSV to support the FastAPI implementation in Question 5.
- File paths are managed using the `here` package to ensure 
  reproducibility and portability across different environments.