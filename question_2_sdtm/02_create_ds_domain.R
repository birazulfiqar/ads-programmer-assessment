# =========================================================
# Question 2 - Start of SDTM DS Domain Creation
# =========================================================
# Programmer: Bira Aziz Khan
# Date: 01-07-2026
# Project: ADS Programmer Assessment
# Domain: DS (Disposition)
# Purpose: Derive SDTM DS domain from raw clinical trial data
# =========================================================

# -----------------------------
# Load packages
# -----------------------------
library(sdtm.oak)
library(pharmaverseraw)
library(pharmaversesdtm)
library(dplyr)
library(haven)
library(labelled)

# -----------------------------
# Read Study controlled terminology
# -----------------------------
study_ct <- read.csv("metadata/sdtm_ct.csv", stringsAsFactors = FALSE)

# -----------------------------
# Input data
# -----------------------------
ds_raw0 <- pharmaverseraw::ds_raw 
dm <- pharmaversesdtm::dm

# -----------------------------
# SDTM DS derivation
# -----------------------------
# Create ID Vars using sdtm.oak and prepare CT variables to only include terms that are collected in study_ct 
# this avoids any additional log notes for terms that are not present in CT
ds_raw1 <- ds_raw0 |>
  generate_oak_id_vars(
    pat_var = "PATNUM",
    raw_src = "ds_raw0"
  )|>
  mutate(
    DSDECOD_RAW = if_else(
      gsub('Completed','Complete',IT.DSDECOD) %in% study_ct$collected_value,
      gsub('Completed','Complete',IT.DSDECOD),
      NA_character_),
    
    VISIT_RAW = if_else(
      gsub('Ecg','ECG',INSTANCE) %in% study_ct$collected_value,
      gsub('Ecg','ECG',INSTANCE),
      NA_character_),
  )

# Map CT values for DSDECOD and VISIT variables
ds0 <- 
  # Map DSDECOD using assign_ct
  assign_ct(
    raw_dat = ds_raw1,
    raw_var = "DSDECOD_RAW",
    tgt_var = "DSDECOD",
    ct_spec = study_ct,
    ct_clst = "C66727",
    id_vars = oak_id_vars()
  )  |>
  # Map VISIT using assign_ct
  assign_ct(
    raw_dat = ds_raw1,
    raw_var = "VISIT_RAW",
    tgt_var = "VISIT",
    ct_spec = study_ct,
    ct_clst = "VISIT",
    id_vars = oak_id_vars()
  ) |>
  # Map VISITNUM using assign_ct
  assign_ct(
    raw_dat = ds_raw1,
    raw_var = "VISIT_RAW",
    tgt_var = "VISITNUM",
    ct_spec = study_ct,
    ct_clst = "VISITNUM",
    id_vars = oak_id_vars()
  ) 

# Map date variables
ds0 <- ds0 |>
  # Map DSSTDTC using assign_datetime
  assign_datetime(
    raw_dat = ds_raw1,
    raw_var = "IT.DSSTDAT",
    tgt_var = "DSSTDTC",
    raw_fmt = c("m-d-y"),
    id_vars = oak_id_vars()
  ) |>
  # Map DSDTC using assign_datetime, raw_var=IT.AESTDAT
  assign_datetime(
    raw_dat = ds_raw1,
    raw_var = c("DSDTCOL", "DSTMCOL"),
    tgt_var = "DSDTC",
    raw_fmt = c("m-d-y", "H:M"),
    id_vars = oak_id_vars()
  )


# Combine all variables
ds1 <- ds_raw1 |>
  left_join(ds0, by = c("oak_id", "raw_source", "patient_number")) |>
  mutate(
    DOMAIN = "DS",
    STUDYID = STUDY,
    USUBJID = paste0("01-", PATNUM),
    
    DSTERM=if_else(!is.na(OTHERSP) & OTHERSP != "", OTHERSP, IT.DSTERM),
    
    DSDECOD = case_when(
      !is.na(OTHERSP) & OTHERSP != "" ~ toupper(OTHERSP),
      is.na(DSDECOD) ~ toupper(IT.DSDECOD),
      TRUE ~ DSDECOD),
    
    DSCAT = if_else(DSDECOD == "RANDOMIZED", "PROTOCOL MILESTONE", "DISPOSITION EVENT"),
    
    VISIT=if_else(!is.na(VISIT), VISIT, toupper(INSTANCE)),
    CHAR_VISITNUM=if_else(!is.na(VISITNUM), VISITNUM, sub(".*?(\\d+(\\.\\d+)?).*", "\\1", INSTANCE)),
    VISITNUM= as.numeric(CHAR_VISITNUM)
   ) |>
  # Derive DSSTDY
  derive_study_day(
    dm_domain = dm,
    tgdt = "DSSTDTC",
    refdt = "RFSTDTC",
    study_day_var = "DSSTDY"
  ) |>
  # Derive DSDY
  derive_study_day(
  dm_domain = dm,
    tgdt = "DSDTC",
    refdt = "RFSTDTC",
    study_day_var = "DSDY"
  ) |>
  # Derive seq var
  derive_seq(
    tgt_var = "DSSEQ",
    rec_vars = c("STUDYID", "USUBJID", "DSTERM", "DSDECOD", "DSSTDTC")
  )

# -----------------------------
# Optional: Adding Var Labels 
# -----------------------------
ds1 <- labelled::set_variable_labels(
  ds1,
  STUDYID = "Study Identifier",
  DOMAIN  = "Domain Abbreviation",
  USUBJID = "Unique Subject Identifier",
  DSSEQ   = "Sequence Number",
  DSTERM  = "Reported Term for the Disposition Event",
  DSDECOD = "Standardized Disposition Term",
  DSCAT   = "Category for Disposition Event",
  VISIT   = "Visit Name",
  VISITNUM= "Visit Number",
  DSDTC   = "Date/Time of Disposition Event (Collected)",
  DSSTDTC = "Start Date/Time of Disposition Event",
  DSDY  = "Study Day of Disposition Event (Collected)",
  DSSTDY  = "Study Day of Start of Disposition Event"
)

# -----------------------------
# Output final data 
# -----------------------------
ds <- ds1 |>
  select(
    STUDYID,
    DOMAIN,
    USUBJID,
    DSSEQ,
    DSTERM,
    DSDECOD,
    DSCAT,
    VISITNUM,
    VISIT,
    DSDTC,
    DSSTDTC,
    DSDY,
    DSSTDY 
  )

haven::write_xpt(data = ds, path = "output/ds.xpt")

# =========================================================
# Question 2 - End of SDTM DS Domain Creation
# =========================================================