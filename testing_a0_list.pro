pro testing_a0_list
  ;
  ; In this version use the new full list from Sep 2022
  ; and restrict to "good" shutter out events using this info
  ; and the info from the LHH list ? (though only does up to 2016?)
  ;
  ; ; The full list is here:
  ; https://hesperia.gsfc.nasa.gov/hessidata/dbase/hessi_flare_list.txt
  ; Containing 104,035 events
  ;
  ; Loumou et al. 2018 (LHH) paper https://doi.org/10.1051/0004-6361/201731050
  ; Only does 12-Feb-2002 to 23-Feb-2016 which over that period the full list gives 117,427 flares
  ; This restricted list (non-imagable, anomalous positions and GOES BS flux > 1e-8) gives 73,711 flares.
  ;
  ; But 'full_fl_simp_lhh.dat' actually goes up to 03-Mar-2018 instead with 75,306 events 
  ; so was updated and expanded... make_kh_flarelist.pro and update_kh_flarelist.pro in Nov 2020
  ;
  ; Times of anneal and offpointing from my old
  ; https://hesperia.gsfc.nasa.gov/ssw/hessi/dbase/rhessi_nosun_times.txt
  ;
  ; 17-jun-2002 11:26, 24-jun-2002 17:10,  Offpoint
  ; 08-May-2003 11:00, 09-may-2003 06:00,  Offpoint test
  ; 23-may-2003 05:00, 24-may-2003 02:00,  Offpoint test
  ; 14-jun-2003 19:00, 16-jun-2003 22:00,  Offpoint
  ; 16-apr-2004 23:00, 18-apr-2004 03:00,  Offpoint test
  ; 08-jun-2004 22:00, 25-jun-2004 22:00,  Offpoint
  ; 20-jul-2004 17:10, 21-jul-2004 06:30,  offpoint
  ; 03-jun-2005 03:04, 25-jun-2005 16:24,  Offpoint
  ; 09-jun-2006 05:00, 24-jun-2006 22:00,  Offpoint
  ; 12-jun-2007 06:00, 27-jun-2007 16:30,  Offpoint
  ; 05-nov-2007 07:00, 27-nov-2007 20:00,  Anneal
  ; 05-jun-2008 00:00, 26-jun-2008 14:00,  Offpoint
  ; 16-mar-2010 00:30, 01-may-2010 01:50,  Anneal
  ; 10-jun-2010 14:00, 23-Jun-2010 02:00,  Offpoint
  ; 17-jan-2012 03:00, 22-feb-2012 14:50,  Anneal
  ; 26-Jun-2014 04:00, 13-Aug-2014 00:00,  Anneal
  ; 23-Feb-2016 02:19, 29-Apr-2016 03:48,  Anneal
  ; 11-Apr-2018 01:50, 12-Jun-2018 00:00,  Anneal
  ; 12-Jun-2018 00:00, 01-jan-2050 00:00,  Inoperative
  ;
  ; So didn't miss much after Feb 2016, as annealing till end of Apr 2016,
  ; then performance not great after then, was through solar min so not many flares (?)
  ; and lasted about 2 years till final anneal then turn off
  ;
  ; 04-Dec-2024 IGH
  ;
  ; -------------------------
  ;

  ;;   Previously did till 04 Mar 2018 but no dofference as solar min
