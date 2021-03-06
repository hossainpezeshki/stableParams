---
title: "Estimating the parameters of a symmetric stable location-scale model"
author: "Dr. Hossain Pezeshki"
date: '2015-06-12'
output: html_document
css: style.css
bibliography: bibliography.bib
csl: ieee.csl
---

# Prompt #
We noticed that `stableFit{fBasics}` function @fBasics in
R version 3.2.0 @theRlang is quite time-consuming when run in the "MLE" mode. 
This is understandable in light of the fact that the CDF's of stable laws
are known only in the forms of power series or asymptotic series; see for instance
page 165ff of @guidetosim.
Here we suggest a different method that can be considered a combination 
of quantile-fitting and the MLE.

# The basic model #
The input vector $\underline{y} = [y_1, y_2,\ldots, y_m]^{\top}$
is assumed to be iid samples from the random variable $Y$ which has the form
$$ Y = c + s X $$
where $c$ is the location parameter, $s$ is the scale parameter
and $X$ is distributed according a symmetric stable law with characteristic index
$\alpha$. The three parameters $c,\, s$ and $\alpha$ are not known and we are
trying to estimate them. Clearly the CDF's and the pdf's of $Y$ and $X$ are related as:
$$
F_Y (y) = F_X \left(\dfrac{y-l}{c} \right)
\;\mbox{and}\;\;
 f_{Y}(y) = \frac{1}{s} f_{X} \left(\dfrac{y-c}{s}\right)
\;\;\mbox{respectively}
\;\mbox{for}\; -\infty < y < \infty $$
Likewise the quantiles of $X$ and $Y$ are related as
$$ F^{-1}_Y (t) = c + s\, F^{-1}_X(t)\;\;\mbox{for}\;\; 0 < t <1$$

Let $F_{m}(\,)$ be the empirical cdf of $\underline{y}$ our observation vector,
then by the Gilvenko-Cantelli theorem (pg. 269 of @probandmeasure) we expect	
$$F_{m}^{-1}(t) \approx F_Y^{-1}(t)
\;\;\mbox{for}\;\; \dfrac{1}{m} < t < \dfrac{m-1}{m}
 $$
so that
$$F_{m}^{-1}(t) \approx c + s\, F^{-1}_X(t)
\;\;\mbox{for}\;\; \dfrac{1}{m} < t < \dfrac{m-1}{m}
$$
That is, if the characteristic index $\alpha$ is chosen correctly then
a plot of the quantiles of the data against the quantiles of the symmetric stable law
with index $\alpha$ should be nearly a straight line whose intercept
and slope correspond to the location and scale parameters, $c$ and $s$ respectively.
Our procedure, thus, is to look for the value of $\alpha$ that gives the best
straight line approximation to $F_{m}^{-1}(t)$; clearly is a a linear least squares problem.
However, we found we get better results if we fit $\alpha$ in this way 
not
to the quantiles of the observations directly,
but rather to observations  centred and scaled by initial guesses
at $c$ and $s$, say $c_{\mbox{init}}$ and $s_{\mbox{init}}$ respectively as follows:
Define the vector $\underline{W} = 
[W_1, W_2,\ldots, W_m]^\top$ by
$$ W_j \stackrel{\Delta}{=} \left(y_j - c_\mbox{init}\right)/{s_\mbox{init}}
\;\;\mbox{for}\;\; 1\leq j \leq m$$
Then we look for $\alpha$,
such that a symmetric stable random variable $X$ with characterisitic index
$\alpha$
makes the following affine approximation tightest in the least squares sense.
$$
F_{W}^{-1} \approx 
a + b\,\, F^{-1}_X(t)
\;\;\mbox{for}\;\; \dfrac{1}{m} < t < \dfrac{m-1}{m}
$$
For the initial guesses of $c$ and $s$ we use the following:
$$
c_{\mbox{init}} \stackrel{\Delta}{=} \dfrac{1}{m}\sum_{i=1}^{m} y_i\;\;
\mbox{and}\;\;
s_{\mbox{init}} =
\dfrac{\dfrac{1}{2}\left(\widehat{F}_{m}^{-1}(3/4) - \widehat{F}_{m}^{-1}(1/4)\right)}{0.6745}
$$
where particular choice of $s_{\mbox{init}}$ is motivated by the dicussion on page
86 of @serfling.

