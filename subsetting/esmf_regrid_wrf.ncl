;----------------------------------------------------------------------
; ESMF_regrid_with_weights_template.ncl
;
; This is a template file for use with ESMF regridding. This is the
; template that uses the "ESMF_regrid_with_weights" function to do the 
; regridding. It assumes that you already have a weights file,
; possibly created from a previous call to ESMF_regrid.
;
;----------------------------------------------------------------------
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin
    srcFileName = "/scratch/mmasarik/wrfout_d02_2010-06-02_00:00:00.nc"         ; File that has data to be regridded
    wgtFileName = "/home/mmasarik/LEAF/WRF_HYDRO-R2/upper_boise/DOMAIN/spatialweights.nc"     ; File with interpolation weights

;---Open the source data file and get some data to regrid
    sfile = addfile(srcFileName,"r")
    t2     = sfile->T2            ; You may need to subscript this.

    Opt = True  
    t2_regrid = ESMF_regrid_with_weights(t2,wgtFileName,Opt)
    printVarSummary(t2_regrid)

;----------------------------------------------------------------------
;     Plot the original and regridded data.
;----------------------------------------------------------------------
;     wks = gsn_open_wks("ps","ESMF")             ; ESMF.ps

;     res                     = True              ; Plot mods desired.
;     res@gsnDraw             = False             ; We will panel later.
;     res@gsnFrame            = False

;     res@gsnMaximize         = True              ; Maximize plot
    
;     res@mpMaxLatF           =   90              ; Set accordingly
;     res@mpMinLatF           =  -90
;     res@mpMinLonF           = -180
;     res@mpMaxLonF           =  180

;     res@cnFillOn            = True              ; color plot desired
;     res@cnLinesOn           = False             ; turn off contour lines
;     res@cnLineLabelsOn      = False             ; turn off contour lines

; ;;--Change (maybe)
;     mnmxint = nice_mnmxintvl( min(var), max(var), 18, False)
;     res@cnLevelSelectionMode = "ManualLevels"
;     res@cnMinLevelValF       = mnmxint(0)
;     res@cnMaxLevelValF       = mnmxint(1)
;     res@cnLevelSpacingF      = mnmxint(2)

;     res@lbLabelBarOn        = False              ; Labelbar will be in panel

; ;---Plot data on original grid
;     res@gsnAddCyclic = False                     ; if regional
;     res@tiMainString = "Original data"

;     plot_orig = gsn_csm_contour_map(wks,x,res)     

; ;---Plot data on new grid
;     res@gsnAddCyclic = True                      ; if cyclic point needed
;     res@tiMainString = "Regridded data"

;     plot_regrid = gsn_csm_contour_map(wks,x_regrid,res)     

; ;---Resources for paneling
;     pres                  = True
;     pres@gsnMaximize      = True
;     pres@gsnPanelLabelBar = True

;     gsn_panel(wks,(/plot_orig,plot_regrid/),(/2,1/),pres)
end
