pro compare_lasp_nrl_nrlssi2

time_bin = 'yearly' ;CHANGE

if time_bin eq 'daily' then begin 
  nrl_ssi = '/Users/hofmann/Downloads/NRLSSI2_1882_1909d_6Apr15.txt'
  ;nrl_ssi = '/Users/hofmann/Downloads/NRLSSI2_1910_1949d_6Apr15.txt'
  ;nrl_ssi = '/Users/hofmann/Downloads/NRLSSI2_1950_1977d_6Apr15.txt'
  ;nrl_ssi = '/Users/hofmann/Downloads/NRLSSI2_1978_2014d_6Apr15.txt'
  startyear=1882 ;CHANGE to match time frame in daily files
  endyear = 1909 ;CHANGE to match time frame in daily files
  jud = read_nrl_nrlssi2d(nrl_ssi,startyear,endyear) ;read Judith's MEGA files, 1978-2014
endif
if time_bin eq 'monthly' then begin
  ;nrl_ssi = '/Users/hofmann/Downloads/NRLSSI2_1882_1959m_6Apr15.txt' 
  nrl_ssi = '/Users/hofmann/Downloads/NRLSSI2_1960_2014m_6Apr15.txt'
  startyear=1960 ;CHANGE to match time frame in monthly files (ALSO NEED TO SUBSET DATA in lines 45-49)
  endyear = 2014 ;CHANGE to match time frame in monthly files (ALSO NEED TO SUBSET DATA in lines 45-49)
  jud = read_nrl_nrlssi2m(nrl_ssi,startyear,endyear) ;read Judith's MEGA files, 1978-2014
endif
if time_bin eq 'yearly' then begin
  nrl_ssi = '/Users/hofmann/Downloads/NRLSSI2_1882_2014a_6Apr15.txt' 
  startyear=1882 
  endyear = 2014 
  jud = read_nrl_nrlssi2a(nrl_ssi,startyear,endyear) ;read Judith's MEGA files, 1978-2014
endif

 
;judith data
judssi = jud.spec
judtsi = jud.tsi
judtotssi = jud.totspec
jwavelength=jud.wl[*,0]
jbandwidth=jud.wl[*,1]
k=n_elements(judssi[0,*]) ;elements in time series

if time_bin eq 'yearly' then ik = k ;number of elements in time series
if time_bin eq 'monthly' then ik = k / 12. ;number of elements in time series in units of months
if time_bin eq 'daily' then ik = 12. ;only 12 years on my computer
lasp_ssi = judssi
lasp_tsi = judtsi
lasp_date = judtsi

year = startyear
ix = 0
for i=0,ik-1 do begin  
  if time_bin eq 'monthly' then begin
    ym1 = strtrim(string(year),2)+'01'
    ym2 = strtrim(string(year),2)+'12'
    file = '/Users/hofmann/NRL2_OUTPUT/ssi_v02r00_monthly_s'+ym1+'_e'+ym2+'_c20150730.nc'
  endif
  if time_bin eq 'daily' then begin
    ym1 = strtrim(string(year),2)+'0101'
    ym2 = strtrim(string(year),2)+'1231'
    file = '/Users/hofmann/NRL2_OUTPUT/ssi_v02r00_daily_s'+ym1+'_e'+ym2+'_c20150422.nc'
  endif
  cdfid = ncdf_open(file,/nowrite)
  ivaridt = ncdf_varid(cdfid,'SSI')
  ncdf_varget,cdfid,ivaridt,laspssi
  ivaridt = ncdf_varid(cdfid,'time')
  ncdf_varget,cdfid,ivaridt,laspdate
  day_zero_mjd = iso_date2mjdn('1610-01-01')
  laspdate = laspdate + day_zero_mjd
  laspdate_jd = mjd2jd(laspdate)
  laspdate = jd2yf4(mjd2jd(laspdate))
  ivaridt=ncdf_varid(cdfid,'wavelength')
  ncdf_varget,cdfid,ivaridt,wavelength
  ivaridt=ncdf_varid(cdfid,'Wavelength_Band_Width')
  ncdf_varget,cdfid,ivaridt,bandwidth
  ivaridt=ncdf_varid(cdfid,'TSI')
  ncdf_varget,cdfid,ivaridt,lasptsi
  ivaridt=ncdf_varid(cdfid,'TSI_UNC')
  ncdf_varget,cdfid,ivaridt,lasptsi_unc
  ivaridt=ncdf_varid(cdfid,'time_bnds')
  ncdf_varget,cdfid,ivaridt,time_bnds

  iy = ix + n_elements(lasptsi)
  ;build arrays to increment
  lasp_tsi[ix:iy-1] = lasptsi
  lasp_ssi[*,ix:iy-1] = laspssi
  lasp_date[ix:iy-1] = laspdate
  
  ix = iy ;increment subelement counter for array
  year = year+1 ;increment year
