# =========================================================
# Question 3 - Start of ADaM ADSL Dataset Creation
# =========================================================
# Programmer: Bira Aziz Khan
# Date: 01-07-2026
# Project: ADS Programmer Assessment
# Dataset: ADSL
# Purpose: Create subject-level ADaM dataset using admiral
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
# AGEGR9 / AGEGR9N
# -----------------------------
adsl <- adsl |>
  mutate(
    AGEGR9 = case_when(
      AGE < 18 ~ "<18",
      AGE >= 18 & AGE <= 50 ~ "18 - 50",
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
# TRTSDTM (first exposure, valid dose only)
# -----------------------------
ex_ext <- ex |>
  derive_vars_dtm(
    dtc = EXSTDTC,
    new_vars_prefix = "EXST"
  ) |>
  derive_vars_dtm(
    dtc = EXENDTC,
    new_vars_prefix = "EXEN",
    time_imputation = "last"
  )

adsl <- adsl |>
  derive_vars_merged(
    dataset_add = ex_ext,
    filter_add = (
      EXDOSE > 0 |
        (EXDOSE == 0 & str_detect(EXTRT, regex("PLACEBO", ignore_case = TRUE)))
    ) & !is.na(EXSTDTM),
    new_vars = exprs(TRTSDTM = EXSTDTM, TRTSTMF = EXSTTMF),
    order = exprs(EXSTDTM, EXSEQ),
    mode = "first",
    by_vars = exprs(STUDYID, USUBJID)
  ) |>
  derive_vars_merged(
    dataset_add = ex_ext,
    filter_add = (
      EXDOSE > 0 |
        (EXDOSE == 0 & str_detect(EXTRT, regex("PLACEBO", ignore_case = TRUE)))
    ) & !is.na(EXENDTM),
    new_vars = exprs(TRTEDTM = EXENDTM, TRTETMF = EXENTMF),
    order = exprs(EXENDTM, EXSEQ),
    mode = "last",
    by_vars = exprs(STUDYID, USUBJID)
  ) |>
  derive_vars_dtm_to_dt(
    source_vars = exprs(TRTSDTM, TRTEDTM)
  )

# -----------------------------
# ITTFL (randomized subjects)
# -----------------------------
adsl <- adsl |>
  mutate(
    ITTFL = if_else(!is.na(ARM), "Y", "N")
  )

# -----------------------------
# ABNSBPFL (SYSBP abnormal flag)
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
# CARPOPFL (cardiac AE flag)
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
# LSTALVDT (last known alive date)
# -----------------------------
to_date <- function(x) {
  lubridate::parse_date_time(
    x,
    orders = c("ymd", "dmy", "mdy", "ymd HMS", "dmy HMS", "mdy HMS"),
    quiet = TRUE
  ) |>
    as.Date()
}

adsl <- adsl |>
  left_join(
    vs |>
      mutate(dt = to_date(VSDTC)) |>
      group_by(USUBJID) |>
      summarise(vs_dt = max(dt, na.rm = TRUE)),
    by = "USUBJID"
  ) |>
  left_join(
    ae |>
      mutate(dt = to_date(AESTDTC)) |>
      group_by(USUBJID) |>
      summarise(ae_dt = max(dt, na.rm = TRUE)),
    by = "USUBJID"
  ) |>
  left_join(
    ds |>
      mutate(dt = to_date(DSSTDTC)) |>
      group_by(USUBJID) |>
      summarise(ds_dt = max(dt, na.rm = TRUE)),
    by = "USUBJID"
  ) |>
  left_join(
    ex |>
      mutate(dt = to_date(EXSTDTC)) |>
      group_by(USUBJID) |>
      summarise(ex_dt = max(dt, na.rm = TRUE)),
    by = "USUBJID"
  ) |>
  mutate(
    LSTALVDT = pmax(vs_dt, ae_dt, ds_dt, ex_dt, na.rm = TRUE)
  )

# -----------------------------
# Final dataset
# -----------------------------
adsl <- adsl |>
  select(
    STUDYID,
    USUBJID,
    AGE,
    AGEGR9,
    AGEGR9N,
    TRTSDTM,
    ITTFL,
    ABNSBPFL,
    CARPOPFL,
    LSTALVDT
  )

# -----------------------------
# Export
# -----------------------------
dir.create("output/question3", recursive = TRUE, showWarnings = FALSE)

haven::write_xpt(adsl, "output/question3/adsl.xpt")


# =========================================================
# Question 3 - End of ADaM ADSL Dataset Creation
# =========================================================