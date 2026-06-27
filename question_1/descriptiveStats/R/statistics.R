#' Calculate the arithmetic mean
#'
#' Calculates the arithmetic mean of a numeric vector.
#'
#' @param x A numeric vector.
#'
#' @return A numeric value representing the arithmetic mean.
#'
#' @examples
#' data <- c(1, 2, 3, 4, 5)
#' calc_mean(data)
#'
#' @export
calc_mean <- function(x) {
  
  if (!is.numeric(x)) {
    stop("Input must be a numeric vector.")
  }
  
  if (length(x) == 0) {
    stop("Input vector is empty.")
  }
  
  mean(x, na.rm = TRUE)
  
}


#' Calculate the median
#'
#' Calculates the median of a numeric vector.
#'
#' @param x A numeric vector.
#'
#' @return A numeric value representing the median.
#'
#' @examples
#' data <- c(1, 2, 3, 4, 5)
#' calc_median(data)
#'
#' @export
calc_median <- function(x) {
  
  if (!is.numeric(x)) {
    stop("Input must be a numeric vector.")
  }
  
  if (length(x) == 0) {
    stop("Input vector is empty.")
  }
  
  median(x, na.rm = TRUE)
}


#' Calculate the mode
#'
#' Calculates the most frequently occurring value(s).
#'
#' @param x A numeric vector.
#'
#' @return A numeric value or vector representing the mode.
#' @details If multiple values have the same highest frequency, all are returned.
#' If all values occur only once, returns NA.
#'
#' @examples
#' calc_mode(c(1, 2, 2, 3))
#' calc_mode(c(1, 2, 3))
#'
#' @export
calc_mode <- function(x) {
  
  if (!is.numeric(x)) {
    stop("Input must be a numeric vector.")
  }
  
  if (length(x) == 0) {
    stop("Input vector is empty.")
  }
  
  tab <- table(x)
  max_freq <- max(tab)
  
  modes <- as.numeric(names(tab)[tab == max_freq])
  
  if (max_freq == 1) {
    return(NA_real_)
  }
  
  modes
}


#' Calculate first quartile (Q1)
#'
#' @param x A numeric vector.
#'
#' @return Q1 value.
#'
#' @export
calc_q1 <- function(x) {
  
  if (!is.numeric(x)) {
    stop("Input must be a numeric vector.")
  }
  
  if (length(x) == 0) {
    stop("Input vector is empty.")
  }
  
  as.numeric(quantile(x, 0.25, na.rm = TRUE))
}


#' Calculate third quartile (Q3)
#'
#' @param x A numeric vector.
#'
#' @return Q3 value.
#'
#' @export
calc_q3 <- function(x) {
  
  if (!is.numeric(x)) {
    stop("Input must be a numeric vector.")
  }
  
  if (length(x) == 0) {
    stop("Input vector is empty.")
  }
  
  as.numeric(quantile(x, 0.75, na.rm = TRUE))
}


#' Calculate interquartile range (IQR)
#'
#' @param x A numeric vector.
#'
#' @return Numeric value representing IQR.
#'
#' @export
calc_iqr <- function(x) {
  
  if (!is.numeric(x)) {
    stop("Input must be a numeric vector.")
  }
  
  if (length(x) == 0) {
    stop("Input vector is empty.")
  }
  
  q1 <- as.numeric(quantile(x, 0.25, na.rm = TRUE))
  q3 <- as.numeric(quantile(x, 0.75, na.rm = TRUE))
  
  q3 - q1
}