require (stabledist)
require (gtools)

hp_lse <- defmacro (y, x, expr={
  X <- matrix (rep(1, 2*length(x)), ncol=2);
  X[,2] <- x;
  Y <- matrix (y, ncol=1);
  
  XtX <- t(X) %*% X;
  
  theta <- solve (XtX) %*% t(X) %*% Y;
  yhat <- X %*% theta;
  
  sum ((Y - yhat)^2);
})


hp_stableparams <- function (obs, method=c("q", "likelihood")) { # obs is a vector of observations
  ptm <- proc.time()
  
  result <- list()

  # We need initial guesses at location and scale parameters
  init_Location = mean (obs)
  init_Scale = (quantile (obs, 0.75) - quantile (obs, 0.25)) / 2 / 0.6745
  
  num_probs <- min (100, length(obs))
  probs <- c(1:(num_probs-1))/num_probs
  
  qdata <- quantile ((obs-init_Location)/init_Scale, probs=probs)
  
  targetAlpha <- function (a, qd, probs) {
    if (a > 2) {
      a = 2
    } else if (a < 1) {
      a = 1
    }
    qtheoretical <- qstable (alpha=a, p=probs, beta=0.0)
    hp_lse (qd, qtheoretical)
  }
  
  
  tmp <- optimize (f=targetAlpha, interval=c(1,2), maximum=FALSE, qd=qdata, probs=probs)
  names (tmp$minimum) <- NULL
  result$alpha_hat <- tmp$minimum
  
  if (method[1] == "q") {
    qtheoretical <- qstable (alpha=result$alpha_hat, p=probs, beta=0.0)
    md <- lm (qdata~qtheoretical)
    ptm <- proc.time() - ptm
    result$method <- "q"
    result$compute.time <- ptm["elapsed"]
    result$Location_hat <- init_Scale * md$coefficients[1] + init_Location
    result$Scale_hat <- init_Scale * md$coefficients[2]
  }
  else {
    # The following function is the log pdf for a random variable
    # Y = l + s * X where X is a symmetric stable r.v. with characterisitic index alpha as index
    logpdf <- defmacro (x, Location, Scale, alpha, 
                      expr= {temp = (x - Location) / Scale;
                             temp = log (dstable (temp, alpha, beta=0.0)) - log (Scale);
                             temp;})
  
    targetLS <- function (init_guess, #initial guess at location and scale
                      x, alpha) {
      tmp <- sapply (1:length(x), function (i) {logpdf (x[i], init_guess[1], init_guess[2], alpha)})
      0.0 - sum(tmp)
    }
  
    tmp <- optim (c(init_Location, init_Scale), fn=targetLS, x=obs, a=result$alpha_hat, method="Nelder-Mead")


    ptm <- proc.time() - ptm
    result$compute.time <- ptm["elapsed"]
    result$method <- "likelihood"
    result$Location_hat <- tmp$par[1]
    names (tmp$par[2]) <- NULL
    result$Scale_hat <- tmp$par[2]
  }
  
  result
}
