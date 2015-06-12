## Overview 
We noticed that `stableFit{fBasics}` 
was fast but inaccurate in "quantile" mode, and very slow albeit somewhat
more accurate in "MLE" mode; so we wrote
our own code for estimating the parameters of a location-scale symmetric stable
model from data which is faster than stableFit and almost as accurate.

## R code
The accompanying file hp_stableparams.R is standalone R code
that implements what is in the document, and testhp_stableparams.R 
is a short program for testing the former.

The file hp_stable.R is a function for simulating vectors of symmetric stable
random variates of a specified index, and the testhp_stable.R is
a simple program for testing hp_stable.R


## Copyright notice
Copyright (C) 2015 by Dr. Hossain Pezeshki June 12th, 2015

[My LinkedIn profile](https://ca.linkedin.com/pub/hossain-pezeshki/0/778/395)

Permission is granted for anyone to copy, use, or modify these
programs and accompanying documents for purposes of research or
education, provided this copyright notice is retained, and note is
made of any changes that have been made.
 
These programs and documents are distributed without any warranty,
express or implied.  As the programs were written for research
purposes only, they have not been tested to the degree that would be
advisable in any important application.  All use of these programs is
entirely at the user's own risk.
