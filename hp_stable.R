# Use the algorithm on page 166 of Bratley et al [A Guide to Simulatino]
# to generate from symmetric stable laws
require (gtools)
rsymstable_helper <- defmacro (alpha, expr= {
  temp = runif (n=2);
  V =  pi * (temp[1] - 1/2);
  W = 0.0 - log (1 - temp[2]);
  
  firstfactor = sin (alpha * V) / (cos(V)^(1.0/alpha));
  secondfactor = (cos(V - alpha * V)/W)^(1.0/alpha - 1);
  
  tmp = firstfactor * secondfactor;
  tmp;})

rsymstable <- function (n, alpha) {
  tmp = sapply (1:n, function(i) {rsymstable_helper(alpha)})
  tmp
}
