; ============================================================================== ;
;                                                                                ;
; FILE:    w2wh_esmf_regrid_w_weights.ncl                                        ;
; PURPOSE: Use weight file to regrid input from a source grid (WRF) to a         ;
;          a destination grid (WRF-Hydro).
; USAGE:   ncl w2wh_esmf_generate_weights.ncl <src_grid_file> <dest_grid_file>   ;
;                                                                                ;
; Matt Masarik - May 20, 2019 (See below for original documentation)             ;
;                                                                                ;
; ============================================================================== ;
;                                                                                ;
; adapted from RAP2WRFHydro_regrid.ncl K. FitzGerald                             ;
;                                                                                ;
; Remarks:  (1) Assumes that wrfout files are hourly output. Important for       ;
;               computing rainrate.                                              ;
;           (2) ESMF regridding performed with "conserve" option for             ;
;               precipitation and SWE. All other variables use bilinear option   ;
;               for remapping.                                                   ;
;                                                                                ;
; Usage: ncl 'RUNNAME="BASELINE"' 'wrf_domain_name="d03"' \                      ;
;            'srcfilename="wrfout_d03*"'                  \                      ;
;            WRF_HYDRO_sub_domain_forcing_regridder_ESMFregrid.ncl               ;
;                                                                                ;
; *  RUNNAME = name of wrf run.  This is used for the input path and the         ;
;              weight filename.                                                  ;
; *  wrf_domain_name = domain name (d01, d02, d03) which is used to identify     ;
;                      the weight file.                                          ;
; *  srcfilename = filename pattern of the souce wrfout files. Should have       ;
;                  matching domain number.                                       ;
;                  e.g., "wrfout_d01_2007-09-01_00_00_00.nc",                    ;
;                        "wrfout_d01_2007*.nc",                                  ;
;                        "wrfout_d01_2007-09-0[1-3].nc"                          ;
;                                                                                ;
;--------------------------------------------------------------------------------;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/ut_string.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"


begin
;--------------------------------------------------------------------------------
; Parameters
;--------------------------------------------------------------------------------
srcGridFile     = "wrfout_d02_2010-06-02_01:00:00"
dstGridFile     = "geo_em.d01.nc"
out_file         = ""


;--------------------------------------------------------------------------------
; Weight filenames for regridding                               
;--------------------------------------------------------------------------------
;wgtFileName_conserve = "./RAP2WRFHydro_weight_conserve.nc"
wgtFileName_bilinear = "./WRF2WRFHydro_weight_bilinear.nc"


;--------------------------------------------------------------------------------
; Data field names from the source (WRF) file to be regridded          
;--------------------------------------------------------------------------------
P_varname       = "PSFC"
T_varname       = "T2"
U_varname       = "U10"
V_varname       = "V10"
Q_varname       = "Q2"
PCP_varname     = "RAINC"
PCP2_varname    = "RAINNC"
DSWR_varname    = "SWDOWN"
DLWR_varname    = "GLW"
VEGFRA_varname  = "VEGFRA"
LAI_varname     = "LAI"
  

;--------------------------------------------------------------------------------
; Read in source and destination grid netCDF files
;--------------------------------------------------------------------------------
src_file        = addfile(srcGridFile, "r")
dst_file        = addfile(dstGridFile, "r")
dlon2d          = dst_file->XLONG_M(0,:,:)
dlat2d          = dst_file->XLAT_M(0,:,:)
dims            = dimsizes(dlat2d)


;--------------------------------------------------------------------------------
; Open source data files to be regridded...
;--------------------------------------------------------------------------------
out_dir         = "./output_files" 
if(.not. isfilepresent(out_dir)) then
   system("mkdir "+out_dir)
end if
    
out_file        = out_dir + "/" + srcGridFile +".nc"
if (isfilepresent(out_file)) then
   system ("/bin/rm "+out_file)
end if

ncdf            = addfile(out_file,"c")
print(ncdf)
filedimdef(ncdf, "Time", -1, True)
ncdf->lat = dlat2d   ;output lat
ncdf->lon = dlon2d   ;output lon


