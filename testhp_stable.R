rm (list = ls())
graphics.off()

source ("./hp_stable.R")

alpha = 1.3

rv <- rsymstable (n=10000, alpha = alpha)

cdf <- ecdf (rv)

x <- seq (from=-4, to=4, length=1000)

library (stabledist)
y <- pstable (x, alpha=alpha, beta=0)

mypar <- par ("mar")
mypar[2] <- 1.15 * mypar[2]
par (mar=mypar)

str <- sprintf ("Comparing the simualted CDF with true CDF for alpha=%.2f", alpha)

plot (x, y, type='l', col='blue',
      xlab="x",
      ylab=expression (Pr(X <= x)),
      main=str); 

grid(ny=5, nx=8)
lines (x, cdf(x), lty=2, col='red')
legend (x=-4, y= 0.8, legend=c("Empirical CDF", "True CDF"),
        lty=c(2,1), col=c('red', 'blue'))
abline (v=0, lty=2)