Although at this point estimates of location and scale,
$\widehat{c}$ and $\widehat{s}$ respectively,
can be found as:
$$ \widehat{c} =  c_\mbox{init} +  a \times s_\mbox{init}\;\;
\mbox{and}\;\;
\widehat{s} = b \times s_\mbox{init}
$$
we can, more accurately, find MLE's of $c$ and $s$ since $\alpha$ is now known. 

# Implementation and testing #
Our R function `hp_stableparams` implements the above procedure. 


```r
require (stabledist)
```

```
## Loading required package: stabledist
```

```r
require (gtools)
```

```
## Loading required package: gtools
```

```r
hp_lse <- function (y, x) {
  X <- matrix (rep(1, 2*length(x)), ncol=2);
  X[,2] <- x;
  Y <- matrix (y, ncol=1);
  
  XtX <- t(X) %*% X;
  
  theta <- solve (XtX) %*% (t(X) %*% Y);
  yhat <- X %*% theta;
  
  temp = sum ((Y - yhat)^2);
  temp
}

hp_stableparams <- function (obs, method=c("q", "likelihood")) {
  # obs is a vector of observations
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
  
  
  tmp <- optimize (f=targetAlpha, interval=c(1,2),
			maximum=FALSE, qd=qdata, probs=probs)
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
    # Y = l + s * X where X is a symmetric stable r.v. with characterisitic
    # index alpha as index
    logpdf <- function (x, Location, Scale, alpha) {
				temp = (x - Location) / Scale;
                             temp = log (dstable (temp, alpha, beta=0.0)) - log (Scale);
                             temp;}
  
    targetLS <- function (init_guess, #initial guess at location and scale
                      x, alpha) {
      tmp <- sapply (1:length(x),
		function (i) {logpdf (x[i], init_guess[1], init_guess[2], alpha)})
      0.0 - sum(tmp)
    }
  
    tmp <- optim (c(init_Location, init_Scale), fn=targetLS,
		x=obs, a=result$alpha_hat, method="Nelder-Mead")

    ptm <- proc.time() - ptm
    result$compute.time <- ptm["elapsed"]
    result$method <- "likelihood"
    result$Location_hat <- tmp$par[1]
    names (tmp$par[2]) <- NULL
    result$Scale_hat <- tmp$par[2]
  }
  
  result
}
```
Let us now test the code and the procedure.


```r
library (stabledist)
source ("./hp_stable.R")

set.seed (29524852)

obs <- 2 + 5 * rsymstable (n=200, alpha=1.2)
#obs <- 3 + 2 * rstable (n=200, alpha=1.6, beta=0)

source ("./hp_stableparams.R")

result <- hp_stableparams (obs = obs, method="mle")

str=sprintf ("By hp_stableparams (%s method): alpha = %.3f, location = %.3f, scale = %.3f",
               result$method, result$alpha_hat, result$Location_hat, result$Scale_hat)
print (result$compute.time)
```

```
## elapsed 
##  38.291
```

```r
str
```

```
## [1] "By hp_stableparams (likelihood method): alpha = 1.181, location = 1.908, scale = 4.600"
```

```r
library (fBasics)
```

```
## Loading required package: timeDate
## Loading required package: timeSeries
## 
## 
## Rmetrics Package fBasics
## Analysing Markets and calculating Basic Statistics
## Copyright (C) 2005-2014 Rmetrics Association Zurich
## Educational Software for Financial Engineering and Computational Science
## Rmetrics is free software and comes with ABSOLUTELY NO WARRANTY.
## https://www.rmetrics.org --- Mail to: info@rmetrics.org
```

```r
ptm <-proc.time()
sf <- stableFit (x = obs, beta=0, doplot=FALSE, type="mle")
sf <- attributes (sf)
ptm <- proc.time() - ptm
str=sprintf ("By stableFit (q method): alpha = %.3f, location = %.3f, scale = %.3f",
               sf$fit$estimate[1], sf$fit$estimate[4], sf$fit$estimate[3])
print (ptm["elapsed"])
```

```
## elapsed 
##  95.051
```

```r
str
```

```
## [1] "By stableFit (q method): alpha = 1.232, location = 1.577, scale = 4.650"
```
We see that our procedure produces more accurate results in less than half the time
take by `stableFit`.

# References #
