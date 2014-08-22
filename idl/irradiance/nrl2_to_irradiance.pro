;@***h* SOLAR_IRRADIANCE_FCDR/nrl2_to_irradiance.pro
;
; NAME
;   nrl2_to_irradiance.pro
;
; PURPOSE
;   The nrl2_to_irradiance.pro procedure computes daily Model Total Solar Irradiance and Solar Spectral Irradiance using the Judith Lean
;   (Naval Research Laboratory) NRL2 model and writes the output to NetCDF4 format.
;
; DESCRIPTION
;   The nrl2_to_irradiance.pro procedure is the main driver routine that computes the Model Total Solar Irradiance (TSI)
;   and Solar Spectral Irradiance (SSI) using the 2-component regression formulas described below and the variables as defined. Required 
;   input data is the time-dependent facular brightening and sunspot darkening functions that are derived from independent solar
;   observations made approximately daily, respectively, the Mg II index of global facular emission and the areas and locations of 
;   sunspot active regions on the solar disk.
; 
;   Variable Definitions:
;   T(t) is the time-dependency (t) of TSI,
;   I(k,t) it the spectral (k) and time-dependency (t) of SSI.
;   delta_T_F(t) is the time dependency of the delta change to TSI from the facular brightening index, F(t)
;   delta_I_F(k,t) is similarly described, but for SSI, and is also spectrally dependent 
;   delta_T_S(t) is the time dependency of the delta change to TSI from the sunspot darkening index, S(t)
;   delta_I_S(t) is similarly described, but for SSI, and is also spectrally dependent
;   
;   2-Component Regression formulas: 
;   T(t) = T_Q + delta_T_F(t) + delta_T_S(t)
;   I(k,t) = I_Q + delta_I_F(t) + delta_I_S(t)
;
;   Quantifying time-dependent TSI (T) Irradiance Variations from Faculae (F) and Sunspots (S):
;   delta_T_F(t) = a_F + b_F * [F(t) - F_Q]
;   delta_T_S(t) = a_S + b_S * [S(t) - S_Q]
;   F_Q and S_Q (=0) are the values of the facular brightening and sunspot darkening indices corresponding to T_Q 
;   (i.e. for the quiet Sun). 
;   
;   Quantifying time and spectrally-dependent SSI (I) Irradiance variation from Faculae (F) and Sunspot (S):
;   delta_I_F(k,t) = c_F(k) + d_F(k) * [F(t) - F_Q] + e_F * [F(t) - F_Q]
;   delta_I_S(k,t) = c_S(k) + d_S(k) * [S(t) - S_Q] + e_S * [S(t) - S_Q]
;   
;   Coefficients for faculae and sunspots:
;   The a, b, c(k), and d(k) coefficients for faculae and sunspots are specified (determined using multiple linear regression) 
;   and supplied with the algorithm. These coefficients best reproduce the TSI irradiance variability  measured directly by 
;   SORCE TIM from 2003 to 2014 and detrended SSI irradiance variability (removal of 81-day running mean) measured by SORCE SIM. 
;   Note, the a and c coefficients are nominally zero so that when F=F_Q and S=S_Q, then T=T_Q and I=I_Q.
;   The additional wavelength-dependent terms in the spectral irradiance facular and sunspot components evaluated with the 
;   e coefficients provide small adjustments to ensure that 1) the numerical integral over wavelength of the solar spectral irradiance is 
;   equal to the total solar irradiance, 2) the numerical integral over wavelength of the time-dependent SSI irradiance variations from
;   faculae and sunspots is equal to the time-dependent TSI irradiance variations from the faculae and sunspots. 
;   
;   Reference(s):
;   Reference describing the solar irradiance variability due to linear combinations of sunspot darkening
;   and facular brightening: 
;      Fröhlich, C., and J. Lean, The Sun’s total irradiance: Cycles, trends
;      and climate change uncertainties since 1976, Geophys. Res. Lett., 25, 4377‐4380, 1998.
;   References describing the original NRLTSI and NRLSSI models are:
;      Lean, J., Evolution of the Sun's Spectral Irradiance Since the Maunder Minimum, Geophys. Res. Lett., 27, 2425-2428, 2000.
;      Lean, J., G. Rottman, J. Harder, and G. Kopp, SORCE Contributions to New Understanding of Global Change and Solar Variability,
;      Solar. Phys., 230, 27-53, 2005.
;      Lean, J. L., and T.N. Woods, Solar Total and Spectral Irradiance Measurements and Models: A Users Guide,
;      in Evolving Solar Physics and the Climates of Earth and Space, Karel Schrijver and George Siscoe (Eds), Cambridge Univ. Press, 2010.
;   Reference describing the extension of the model to include the extreme ultraviolet spectrum and the empirical capability to specify 
;   entire solar spectral irradiance and its variability from 1 to 100,000 nm:
;      Lean, J. L., J. T. Emmert, J. M. Picone, and R. R. Meier, Global and regional trends in ionospheric total electron content, 
;      J. Geophys. Res., 116, A00H04, doi:10.1029/2010JA016378.
;      
; INPUTS
;   ymd1 - starting time range respective to midnight GMT of the given day, of the form 'yyyy-mm-dd'
;   ymd2 - ending time range respective to midnight GMT of the given day (i.e. in NOT inclusive), of the form 'yyyy-mm-dd'.
;
;infile - an ascii text columnar file containing model coefficients and adopted quiet Sun irradiance value
;
; OUTPUTS
;   outfile - user provided output filename (default filename is 'nrl_tsi.nc') that contains a data structure of
;   Modeled Total Solar Irradiance ('tsi'), 'year', day of year ('doy'), and 'day_number'
;   (cumulative day number since Jan. 1, 1978) in netCDF4 format.
;
; AUTHOR
;   Judith Lean, Space Science Division, Naval Research Laboratory, Washington, DC
;   Odele Coddington, Laboratory for Atmospheric and Space Physics, Boulder, CO
;   Doug Lindholm, Laboratory for Atmospheric and Space Physics, Boulder, CO
;
; COPYRIGHT
;   THIS SOFTWARE AND ITS DOCUMENTATION ARE CONSIDERED TO BE IN THE PUBLIC
;   DOMAIN AND THUS ARE AVAILABLE FOR UNRESTRICTED PUBLIC USE. THEY ARE
;   FURNISHED "AS IS." THE AUTHORS, THE UNITED STATES GOVERNMENT, ITS
;   INSTRUMENTALITIES, OFFICERS, EMPLOYEES, AND AGENTS MAKE NO WARRANTY,
;   EXPRESS OR IMPLIED, AS TO THE USEFULNESS OF THE SOFTWARE AND
;   DOCUMENTATION FOR ANY PURPOSE. THEY ASSUME NO RESPONSIBILITY (1) FOR
;   THE USE OF THE SOFTWARE AND DOCUMENTATION; OR (2) TO PROVIDE TECHNICAL
;   SUPPORT TO USERS.
;
; REVISION HISTORY
;   08/22/2014 Initial Version prepared for NCDC
;
; USAGE
;   nrl2_to_irradiance, ymd1, ymd2
;
;@*****

