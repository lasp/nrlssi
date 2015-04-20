;@***h* SOLAR_IRRADIANCE_FCDR/nrl2_to_irradiance.pro
;
; NAME
;   nrl2_to_irradiance.pro
;
; PURPOSE
;   The nrl2_to_irradiance.pro procedure is the driver routine to compute daily Model Total Solar Irradiance (TSI) and 
;   Solar Spectral Irradiance (SSI) using the Judith Lean (Naval Research Laboratory) NRLTSI2 and NRLSSI2 models 
;   and write the output to NetCDF4 format.
;
; DESCRIPTION
;   The nrl2_to_irradiance.pro procedure is the main driver routine that computes the Model Total Solar Irradiance
;   and Solar Spectral Irradiance using the 2-component regression formulas described below and the variables as defined. Required 
;   input data is the time-dependent facular brightening and sunspot darkening functions that are derived from independent solar
;   observations made approximately daily, respectively, the Mg II index of global facular emission and the number, areas and locations of 
;   sunspot active regions on the solar disk.
; 
;   Variable Definitions:
;   T(t) is the time-dependency (t) of TSI,
;   I(k,t) it the spectral (k) and time-dependency (t) of SSI.
;   delta_T_F(t) is the time dependency of the delta change to TSI from the facular brightening index, F(t)
;   delta_I_F(k,t) is the time and wavelength dependency of the delta change to SSI from the facular brightening index, F(t)
;   delta_T_S(t) is the time dependency of the delta change to TSI from the sunspot darkening index, S(t)
;   delta_I_S(t) is the time and wavelength dependency of the delta change to SSI from the sunspot darkening index, S(t)
;   T_Q is the TSI of the adopted Quiet Sun reference value.
;   I_Q is the SSI of the adopted Quiet Sun reference spectrum.
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
;   The 'a', 'b', 'c(k)', and 'd(k)' coefficients for faculae and sunspots are specified (determined using multiple linear regression) 
;   and supplied with the algorithm. These coefficients best reproduce the TSI irradiance variability  measured directly by 
;   SORCE TIM from 2003 to 2014 and detrended SSI irradiance variability (removal of 81-day running mean) measured by SORCE SIM. 
;   Note, the a and c coefficients are nominally zero so that when F=F_Q and S=S_Q, then T=T_Q and I=I_Q.
;   The additional wavelength-dependent terms in the spectral irradiance facular and sunspot components evaluated with the 
;   'e' coefficients provide small adjustments to ensure that 1) the numerical integral over wavelength of the solar spectral irradiance is 
;   equal to the total solar irradiance, 2) the numerical integral over wavelength of the time-dependent SSI irradiance variations from
;   faculae and sunspots is equal to the time-dependent TSI irradiance variations from the faculae and sunspots. 
;   
;   Additional explanation of coefficients used to model solar spectral irradiance: 
;   A relationship of solar spectral irradiance variability to sunspot darkening and facular brightening determined using observations of 
;   solar rotational modulation: instrumental trends are smaller over the (much) shorter rotational times scales than during the solar cycle. 
;   For each 1 nm bin, the observed spectral irradiance and the facular brightening and sunspot darkening indices are detrended by 
;   subtracting 81-day running means. Multiple linear regression is then used to determine the relationships of the detrended time series:
;   
;   I_detrend_mod(k,t) = I_mod(k,t) - I_smooth(k,t)
;                      = c(k) + d_F_detrend(k) * [F(t) - F_smooth(t)] + d_S_detrend(k) * [S(t) - S_smooth(t)]
;                      
;   Variable Definitions:
;   I_mod(k,t) = the spectral (k) and time (t) dependecies of the modeled spectral irradiance, I_mod.
;   I_smooth(k,t) = the spectral and time dependences of the smoothed (i.e. after subtracting 81-day running mean) observed spectral irradiance.
;   F_smooth(t) = the time dependency of the smoothed (i.e. after subtracting 81-day running mean) observed facular brightening index, F(t).
;   S_smooth(t) = as above, but for the observed sunspot darkening index, S(t).
;   
;   The range of facular variability in the detrended time series is smaller than during the solar cycle which causes the coefficients
;   of models developed from detrended time series to differ from those developed from non-detrended observations. To address this, total
;   solar irradiance observations are used to numerically determine ratios of coefficients obtained from multiple regression using direct observations,
;   with those obtained from multiple regression of detrended observations. Using a second model of TIM observations (using detrended observations),
;   the ratios of the coefficients for the two approaches are used to adjust the coefficients for spectral irradiance variations.
;   
;   For wavelengths > 295 nm, where both sunspots and faculae modulate spectral and total irradiance, 
;   the d coefficients, d_F and d_S are estimated as:
;   d_F(k) = d_F_detrend(k) * [b_F / b_F_detrend]
;   d_S(k) = d_S_detrend(k) * [b_S / b_S_detrend]
;   
;   For wavelengths < 295 nm, where faculae dominate irradiance variability (d_S(k) ~ 0), the adjustments for 
;   the coefficients are estimated using the Ca K time series, a facular index independent of Mg II index, and a proxy for UV
;   spectral irradiance variability.
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
;      Lean, J. L., T. N. Woods, F. G. Eparvier, R. R. Meier, D. J. Strickland, J. T. Correira, and J. S. Evans,
;      Solar Extreme Ultraviolet Irradiance: Present, Past, and Future, J. Geophys. Res., 116, A001102, 
;      doi:10.1029/2010JA015901, 2011.
;      
; INPUTS
;   ymd1       - starting time range respective to midnight GMT of the given day, of the form 'yyyy-mm-dd'
;   ymd2       - ending time range respective to midnight GMT of the given day (i.e. in NOT inclusive), of the form 'yyyy-mm-dd'.
;   output_dir - path to desired output directory. If left blank, the output files are placed in the current working directory. 
;
; OUTPUTS
;   outfiles - default titles of 'tsi_ver_rev_ymd1_ymd2_creation-date.sav' and 'ssi_ver_rev_ymd1_ymd2_creation-date'; using the 
;                time ranges specified on input, a specified "version" (ver) and "revision" (rev) number, and the 
;                creation_date (i.e. date when code was run).user provided output filename (default filename is 'nrl_tsi.nc') that contains a data structure of
;                
; AUTHOR
;   Odele Coddington, Laboratory for Atmospheric and Space Physics, Boulder, CO
;   Doug Lindholm, Laboratory for Atmospheric and Space Physics, Boulder, CO
;   Judith Lean, Space Science Division, Naval Research Laboratory, Washington, DC
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
;   01/14/2015 Initial Version prepared for NCDC
;
; USAGE
;   nrl2_to_irradiance, ymd1, ymd2,output_dir=output_dir
;
;@*****

