# FAO-56 equations.


#' Estimate saturation vapor pressure.
#'
#' @description Estimate saturation vapor pressure from air
#'              temperature.
#'
#' @param t Air temperature [Celsius].
#'
#' @return saturation vapor pressure [kPa].
#'
#' @export
vp.temp <- function(t) {
  0.6108 * exp((17.27 * t) / (t + 237.3))
}

#' Calculate psychrometric constant.
#'
#' @description Calculate psychrometric constant.
#'
#' @param pres Air pressure [kPa].
#'
#' @param z Elevation above sea level [m]. Must provided if pres
#'          are not provided.
#'
#' @return Psychrometric constant [kPa degC-1].
#'
#' @export
cal_gamma <- function(pres = NULL, z=NULL) {
  if(is.null(pres))
    if(is.null(z)) {
      stop('If pres is null, must provide z (elevation).')
    } else {
      pres <- 101.3 * ((293.0 - (0.0065 * z)) / 293.0) ** 5.26
    }
  0.000665 * pres
}

#' Estimate monthly soil heat flux.
#'
#' @description Estimate monthly soil heat flux (G) from the mean air
#'              temperature of the previous, current or next month assuming
#'              as grass crop.
#'
#' @param t.p Mean air temperature of the previous month [Celsius].
#' @param t.n Mean air temperature of the next month [Celsius].
#' @param t.c Mean air temperature of the current month [Celsius].
#'
#'
#' @return Soil heat flux [MJ m-2 day-1].
#' @export
soil_heat_flux <- function(t.p, t.n = NULL, t.c = NULL) {
  if(!is.null(t.n))
    return(0.07 * (t.n - t.p))
  if(!is.null(t.c))
    return(0.14 * (t.c - t.p))
  stop('Temperature of the next time step or the current time step must provide one.')
}


#' Estimate daily daily extraterrestrial radiation.
#'
#' @description Estimate daily daily extraterrestrial radiation [MJ m-2 day-1].
#'
#' @param lat Latitude [degree].
#'
#' @param dates A R Date type of a vector of Date type. If not provided, it will
#'              Regard the ssd series is begin on the first day of a year.
#'
#' @return extraterrestrial radiation [MJ m-2 day-1].
#' @export
ext_rad <- function(lat, dates) {
  lat <- lat * pi/180
  if (is.numeric(dates)) {
    J <- dates
  } else {
    J <- as.double(format(dates, '%j'))
  }

  dr <- 1 + 0.033 * cos(pi * J/182.5)
  delta <- 0.408 * sin(pi * J/182.5 - 1.39)

  tmpv <- tan(lat) * tan(delta)
  tmpv[tmpv > 1.] <- 1.
  tmpv[tmpv < -1.] <- -1.

  ws <- acos(-tmpv)
  Ra <- 118.08 * dr/pi * (ws * sin(lat) * sin(delta) + cos(lat) *
                            cos(delta) * sin(ws))
  Ra
}

#' Estimate daily solar radiation.
#'
#'
#' @description Estimate daily solar radiation at crop surface [MJ m-2 day-1]
#'              by providing sunshine duration (SSD) in hours or cloud cover
#'              in fraction.
#'
#' @param ssd sunshine duration [hours].
#'
#' @param lat Latitude [degree].
#'
#' @param dates A R Date type of a vector of Date type. If not provided, it will
#'              Regard the ssd series is begin on the first day of a year.
#'
#' @param a Coefficient of the Angstrom formula. Determine the relationship
#'          between ssd and radiation. Default 0.25.
#' @param b Coefficient of the Angstrom formula. Default 0.50.
#'
#' @param cld Cloud cover [fraction]. If provided it would be directly used to
#'            calculate solar radiation rather than SSD and parameter a and b.
#'
#' @return Solar radiation at crop surface [MJ m-2 day-1].
#'
#' @references Martinezlozano J A, Tena F, Onrubia J E, et al. The historical
#'             evolution of the Angstrom formula and its modifications: review
#'             and bibliography.[J]. Agricultural & Forest Meteorology, 1985,
#'             33(2):109-128.
#'
#' @export
sur_rad <- function(ssd, lat, dates = NULL, a = 0.25, b = 0.5, cld = NULL) {
  lat <- lat*pi/180
  if (is.null(dates)) {
    J <- rep_len(c(1:365, 1:365, 1:365, 1:366), length(ssd))
  } else {
    J <- as.double(format(dates, '%j'))
  }

  delta <- 0.408 * sin(pi * J/182.5 - 1.39)
  tmpv <- tan(lat*pi/180) * tan(delta)
  tmpv[tmpv > 1.] <- 1.; tmpv[tmpv < -1.] <- -1.
  ws <- acos(-tmpv)

  Ra <- 118.08 * dr/pi * (ws * sin(lat) * sin(delta) + cos(lat) *
                          cos(delta) * sin(ws))
  if(!is.null(cld)) {
    Rs <- (1. - cld) * Ra
  } else {
    N <- ws * 24/pi
    Rs <- (a + b * ssd/N) * Ra
  }
  Rs
}

