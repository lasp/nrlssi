;@***h* SOLAR_IRRADIANCE_FCDR/write_yearly_average_tsi_to_netcdf2.pro
; 
; NAME
;   write_yearly_average_tsi_to_netcdf2.pro
;
; PURPOSE
;   The write_yearly_average_tsi_to_netcdf2.pro function outputs yearly-averaged Total Solar Irradiance
;   to a netcdf4 file. This function is called from the routine, write_irradiance_data.pro.
;
; DESCRIPTION
;   The write_yearly_average_tsi_to_netcdf2.pro function outputs yearly-averaged Total Solar Irradiance
;   to a netcdf4 file and (midpoint) date (YYYY-MM) to a netcdf4 formatted file. 
;   The time format variables is seconds since a 1610-01-01 00:00:00 epoch
;   Missing values (NaN's or '0's) are defined as -99.0. 
;   
; INPUTS
;   ymd1  - starting time  (yyyy-mm-dd)
;   ymd2  - ending time  (yyyy-mm-dd)
;   ymd3  - creation date (yyyy-mm-dd)
;   version         - version and revision number of the NRLTSI2 model (e.g., v02r00)
;   irradiance_data - a structure containing the following variables
;     mjd    - Modified Julian Date
;     iso    - iso 8601 formatted time
;     tsi    - Modeled Total Solar Irradiance
;     tsiunc - Uncertainty in total solar irradiance
;     ssi    - Modeled Solar Spectral Irradiance (in wavelength bins)
;     ssitot - Integral of the Modeled Solar Spectral Irradiance
;   spectral_bins - a structure containing the following variables
;     nband       - number of spectral bands, for a variable wavelength grid, that the NRL2 model bins 1 nm solar spectral irradiance onto.
;     bandcenter  - the bandcenters (nm) of the variable wavelength grid.
;     bandwidth   - the bandwidths (delta wavelength, nm)  of the variable wavelength grid.
;   output_dir - Directory path for output file
;   file       - filename (dynamically created from write_irradiance_data.pro)
;      
; OUTPUTS
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
;   11/10/2014 Initial Version prepared for NCDC
; 
; USAGE
;   result=write_yearly_average_tsi_to_netcdf2(ymd1, ymd2, ymd3, version, irradiance_data, output_dir=output_dir, file)
;  
;@***** 
function write_yearly_average_tsi_to_netcdf2, ymd1, ymd2, ymd3, version, irradiance_data, output_dir=output_dir, file

  ;Extract data component
  data = irradiance_data.data

  ; Define missing value and replace NaNs in the modeled data with it.
  missing_value = -99.0
  tsi = replace_nan_with_value(data.tsi, missing_value)
  tsiunc = replace_nan_with_value(data.tsiunc, missing_value)
  day_zero_mjd = iso_date2mjdn('1610-01-01')
  dates = data.iso 
    
  ; Create NetCDF file for writing output
  id = NCDF_CREATE(output_dir+file, /NOCLOBBER, /netCDF4_format) ;noclobber = don't overwrite existing file
  ;TODO: handle error: NCDF_CREATE: Unable to create the file, /data/tmp/nrltsi.nc. (NC_ERROR=-35)
  src = 'NRLTSI2_'+version ;'creates the dynamic 'source' model version/revision for global attributes
  
  ; Global Attributes
  NCDF_ATTPUT, id, /GLOBAL, "Conventions", "CF-1.6",/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "Metadata_Conventions","CF-1.6, Unidata Dataset Discovery v1.0",/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "title", "Yearly Averaged TSI calculated using NRL2 solar irradiance model",/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "source", src,/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "institution", "Naval Research Laboratory Space Science Division and Laboratory for Atmospheric and Space Physics",/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "standard_name_vocabulary", "CF Standard Name Table v29",/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "id", file,/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "naming_authority", "gov.noaa.ncdc",/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "date_created",ymd3,/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "license","No constraints on data use.",/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "summary", "This dataset contains total irradiance as a function of time (yearly averaged) created with the Naval Research Laboratory model for spectral and total irradiance (version 2). Total solar irradiance is the total, spectrally integrated energy input to the top of the Earth’s atmosphere, at a standard distance of one Astronomical Unit from the Sun. Its units are W per m2. The dataset is created by Judith Lean (Space Science Division, Naval Research Laboratory), and Odele Coddington, Doug Lindholm, Peter Pilewskie, and Martin Snow (Laboratory for Atmospheric and Space Science, University of Colorado).",/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "keywords", "EARTH SCIENCE, ATMOSPHERE, ATMOSPHERIC RADIATION, INCOMING SOLAR RADIATION, SOLAR IRRADIANCE, SOLAR RADIATION, SOLAR FORCING, INSOLATION RECONSTRUCTION, SUN-EARTH INTERATIONS, CLIMATE INDICATORS, PALEOCLIMATE INDICATORS, SOLAR FLUX, SOLAR ENERGY, SOLAR ACTIVITY, SOLAR CYCLE",/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "keywords_vocabulary","NASA Global Change Master Directory (GCMD) Earth Science Keywords, Version 8.0",/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "cdm_data_type","Any",/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "time_coverage_start", ymd1,/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "time_coverage_end", ymd2,/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "cdr_program", "NOAA Climate Data Record Program",/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "cdr_variable", "TSI",/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "metadata_link", "http://doi.org/10.7289/V55B00C1",/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "product_version", version,/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "geospatial_lat_min","-90.0",/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "geospatial_lat_max"," 90.0",/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "geospatial_lon_min","-180.0",/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "geospatial_lon_max"," 180.0",/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "spatial_resolution", "N/A",/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "contributor_name", "Judith Lean, Peter Pilewskie, Odele Coddington",/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "contributor_role", "Principal Investigator and originator of total and spectral solar irradiance model, Principal Investigator ensuring overall integrity of the data product, Co-Investigator and Point-of-Contact and translated research-grade code to operational routine with FCDR output data being written out in NetCDF-4",/CHAR
  
  ; Define Dimensions
  tid = NCDF_DIMDEF(id, 'time', /UNLIMITED) ;time series
  bid = NCDF_DIMDEF(id, 'bounds', 2) ;time bounds dimension
  
  ; Variable Attributes
  x1id = NCDF_VARDEF(id, 'TSI', [tid], /FLOAT, CHUNK=1)
  NCDF_ATTPUT, id, x1id, 'long_name', 'NOAA Climate Data Record of Yearly Averaged Total Solar Irradiance (W m-2)',/CHAR
  NCDF_ATTPUT, id, x1id, 'standard_name', 'solar_irradiance',/CHAR
  NCDF_ATTPUT, id, x1id, 'units', 'W m-2',/CHAR
  NCDF_ATTPUT, id, x1id, 'cell_methods','time: mean',/CHAR
  NCDF_ATTPUT, id, x1id, 'ancillary_variables','TSI_UNC',/CHAR
  NCDF_ATTPUT, id, x1id, 'missing_value', missing_value
  
  x2id = NCDF_VARDEF(id, 'time', [tid], /FLOAT, CHUNK=1)
  NCDF_ATTPUT, id, x2id, 'units','days since 1610-01-01 00:00:00',/CHAR
  NCDF_ATTPUT, id, x2id, 'standard_name','time',/CHAR
  NCDF_ATTPUT, id, x2id, 'axis','T',/CHAR
  NCDF_ATTPUT, id, x2id, 'bounds', 'time_bnds',/CHAR
  
  x3id = NCDF_VARDEF(id, 'time_bnds', [bid,tid], /FLOAT) 
  NCDF_ATTPUT, id, x3id, 'long_name', 'Minimum (inclusive) and maximum (exclusive) dates included in the time averaging',/CHAR
  NCDF_ATTPUT, id, x3id, 'units', 'days since 1610-01-01 00:00:00',/CHAR
  
  x4id = NCDF_VARDEF(id,'TSI_UNC',[tid],/FLOAT, CHUNK=1)
  NCDF_ATTPUT, id, x4id, 'long_name','Uncertainty in Yearly-Averaged Total Solar Irradiance (W m-2)',/CHAR
  NCDF_ATTPUT, id, x4id, 'units', 'W m-2',/CHAR
  NCDF_ATTPUT, id, x4id, 'missing_value',missing_value 
  
  ; Put file in data mode:
  NCDF_CONTROL, id, /ENDEF
  
  ; Input data:
  NCDF_VARPUT, id, x2id, data.mjd - day_zero_mjd
  NCDF_VARPUT, id, x1id, tsi
  NCDF_VARPUT, id, x4id, tsiunc
  
  ;Define the bounds for each time bin.
  time_bounds = get_yearly_time_bounds(data.mjd)
  NCDF_VARPUT, id, x3id, time_bounds - day_zero_mjd
  
  ; Close the NetCDF file.
  NCDF_CLOSE, id 
  
  ;TODO: error status
  return, 0
end