function nrl2_to_irradiance, ymd1, ymd2, output_dir=output_dir, final=final, time_bin=time_bin

  data_list = process_irradiance(ymd1, ymd2, final=final, time_bin=time_bin)
  
  ;Convert data List to array
  data = data_list.toArray()




;--------

;TODO: much of this has been superceded by process_irradiance.
;This driver should delegate to it to get the 'data_list' then resume with file creation logic.

  algver = 'v02' ; get from function parameter?
  algrev = 'r00' ; for 'final' files;  get from function parameter?
  ;algrev = 'r00-preliminary' ; include '-preliminary' for operational, quarterly updates
 
  ;Creation date, used for output files (TO DO: change to form DDMMMYY, ex., 09Sep14, but saved under alternative variable name as .nc4 metadata requires this info as well in ISO 8601 form..) 
  creation_date = jd2iso_date(systime(/julian, /utc)) 
   
  ;Convert start and stop dates to Modified Julian Day Number (integer).
  mjd_start = iso_date2mjdn(ymd1)
  mjd_stop  = iso_date2mjdn(ymd2)
  
  ;Number of time samples (days)
  n = mjd_stop - mjd_start + 1
  
  ;Restore model parameters
  model_params = get_model_params()
  
  ;Set up wavelength bands for summing 1 nm spectrum
  spectral_bins = get_spectral_bins() 
  
  ;Get input data
  sunspot_blocking = get_sunspot_blocking(ymd1, ymd2, final=final, dev=dev) ;sunspot blocking/darkening data
  mg_index = get_mg_index(ymd1, ymd2, final=final) ;MgII index data - facular brightening
  
  ;Create a Hash for each input dataset mapping MJD (assumed to be integer, i.e. midnight) to the appropriate record.
  ;Note, Hash values will be arrays but should have only one element: the data record for that day.
  sunspot_blocking_by_day = group_by_tag(sunspot_blocking, 'MJDN')
  mg_index_by_day = group_by_tag(mg_index, 'MJD')

  ;Make list to accumulate results
  data_list = List()
  
  ;Iterate over days.
  ;TODO: consider passing complete arrays of data to these routines
  for i = 0, n-1 do begin
    mjd = mjd_start + i
    
    ;sb = sunspot_blocking[i].ssbt
    ;mg = mg_index[i].index
    sb = sunspot_blocking_by_day[mjd].ssbt
    mg = mg_index_by_day[mjd].index
    
    ;sanity check that we have one record per day
    if ((n_elements(sb) ne 1) or (n_elements(mg) ne 1)) then begin
      print, 'WARNING: Invalid input data for day ' + mjd2iso_date(mjd)
      continue  ;skip this day
    endif
    
    nrl2_tsi = compute_tsi(sb ,mg ,model_params) ;calculate TSI for given sb and mg
    ssi = compute_ssi(sb, mg, model_params) ;calculate SSI for given sb and mg (1 nm bands)
    nrl2_ssi = bin_ssi(model_params, spectral_bins, ssi) ; SSI on the binned wavelength grid
    
    iso_time = mjd2iso_date(mjd)
    
    ; TODO Add bandcenters and bandwidths and nband to data structure
    struct = {nrl2,                 $
      mjd:    mjd,                  $
      iso:    iso_time,             $
      tsi:    nrl2_tsi.totirrad,    $
      tsiunc: nrl2_tsi.totirradunc, $
      ssi:    nrl2_ssi.nrl2bin,     $
      ssiunc: nrl2_ssi.nrl2binunc,  $
      ssitot: nrl2_ssi.nrl2binsum   $
    }
    
    data_list.add, struct
  endfor
  

;----------

  
  ;Dynamically create output file names
  ;TO DO (replace daily, monthly, and annual keywords with time_bin? If so, would need to revise create_filenames.pro as well.
  names = create_filenames(ymd1,ymd2,creation_date,algver,algrev, final=final, dev=dev,  $
  daily=daily,monthly=monthly, annual=annual)

  ;Write the results to output in netCDF4 format; 
  ;To Do: include an output file directory
  ;TO Do: point to separate writers for the daily, monthly and annual average output
  result = write_tsi_model_to_netcdf2(ymd1,ymd2,creation_date,algver,algrev,data,names.tsi)
  result = write_ssi_model_to_netcdf2(ymd1,ymd2,creation_date,algver,algrev,data,spectral_bins,names.ssi)
  
  ;Dynamically determine file size (in bytes) and MD5 checksum and output to manifest file
  manifest=create_manifest(names.tsi,names.ssi)

  ;Write the manifest data to file
  result = write_to_manifest(names.tsi, manifest.tsibytes, manifest.tsichecksum, names.tsi_man)
  result = write_to_manifest(names.ssi, manifest.ssibytes, manifest.ssichecksum, names.ssi_man)
  
  return, data
end

