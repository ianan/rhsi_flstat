pro rhsi_flstat_sumltc

  ; Produce summary data files for each of the "good" shutter out flares
  ; produced by make_better_a0_list.pro - some of these won't be "good"
  ;
  ;
  ; 16-Dec-2024 IGH
  ;;~~~~~~~~~~~~~~~~~~~~~~
  ; if need to delete all the pngs then from omdir  do: find . -name "*.bak" -type f -delete
  ;

  ;   Save out +/- 3 mins
  tmore=180

  overwrite=1
  flen=32

  search_network,/enabled;,/glasgow
  restgen, file = 'bet_mfdata_a0gd.genx', res

  nf=n_elements(res.id_num)

  print,nf

  omdir='/scratch/trifid/iain/rfl_a0/'
  domdir=omdir+'data_ltc/'

  @post_outset

  for i=0, nf-1 do begin

    ; For time range just that from start of back time (always before 60s ?) to end of flare
    ; plus the tmore padding
    tr1=res.bk_timer[0,i]-tmore
    tr2=res.end_time[i]+tmore

    tr=anytim([tr1,tr2],/yoh,/trunc)

    ;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ; Sort out the file and directory names
    ; Do file name based of the flare start time

    stemp=anytim(res.start_time[i],/ecs)
    yr=strmid(stemp,0,4)
    mh=strmid(stemp,5,2)
    dy=strmid(stemp,8,2)
    hr=strmid(stemp,11,2)
    mn=strmid(stemp,14,2)

    ddir=domdir+yr+'/'+mh+'/'+dy+'/'
    fname='sumltc_'+yr+mh+dy+hr+mn
    print,i+1,100*(i+1)/(1.0*nf),'%  ---  ',fname

    datname=ddir+fname

    ;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ; Get the data
    ;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ; Am getting weird behaviour at edges of time range so
    ; make bigger than tr and then just take out the part we need
    tr_hos=anytim([anytim(tr[0])-60.,anytim(tr[1])+60.],/yoh,/trunc)
    o=hsi_obs_summary()
    o->set,obs_time_interval=tr_hos
    ;       corrected works on cluster but not on laptop?!?!?
    ctd0=o->getdata(/corrected)
    ;      ctd=o->getdata()
    tims0=o->getaxis(/ut)
    flgs0=o->getdata(class='flag')
    suminfo=o->get(/info)
    destroy,o
    ;      what part of time range do we actually need?
    gd_tid=where(tims0 ge anytim(tr[0]) and tims0 lt anytim(tr[1]))
    tims=tims0[gd_tid]
    ctd=ctd0[gd_tid]
    flgs=flgs0[gd_tid]
    ;      Sort out the dets info
    dets0=indgen(9)+1
    dets_ind=strjoin(string(dets0[where(suminfo.seg_index_mask[0:8] eq 1)],format='(i1)'))

    ;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ;       Save out the data file
    times=anytim(tims,/ccsds)
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
    
    ;  Save it out...
    save,file=datname+'.dat',times,countrate,dets_id,engs_id,saa_flag,ecl_flag,flr_flag,atn_flag,dets_ind

  endfor

  stop
end