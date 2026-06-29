# =========================================================
# Question 4 - Start of AE Listing
# =========================================================
# Programmer: Bira Aziz Khan
# Date: 01-07-2026
# Project: ADS Programmer Assessment
# Output: AE Listing
# Purpose: Create a subject-level listing of treatment-emergent
#          adverse events (TEAEs) using ADAE and ADSL datasets
#          from pharmaverseadam package.
# =========================================================

# -----------------------------
# Load packages
# -----------------------------
library(dplyr)
library(gtsummary)
library(pharmaverseadam)
library(gt)

# -----------------------------
# Input data
# -----------------------------
adae <- pharmaverseadam::adae
adsl <- pharmaverseadam::adsl

# -----------------------------
# Prepare TEAE listing dataset
# -----------------------------
ae_list <- adae |>
  filter(TRTEMFL == "Y") |>
  select(-ACTARM) |>
  left_join(
    adsl |> select(USUBJID, ACTARM),
    by = "USUBJID"
  ) |>
  # Sorted by Subject and Event Date
  arrange(USUBJID, ASTDT) |>
  
  # Group SUBJECT and ACTARM
  group_by(USUBJID) |>
  mutate(
    USUBJID_disp = if_else(row_number() == 1, USUBJID, ""),
    ACTARM_disp  = if_else(row_number() == 1, ACTARM, "")
  ) |>
  ungroup()

# -----------------------------
# Preserve variable labels
# -----------------------------
usubjid_label <- attr(adae$USUBJID, "label")
actarm_label  <- attr(adae$ACTARM, "label")

attr(ae_list$USUBJID_disp, "label") <- usubjid_label
attr(ae_list$ACTARM_disp,  "label") <- actarm_label

# -----------------------------
# Select variables for output
# -----------------------------
ae_list_final <- ae_list |>
  select(
    USUBJID_disp,
    ACTARM_disp,
    AETERM,
    AESEV,
    AEREL,
    AESTDTC,
    AEENDTC
  )

# -----------------------------
# Create AE Listing Output
# -----------------------------
ae_list_final |>
  gt::gt() |>
  
  # Add Title and Subtitle and align it left
  gt::tab_header(
    title = gt::html("Listing of Treatment-Emergent Adverse Events by Subjects"),
    subtitle = gt::html("Excluding Screen Failure Subjects")
  ) |>
  gt::opt_align_table_header(align = "left") |>
  
  # Align Listing body txt left
  gt::tab_style(
    style = gt::cell_text(align = "left"),
    locations = gt::cells_body()
  ) |>
  
  gt::gtsave("output/ae_listings.html")

# =========================================================
# Question 4 - End of AE Listing
# =========================================================