# Question 4 TLG Creation

# Overview

This script creates a set of Tables, Listings, and Graphs (TLGs)
using the pharmaverseadam ADAE and ADSL datasets.

The workflow includes:
- Treatment-emergent adverse event (TEAE) summary table using {gtsummary}
- Subject-level TEAE listing using {gt}
- AE severity distribution visualization using {ggplot2}
- Top 10 most frequent adverse event incidence plot with 95% confidence intervals


# Packages Used

dplyr              : Data manipulation
gtsummary          : Summary table generation
gt                 : HTML table formatting
ggplot2            : Data visualization
scales             : Percentage axis formatting
pharmaverseadam    : ADAE and ADSL analysis datasets


# Input Data

adae    : ADaM adverse events dataset
adsl    : ADaM subject-level analysis dataset


# AE Summary Table

Treatment-emergent adverse events are identified using:

- TRTEMFL = "Y"

Summary table created using:
- tbl_hierarchical()

Table characteristics:
- Hierarchical display by Primary System Organ Class (AESOC)
  and Reported Term (AETERM)
- Treatment groups displayed as columns
- Overall treatment-emergent adverse event row included
- Unique subject counts and percentages calculated using
  ADSL as the denominator
- Rows sorted by descending overall frequency
- Treatment headers formatted with multi-line labels
- Output exported as HTML


# AE Listing

Treatment-emergent adverse events are identified using:

- TRTEMFL = "Y"

Listing includes:

- Unique Subject Identifier
- Treatment Arm
- Reported Term for the Adverse Event
- Severity/Intensity
- Relationship to Study Drug
- Adverse Event Start Date
- Adverse Event End Date

Listing characteristics:

- Sorted by Subject and Event Date
- Subject ID and Treatment displayed only on the first
  record for each subject to improve readability
- Variable labels preserved from the source dataset
- HTML title and subtitle added using gt formatting
- Listing body left-aligned
- Output exported as HTML


# Plot 1 - AE Severity Distribution

Treatment-emergent adverse events are identified using:

- TRTEMFL = "Y"

Visualization characteristics:

- Stacked bar chart
- X-axis displays Treatment Arms
- Y-axis displays counts of adverse events
- Bars coloured by AE Severity (AESEV)
- Created using ggplot2
- Output exported as PNG


# Plot 2 - Top 10 Most Frequent Adverse Events

Overall adverse events are summarized by:

- Unique subject and adverse event term

Visualization characteristics:

- Top 10 most frequent adverse events
- Incidence calculated using unique subjects
- 95% confidence intervals displayed
- Horizontal point-range plot
- Percentage axis formatting
- Subtitle includes total number of subjects analysed
- Output exported as PNG


# Output Files

AE Summary Table

output/ae_summary_table.html

AE Listing

output/ae_listings.html

Visualizations

output/ae_severity_distribution.png

output/top_10_ae_incidence.png


# Notes

- Treatment-emergent filtering is applied to the summary table,
  listing, and AE severity visualization.
- The incidence plot summarises overall adverse events using
  unique subjects for frequency calculations.
- Subject-level counts are used throughout to avoid duplicate
  counting of multiple adverse event records.
- HTML formatting is applied using gt and gtsummary to produce
  presentation-ready outputs.
- Visualizations are created using ggplot2 and exported at
  publication-quality resolution (300 dpi).