;  fl=hsi_flare_list(obs_time_interval=['12-Feb-2002 00:00','11-Apr-2018 00:00'])
;  fdata=fl->getdata()
;  
;  ;;Just to sped things up
;  savegen,file='~/Desktop/fdata',fdata
  restgen,file='~/Desktop/fdata',fdata
  
  ;;  How many flares?
  nf=n_elements(fdata.id_number)
  ;print,nf
  ;;  104036
  ;; Print out the time of the final few flares
  ;print,anytim(fdata[-3:-1].peak_time,/yoh,/trunc)
  ;; 26-Feb-18 15:51:14 03-Mar-18 04:06:10 30-Mar-18 05:11:42
  ;
  ;; Number of flares from end of LHH list?
  restore,file='full_fl_simp_lhh.dat';,id_num_lhh,ptim_lhh,bsges_lhh,x_lhh,y_lhh,lat_lhh,lng_lhh
  lnf=n_elements(id_num_lhh)
  ;print,lnf
  ;;  75306
  ;print,ptim_lhh[-1]
  ;;  03-Mar-18 04:06:22
  ;; which is the penulatimate event in the main list,
  ;; though the last even 30-Mar-18 05:11:42 doesn't look real on the browser
  ;; a GOES flare but nothing but noise in the RHESSI data
  ;; http://sprg.ssl.berkeley.edu/~tohban/browser/?show=grth1+grth3+qlpcr&date=20180330&time=051012

  ;; So just check the last event in lhh and 2nd last in main list are the same
  ;print,fdata[-2].id_number
  ;;  18030301
  ;print,id_num_lhh[-1]
  ;;  18030301

  ;; One of the lhh flares seems to have a bad position at (-1200,-1200)
  ;print,where(x_lhh eq -1200.00)
  ;;  73273
  ;print,ptim_lhh(where(x_lhh eq -1200.00))
  ;;  22-Feb-16 20:54:02
  badxy_id=id_num_lhh(where(x_lhh eq -1200.00))
  ;print,badxy_id
  ;;  16022202
  ; where this occurs in main list
  mflid=where(fdata.id_number eq badxy_id[0])
  ;print,fdata[mflid].position
  ;   -949.014     -116.331
  ;print,anytim(fdata[mflid].peak_time,/yoh,/trunc)
  ;; 22-Feb-16 20:54:14   
  ;  ****** need to deal with the above one....  
  ;   
  ;   
  ;; All in LHH have a non-zero position ?
  ;print,where(x_lhh eq 0.0)
;;          -1
  ;print,where(y_lhh eq 0.0)
;;         -1
  ;; ------------------------------------
  ;; Now check all these LHH flares are still in the main flare list
  
;  stop

  ;; ------------------------------------
  ;; Now check none of the LHH flares occur during the bad times (offpointing or anneal)
  otimes=[['17-jun-2002 11:26','24-jun-2002 17:10'],$
    ['08-May-2003 11:00','09-may-2003 06:00'],$
    ['23-may-2003 05:00','24-may-2003 02:00'],$
    ['14-jun-2003 19:00','16-jun-2003 22:00'],$
    ['16-apr-2004 23:00','18-apr-2004 03:00'],$
    ['08-jun-2004 22:00','25-jun-2004 22:00'],$
    ['20-jul-2004 17:10','21-jul-2004 06:30'],$
    ['03-jun-2005 03:04','25-jun-2005 16:24'],$
    ['09-jun-2006 05:00','24-jun-2006 22:00'],$
    ['12-jun-2007 06:00','27-jun-2007 16:30'],$
    ['05-nov-2007 07:00','27-nov-2007 20:00'],$
    ['05-jun-2008 00:00','26-jun-2008 14:00'],$
    ['16-mar-2010 00:30','01-may-2010 01:50'],$
    ['10-jun-2010 14:00','23-Jun-2010 02:00'],$
    ['17-jan-2012 03:00','22-feb-2012 14:50'],$
    ['26-Jun-2014 04:00','13-Aug-2014 00:00'],$
    ['23-Feb-2016 02:19','29-Apr-2016 03:48'],$
    ['11-Apr-2018 01:50','12-Jun-2018 00:00'],$
    ['12-Jun-2018 00:00','01-jan-2050 00:00' ]]

  offs=lonarr(lnf)
  noff=n_elements(otimes[0,*])
  badoff=[0]
  for i=0, noff-1 do begin
    id=where(fdata.peak_time ge anytim(otimes[0,i]) and fdata.peak_time le anytim(otimes[1,i]),nid)
    
    if (nid gt 0) then badoff=[badoff,id]
    
    
;    print,offs[75305],otimes[*,i],id
;    if (nid gt 0) then offs[id]=1
;;    if (offs[75305] eq 1) then stop
;    print,offs[75305],otimes[*,i]
  endfor
  badoff=badoff[1:-1]
;  badoff=where(offs eq 1,nbadoff)
  print,n_elements(badoff)
  ;; 133 !!
  ;gdr=where(offs ne 1,ngdr)
  
;  for i in for ii=0, nmf-1 do



  stop
end