#' Estimate actual vapor pressure.
#'
#'
#' @description Estimate actual vapor pressure by providing daily maximum and minimum
#'              air temperature, daily maximum, mean and minimum relative humidity.
#'
#' @param tmax Daily maximum air temperature at 2m height [deg Celsius].
#'
#' @param tmin Daily minimum air temperature at 2m height [deg Celsius].
#'
#' @param rhmax Daily mean relative humidity [\%].
#'
#' @param rhmean Daily mean relative humidity [\%].
#'
#' @param rhmin Daily mean relative humidity [\%].
#'
#' @details tmin must be provided. If tmax was not provided,
#'          avp will only estimated by tmin. If both rhmax and rhmin are
#'          provided, avp will be estimated by tmax, tmin, rhmax and rhmin.
#'          If rhmin was not provided but provided rhmean, avp will
#'          estimated by rhmean, tmax and tmin.
#'          If rhmin and rhmean are not provided, avp will estimated by
#'          rhmax, tmax and tmin.
#'          If rhmax, rhmean and rhmin are not provided, avp will only
#'          estimated by tmin.
#'
#' @return Actual vapor pressure (i.e. avp or ea) [kPa].
#'
#'
#' @export
actual_vp <- function(tmin, tmax = NULL, rhmax = NULL, rhmean = NULL, rhmin = NULL) {
  if(is.null(tmax))
    return(vp.temp(tmin))
  if(!is.null(rhmax) & !is.null(rhmin))
    return((vp.temp(tmax) * rhmin + vp.temp(tmin) * rhmax)/200)
  if(!is.null(rhmean))
    return((vp.temp(tmax) + vp.temp(tmin)) * rhmean/200)
  if(!is.null(rhmax))
    return(vp.temp(tmin) * rhmax / 100)
  if(is.null(rhmax) & is.null(rhmean) & is.null(rhmin))
    return(vp.temp(tmin))
}

#' Estimate the slope of the saturation vapour pressure curve.
#'
#'
#' @description Estimate the slope of the saturation vapour pressure curve
#'              by providing a air temperature.
#'
#' @param t Daily mean air temperature at 2m height [deg Celsius].
#'
#' @return Slope of the saturation vapour pressure curve.
#' @export
delta_svp <- function(t) {
  4098 * (0.6108 * exp((17.27 * t) / (t + 237.3))) /
    (t + 237.3)**2
}

#' Estimate net outgoing longwave radiation.
#'
#'
#' @description Estimate net outgoing longwave radiation.
#'
#' @param tmax Daily maximum air temperature at 2m height [deg Celsius].
#'
#' @param tmin Daily minimum air temperature at 2m height [deg Celsius].
#'
#' @param Rs Incoming shortwave radiation at crop surface [MJ m-2 day-1].
#'
#' @param ea Actual vapor pressure [kPa]. Can be estimated by maximum or minimum
#'           air temperature and mean relative humidity.
#'
#' @param Rso Clear sky incoming shortwave radiation, i. e. extraterrestrial
#'            radiation multiply by clear sky transmissivity (i. e. a + b,
#'            a and b are coefficients of Angstrom formula. Normally 0.75)
#'            [MJ m-2 day-1].
#'
#' @param cld Cloud cover [fraction]. If provided it would be directly used to
#'            calculate net outgoing longwave radiation than Rso.
#'
#' @return Net outgoing longwave radiation [MJ m-2 day-1]
#'
#' @export
ol_rad <- function(tmax, tmin, ea, Rs = NULL, Rso = NULL, cld = NULL) {
  if((is.null(Rs) || is.null(Rso)) && is.null(cld))
    stop("Must provide `Rs` and `Rso`, or provide `cld`.")
  if(is.null(cld)){
    cld <- 1. - Rs / Rso
    cld[is.na(cld)] <- 1.
  }
  (4.093e-9 * (((tmax+273.15)**4 + (tmin+273.15)**4) / 2)) *
    (0.34 - (0.14 * sqrt(ea))) *
    (1.35 * (1. - cld) - 0.35)
}