;--------------------------------------------------------------------------------
;  Processing...no further mods should be required...
;--------------------------------------------------------------------------------
do v=1,11
   if (v.eq.1) then
      var = datfile->$T_varname$
      wgtFileName = wgtFileName_bilinear
   end if
   if (v.eq.2) then
      var = datfile->$Q_varname$
      wgtFileName = wgtFileName_bilinear
   end if
   if (v.eq.3) then
      var = datfile->$U_varname$
      wgtFileName = wgtFileName_bilinear
   end if
   if (v.eq.4) then
      var = datfile->$V_varname$
      wgtFileName = wgtFileName_bilinear
   end if
   if (v.eq.5) then
      var = datfile->$P_varname$
      wgtFileName = wgtFileName_bilinear
   end if
   if (v.eq.6) then
      var = datfile->$PCP_varname$
      wgtFileName = wgtFileName_bilinear 
   end if
   if (v.eq.7) then
      var = datfile->$PCP2_varname$
      wgtFileName = wgtFileName_bilinear 
   end if
   if (v.eq.8) then
      var = datfile->$DSWR_varname$
      wgtFileName = wgtFileName_bilinear
   end if
   if (v.eq.9) then
      var = datfile->$DLWR_varname$
      wgtFileName = wgtFileName_bilinear
   end if
   if (v.eq.10) then
      var = datfile->$VEGFRA_varname$
      wgtFileName = wgtFileName_bilinear
   end if
   if (v.eq.11) then
      var = datfile->$LAI_varname$
      wgtFileName = wgtFileName_bilinear
   end if
   printVarSummary(var)      


   ;-----------------------------------------------------------------------------
   ; Define new array for current variable
   ;-----------------------------------------------------------------------------
   ntimes = 1  ; for WRF, there is only one time step in each file
   loop_field_var = new((/ntimes(0), dims(0), dims(1)/),"double")
   printVarSummary(loop_field_var)


   ;---Options to pass to ESMF_regrid--------------------------------------------
   Opt                = True
   Opt@WgtFileName    = wgtFileName
   Opt@CopyVarAtts    = True
   Opt@CopyVarCoords  = False
   Opt@PrintTimings   = True ;---Debug information
   Opt@Debug          = True ;---Debug information


   ;-----------------------------------------------------------------------------
   ; Check for weight file, then regrid current variable
   ;-----------------------------------------------------------------------------   
   wgt_exist          = isfilepresent(wgtFileName)
   if (.not. wgt_exist) then
       print(" ... no weight file.") 
       print("Run WRF2WRFHydro_generate_weights.ncl to generate weights.")
       exit
   end if

   loop_field_var     = ESMF_regrid_with_weights(var, wgtFileName, Opt)
   delete(Opt)


   ;---------------------------------------------------------------
   ; Export interpolated data to new forcing file...
   ;---------------------------------------------------------------
   ;--- change dimension names so that ncks command works appropriately ---;
   loop_field_var!0 = "Time"
   loop_field_var!1 = "south_north"
   loop_field_var!2 = "west_east"
   printVarSummary(loop_field_var)
   if      (v.eq.1)  then
	  ncdf->T2     = loop_field_var
   else if (v.eq.2)  then
	  ncdf->Q2     = loop_field_var
   else if (v.eq.3)  then
	  ncdf->U10    = loop_field_var
   else if (v.eq.4)  then
	  ncdf->V10    = loop_field_var
   else if (v.eq.5)  then
	  ncdf->PSFC   = loop_field_var
   else if (v.eq.6)  then
	  ncdf->RAINC  = loop_field_var
   else if (v.eq.7)  then
	  ncdf->RAINNC = loop_field_var
   else if (v.eq.8)  then
	  ncdf->SWDOWN = loop_field_var
   else if (v.eq.9)  then
	  ncdf->GLW    = loop_field_var
   else if (v.eq.10) then
	  ncdf->VEGFRA = loop_field_var
   else if (v.eq.11) then
	  ncdf->LAI    = loop_field_var
   end if
   end if
   end if
   end if
   end if
   end if
   end if
   end if
   end if
   end if
   end if

   delete([/var, loop_field_var, wgtFileName/])
end do 
   


end
