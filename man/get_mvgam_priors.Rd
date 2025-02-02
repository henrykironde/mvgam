% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_mvgam_priors.R
\name{get_mvgam_priors}
\alias{get_mvgam_priors}
\title{Extract information on default prior distributions for an mvgam model}
\usage{
get_mvgam_priors(
  formula,
  data,
  data_train,
  family = "poisson",
  use_lv = FALSE,
  n_lv,
  use_stan = TRUE,
  trend_model = "None",
  drift = FALSE
)
}
\arguments{
\item{formula}{A \code{character} string specifying the GAM formula. These are exactly like the formula
for a GLM except that smooth terms, s, te, ti and t2, can be added to the right hand side
to specify that the linear predictor depends on smooth functions of predictors (or linear functionals of these)}

\item{data}{A \code{dataframe} or \code{list} containing the model response variable and covariates
required by the GAM \code{formula}. Should include columns:
'y' (the discrete outcomes; \code{NA}s allowed)
'series' (character or factor index of the series IDs)
'time' (numeric index of the time point for each observation).
Any other variables to be included in the linear predictor of \code{formula} must also be present}

\item{data_train}{Deprecated. Still works in place of \code{data} but users are recommended to use
\code{data} instead for more seamless integration into \code{R} workflows}

\item{family}{\code{character}. Must be either 'nb' (for Negative Binomial), 'tw' (for Tweedie) or 'poisson'}

\item{use_lv}{\code{logical}. If \code{TRUE}, use dynamic factors to estimate series'
latent trends in a reduced dimension format. If \code{FALSE}, estimate independent latent trends for each series}

\item{n_lv}{\code{integer} the number of latent dynamic factors to use if \code{use_lv == TRUE}.
Cannot be \code{>n_series}. Defaults arbitrarily to \code{min(2, floor(n_series / 2))}}

\item{use_stan}{Logical. If \code{TRUE} and if \code{rstan} is installed, the model will be compiled and sampled using
the Hamiltonian Monte Carlo with a call to \code{\link[cmdstanr]{cmdstan_model}} or, if \code{cmdstanr} is not available,
a call to \code{\link[rstan]{stan}}. Note that this functionality is still in development and
not all options that are available in \code{JAGS} can be used, including: no option for a Tweedie family and no option for
dynamic factor trends. However, as \code{Stan} can estimate Hilbert base approximate Gaussian Processes, which
are much more computationally tractable than full GPs for time series with \verb{>100} observations, estimation
in \code{Stan} can support latent GP trends while estimation in \code{JAGS} cannot}

\item{trend_model}{\code{character} specifying the time series dynamics for the latent trend. Options are:
'None' (no latent trend component; i.e. the GAM component is all that contributes to the linear predictor,
and the observation process is the only source of error; similarly to what is estimated by \code{\link[mcgv]{gam}}),
'RW' (random walk with possible drift),
'AR1' (AR1 model with intercept),
'AR2' (AR2 model with intercept) or
'AR3' (AR3 model with intercept) or
'VAR1' (with possible drift; only available in \code{Stan}) or
'GP' (Gaussian Process with squared exponential kernel;
only available for estimation in \code{Stan})}

\item{drift}{\code{logical} estimate a drift parameter in the latent trend components. Useful if the latent
trend is expected to broadly follow a non-zero slope. Note that if the latent trend is more or less stationary,
the drift parameter can become unidentifiable, especially if an intercept term is included in the GAM linear
predictor (which it is by default when calling \code{\link[mcgv]{jagam}}). Therefore this defaults to \code{FALSE}}
}
\value{
either a \code{data.frame} containing the prior definitions (if any suitable
priors can be altered by the user) or \code{NULL}, indicating that no priors in the model
can be modified through the \code{mvgam} interface
}
\description{
This function lists the parameters that can have their prior distributions
changed for a given \code{mvgam} model, as well listing their default distributions
}
\details{
Users can supply a model formula, prior to fitting the model, so that default priors can be inspected and
altered. To make alterations, change the contents of the \code{prior} column and supplying this
\code{data.frame} to the \code{mvgam} function using the argument \code{priors}. If using \code{Stan} as the backend,
users can also modify the parameter bounds by modifying the \code{new_lowerbound} and/or \code{new_upperbound} columns.
This will be necessary if using restrictive distributions on some parameters, such as a Beta distribution
for the trend sd parameters for example (Beta only has support on  \code{(0,1)}), so the upperbound cannot
be above \code{1}
}
\note{
Only the \code{prior}, \code{new_lowerbound} and/or \code{new_upperbound} columns of the output
should be altered when defining the user-defined priors for the \code{mvgam} model. Use only if you are
familiar with the underlying probabilistic programming language. There are no sanity checks done to
ensure that the code is legal (i.e. to check that lower bounds are smaller than upper bounds, for
example)
}
\examples{
# Simulate three integer-valued time series
library(mvgam)
dat <- sim_mvgam(trend_rel = 0.5)

# Get a model file that uses default mvgam priors for inspection (not always necessary,
# but this can be useful for testing whether your updated priors are written correctly)
mod_default <- mvgam(y ~ s(series, bs = 're') +
              s(season, bs = 'cc') - 1,
              family = 'nb',
              data = dat$data_train,
              trend_model = 'AR2',
              priors = test_priors,
              run_model = FALSE)

# Inspect the model file with default mvgam priors
mod_default$model_file

# Look at which priors can be updated in mvgam
test_priors <- get_mvgam_priors(y ~ s(series, bs = 're') +
                                s(season, bs = 'cc') - 1,
                                family = 'nb',
                                data = dat$data_train,
                                trend_model = 'AR2')
test_priors

# Make a few changes; first, change the population mean for the series-level
# random intercepts
test_priors$prior[1] <- 'mu_raw1 ~ dnorm(-1, 2)'

# Now use stronger regularisation for the series-level AR2 coefficients
test_priors$prior[4] <- 'ar2[s] ~ dnorm(0, 20)'

# Check whether the notation in the 'prior' column is correct (note, this function
# will not check that densities are correctly spelled and parameterised, that is up
# to the user!)
update_priors(model_file = mod_default$model_file,
              priors = test_priors)

# No warnings, the model is ready for fitting now in the usual way with the addition
# of the 'priors' argument:
# mod <- mvgam(y ~ s(series, bs = 're') +
#                s(season, bs = 'cc') - 1,
#              family = 'nb',
#              data = dat$data_train,
#              trend_model = 'AR2',
#              priors = test_priors)

# Look at what is returned when an incorrect spelling is used
test_priors$prior[4] <- 'ar2_bananas ~ dnorm(0, 20)'
update_priors(model_file = mod_default$model_file,
              priors = test_priors)

}
\seealso{
\code{\link{mvgam}}
}
\author{
Nicholas J Clark
}