pro nrl2_to_irradiance

  ; pro to calculate nrltsi2 and nrlssi2 using saved parameters

  ; test day is 1 Jan 2003
  day=1
  month=1
  year=2003
  sb=79.76      ; from NOAA WDC sunspot regions
  mg=0.1612   ; on GOME scale
  ;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  
  modver='18Aug14'
  fn='~/git/nrlssi/data/judith_2014_08_21/NRL2_model_parameters_'+modver+'.sav'
  
  model_params = get_model_params(fn) ; restore model parameters
  
  spectral_bins = get_spectral_bins() ; set up wavelength bands for summing 1 nm spectrum
  
  nrl2_tsi = compute_tsi(sb ,mg ,model_params) ;calculate TSI for given sb and mg
  
  ssi = compute_ssi(sb, mg, model_params) ;calculate SSI for given sb and mg (1 nm bands)
  
  nrl2_ssi = bin_ssi(model_params, spectral_bins, ssi) ; SSI on the binned wavelength grid
 
  outfile = '~/fit/nrlssi/data/judith_2014_08_21/tsi_day.nc' ;this is temporary - replace with routine to generate filename
  ;stop
  ;status = write_tsi_model_to_netcdf(nrl2_tsi, outfile, year, month, day) ;need to replace with ymd1, ymd2 and assign new time variable attribute in netcdf4 format.
  
  print,systime(0),mg,sb,nrl2_tsi.totirrad,ssi.nrl2tot,nrl2_ssi.nrl2binsum
  stop
  
end
