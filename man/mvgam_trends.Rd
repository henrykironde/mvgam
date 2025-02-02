% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/trends.R
\name{mvgam_trends}
\alias{mvgam_trends}
\title{Supported mvgam trend models}
\description{
Supported mvgam trend models
}
\details{
\code{mvgam} currently supports the following dynamic trend models:
\itemize{
\item \code{RW} Random Walk
\item \code{AR1} Autoregressive model with AR coefficient for lag 1
\item \code{AR2} Autoregressive model with AR coefficients for lags 1 and 2
\item \code{AR3} Autoregressive model with AR coefficients for lags 1, 2 and 3
\item \code{VAR1} Vector Autoregressive model with VAR coefficients for lag 1; contemporaneously uncorrelated errors
\item \code{GP} Squared exponential Gaussian Process
\item \code{None} No latent trend is fitted
}

Dynamic factor models can be used in which the latent factors evolve as either
\code{RW}, \code{AR1}, \code{AR2}, \code{AR3} or \code{GP}. Note that only \code{RW}, \code{AR1}, \code{AR2} and \code{AR3} are available if
using \code{JAGS}. All trend models are supported if using \code{Stan}.
}
