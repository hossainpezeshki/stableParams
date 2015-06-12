rm (list = ls())
graphics.off()

require (gtools)

library (stabledist)
source ("./hp_stable.R")

set.seed (29524852)

obs <- 2 + 5 * rsymstable (n=200, alpha=1.2)
#obs <- 3 + 2 * rstable (n=200, alpha=1.6, beta=0)

source ("./hp_stableparams.R")

result <- hp_stableparams (obs = obs, method="mle")

str <- sprintf ("By hp_stableparams (%s method): alpha = %.3f, location = %.3f, scale = %.3f\n",
               result$method, result$alpha_hat, result$Location_hat, result$Scale_hat)
print (result$compute.time)
print (str)

library (fBasics)

ptm <-proc.time()
sf <- stableFit (x = obs, beta=0, doplot=FALSE, type="mle")
sf <- attributes (sf)
ptm <- proc.time() - ptm
str <- sprintf ("By stableFit (q method): alpha = %.3f, location = %.3f, scale = %.3f\n",
               sf$fit$estimate[1], sf$fit$estimate[4], sf$fit$estimate[3])
print (str)
print (ptm["elapsed"])
