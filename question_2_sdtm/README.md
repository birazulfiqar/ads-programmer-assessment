#  Question 2 SDTM DS Domain Creation

# Overview

This script creates the SDTM Disposition (DS) domain from raw clinical trial data
using pharmaverseraw and SDTM utilities from sdtm.oak and pharmaversesdtm.

The workflow follows SDTM IG principles including:
- Controlled terminology mapping
- Visit and date derivations
- Subject identifier creation
- Study day and sequence derivations

# Packages Used

sdtm.oak            : ID generation and CT mapping utilities
pharmaverseraw      : Raw input datasets
pharmaversesdtm     : Reference DM dataset and study day derivations
dplyr               : Data manipulation
haven               : XPT export
labelled            : Variable labels
here                : Reproducible file paths

# Input Data
ds_raw0   : Raw disposition dataset
dm        : Demographics dataset
study_ct  : Controlled terminology reference file


# Data Preparation

Create ID variables using PATNUM and raw source tracking using generate_oak_id_vars()
Controlled terminology preparation:
DSDECOD_RAW, VISIT_RAW derived by standardising raw values
and filtering against study_ct to reduce CT warnings


# Controlled Terminology Mapping

assign_ct() used for:
- DSDECOD (disposition terms)
- VISIT (visit labels)
- VISITNUM (visit numbering)

Only values present in study_ct are retained


# Date and Time Derivations

DSSTDTC derived from IT.DSSTDAT using m-d-y format
DSDTC derived from DSDTCOL and DSTMCOL using m-d-y and H:M formats


# SDTM Variable Derivations

DSTERM
- Sponsor reported disposition term or OTHERSP override

DSDECOD
- Controlled terminology mapped disposition term

DSCAT
- "PROTOCOL MILESTONE" when DSDECOD = RANDOMIZED
- "DISPOSITION EVENT" otherwise

VISIT and VISITNUM
- Derived from INSTANCE or CT mapping when available


# Identifiers

STUDYID  : Taken from raw dataset
USUBJID  : Constructed using STUDYID and PATNUM


# Study Day Derivations

DSSTDY : Study day relative to DSSTDTC and RFSTDTC
DSDY   : Study day relative to DSDTC and RFSTDTC


# Sequence Number

DSSEQ generated using:
STUDYID + USUBJID + DSTERM + DSDECOD + DSSTDTC


# Output

Final SDTM DS dataset exported as:
question_2_sdtm/output/ds.xpt using haven::write_xpt()

Contains:
STUDYID, DOMAIN, USUBJID, DSSEQ,
DSTERM, DSDECOD, DSCAT,
VISIT, VISITNUM,
DSDTC, DSSTDTC,
DSDY, DSSTDY




# Notes

- Controlled terminology filtered to study-specific values
- VISITNUM derived from INSTANCE when not directly available
- USUBJID constructed for assignment purposes
- Date parsing assumes consistent m-d-y format
- File paths are managed using the `here` package to ensure 
  reproducibility and portability across different environments.