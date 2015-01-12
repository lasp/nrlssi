;@***h* SOLAR_IRRADIANCE_FCDR/write_tsi_model_to_netcdf.pro
; 
; NAME
;   write_tsi_model_to_netcdf.pro
;
; PURPOSE
;   The write_tsi_model_to_netcdf.pro function writes the date and Model Total Solar Irradiance
;   to a netcdf4 file. This function is called from the main routine, nrl2_2_irradiance.pro.
;
; DESCRIPTION
;   The write_tsi_model_to_netcdf.pro function writes the Model Total Solar Irradiance, year, day of year, and cumulative day number 
;   to a netcdf4 formatted file. CF-1.5 metadata conventions are used in defining global and variable name attributes. 
;   Missing values (NaN's or '0's) are defined as -99.0. TODO: check: do we have NaN output still?
;   This function is called from the main routine, nrl2_2_irradiance.pro.
; 
; INPUTS
;   ymd1  - starting time  (yyyy-mm-dd)
;   ymd2  - ending time  (yyyy-mm-dd)
;   mjd   - time period (in Modified Julian Day format)
;   data  - Modeled Total Solar Irradiance
;   file  - name for output file. The default file naming convention is tsi_YMD1_YMD2_VER.nc 
;           
;           ; UPDATE: Include "creation date in file naming convention"
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
;   09/08/2014 Initial Version prepared for NCDC
; 
; USAGE
;   write_tsi_model_to_netcdf, ymd1, ymd2, ymd3, algver, algrev, data, file
;  
;@***** 
function write_tsi_model_to_netcdf2, ymd1, ymd2, ymd3, algver,algrev, data, file

  ; Define missing value and replace NaNs in the modeled data with it.
  ;if (n_elements(missing_value) eq 0) then missing_value = -99.0
  missing_value = -99.0
  tsi = replace_nan_with_value(data.tsi, missing_value)
  dates =  data.iso 
  
  ; Create NetCDF file for writing output
  id = NCDF_CREATE(file, /NOCLOBBER, /netCDF4_format) ;noclobber = don't overwrite existing file
  ;TODO: handle error: NCDF_CREATE: Unable to create the file, /data/tmp/nrltsi.nc. (NC_ERROR=-35)
  
  ; Global Attributes
  NCDF_ATTPUT, id, /GLOBAL, "Conventions", "CF-1.6"
  NCDF_ATTPUT, id, /GLOBAL, "Metadata_Conventions","CF-1.6, Unidata Dataset Discovery v1.0"
  NCDF_ATTPUT, id, /GLOBAL, "title", "Daily TSI calculated using NRL2 solar irradiance model"
  NCDF_ATTPUT, id, /GLOBAL, "source", "nrl2_to_irradiance.pro"
  NCDF_ATTPUT, id, /GLOBAL, "institution", "Naval Research Laboratory Space Science Division and Laboratory for Atmospheric and Space Physics"
  NCDF_ATTPUT, id, /GLOBAL, "standard_name_vocabularly", "CD Standard Name Table v27"
  NCDF_ATTPUT, id, /GLOBAL, "id", file
  NCDF_ATTPUT, id, /GLOBAL, "naming_authority", "gov.noaa.ncdc"
  NCDF_ATTPUT, id, /GLOBAL, "date_created",ymd3
  NCDF_ATTPUT, id, /GLOBAL, "license","No constraints on data use."
  NCDF_ATTPUT, id, /GLOBAL, "summary", "This dataset contains total irradiance as a function of time created with the Naval Research Laboratory model for spectral and total irradiance (version 2). Total solar irradiance is the total, spectrally integrated energy input to the top of the Earth’s atmosphere, at a standard distance of one Astronomical Unit from the Sun. Its units are W per m2. The dataset is created by Judith Lean (Space Science Division, Naval Research Laboratory), Odele Coddington and Peter Pilewskie (Laboratory for Atmospheric and Space Science, University of Colorado).
  NCDF_ATTPUT, id, /GLOBAL, "keywords", "EARTH SCIENCE &gt; ATMOSPHERE &gt; ATMOSPHERIC RADIATION &gt; INCOMING SOLAR RADIATION, EARTH SCIENCE &gt; ATMOSPHERE &gt; ATMOSPHERIC RADIATION &gt; SOLAR IRRADIANCE, EARTH SCIENCE &gt; ATMOSPHERE &gt; ATMOSPHERIC RADIATION &gt; SOLAR RADIATION, EARTH SCIENCE &gt; SUN-EARTH INTERACTIONS &gt; SOLAR ACTIVITY &gt; SOLAR IRRADIANCE, EARTH SCIENCE &gt; PALEOCLIMATE &gt; PALEOCLIMATE RECONSTRUCTIONS &gt; SOLAR FORCING/INSOLATION RECONSTRUCTION, EARTH SCIENCE &gt; SUN-EARTH INTERACTIONS &gt; SOLAR ACTIVITY &gt; SOLAR IRRADIANCE, EARTH SCIENCE &gt; CLIMATE INDICATORS &gt; SUN-EARTH INTERACTIONS &gt; SUNSPOT ACTIVITY &gt; SOLAR FLUX, EARTH SCIENCE &gt; CLIMATE INDICATORS &gt; PALEOCLIMATE INDICATORS &gt; PALEOCLIMATE RECONSTRUCTIONS &gt; SOLAR FORCING/INSOLATION RECONSTRUCTION, EARTH SCIENCE &gt; CLIMATE INDICATORS &gt; SUN-EARTH INTERACTIONS &gt; SUNSPOT ACTIVITY &gt; SOLAR FLUX";
  NCDF_ATTPUT, id, /GLOBAL, "keywords_vocabularly","NASA Global Change Master Directory (GCMD) Earth Science Keywords, Version 8.0"
  NCDF_ATTPUT, id, /GLOBAL, "cdm_data_type","Point"
  NCDF_ATTPUT, id, /GLOBAL, "time_coverage_start", ymd1
  NCDF_ATTPUT, id, /GLOBAL, "time_coverage_end", ymd2
  NCDF_ATTPUT, id, /GLOBAL, "cdr_program", "NOAA Climate Data Record Program"
  NCDF_ATTPUT, id, /GLOBAL, "cdr_variable", "total solar irradiance"
  NCDF_ATTPUT, id, /GLOBAL, "metadata_link", "gov.noaa.ncdc:C00828"
  NCDF_ATTPUT, id, /GLOBAL, "product_version", algver+algrev
  NCDF_ATTPUT, id, /GLOBAL, "platform", "SORCE, TSIS"
  NCDF_ATTPUT, id, /GLOBAL, "instrument", "Total Irradiance Monitor (TIM)"
  NCDF_ATTPUT, id, /GLOBAL, "geospatial_lat_min","-90.0"
  NCDF_ATTPUT, id, /GLOBAL, "geospatial_lat_max"," 90.0"
  NCDF_ATTPUT, id, /GLOBAL, "geospatial_lon_min","-180.0"
  NCDF_ATTPUT, id, /GLOBAL, "geospatial_lon_max"," 180.0"
  NCDF_ATTPUT, id, /GLOBAL, "spatial_resolution", "N/A"
  NCDF_ATTPUT, id, /GLOBAL, "contributor_name", "Judith Lean, Peter Pilewskie, Odele Coddington"
  NCDF_ATTPUT, id, /GLOBAL, "contributor_role", "Principal Investigator and originator of total and spectral solar irradiance model, Principal Investigator ensuring overall integrity of the data product, Co-Investigator and Point-of-Contact and translated research-grade code to operational routine with FCDR output data being written out in NetCDF-4"
  
  ; Define Dimensions
  tid = NCDF_DIMDEF(id, 'time', n_elements(dates)) ;time series
  
  ; Variable Attributes
  x1id = NCDF_VARDEF(id, 'TSI', [tid], /FLOAT)
  NCDF_ATTPUT, id, x1id, 'long_name', 'NOAA Fundamental Climate Data Record of Daily Total Solar Irradiance (Watt/ m**2)'
  NCDF_ATTPUT, id, x1id, 'standard_name', 'toa_incoming_shortwave_flux'
  NCDF_ATTPUT, id, x1id, 'units', 'W m-2'
  NCDF_ATTPUT, id, x1id, 'missing_value', missing_value
  
  x2id = NCDF_VARDEF(id, 'iso_time', [tid], /STRING)
  NCDF_ATTPUT, id, x2id, 'long_name', 'ISO8601 date/time (YYYY-MM-DD) string'

  x3id = NCDF_VARDEF(id,'time',[tid],/FLOAT) ;Fix!                                                                                               
  NCDF_ATTPUT, id, x3id, 'long_name','days since 1858-11-17 00:00:00.0' ;for MJD
  NCDF_ATTPUT, id, x2id, 'standard_name','time'

  
  ; Put file in data mode:
  NCDF_CONTROL, id, /ENDEF
  
  ; Input data:
  NCDF_VARPUT, id, x2id, dates ;YYYY-MM-DD; ISO 8601 standards
  NCDF_VARPUT, id, x3id, data.mjd ;CF-compliant time variable
  NCDF_VARPUT, id, x1id, tsi
  
  ; Close the NetCDF file.
  NCDF_CLOSE, id 
  
  ;TODO: error status
  return, 0
end
