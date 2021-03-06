% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/qgg.R
\name{setTest}
\alias{setTest}
\title{Genetic marker set tests based on sum statistics}
\usage{
setTest(stat = NULL, W = NULL, sets = NULL, nperm = NULL,
  method = "sum", threshold = 0.05)
}
\arguments{
\item{stat}{vector of single marker statistics (e.g. marker effects, t-stat, p-values)}

\item{W}{matrix of centered and scaled genotypes (used if method = cvat or score)}

\item{sets}{list of marker sets - names corresponds to rownames in stat}

\item{nperm}{number of permutations}

\item{method}{including sum, cvat, hyperG, score}

\item{threshold}{used if method = hyperG}
}
\value{
Returns a dataframe including 
\item{setT}{marker set test statistics} 
\item{nset}{number of markers in the set}
\item{p}{p-value for marker set}
}
\description{
Set test based on summing the single genetic marker test statistics.
The sum test is powerful if the genomic feature harbors many genetic markers having small to moderate effects.
}
\details{
The singler marker test statistics can be obtained from GBLUP and GFBLUP model fits or from standard GWAS. 
The distribution of this test statistic under the null hypothesis (associated markers are picked at random from the total 
number of tested genetic markers) is difficult to describe in terms of exact or approximate 
distributions, and an empirical distribution is required.
}
\examples{

# Simulate data
W <- matrix(rnorm(2000000), ncol = 10000)
  colnames(W) <- as.character(1:ncol(W))
y <- rowSums(W[, 1:10]) + rowSums(W[, 1001:1010]) + rnorm(nrow(W))

# REML analyses 
data <- data.frame(y = y, mu = 1)
fm <- y ~ mu
fit <- gfm(fm = fm, W = W, sets = list(colnames(W)), data = data)
fit$df <- 10
fit$p <- pt(fit$s / sqrt(fit$vs), df = fit$df, lower.tail = FALSE) 

sets <- list(A = as.character(1:100), B = as.character(101:1000), C = as.character(1001:5000), D = as.character(5001:10000))

# Set test based on sums 
res <- setTest(stat = fit$s**2, sets = sets, method = "sum", nperm = 100)

# Set test based on cvat 
res <- setTest(stat = fit$s, W = W, sets = sets, method = "cvat", nperm = 100)

# Set test based on hyperG 
res <- setTest(stat = fit$p, sets = sets, method = "hyperG", threshold = 0.05)

}
\author{
Peter Sørensen
}

