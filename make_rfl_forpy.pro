pro make_rfl_forpy

  ; Producing a version of the RHESSI flare list, updated with LHH info, to work easily in python
  ;
  ; The full list is here:
  ; https://hesperia.gsfc.nasa.gov/hessidata/dbase/hessi_flare_list.txt
  ; Containing 121,180 events
  ;
  ; Loumou et al. 2018 (LHH) paper https://doi.org/10.1051/0004-6361/201731050
  ; Only does 12-Feb-2002 to 23-Feb-2016 which over that period the full list gives 117,427 flares
  ; This restricted list (non-imagable, anomalous positions and GOES BS flux > 1e-8) gives 73,711 flares.
  ;
  ; So, want to output full flare list of the 121,180 events, saving out select info and highlight LHH events
  ;
  ; 09-Nov-2020
  ;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ; Get the full list to begin with
  fl=hsi_flare_list(obs_time_interval=['12-Feb-2002 00:00','04-Mar-2018 00:00'])
  fdata=fl->getdata()
  ;  How many flares?
  nf=n_elements(fdata.id_number)
  print,nf
  ;      121206
  ; Which is slightly more than at the above url !!! (121,180 vs 121,206)
  ;
  ;IDL> print,n_elements(where(fdata.sflag1 eq 1))
  ;115636
  ;   So these are the "solar events"

  ;flag_ids = string identifiers for each data flag, e.g.,
  ; http://sprg.ssl.berkeley.edu/~jimm/hessi/hsi_flare_list.html
  ;fids = [0'SAA_AT_START', 1'SAA_AT_END', 2'SAA_DURING_FLARE', $ 3'ECLIPSE_AT_START', 4'ECLIPSE_AT_END', $ 5'ECLIPSE_DURING_FLARE', $
  ; 6'FLARE_AT_SOF', 7'FLARE_AT_EOF', 8'NON_SOLAR', $ 9'FAST_RATE_MODE', 10'FRONT_DECIMATION', 11'ATT_STATE_AT_PEAK', $
  ; 12'DATA_GAP_AT_START', 13'DATA_GAP_AT_END', $ 14'DATA_GAP_DURING_FLARE', $ 15'PARTICLE_EVENT', 16'DATA_QUALITY', $
  ; 17'POSITION_QUALITY', 18'ATTEN_0', 19'ATTEN_1', $ 20'ATTEN_2', 21'ATTEN_3', 22'REAR_DECIMATION', $
  ; 23'MAGNETIC_REGION', 24'IMAGE_STATUS', 25'SPECTRUM_STATUS', $ 26'SOLAR_UNCONFIRMED', 27'SOLAR'].

  ;IDL> print,n_elements(where(fdata.flags[27] eq 1))
  ;115636
  ; Double check the solar flag matches sflag1

  ; Some useful things to save out
  id_num=fdata.id_number
  ;   Helioprojective in arcsec from sun centre
  x=fdata.position[0]
  y=fdata.position[1]
  ptim=anytim(fdata.peak_time,/ccsds)
  stim=anytim(fdata.start_time,/ccsds)
  etim=anytim(fdata.end_time,/ccsds)

  ; Also useful to have the positions in Stonyhurst lat and lon degrees
  lonlat=dblarr(2,nf)
  for i=0l, nf-1 do lonlat[*,i]=xy2lonlat(fdata[i].position,fdata[i].peak_time,/quiet)
  lat=lonlat[1,*]
  lng=lonlat[0,*]

  ; Energy range could image and get flare position (start of energy range)
  enghi=round(fdata.energy_hi[0])
  ; Was this a shutter out flare (i.e. a RHESSI microflare?)
  att_in=total(fdata.flags[19:21],1)
  a0_id=where(att_in ne 1)
  a0only=bytarr(nf)
  a0only[a0_id]=1

  ;  Was something happening during the flare?
  sflag1=fdata.sflag1
  saa=total(fdata.flags[0:2],1)
  ecl=total(fdata.flags[3:5],1)
  dgp=total(fdata.flags[12:14],1)

  ; How many shutter out events, with solar poisiton and nothing happening in saa, ecl, dgp ???
  print, n_elements(where(sflag1 eq 1 and dgp eq 0 and saa eq 0 and ecl eq 0 and a0only eq 1))
  ;         94818

  ; Was the event in the Loumou et al. list, and
  ; include the background subtracted GOES class from that list
  restore,file='full_fl_simp_lhh.dat';,id_num_lhh,ptim_lhh,bsges_lhh,x_lhh,y_lhh,lat_lhh,lng_lhh
  nf_lhh=n_elements(id_num_lhh)
  ;  IDL> help,nf_lhh
  ;  NF_LHH          LONG      =        75306
  lhh=bytarr(nf)
  bsges=fltarr(nf)
  xlhh=fltarr(nf)
  ylhh=fltarr(nf)
  latlhh=fltarr(nf)
  lnglhh=fltarr(nf)

  lhh_id=lonarr(nf_lhh)
  for ii=0, nf_lhh-1 do lhh_id[ii]=where(id_num eq id_num_lhh[ii])
  lhh[lhh_id]=1
  bsges[lhh_id]=bsges_lhh
  ;  And add in the improved lhh positions
  xlhh[lhh_id]=x_lhh
  ylhh[lhh_id]=y_lhh
  latlhh[lhh_id]=lat_lhh
  lnglhh[lhh_id]=lng_lhh

  ; How many shutter out events, with solar poisiton and nothing happening in saa, ecl, dgp and in LHH list? ???
  print, n_elements(where(sflag1 eq 1 and dgp eq 0 and saa eq 0 and ecl eq 0 and a0only eq 1 and lhh eq 1))
  ;         61545

  save,file='rfl_py_full.dat',id_num,x,y,lat,lng,ptim,stim,etim,enghi,a0only,sflag1,saa,ecl,dgp,lhh,bsges,xlhh,ylhh,latlhh,lnglhh
  save,file='rfl_py_mid.dat',id_num,ptim,stim,etim,enghi,a0only,sflag1,saa,ecl,dgp,lhh,bsges

  ; Make a simplier "good" flag of solar position and no saa, ecl or dgp (supposedly) happening about/during flare time
  gd_id=where(sflag1 eq 1 and dgp eq 0 and saa eq 0 and ecl eq 0)
  gdflg=intarr(nf)
  gdflg[gd_id]=1
  save,file='rfl_py_simp.dat',id_num,ptim,enghi,a0only,gdflg,lhh

  stop
end