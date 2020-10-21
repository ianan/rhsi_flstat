pro rfl_sumltc_forpy

  ;For some time range write out the RHESSI quicklook summary lightcurve and flags in
  ;a format that should be readable in python.
  ;
  ;21-Oct-2020 IGH
  ;
  search_network,/enabled
  ; Do 2 hour window to cover night before, sunlight, and night after.
  ;; http://sprg.ssl.berkeley.edu/~tohban/browser/?show=grth1+qlpcr&date=20021103&time=172841
  tr1='03-Nov-2002 '+['16:30','18:30']
  ;; http://sprg.ssl.berkeley.edu/~tohban/browser/?show=grth1+qlpcr&date=20030302&time=224144
  tr2='02-Mar-2003 '+['22:00','24:00']
  ;; http://sprg.ssl.berkeley.edu/~tohban/browser/?show=grth1+qlpcr&date=20050311&time=130000
  tr3='11-Mar-2005 '+['12:00','14:00']

  trs=[[tr1],[tr2],[tr3]]
  nt=n_elements(trs[0,*])

  for i=0, nt-1 do begin

    ;  Use the obs summary object to get the quick look info
    o=hsi_obs_summary()
    o->set,obs_time_interval=trs[*,i]
    ctd=o->getdata(/corrected)
    times=anytim(o->getaxis(/ut),/ccsds)
    flgs=o->getdata(class='flag')
    suminfo=o->get(/info)
    destroy,o

    ;  As mostly dealding with the shutter out (A0) events just use the energies up to 100keV
    dets_id=where(suminfo.seg_index_mask[0:8] eq 1)+1
    engs_id=suminfo.dim1_ids[0:4]+' keV'
    countrate=ctd.countrate[0:4]
    ; The flags we want to save out are Night, SAA, Flare, Attenuator state
    ;  http://sprg.ssl.berkeley.edu/~jimm/hessi/hsi_obs_summ_soc.html#hsi_obs_summ_flag
    saa_flag=flgs.flags[0]
    ecl_flag=flgs.flags[1]
    flr_flag=flgs.flags[2]
    atn_flag=flgs.flags[14]

    fname='qlsum_'+break_time(trs[0,i])+'.dat

    ;  Save it out...
    save,file=fname,times,countrate,dets_id,engs_id,saa_flag,ecl_flag,flr_flag,atn_flag
  endfor

  stop
end