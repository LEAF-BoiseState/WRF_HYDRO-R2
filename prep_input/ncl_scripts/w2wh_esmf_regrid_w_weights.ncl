; ============================================================================== ;
;                                                                                ;
; FILE:    w2wh_esmf_regrid_w_weights.ncl                                        ;
;                                                                                ; 
; PURPOSE: Use weight file to regrid input from a source grid (WRF) to a         ;
;          a destination grid (WRF-Hydro).                                       ;
;                                                                                ;
; USAGE:   ncl 'srcGridFile="<src_grid_file>"' 'dstGridFile="<dst_grid_file>"' \ ; 
;              'wgtFileName="<weight_file>"'   'outputDir="<output_dir>"'      \ ;
;               w2wh_esmf_generate_weights.ncl                                   ;     
;                                                                                ;
;            where,                                                              ;
;                   <src_grid_file>  = [SRC] wrfout (WRF grid) file name         ;
;                   <dst_grid_file>  = [DST] geogrid (WRF-Hydro grid) file name  ;
;                   <weight_file>    = file w weights to convert WRF->WRF-Hydro  ;
;                   <output_dir>     = directory for output files                ;
;                                                                                ;
; Matt Masarik - May 20, 2019 (adapted from K. FitzGerald, see below)            ;
;                                                                                ;
; ============================================================================== ;
;                                                                                ;
; adapted from RAP2WRFHydro_regrid.ncl K. FitzGerald                             ;
;                                                                                ;
; Remarks:  (1) Assumes that wrfout files are hourly output. Important for       ;
;               computing rainrate.                                              ;
;       !!    (2) ESMF regridding performed with "conserve" option for           ;
;               precipitation and SWE. All other variables use bilinear option   ;
;               for remapping.                                                   ;
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
; user input
;;;srcGridFile          = "wrfout_d02_2010-06-02_01:00:00"
;;;dstGridFile          = "geo_em.d01.nc"
;;;wgtFileName          = wgtFileName_bilinear
;;;outputDir            = "./output_files" 


;;wgtFileName_bilinear = "./WRF2WRFHydro_weight_bilinear.nc"
;wgtFileName_conserve = "./RAP2WRFHydro_weight_conserve.nc"


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
HGT_varname     = "HGT"
  

;--------------------------------------------------------------------------------
; Read in source and destination grid netCDF files
;--------------------------------------------------------------------------------
src_file        = addfile(srcGridFile, "r")
dst_file        = addfile(dstGridFile, "r")
dlon2d          = dst_file->XLONG_M(0,:,:)
dlat2d          = dst_file->XLAT_M(0,:,:)
dims            = dimsizes(dlat2d)


;--------------------------------------------------------------------------------
; Open new output file for regridded data
;--------------------------------------------------------------------------------
outdir_exists = systemfunc("test -d "+outputDir+"; echo $?")
if      (outdir_exists .eq. 0) then
    system("echo")    
    print("Output directory: "+outputDir+", exists.")  
else if (outdir_exists .eq. 1) then
    system("echo")
    print("Output directory: "+outputDir+", does NOT exist.")  
    print("Making output directory: "+outputDir+".")
    system("mkdir -p "+outputDir)
end if
end if




; get output file name
srcName       = systemfunc("echo $(basename "+srcGridFile+")")
out_file      = outputDir + "/" + srcName
if (isfilepresent(out_file)) then
   system ("/bin/rm "+out_file)
end if

; create/open output file
ncout         = addfile(out_file,"c")
filedimdef(ncout, "Time", -1, True)
ncout->lat    = dlat2d   ;output lat
ncout->lon    = dlon2d   ;output lon


;--------------------------------------------------------------------------------
;  Processing...no further mods should be required...
;--------------------------------------------------------------------------------
do v=1,12
   if (v.eq.1) then
      var = src_file->$T_varname$
   end if
   if (v.eq.2) then
      var = src_file->$Q_varname$
   end if
   if (v.eq.3) then
      var = src_file->$U_varname$
   end if
   if (v.eq.4) then
      var = src_file->$V_varname$
   end if
   if (v.eq.5) then
      var = src_file->$P_varname$
   end if
   if (v.eq.6) then
      var = src_file->$PCP_varname$
   end if
   if (v.eq.7) then
      var = src_file->$PCP2_varname$
   end if
   if (v.eq.8) then
      var = src_file->$DSWR_varname$
   end if
   if (v.eq.9) then
      var = src_file->$DLWR_varname$
   end if
   if (v.eq.10) then
      var = src_file->$VEGFRA_varname$
   end if
   if (v.eq.11) then
      var = src_file->$LAI_varname$
   end if
   if (v.eq.12) then
      var = src_file->$HGT_varname$
   end if
   ;;printVarSummary(var)      


   ;-----------------------------------------------------------------------------
   ; Define new array for current variable
   ;-----------------------------------------------------------------------------
   ntimes = 1  ; for WRF, there is only one time step in each file
   loop_field_var = new((/ntimes(0), dims(0), dims(1)/),"double")
   ;;printVarSummary(loop_field_var)


   ;---Options to pass to ESMF_regrid--------------------------------------------
   Opt                = True
   Opt@WgtFileName    = wgtFileName
   Opt@CopyVarAtts    = True
   Opt@CopyVarCoords  = False
   ;;Opt@PrintTimings   = True        ; DEBUG
   ;;Opt@Debug          = True        ; DEBUG


   ;-----------------------------------------------------------------------------
   ; Check for weight file, then regrid current variable
   ;-----------------------------------------------------------------------------   
   wgt_exist          = isfilepresent(wgtFileName)
   if (.not. wgt_exist) then
       print(" ... no weight file.") 
       print("Run WRF2WRFHydro_generate_weights.ncl to generate weights.")
       exit
   end if

   ; The call
   loop_field_var     = ESMF_regrid_with_weights(var, wgtFileName, Opt)
   delete(Opt)


   ;---------------------------------------------------------------
   ; Export interpolated data to new forcing file...
   ;---------------------------------------------------------------
   ;--- change dimension names so that ncks command works appropriately ---;
   loop_field_var!0 = "Time"
   loop_field_var!1 = "south_north"
   loop_field_var!2 = "west_east"
   ;;printVarSummary(loop_field_var)
   if      (v.eq.1)  then
	  ncout->T2     = loop_field_var
   else if (v.eq.2)  then
	  ncout->Q2     = loop_field_var
   else if (v.eq.3)  then
	  ncout->U10    = loop_field_var
   else if (v.eq.4)  then
	  ncout->V10    = loop_field_var
   else if (v.eq.5)  then
	  ncout->PSFC   = loop_field_var
   else if (v.eq.6)  then
	  ncout->RAINC  = loop_field_var
   else if (v.eq.7)  then
	  ncout->RAINNC = loop_field_var
   else if (v.eq.8)  then
	  ncout->SWDOWN = loop_field_var
   else if (v.eq.9)  then
	  ncout->GLW    = loop_field_var
   else if (v.eq.10) then
	  ncout->VEGFRA = loop_field_var
   else if (v.eq.11) then
	  ncout->LAI    = loop_field_var
   else if (v.eq.12) then
	  ncout->HGT    = loop_field_var
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
   end if

   delete([/var, loop_field_var/])
end do 

; display location of regridded files
system("echo")
print("Regridded output written to directory: "+outputDir+".")   
system("echo")

end