#' Estimate ET0 by FAO-56 Penman-Monteithe quation.
#'
#'
#' @description Estimate reference evapotranspiration (ET0) from a hypothetical
#'              short grass reference surface using the FAO-56 Penman-Monteithe
#'              quation (equation 6 in Allen et al. (1998))
#'
#' @param Rs Incoming shortwave radiation at crop surface [MJ m-2 day-1].
#'           Can be calculated by \link{sur_rad}.
#'
#' @param tmax Daily maximum air temperature at 2m height [deg Celsius].
#'
#' @param tmin Daily minimum air temperature at 2m height [deg Celsius].
#'
#' @param ws Wind speed [m s-1].
#'
#' @param G Soil heat flux [MJ m-2 day-1]. Normally set to 0.0 when the time
#'          steps are less than 10 days. Should be calculated in monthly or
#'          longer time step. Can be calculated using function \link{soil_heat_flux}.
#'          Default 0.0.
#'
#' @param h.ws Height where measure the wind speed [m]. Default 10m.
#'
#' @param albedo Albedo of the crop as the proportion of gross incoming solar
#'               radiation that is reflected by the surface. Default 0.23
#'               (i. e. the value of the short grass reference crop defined
#'               by the FAO).
#'
#' @param delta Slope of the saturation vapour pressure curve. Can be estimated
#'              by air temperature if is not provided.
#'
#' @param gamma Psychrometric constant [kPa Celsius -1]. Can be estimated
#'              by the air pressure or elevation if is not provided.
#'
#' @param z Elevation above sea level [m]. Must provided if gamma and pres
#'          are not provided.
#'
#' @param ea Actual vapor pressure [kPa]. Can be estimated by maximum or minimum
#'           air temperature and mean relative humidity.
#'
#' @param es Saturated vapor pressure [kPa]. Can be estimated by maximum or
#'           minimum air temperature if is not provided.
#'
#' @param rhmean Daily mean relative humidity [%]. If not provided then
#'               the actual vapor pressure would be estimated by minimum air
#'               temperature.
#'
#' @param pres Air pressure [kPa]. If not provided, must provide z.
#'
#' @param cld Cloud cover [fraction]. If provided it would be directly used to
#'            calculate net outgoing longwave radiation than Rso.
#'
#' @param Rso Clear sky incoming shortwave radiation, i. e. extraterrestrial
#'            radiation multiply by clear sky transmissivity (i. e. a + b + 2E-5*elev[m],
#'            a + b are coefficients of Angstrom formula. Normally 0.75)
#'            [MJ m-2 day-1]. Ext. rad. can be calculated by \link{ext_rad}.
#'            Should be provided if `cld` is not provided.
#'
#' @return Reference evapotranspiration ET0 from a hypothetical grass
#'         reference surface [mm day-1].
#'
#'
#' @export
et0_pm <- function(Rs, tmax, tmin, ws, G = 0.0, h.ws = 10.0, albedo = 0.23,
                   delta = NULL, gamma = NULL, z = NULL, ea = NULL, es = NULL,
                   rhmean = NULL, pres = NULL, Rso = NULL, cld = NULL,
                   tall_crop = FALSE){

  tas <- (tmax + tmin) / 2
  if(is.null(ea))
    if(!is.null(rhmean)) {
      ea <- actual_vp(tmin, tmax, rhmean = rhmean)
    } else {
      ea <- vp.temp(tmin)
    }

  if(is.null(es)) es <- (vp.temp(tmax) + vp.temp(tmin)) / 2
  if(is.null(delta)) delta <- delta_svp(tas)

  Rl <- ol_rad(tmax, tmin, ea, Rs, Rso, cld)
  Rn <- Rs * (1 - albedo) - Rl
  Rn[Rn < 0] <- 0

  if(is.null(gamma)) gamma <- cal_gamma(pres, z)

  if(tall_crop) {
    p1 <- 1600
    p2 <- 0.38
  } else {
    p1 <- 900
    p2 <- 0.34
  }

  u2 <- ws * (4.87 / log((67.8 * h.ws) - 5.42))

  (0.408 * delta * (Rn - G) +
      gamma * 900 / (tas + 273.15) * u2 * (es - ea)) /
    (delta + (gamma * (1 + 0.34 * u2)))
}

