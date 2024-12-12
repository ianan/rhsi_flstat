pro make_better_a0_list
  compile_opt idl2

  ; ***** Completely changing how access list, now using:
  ; https://hesperia.gsfc.nasa.gov/ssw/hessi/doc/guides/flare_list_utilities.htm

  ;
  ; In this version use the new full list from Sep 2022
  ; and restrict to "good" shutter out events using this info
  ; and maybe the additional info from the LHH list
  ;
  ; ; The full list is here:
  ; https://hesperia.gsfc.nasa.gov/hessidata/dbase/hessi_flare_list.txt
  ; Containing 104,035 events
  ;
  ; First flare
  ; 2021229 12-Feb-2002 02:15:24 02:19:22 02:25:48   624     46     75270       25-50   958  -118    965 9809  A1 P1
  ; Last flares (noisy RHESSI but also solar min so not many flares)
  ; 18022601 26-Feb-2018 15:49:40 15:51:14 15:53:56   256    155     16984        6-12   -15   199    199    0  A0 DF P1 PE Q2
  ; 18030301  3-Mar-2018 04:04:24 04:06:10 04:09:52   328    116     19161        6-12   924   129    933 2700  A0 P1 PE Q1
  ; 18033001 30-Mar-2018 05:10:12 05:11:42 05:23:20   788    184     47739        6-12  -897  -135    907    0  A0 DF P1 PE Q2
  ;
  ; 18022601,18030301 looks like a real flare from GOES/XRS and detected properly in RHESSI, though noisy (D3, D8 only)
  ; 18033001 looks like a real flare from GOES/XRS but very noisy in D3,8 only - not really useable
  ;
  ; Loumou et al. 2018 (LHH) paper https://doi.org/10.1051/0004-6361/201731050
  ; Only does 12-Feb-2002 to 23-Feb-2016 which over that period the full list gives 117,427 flares
  ; This restricted list (non-imagable, anomalous positions and GOES BS flux > 1e-8) gives 73,711 flares.
  ;
  ; This was updated to cover up to Mar-2018 giving 75,306 events
  ; doesn't add much as 5th anneal was Feb-Apr 2016 and then into solar minimum
  ;
  ; Times of anneal and offpointing, which want to filter out
  ; For offpointing not a big deal (especially near start/end times) more
  ; of an issue for anneal times, but just get rid of all
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
  ; 05-nov-2007 07:00, 27-nov-2007 20:00,  Anneal - 1
  ; 05-jun-2008 00:00, 26-jun-2008 14:00,  Offpoint
  ; 16-mar-2010 00:30, 01-may-2010 01:50,  Anneal - 2
  ; 10-jun-2010 14:00, 23-Jun-2010 02:00,  Offpoint
  ; 17-jan-2012 03:00, 22-feb-2012 14:50,  Anneal - 3
  ; 26-Jun-2014 04:00, 13-Aug-2014 00:00,  Anneal - 4
  ; 23-Feb-2016 02:19, 29-Apr-2016 03:48,  Anneal - 5
  ; 11-Apr-2018 01:50, 12-Jun-2018 00:00,  Anneal - 6
  ; 12-Jun-2018 00:00, 01-jan-2050 00:00,  Inoperative
  ;
  ;
  ; 04-Dec-2024 IGH
  ; 12-Dec-2024
  ;
  ; ; -------------------------
  ; ;
  ; ; Get list for full mission
  fdata = hsi_read_flarelist(info = flare_info)

  print, n_elements(fdata.id_number) ; 104036

  ; ; -------------------------
  ; ; -------------------------
  ; ; Filter out offpointing and anneal times
  otimes = [['17-jun-2002 11:26', '24-jun-2002 17:10'], $
    ['08-May-2003 11:00', '09-may-2003 06:00'], $
    ['23-may-2003 05:00', '24-may-2003 02:00'], $
    ['14-jun-2003 19:00', '16-jun-2003 22:00'], $
    ['16-apr-2004 23:00', '18-apr-2004 03:00'], $
    ['08-jun-2004 22:00', '25-jun-2004 22:00'], $
    ['20-jul-2004 17:10', '21-jul-2004 06:30'], $
    ['03-jun-2005 03:04', '25-jun-2005 16:24'], $
    ['09-jun-2006 05:00', '24-jun-2006 22:00'], $
    ['12-jun-2007 06:00', '27-jun-2007 16:30'], $
    ['05-nov-2007 07:00', '27-nov-2007 20:00'], $
    ['05-jun-2008 00:00', '26-jun-2008 14:00'], $
    ['16-mar-2010 00:30', '01-may-2010 01:50'], $
    ['10-jun-2010 14:00', '23-Jun-2010 02:00'], $
    ['17-jan-2012 03:00', '22-feb-2012 14:50'], $
    ['26-Jun-2014 04:00', '13-Aug-2014 00:00'], $
    ['23-Feb-2016 02:19', '29-Apr-2016 03:48'], $
    ['11-Apr-2018 01:50', '12-Jun-2018 00:00'], $
    ['12-Jun-2018 00:00', '01-jan-2050 00:00']]

  noff = n_elements(otimes[0, *])
  badoff = [0]
  for i = 0, noff - 1 do begin
    id = where(fdata.end_time ge anytim(otimes[0, i]) and fdata.start_time le anytim(otimes[1, i]), nid)

    if (nid gt 0) then begin
      badoff = [badoff, id]
      ; print,'------------------'
      ; print,otimes[*,i]
      ; print,anytim(fdata[id].peak_time,/yoh,/trunc)
    endif
  endfor
  badoff = badoff[1 : -1]
  print, n_elements(badoff) ; 155

  gdoff = bytarr(n_elements(fdata.id_number)) + 1
  gdoff[badoff] = 0
  gdid = where(gdoff ne 0)
  fdata = fdata[gdid]
  print, n_elements(fdata.id_number) ; 103881

  ; ; -------------------------
  ; ; -------------------------
  ; What are the flare flags
  ; for i=0, flare_info.nflags-1 do print, i, '   ',flare_info.flag_ids[i]
  ; 0   SAA_AT_START
  ; 1   SAA_AT_END
  ; 2   SAA_DURING_FLARE
  ; 3   ECLIPSE_AT_START
  ; 4   ECLIPSE_AT_END
  ; 5   ECLIPSE_DURING_FLARE
  ; 6   NON_SOLAR
  ; 7   FRONT_DECIMATION
  ; 8   ATT_STATE_AT_PEAK
  ; 9   DATA_GAP_AT_START
  ; 10   DATA_GAP_AT_END
  ; 11   DATA_GAP_DURING_FLARE
  ; 12   PARTICLE_EVENT
  ; 13   DATA_QUALITY
  ; 14   POSITION_QUALITY
  ; 15   ATTEN_0
  ; 16   ATTEN_1
  ; 17   ATTEN_2
  ; 18   ATTEN_3
  ; 19   REAR_DECIMATION
  ; 20   MAGNETIC_REGION
  ; 21   IMAGE_STATUS
  ; 22   SPECTRUM_STATUS
  ; 23   SOLAR_UNCONFIRMED
  ; 24   SOLAR
  ; 25   NEAR_SPIN_AXIS
  ; 26   NOMATCH_WITH_FSIMG
  ; 27   USED_AIA_POSITION
  ; 28   ASPECT_GAP
  ;
  ; ;  Only want attenuator out for whole flare
  att = total(fdata.flags[16 : 18], 1)
  a0_id = where(att ne 1 and fdata.flags[15] ne 0)
  a0only = bytarr(n_elements(fdata.id_number))
  a0only[a0_id] = 1

  ; Don't want SAA, Eclipse changes or data gaps
  saa = total(fdata.flags[0 : 2], 1)
  ecl = total(fdata.flags[3 : 5], 1)
  dgp = total(fdata.flags[9 : 11], 1)

  ; Also add filter based on ratio of peak to background 6-12 counts?
  ; Would remove those with flares just before... as well as bad?
  ; These are some sort of "corrected" rates? But same correction peak and back?
  ; Only a correction for when shutters are in, which shouldn't matter in our case?
  ; So run something less restrictive, just make sure back isn't bigger than peak
  sig612 = fdata.peak_countrate / fdata.bck_countrate

  gdflg = where(fdata.sflag1 eq 1 and sig612 ge 1. and fdata.flags[24] eq 1 and $
    dgp eq 0 and saa eq 0 and ecl eq 0 and a0only eq 1 and $
    fdata.position[0] ne 0.0 and fdata.position[1] ne 0.0)
  fdata = fdata[gdflg]
  ngd = n_elements(fdata.id_number)
  print, ngd ; 60427

  ; How many overlap with microflare paper/list
  ; Not many flares about this end time as solar minimum
  mfid = where(fdata.peak_time lt anytim('10-Feb-2007'))
  print, n_elements(mfid) ; 24956

  ; ; -------------------------
  ; ; -------------------------

  ; Check the hard microflare is still there....
  print, anytim(fdata[where(fdata.id_number eq 6111704)].peak_time, /yoh, /trunc)
  ; Save out the whole list?????
  ; save, file = 'bet_mfdata_a0gd.sav', fdata

  flag_ids = strarr(29)
  for i = 0, 28 do begin
    flag_idnum = strcompress(string(1000 + i, format = '(i4)'), /rem)
    flag_ids[i] = strmid(flag_idnum, 2, 2) + '__' + flare_info.flag_ids[i]
  endfor

  ; Just save out the bits we need:
  res = {id_num: fdata.id_number, start_time: fdata.start_time, end_time: fdata.end_time, peak_time: fdata.peak_time, $
    bk_timer: fdata.bck_time, eng_found: fdata.energy_range_found, eng_hi: fdata.energy_hi, $
    peak_cr: fdata.peak_countrate, back_cr: fdata.bck_countrate, tot_c: fdata.total_counts, $
    pos: fdata.position, goes_pk: fdata.goes_level_pk, $
    flag_ids: flag_ids, flags: fix(fdata.flags[0 : 28])}
  savegen, file = 'bet_mfdata_a0gd.genx', res

  ; ; -------------------------
  ; ; -------------------------
  ; Add in the LHH data?
  restore, file = 'full_fl_simp_lhh.dat' ; ,id_num_lhh,ptim_lhh,bsges_lhh,x_lhh,y_lhh,lat_lhh,lng_lhh

  id_lhh = lonarr(ngd)
  ; Find out where in the main list where they correspond to in the lhh list (if they do)
  for i = 0, ngd - 1 do id_lhh[i] = where(fdata[i].id_number eq id_num_lhh)
  ; quick check
  print, fdata[1000].id_number, id_num_lhh[id_lhh[1000]]
  ; Filter out those that don't match up, i.e. no LHH entry
  gd_lhh = where(id_lhh ne -1, ngd_lhh)
  print, ngd_lhh

  ; check it works
  print, fdata[gd_lhh[247]].id_number, id_num_lhh[id_lhh[gd_lhh[247]]]

  lhh_idnum = lonarr(ngd)
  lhh_idnum[gd_lhh] = id_num_lhh[id_lhh[gd_lhh]]
  lhh_bsges = fltarr(ngd)
  lhh_bsges[gd_lhh] = bsges_lhh[id_lhh[gd_lhh]]
  lhh_x = fltarr(ngd)
  lhh_x[gd_lhh] = x_lhh[id_lhh[gd_lhh]]
  lhh_y = fltarr(ngd)
  lhh_y[gd_lhh] = y_lhh[id_lhh[gd_lhh]]
  lhh_lat = fltarr(ngd)
  lhh_lat[gd_lhh] = lat_lhh[id_lhh[gd_lhh]]
  lhh_lng = fltarr(ngd)
  lhh_lng[gd_lhh] = lng_lhh[id_lhh[gd_lhh]]

  res2 = {id_num: fdata.id_number, start_time: fdata.start_time, end_time: fdata.end_time, peak_time: fdata.peak_time, $
    bk_timer: fdata.bck_time, eng_found: fdata.energy_range_found, eng_hi: fdata.energy_hi, $
    peak_cr: fdata.peak_countrate, back_cr: fdata.bck_countrate, tot_c: fdata.total_counts, $
    pos: fdata.position, goes_pk: fdata.goes_level_pk, $
    flag_ids: flag_ids, flags: fix(fdata.flags[0 : 28]), $
    lhh_id_num: lhh_idnum, lhh_bsges: lhh_bsges, lhh_x: lhh_x, lhh_y: lhh_y, lhh_lat: lhh_lat, lhh_lng: lhh_lng}

  ; correct the one bad position, well off disk, in lhh list
  badxyid = where(res2.lhh_x lt -1100.)
  res2.lhh_x[badxyid] = res2.pos[0, badxyid]
  res2.lhh_y[badxyid] = res2.pos[1, badxyid]
  lonlat = xy2lonlat(res2.pos[*, badxyid], res2.peak_time[badxyid], /quiet)
  res2.lhh_lng[badxyid] = lonlat[0]
  res2.lhh_lat[badxyid] = lonlat[1]

  savegen, file = 'bet_mfdata_a0gd_lhh.genx', res2

  stop
end
