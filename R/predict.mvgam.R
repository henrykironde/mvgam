#'Predict from the GAM component of an mvgam model
#'@param object \code{list} object returned from \code{mvgam}
#'@param newdata Optional \code{dataframe} or \code{list} of test data containing the
#'variables included in the linear predictor of \code{formula}. If not supplied,
#'predictions are generated for the original observations used for the model fit.
#'@param data_test Deprecated. Still works in place of \code{newdata} but users are recommended to use
#'\code{newdata} instead for more seamless integration into `R` workflows
#'@param n_cores \code{integer} specifying number of cores for generating predictions in parallel
#'@param type When this has the value \code{link} (default) the linear predictor is calculated on the log link scale.
#'When \code{response} is used, the predictions take uncertainty in the observation process into account to return
#'predictions on the outcome (discrete) scale.
#'@details Note that for both sets of predictions, the temporal
#'dynamics of any fitted latent trends will be ignored. This function is therefore more
#'suited to posterior simulation from the GAM component of a \code{mvgam} model,
#'while the forecasting functions
#'\code{\link{plot_mvgam_fc}} and \code{\link{forecast.mvgam}} are better suited to generate h-step ahead forecasts
#'that respect the temporal dynamics of estimated latent trends.
#'@return A \code{matrix} of dimension \code{n_samples x new_obs}, where \code{n_samples} is the number of
#'posterior samples from the fitted object and \code{n_obs} is the number of test observations in \code{newdata}
#'@export
predict.mvgam = function(object, newdata, data_test, type = 'link',
                         n_cores = 1){

  # Argument checks
  if(class(object) != 'mvgam'){
    stop('argument "object" must be of class "mvgam"')
  }

  if(!missing("data_test")){
    newdata <- data_test
  }

  type <- match.arg(arg = type, choices = c("link", "response"))

  # Generate linear predictor matrix from the mgcv component
  if(missing(newdata)){
    newdata <- object$obs_data
  }

  # Generate the linear predictor matrix
  suppressWarnings(Xp  <- try(predict(object$mgcv_model,
                                      newdata = newdata,
                                      type = 'lpmatrix'),
                              silent = TRUE))

  if(inherits(Xp, 'try-error')){
    testdat <- data.frame(time = newdata$time)
    terms_include <- names(object$mgcv_model$coefficients)[which(!names(object$mgcv_model$coefficients)
                                                                 %in% '(Intercept)')]
    if(length(terms_include) > 0){
      newnames <- vector()
      newnames[1] <- 'time'
      for(i in 1:length(terms_include)){
        testdat <- cbind(testdat, data.frame(newdata[[terms_include[i]]]))
        newnames[i+1] <- terms_include[i]
      }
      colnames(testdat) <- newnames
    }

    suppressWarnings(Xp  <- predict(object$mgcv_model,
                                    newdata = testdat,
                                    type = 'lpmatrix'))
  }

  # Beta coefficients for GAM component
  betas <- mvgam:::mcmc_chains(object$model_output, 'b')

  # Family of model
  family <- object$family

  # Family-specific parameters
  family_pars <- mvgam:::extract_family_pars(object = object)

  # Determine which series each observation belongs to
  series_ind <- as.numeric(newdata$series)

  # Loop across all posterior samples and calculate predictions
  cl <- parallel::makePSOCKcluster(n_cores)
  setDefaultCluster(cl)
  clusterExport(NULL, c('betas',
                        'family_pars',
                        'Xp',
                        'series_ind'),
                envir = environment())

  pbapply::pboptions(type = "none")
  predictions <- do.call(rbind, pbapply::pblapply(seq_len(dim(betas)[1]), function(x){

    # Family-specific parameters
    par_extracts <- lapply(seq_along(family_pars), function(j){
      if(is.matrix(family_pars[[j]])){
        family_pars[[j]][x, series_ind]
      } else {
        family_pars[[j]][x]
      }
    })
    names(par_extracts) <- names(family_pars)
    mvgam:::mvgam_predict(family = family,
                  Xp = Xp,
                  type = type,
                  betas = betas[x,],
                  family_pars = par_extracts)
  }, cl = cl))
  stopCluster(cl)

  return(predictions)
}

