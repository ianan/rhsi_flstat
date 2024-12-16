pro get_goes_bsub

  ; Get the GOES XRS flux at peak time and averaged over the background time
  ; These should without the scaling factor in them
  ;
  ; 16-Dec-2024 IGH
  ;;~~~~~~~~~~~~~~~~~~~~~~

  search_network,/enabled
  restgen, file = 'bet_mfdata_a0gd.genx', res

  nf=n_elements(res.id_num)

  print,nf

  ; The max GOES over the flare time
  gespk=dblarr(nf)
  ; The GOES about time of peak time in RHESSI
  gespt=dblarr(nf)
  ; The GOES averaged over the background time
  gesbt=dblarr(nf)

  for i=0, nf -1 do begin
    print,i+1,100*(i+1)/(1.0*nf),'%'

    ; For speed just get the GOES data once over the whole time of the flare
    ges=ogoes()
    ges->set,bsub=0
    fdata=ges->getdata(tstart=anytim(res.bk_timer[0,i],/yoh),tend=anytim(res.end_time[i],/yoh))
    times=anytim(ges->get(/utbase))+ges->getdata(/times)

    fid =where(times ge anytim(res.start_time[i]) and times le anytim(res.end_time[i]),nfid)
    bid =where(times ge anytim(res.bk_timer[0,i]) and times le anytim(res.bk_timer[1,i]),nbid)
    pid= where(times ge anytim(res.peak_time[i]),npid)
    
    if (nfid gt 0) then gespk[i]=max(fdata[fid,0])
    if (nbid gt 0) then begin
      gd=where(fdata[bid,0] gt 0.,ngd)
      if (ngd gt 0) then gesbt[i]=mean(fdata[bid[gd],0])
    endif
    if (npid gt 0) then gespt[i]=fdata[pid[0],0]

    obj_destroy,ges

    if ( i mod 100 eq 0) then $
      savegen, file = 'bet_mfdata_a0gd_ges.genx', {ges_pk:gespk, ges_pt:gespt, ges_bt:gesbt}

  endfor

  savegen, file = 'bet_mfdata_a0gd_ges.genx', {ges_pk:gespk, ges_pt:gespt, ges_bt:gesbt}

  stop
end