# =========================================================
# Question 4 - Start of AE Visualizations
# =========================================================
# Programmer: Bira Aziz Khan
# Date: 01-07-2026
# Project: ADS Programmer Assessment
# Output: Two AE Visualization PNG Files
# Purpose: Create adverse event visualizations using the
#          pharmaverseadam ADAE and ADSL datasets.
#          Plot 1 summarizes treatment-emergent adverse
#          event severity by treatment group.
#          Plot 2 displays the top 10 most frequent
#          adverse events with 95% confidence intervals.
# =========================================================

# -----------------------------
# Load packages
# -----------------------------
library(dplyr)
library(ggplot2)
library(pharmaverseadam)
library(scales)

# -----------------------------
# Input data
# -----------------------------
adae <- pharmaverseadam::adae
adsl <- pharmaverseadam::adsl

# -----------------------------
# Prepare treatment-emergent AE dataset
# -----------------------------
ae <- adae |>
  filter(TRTEMFL == "Y") |>
  select(-ACTARM) |>
  left_join(
    adsl |>
      select(USUBJID, ACTARM),
    by = "USUBJID"
  )

# -----------------------------
# Prepare overall AE dataset
# -----------------------------
ae1 <- adae |>
  select(-ACTARM) |>
  left_join(
    adsl |>
      select(USUBJID, ACTARM),
    by = "USUBJID"
  )


# =========================================================
# Plot 1 - AE Severity Distribution by Treatment
# =========================================================

# -----------------------------
# Summarize AE severity by treatment arm
# -----------------------------
ae_severity <- ae |>
  count(ACTARM, AESEV) |>
  group_by(ACTARM) |>
  mutate(prop = n / sum(n))

# -----------------------------
# Create visualization
# -----------------------------
p1 <- ggplot(
  ae_severity,
  aes(
    x = ACTARM,
    y = n,
    fill = AESEV
  )
) +
  geom_col(position = "stack") +
  labs(
    title = "AE severity distribution by treatment",
    x = "Treatment Arm",
    y = "Counts of AEs",
    fill = "Severity/Intensity"
  ) +
  theme_minimal()

# -----------------------------
# Create output
# -----------------------------
ggsave(
  filename = "output/ae_severity_distribution.png",
  plot = p1,
  width = 10,
  height = 6,
  dpi = 300
)

# =========================================================
# Plot 2 - Top 10 Most Frequent Adverse Events
# =========================================================

# -----------------------------
# Identify the top 10 most frequent adverse events
# -----------------------------
ae_freq <- ae1 |>
  distinct(USUBJID, AETERM) |>
  count(AETERM) |>
  arrange(desc(n), AETERM) |>
  slice(1:10)

# -----------------------------
# Restrict dataset to the top 10 adverse events
# -----------------------------
top_aes <- ae1 |>
  distinct(USUBJID, AETERM) |>
  filter(AETERM %in% ae_freq$AETERM)

# -----------------------------
# Calculate total number of unique subjects
# -----------------------------
n_total <- n_distinct(ae1$USUBJID)


# -----------------------------
# Prepare Subtitle text
# -----------------------------
subtitle_txt <- paste0(
  "n = ", n_total,
  " subjects, 95% Clopper-Pearson CIs"
)

# -----------------------------
# Calculate incidence proportions and 95% confidence intervals
# -----------------------------
ae_inc <- top_aes |>
  count(AETERM) |>
  mutate(
    prop = n / n_total,
    lower = prop - 1.96 * sqrt((prop * (1 - prop)) / n_total),
    upper = prop + 1.96 * sqrt((prop * (1 - prop)) / n_total)
  ) |>
  arrange(desc(n), AETERM) |>
  mutate(
    AETERM = factor(AETERM, levels = ae_freq$AETERM)
  )

# -----------------------------
# Create visualization
# -----------------------------
p2 <- ggplot(
  ae_inc,
  aes(
    x = reorder(AETERM, prop),
    y = prop
  )
) +
  geom_errorbar(
    aes(ymin = lower, ymax = upper),
    width = 0.2
  ) +
  geom_point(size = 3) +
  coord_flip() +
  scale_y_continuous(
    labels = percent_format()
  ) +
  labs(
    title = "Top 10 Most Frequent Adverse Events",
    subtitle = subtitle_txt,
    x = NULL,
    y = "Percentage of Patients (%)"
  ) +
  theme_gray()

# -----------------------------
# Create output
# -----------------------------
ggsave(
  filename = "output/top_10_ae_incidence.png",
  plot = p2,
  width = 10,
  height = 7,
  dpi = 300
)

# =========================================================
# Question 4 - End of AE Visualizations
# =========================================================