# =========================================================
# Question 3 - Start of ADaM ADSL Dataset Creation
# =========================================================
# Programmer: Bira Aziz Khan
# Date: 01-07-2026
# Project: ADS Programmer Assessment
# Dataset: ADSL
# Purpose: Create subject-level ADaM dataset using admiral
# Note: The ADSL includes all variables requested in the assessment together
#       with a subset of standard subject-level variables including TRT01P/TRT01A etc.
#       Additional variables from the admiral ADSL example were intentionally 
#       omitted as they were outside the scope of the assessment.
# =========================================================

# -----------------------------
# Load packages
# -----------------------------
library(admiral)
library(dplyr, warn.conflicts = FALSE)
library(pharmaversesdtm)
library(lubridate)
library(stringr)
library(haven)
library(labelled)
library(here)

# -----------------------------
# Input data
# -----------------------------
dm <- pharmaversesdtm::dm
vs <- pharmaversesdtm::vs
ex <- pharmaversesdtm::ex
ds <- pharmaversesdtm::ds
ae <- pharmaversesdtm::ae

# -----------------------------
# Start ADSL from DM
# -----------------------------
adsl <- dm |>
  select(-DOMAIN) |>
  mutate(TRT01P = ARM, TRT01A = ACTARM)

# -----------------------------
# Derive AGEGR9 / AGEGR9N
# -----------------------------
adsl <- adsl |>
  mutate(
    AGEGR9 = case_when(
      AGE < 18 ~ "<18",
      between(AGE, 18, 50) ~ "18 - 50",
      AGE > 50 ~ ">50",
      TRUE ~ NA_character_
    ),
    AGEGR9N = case_when(
      AGEGR9 == "<18" ~ 1,
      AGEGR9 == "18 - 50" ~ 2,
      AGEGR9 == ">50" ~ 3,
      TRUE ~ NA_real_
    )
  )


# -----------------------------
# Derive treatment date/time variables
# -----------------------------
# Convert EXSTDTC and EXENDTC to datetime variables.
# Missing time components are imputed according to the specification:
# - treatment start: 00:00:00 (first possible time)
# - treatment end:   23:59:59 (last possible time)
ex_ext <- ex |>
  derive_vars_dtm(
    dtc = EXSTDTC,
    new_vars_prefix = "EXST",
    time_imputation = "first"
  ) |>
  derive_vars_dtm(
    dtc = EXENDTC,
    new_vars_prefix = "EXEN",
    time_imputation = "last"
  )

adsl <- adsl |>
  # Derive TRTSDTM and TRTSTMF from the first valid exposure record.
  # A valid dose is defined as:
  #   - EXDOSE > 0, or
  #   - EXDOSE = 0 and treatment contains "PLACEBO".
  # EXSEQ is included after EXSTDTM to break ties where multiple records
  # have the same treatment start datetime.
  derive_vars_merged(
    dataset_add = ex_ext,
    filter_add = (
      EXDOSE > 0 |
        (EXDOSE == 0 & grepl("PLACEBO", EXTRT, ignore.case = TRUE))
    ) & !is.na(EXSTDTM),
    new_vars = exprs(
      TRTSDTM = EXSTDTM,
      TRTSTMF = EXSTTMF
    ),
    order = exprs(EXSTDTM, EXSEQ),
    mode = "first",
    by_vars = exprs(STUDYID, USUBJID)
  ) |>
  
  # Derive TRTEDTM and TRTETMF from the last valid exposure record.
  derive_vars_merged(
    dataset_add = ex_ext,
    filter_add = (
      EXDOSE > 0 |
        (EXDOSE == 0 & grepl("PLACEBO", EXTRT, ignore.case = TRUE))
    ) & !is.na(EXENDTM),
    new_vars = exprs(
      TRTEDTM = EXENDTM,
      TRTETMF = EXENTMF
    ),
    order = exprs(EXENDTM, EXSEQ),
    mode = "last",
    by_vars = exprs(STUDYID, USUBJID)
  ) |>
  
  # Derive corresponding treatment start and end dates.
  derive_vars_dtm_to_dt(
    source_vars = exprs(TRTSDTM, TRTEDTM)
  )

# -----------------------------
# Derive ITTFL (randomized subjects)
# -----------------------------
adsl <- adsl |>
  mutate(
    ITTFL = if_else(!is.na(ARM), "Y", "N")
  )

# -----------------------------
# Derive ABNSBPFL (abnormal systolic blood pressure flag)
# -----------------------------
adsl <- adsl |>
  left_join(
    vs |>
      mutate(VSSTRESN = as.numeric(VSSTRESN)) |>
      filter(VSTESTCD == "SYSBP", VSSTRESU == "mmHg") |>
      group_by(USUBJID) |>
      summarise(
        ABNSBPFL = if_else(any(VSSTRESN < 100 | VSSTRESN >= 140), "Y", "N")
      ),
    by = "USUBJID"
  ) |>
  mutate(
    ABNSBPFL = if_else(is.na(ABNSBPFL), "N", ABNSBPFL)
  )