#' Estimate ET0 by Hargreaves equation.
#'
#'
#' @description Estimate reference evapotranspiration (ET0) from a hypothetical
#'              short grass reference surface using the the Hargreaves equation.
#'
#'
#' @param tmax Daily maximum air temperature at 2m height [deg Celsius].
#'
#' @param tmin Daily minimum air temperature at 2m height [deg Celsius].
#'
#' @param tmean Daily mean air temperature at 2m height [deg Celsius]. If not
#'              provided it would estimated by averaging the tmax and tmin.
#'
#' @param Ra  Clear sky incoming shortwave radiation, i. e. extraterrestrial
#'            radiation multiply by clear sky transmissivity (i. e. a + b,
#'            a and b are coefficients of Angstrom formula. Normally 0.75)
#'            [MJ m-2 day-1]. If not provided, must provide lat and dates.
#'
#' @param lat Latitude [degree].
#'
#' @param dates A R Date type of a vector of Date type. If not provided, it will
#'              Regard the ssd series is begin on the first day of a year.
#'
#' @return Reference evapotranspiration ET0 from a hypothetical grass
#'         reference surface [mm day-1].
#'
#'
#' @export
et0_hg <- function(tmax, tmin, tmean = NULL, Ra = NULL, lat = NULL, dates=NULL) {
  if(is.null(tmean)) tmean <- (tmax + tmin) / 2
  if(is.null(Ra)) Ra <- ext_rad(lat, dates)
  0.0023 * 0.408 * Ra * sqrt(tmax - tmin) * (tmean + 17.8)
}


#' Estimate Incoming longwave radiation.
#'
#'
#' @description Estimate Incoming longwave radiation. Not included in FAO56
#'              paper but added for convinience.
#'
#'
#' @param temp Near surface air temperature [deg Celsius].
#'
#' @param ea Near surface actual vapour pressure [kPa].
#'
#' @param s Cloud air emissivity, the ratio between acutal incomming shortwave
#'          radiation and clear sky incoming shortwave radiation.
#'
#' @param method The method to estimate the air emissivity.
#'         Must be one of 'MAR', 'SWI', 'IJ', 'BRU', 'SAT', and 'KON'.
#'
#'
#' @return Incomming longwave radiation [W /m2].
#'
#'
#' @export
lw_rad <- function(temp, ea = NULL, s = 1, method = 'KON') {
  if(!(method %in% c('MAR', 'SWI', 'IJ', 'BRU', 'SAT', 'KON')))
    stop("method must be one of 'MAR', 'SWI', 'IJ', 'BRU', 'SAT', and 'KON'.")
  ea <- ea * 10
  temp <- temp + 273.15
  if(method == 'MAR'){
    ep_ac <- 0.5893 + 5.351e-2 * sqrt(ea*10)
  }
  if(method == 'SWI'){
    ep_ac <- 9.294e-6 * temp*temp
  }
  if(method == 'IJ'){
    ep_ac <- 1 - 0.26 * exp(-7.77e-4 * (273 - temp)**2)
  }
  if(method == 'BRU'){
    ep_ac <- 1.24 * (ea/temp)**(1/7)
  }
  if(method == 'SAT'){
    ep_ac <- 1.08 * exp(-ea ** (temp/2016))
  }
  if(method == 'KON'){
    ep_ac <- 0.23 + 0.848 * (ea/temp)**(1/7)
  }
  ep_a <- 1 - s + s*ep_ac
  ep_a * 5.67e-8 * temp**4
}
