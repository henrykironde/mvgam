# Setup models for tests
library("testthat")
library("mvgam")

#### Allow conditional use of vdiffr ####
`expect_doppelganger` <- function(title, fig, ...) {
  testthat::skip_if_not_installed("vdiffr")
  vdiffr::expect_doppelganger(title, fig, ...)
}

#### Fit two models for each testing combination to ensure
# Stan-based forecasts and mvgam-based forecasts are similar;
# use 1000 posterior samples for each chain so out of sample forecast
# scores can be compared with more precision ####
# Simple Gaussian models
# set.seed(100)
# gaus_data <- sim_mvgam(family = gaussian(),
#                        T = 80,
#                        trend_model = 'AR1',
#                        seasonality = 'shared',
#                        trend_rel = 0.5)
# gaus_ar1 <- mvgam(y ~ s(season, bs = 'cc'),
#                   trend_model = 'AR1',
#                   data = gaus_data$data_train,
#                   family = gaussian(),
#                   samples = 1000)
# gaus_ar1fc <- mvgam(y ~ s(season, bs = 'cc'),
#                   trend_model = 'AR1',
#                   data = gaus_data$data_train,
#                   newdata = gaus_data$data_test,
#                   family = gaussian(),
#                   samples = 1000)

# Simple Beta models
set.seed(100)
beta_data <- sim_mvgam(family = betar(),
                       trend_model = 'GP',
                       trend_rel = 0.5)
beta_gp <- mvgam(y ~ s(season, bs = 'cc'),
                  trend_model = 'GP',
                  data = beta_data$data_train,
                  family = betar(),
                 samples = 1000)
beta_gpfc <- mvgam(y ~ s(season, bs = 'cc'),
                    trend_model = 'GP',
                    data = beta_data$data_train,
                    newdata = beta_data$data_test,
                    family = betar(),
                   samples = 1000)