# -----------------------------
# Derive CARPOPFL (cardiac AE flag)
# -----------------------------
adsl <- adsl |>
  left_join(
    ae |>
      mutate(AESOC = toupper(AESOC)) |>
      group_by(USUBJID) |>
      summarise(
        CARPOPFL = if_else(any(AESOC == "CARDIAC DISORDERS"), "Y", NA_character_)
      ),
    by = "USUBJID"
  )

# -----------------------------
# Derive LSTALVDT (last known alive date)
# -----------------------------
# Derive the latest date on which the subject is known to be alive using:
# - Last valid vital signs assessment
# - Last adverse event onset date
# - Last disposition start date
# - Last treatment administration date

adsl <- adsl |>
  derive_vars_extreme_event(
    by_vars = exprs(STUDYID, USUBJID),
    events = list(
      
      # Last vital signs assessment with a valid result
      event(
        dataset_name = "vs",
        order = exprs(VSDTC, VSSEQ),
        condition = !is.na(VSDTC) &
          !(is.na(VSSTRESN) & is.na(VSSTRESC)),
        set_values_to = exprs(
          LSTALVDT = convert_dtc_to_dt(
            VSDTC,
            highest_imputation = "M"
          ),
          seq = VSSEQ
        )
      ),
      
      # Last adverse event onset date
      event(
        dataset_name = "ae",
        order = exprs(AESTDTC, AESEQ),
        condition = !is.na(AESTDTC),
        set_values_to = exprs(
          LSTALVDT = convert_dtc_to_dt(
            AESTDTC,
            highest_imputation = "M"
          ),
          seq = AESEQ
        )
      ),
      
      # Last disposition event start date
      event(
        dataset_name = "ds",
        order = exprs(DSSTDTC, DSSEQ),
        condition = !is.na(DSSTDTC),
        set_values_to = exprs(
          LSTALVDT = convert_dtc_to_dt(
            DSSTDTC,
            highest_imputation = "M"
          ),
          seq = DSSEQ
        )
      ),
      
      # Last treatment administration date
      event(
        dataset_name = "adsl",
        condition = !is.na(TRTEDT),
        set_values_to = exprs(
          LSTALVDT = TRTEDT,
          seq = 0
        )
      )
    ),
    
    # Source datasets containing candidate dates
    source_datasets = list(
      vs = vs,
      ae = ae,
      ds = ds,
      adsl = adsl
    ),
    
    # Select the latest available date across all events
    tmp_event_nr_var = event_nr,
    order = exprs(LSTALVDT, seq, event_nr),
    mode = "last",
    
    # Output variable
    new_vars = exprs(LSTALVDT)
  )

# -----------------------------
# Final dataset and optional variable labels 
# -----------------------------
adsl <- adsl |>
  select(
    STUDYID,
    USUBJID,
    SUBJID,
    SITEID,
    
    AGE,
    AGEU,
    AGEGR9,
    AGEGR9N,
    
    SEX,
    RACE,
    ETHNIC,
    COUNTRY,
    
    ARMCD,
    ARM,
    ACTARMCD,
    ACTARM,
    TRT01P,
    TRT01A,
    
    TRTSDTM,
    TRTSTMF,
    TRTSDT,
    
    TRTEDTM,
    TRTETMF,
    TRTEDT,
    
    ITTFL,
    ABNSBPFL,
    CARPOPFL,
    
    LSTALVDT
  )

adsl <- labelled::set_variable_labels(
  adsl,
  STUDYID  = "Study Identifier",
  USUBJID  = "Unique Subject Identifier",
  SUBJID   = "Subject Identifier for the Study",
  SITEID   = "Study Site Identifier",
  
  AGE      = "Age",
  AGEU     = "Age Units",
  AGEGR9   = "Age Group",
  AGEGR9N  = "Age Group (N)",
  
  SEX      = "Sex",
  RACE     = "Race",
  ETHNIC   = "Ethnicity",
  COUNTRY  = "Country",
  
  ARMCD    = "Planned Arm Code",
  ARM      = "Description of Planned Arm",
  ACTARMCD = "Actual Arm Code",
  ACTARM   = "Description of Actual Arm",
  TRT01P   = "Planned Treatment for Period 01",
  TRT01A   = "Actual Treatment for Period 01",
  
  TRTSDTM  = "Date/Time of First Exposure to Treatment",
  TRTSTMF  = "Treatment Start Time Imputation Flag",
  TRTSDT   = "Date of First Exposure to Treatment",
  
  TRTEDTM  = "Date/Time of Last Exposure to Treatment",
  TRTETMF  = "Treatment End Time Imputation Flag",
  TRTEDT   = "Date of Last Exposure to Treatment",
  
  ITTFL    = "Intent-to-Treat Population Flag",
  ABNSBPFL = "Abnormal Systolic Blood Pressure Flag",
  CARPOPFL = "Cardiac Population Flag",
  
  LSTALVDT = "Last Known Alive Date"
)
# -----------------------------
# Export output
# -----------------------------
haven::write_xpt(adsl, here("question_3_adam","output","adsl.xpt"))


# =========================================================
# Question 3 - End of ADaM ADSL Dataset Creation
# =========================================================