endfor

;Bin SSI for comparisons
wav1a = 200 & wav1b = 210
wav2a = 300 & wav2b = 400
wav3a = 700 & wav3b = 1000
wav4a = 1000 & wav4b = 1300

;Judith binned results
jbin_ssi_1 = dblarr(k) ;200-210 nm
jbin_ssi_2 = dblarr(k) ;300-400 nm
jbin_ssi_3 = dblarr(k) ;700-1000 nm
jbin_ssi_4 = dblarr(k) ;1000-1300 nm

;LASP Binned results
lbin_ssi_1 = dblarr(k) ;200-210 nm  
lbin_ssi_2 = dblarr(k) ;300-400 nm
lbin_ssi_3 = dblarr(k) ;700-1000 nm
lbin_ssi_4 = dblarr(k) ;1000-1300 nm

bin_ssi_1_unc = dblarr(k)
bin_ssi_2_unc = dblarr(k)
bin_ssi_3_unc = dblarr(k)
bin_ssi_4_unc = dblarr(k)

bin_1 =where((jwavelength ge wav1a) and (jwavelength lt wav1b),cntwav)
bin_2 = where((jwavelength ge wav2a) and (jwavelength lt wav2b),cntwav)
bin_3 = where((jwavelength ge wav3a) and (jwavelength lt wav3b),cntwav)
bin_4 = where((jwavelength ge wav4a) and (jwavelength lt wav4b),cntwav)

for j=0, k-1 do begin
 jbin_ssi_1[j] = total(judssi[bin_1,j]*jbandwidth(bin_1),/double)
 jbin_ssi_2[j] = total(judssi[bin_2,j]*jbandwidth(bin_2),/double)
 jbin_ssi_3[j] = total(judssi[bin_3,j]*jbandwidth(bin_3),/double)
 jbin_ssi_4[j] = total(judssi[bin_4,j]*jbandwidth(bin_4),/double)

 lbin_ssi_1[j] = total(lasp_ssi[bin_1,j]*jbandwidth(bin_1),/double)
 lbin_ssi_2[j] = total(lasp_ssi[bin_2,j]*jbandwidth(bin_2),/double)
 lbin_ssi_3[j] = total(lasp_ssi[bin_3,j]*jbandwidth(bin_3),/double)
 lbin_ssi_4[j] = total(lasp_ssi[bin_4,j]*jbandwidth(bin_4),/double)
endfor

;PLOTS
p=plot(lasp_date[0:k-1],(1-(jbin_ssi_1/lbin_ssi_1))*100,layout=[1,4,1],title='Percent Difference in SSI: 200-210 nm',font_size=10)
p1=plot(lasp_date[0:k-1],(1-(jbin_ssi_2/lbin_ssi_2))*100,layout=[1,4,2],title='Percent Difference in SSI: 300-400 nm',/current,font_size=10)
p1=plot(lasp_date[0:k-1],(1-(jbin_ssi_3/lbin_ssi_3))*100,layout=[1,4,3],title='Percent Difference in SSI: 700-1000 nm',/current,font_size=10)
p1=plot(lasp_date[0:k-1],(1-(jbin_ssi_4/lbin_ssi_4))*100,layout=[1,4,4],title='Percent Difference in SSI: 1000-1300 nm',/current,font_size=10)

p=plot(lasp_date,(1-(judtsi[0:k-1]/lasp_tsi))*100,title='Percent Difference in TSI',font_size=10)

end ; pro