% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/qgg.R
\name{greml}
\alias{greml}
\title{Genomic REML analysis}
\usage{
greml(y = NULL, X = NULL, Glist = NULL, G = NULL, theta = NULL,
  ids = NULL, validate = NULL, maxit = 100, tol = 1e-05, bin = NULL,
  nthreads = 1, wkdir = getwd(), verbose = FALSE)
}
\arguments{
\item{y}{vector of phenotypes}

\item{X}{design matrix of fixed effects}

\item{Glist}{list of information about G matrix}

\item{G}{genomic relationship matrix}

\item{theta}{initial values for reml estimation}

\item{ids}{vector of subsetted individuals to retain for analysis, e.g. cross validation}

\item{maxit}{maximum number of iterations of reml analysis}

\item{tol}{tolerance, i.e. the maximum allowed difference between two consecutive iterations of reml to declare convergence}

\item{bin}{executable file in fortran}

\item{nthreads}{number of threads}

\item{wkdir}{working directory}
}
\value{
Returns a list structure, fit, including
\item{llik}{log-likelihood at convergence}
\item{theta}{initial values for reml estimation}
\item{asd}{asymptotic standard deviation}
\item{b}{vector of fixed effect estimates}
\item{varb}{vector of variances of fixed effect estimates}
\item{u}{vector of random effect estimates}
\item{e}{vector of residual effects}
\item{Vy}{product of variance-covariance matrix of y at convergence and y}
\item{Py}{product of projection matrix of y and y}
\item{trPG}{trace of product of projection matrix of y and G}
\item{trVG}{trace of product of variance-covariance matrix of y at convergence and G}
\item{y}{vector of phenotypes}
\item{X}{design matrix of fixed effects}
\item{ids}{vector of subsetted individuals retained for analysis}
\item{yVy}{product of y, variance-covariance matrix of y at convergence, and y}
\item{fnamesG}{filename(s) and locations of of G}
\item{wd}{working directory}
\item{Glist}{list of information about G matrix}
}
\description{
Genomic restricted maximum likelihood estimation (REML) is an analysis used to estimate genomic and residual variance.
Genomic variance is the variance associated with the genomic relationship matrix.
}
\details{
Linear mixed model (LMM) that models covariance among individuals using realized relationships at genotyped loci.
This modeling scheme is achieved through the genomic relationship matrix (G).
This matrix can be inputted 'as is' or with a more efficient list structure, Glist, that contains information about G.
The model can accomodate fixed effects.
Individuals may be subsetted for additional analyses such as cross validation.
}
\examples{

# Simulate data
W <- matrix(rnorm(20000000), ncol = 10000)
	colnames(W) <- as.character(1:ncol(W))
	rownames(W) <- as.character(1:nrow(W))
y <- rowSums(W[, 1:10]) + rowSums(W[, 1001:1010]) + rnorm(nrow(W))

# Create model
data <- data.frame(y = y, mu = 1)
fm <- y ~ 0 + mu
X <- model.matrix(fm, data = data)

# Create framework for lists
setsGB <- list(A = colnames(W)) # gblup model
setsGF <- list(C1 = colnames(W)[1:1000], C2 = colnames(W)[1001:2000], C3 = colnames(W)[2000:10000]) # gfblup model
setsGT <- list(C1 = colnames(W)[1:10], C2 = colnames(W)[1001:1010], C3 = colnames(W)[1:10000]) # true model

# Compute G
G <- computeG(W = W)
GB <- lapply(setsGB, function(x) {computeG(W = W[, x])})
GF <- lapply(setsGF, function(x) {computeG(W = W[, x])})
GT <- lapply(setsGT, function(x) {computeG(W = W[, x])})

# REML analyses
fitGB <- greml(y = y, X = X, G = GB, verbose = TRUE)
fitGF <- greml(y = y, X = X, G = GF, verbose = TRUE)
fitGT <- greml(y = y, X = X, G = GT, verbose = TRUE)

# REML analyses and cross validation
n <- length(y)
fold <- 10
nsets <- 5

validate <- replicate(nsets, sample(1:n, as.integer(n / fold)))

cvGB <- greml(y = y, X = X, G = GB, validate = validate)
cvGF <- greml(y = y, X = X, G = GF, validate = validate)
cvGT <- greml(y = y, X = X, G = GT, validate = validate)

cvGB
cvGF
cvGT

boxplot(cbind(cvGB[,1:4],cvGF[,1:4],cvGT[,1:4]))

}
\author{
Peter Sørensen
}
\references{
Lee, S. H., & van Der Werf, J. H. (2006). An efficient variance component approach implementing an average information REML suitable for combined LD and linkage mapping with a general complex pedigree. Genetics Selection Evolution, 38(1), 25.
}

