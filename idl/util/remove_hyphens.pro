;@***h* SOLAR_IRRADIANCE_FCDR/remove_hyphens.pro
; 
; NAME
;   remove_hypens
;
; PURPOSE
;   Removes hyphens from the ISO 8601 date standard 'YYYY-MM-DD' to create 'YYYYMMDD' format
;
; DESCRIPTION
;   Removes hyphens in the ISO 8601 time standard. 
;   Used for formatting ISO 8601 time for dynamic filename creation. 
;   
; INPUTS
;   string - a value for time in ISO format ('yyyy-mm-dd')
;   
; OUTPUTS
;   result - ISO format without hyphens
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
;   06/04/2015 Initial Version prepared for NCDC
; 
; USAGE
;   result=remove_hyphens(string)
;
;@***** 
function remove_hyphens, string
;For example, convert a date of the form 'yyyy-mm-dd' to 'yyyymmdd'.

  result = strjoin(strsplit(string,"-", /extract))
  
  return, result
  
end