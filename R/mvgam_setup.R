#' Generic GAM setup function
#' @noRd
#'
mvgam_setup <- function(formula,
                        family = gaussian(),
                        data = list(),
                        na.action,
                        knots = NULL,
                        drop.unused.levels = FALSE,
                        maxit = 40) {

  # Initialise the GAM for a few iterations to get all necessary structures for
  # generating predictions; also provides information to regularize parametric
  # effect priors for better identifiability of latent trends
  mgcv::gam(formula(formula),
            data = data,
            method = "REML",
            family = family,
            knots = knots,
            control = list(nthreads = min(4, parallel::detectCores() - 1),
                           maxit = maxit),
            drop.unused.levels = FALSE)
}
