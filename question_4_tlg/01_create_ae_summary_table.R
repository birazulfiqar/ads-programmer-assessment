# =========================================================
# Question 4 - Start of AE Summary Table Creation
# =========================================================
# Programmer: Bira Aziz Khan
# Date: 01-07-2026
# Project: ADS Programmer Assessment
# Output: AE Summary Table
# Purpose: Create a summary table of treatment-emergent adverse events (TEAEs)
#          using the pharmaverseadam ADAE and ADSL datasets together with
#          gtsummary. The table summarizes adverse events by treatment group
#          and includes counts and percentages with an overall summary row
# =========================================================

# -----------------------------
# Load packages
# -----------------------------
library(dplyr)
library(gtsummary)
library(pharmaverseadam)
library(gt)
library(here)


# -----------------------------
# Input data
# -----------------------------
adae <- pharmaverseadam::adae 
adsl <- pharmaverseadam::adsl

# -----------------------------
# Prepare treatment-emergent AE data
# -----------------------------
teae <- adae |>
  filter(TRTEMFL == "Y") |>
  select(-ACTARM) |>
  left_join(
    adsl |>
      select(USUBJID, ACTARM),
    by = "USUBJID"
  )

# -----------------------------
# Create AE summary table dataset
# -----------------------------
tbl_ae <- teae |> 
  tbl_hierarchical(
    
    # Row variables
    variables = c(AESOC, AETERM),
    
    # Column variable
    by = ACTARM, 
    
    # Subject denominator for % math
    denominator = adsl,
    
    # Counts unique subjects per cell
    id = USUBJID, 
    
    # Includes total row
    overall_row = TRUE, 
    label = list(..ard_hierarchical_overall.. = "Treatment Emergent AEs")
  ) |> 
  
  sort_hierarchical(by = "..ard_hierarchical_overall..", order = "descending") |>   
  bold_labels() |>
  modify_header(label = "**Primary System Organ Class<br>&nbsp;&nbsp;&nbsp;Reported Term for the Adverse Event**")

# -----------------------------
# Add line break to Column Headers
# -----------------------------
tbl_ae <- tbl_ae |>
  modify_table_styling(
    columns = all_stat_cols(),
    label = c(
      "Placebo" = "Placebo",
      "Xanomeline High Dose" = "Xanomeline High<br>Dose",
      "Xanomeline Low Dose" = "Xanomeline Low<br>Dose"
    )
  )

# -----------------------------
# Create AE summary table output
# -----------------------------
tbl_ae |>
  as_gt() |>
  gt::tab_style(
    style = gt::cell_text(weight = "bold"),
    locations = gt::cells_column_labels()
  ) |>  
  gt::gtsave(here("question_4_tlg","output","ae_summary_table.html"))

# =========================================================
# Question 4 - End of AE Summary Table Creation
# =========================================================
