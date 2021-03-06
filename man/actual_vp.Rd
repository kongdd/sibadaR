% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/FAO56.R
\name{actual_vp}
\alias{actual_vp}
\title{Estimate actual vapor pressure.}
\usage{
actual_vp(tmin, tmax = NULL, rhmax = NULL, rhmean = NULL, rhmin = NULL)
}
\arguments{
\item{tmin}{Daily minimum air temperature at 2m height [deg Celsius].}

\item{tmax}{Daily maximum air temperature at 2m height [deg Celsius].}

\item{rhmax}{Daily mean relative humidity [\%].}

\item{rhmean}{Daily mean relative humidity [\%].}

\item{rhmin}{Daily mean relative humidity [\%].}
}
\value{
Actual vapor pressure (i.e. avp or ea) [kPa].
}
\description{
Estimate actual vapor pressure by providing daily maximum and minimum
             air temperature, daily maximum, mean and minimum relative humidity.
}
\details{
tmin must be provided. If tmax was not provided,
         avp will only estimated by tmin. If both rhmax and rhmin are
         provided, avp will be estimated by tmax, tmin, rhmax and rhmin.
         If rhmin was not provided but provided rhmean, avp will
         estimated by rhmean, tmax and tmin.
         If rhmin and rhmean are not provided, avp will estimated by
         rhmax, tmax and tmin.
         If rhmax, rhmean and rhmin are not provided, avp will only
         estimated by tmin.
}

