#' Return parameters to monitor during modelling
#'
#'
#' @export
#' @param family \code{character}
#' @param smooths_included Logical. Are smooth terms included in the model formula?
#' @param use_lv Logical (use latent variable trends or not)
#' @param trend_model The type of trend model used
#' @param drift Logical (was a drift term estimated or not)
#' @return A string of parameters to monitor
get_monitor_pars = function(family, smooths_included = TRUE,
                            use_lv, trend_model, drift){

  family <- match.arg(arg = family, choices = c("negative binomial", "poisson",
                                                "tweedie", "beta",
                                                "gaussian", "lognormal",
                                                "student", "Gamma"))

  if(smooths_included){
    param <- c('rho', 'b', 'ypred', 'mus')
  } else {
    param <- c('b', 'ypred', 'mus')
  }

  # Family-specific parameters to monitor
  param <- c(param, family_par_names(family))

  # Trend-specific parameters
  param <- c(param, trend_par_names(trend_model, use_lv, drift))

  return(param)
}
