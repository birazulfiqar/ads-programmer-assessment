# descriptiveStats

## Overview

`descriptiveStats` is an R package that provides functions for calculating basic descriptive statistics for numeric vectors.

The package is designed with a focus on:
- Clean and consistent outputs
- Robust input validation
- Proper R package structure using Roxygen2 documentation

---

## Installation

To use this package locally:

```r
devtools::install("question_1/descriptiveStats")
library(descriptiveStats)
```

---

## Functions Included

### calc_mean(x)
Calculates the arithmetic mean of a numeric vector.

### calc_median(x)
Calculates the median of a numeric vector.

### calc_mode(x)
Returns the most frequently occurring value(s). Returns `NA` if no values repeat.

### calc_q1(x)
Returns the first quartile (25th percentile).

### calc_q3(x)
Returns the third quartile (75th percentile).

### calc_iqr(x)
Calculates the interquartile range (Q3 - Q1).

---

## Example Usage

```r id="example_usage_final"
library(descriptiveStats)

data <- c(1, 2, 2, 3, 4, 5, 5, 5, 6, 10)

calc_mean(data)
calc_median(data)
calc_mode(data)
calc_q1(data)
calc_q3(data)
calc_iqr(data)
```

---

## Expected Output

- Mean: 4.3  
- Median: 4.5  
- Mode: 5  
- Q1: 2.25  
- Q3: 5  
- IQR: 2.75  

---

## Notes

- All functions require numeric input.
- Missing values are handled using `na.rm = TRUE`.
- Functions return numeric outputs for consistency.
```