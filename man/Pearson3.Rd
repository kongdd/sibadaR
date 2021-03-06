% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sibadaR.R
\name{Pearson3}
\alias{Pearson3}
\alias{dPearson3}
\alias{pPearson3}
\alias{qPearson3}
\alias{rPearson3}
\title{Pearson type III distribuion}
\usage{
dPearson3(x, xm, Cv, Cs)

pPearson3(q, xm, Cv, Cs, lower.tail = TRUE)

qPearson3(p, xm, Cv, Cs, lower.tail = TRUE)

rPearson3(n, xm, Cv, Cs)
}
\arguments{
\item{x, q}{vector of quantiles.}

\item{xm}{Mean of the distribution.}

\item{Cv}{Variation coefficient of the distribution.}

\item{Cs}{Deviation coefficient of the distribution.}

\item{lower.tail}{logical; if TRUE (default),
probabilities are `P[X �<U+FFFD> x]`,
otherwise, `P[X > x]`.}

\item{p}{vector of probabilities.}

\item{n}{number of observations. If `length(n) > 1`,
the length is taken to be the number required.}
}
\value{
`dPearson3` gives the density, `pPearson3` gives the
        distribution function, `qPearson3` gives the quantile
        function, and `rPearson3` generates random deviates.
}
\description{
Density, distribution function, quantile
             function and random generation for the
             Pearson type III distribution with
             parameters `xm`, `Cv` and `Cs`.
}

