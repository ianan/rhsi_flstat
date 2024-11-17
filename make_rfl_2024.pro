pro make_rfl_2024

  ; Trying agian produce the flare list in a format that is useful for python work
  ;
  ; Full flare list online is dated 12-Sep-2022 and contains 104,036 events (previously was >120,000)?
  ; https://hesperia.gsfc.nasa.gov/hessidata/dbase/hessi_flare_list.txt
  ;
  ; Details of the original list are in:
  ; https://hesperia.gsfc.nasa.gov/rhessi3/docs/qlook/hsi_flare_list.html
  ;
  ; 13-Nov-2024
  ;
  ;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ; Get the full list to begin with
  fl=hsi_flare_list(obs_time_interval=['12-Feb-2002 00:00','04-Mar-2018 00:00'])
  fdata=fl->getdata()
  ;  How many flares?
  nf=n_elements(fdata.id_number)
  print,nf
  ;      104,035
  ; Which is roughly the number quoted online
  ; what about the number of "solar events"
  print,n_elements(where(fdata.sflag1 eq 1))
  ;       99,915
  ; And "solar events" with non-zero position
  print,n_elements(where(fdata.sflag1 eq 1 and fdata.position[0] ne 0.0 and fdata.position[1] ne 0.0))
  ;       99,885

  ;flag_ids = string identifiers for each data flag, e.g.,
  ; http://sprg.ssl.berkeley.edu/~jimm/hessi/hsi_flare_list.html
  ;fids = [0'SAA_AT_START', 1'SAA_AT_END', 2'SAA_DURING_FLARE', $ 3'ECLIPSE_AT_START', 4'ECLIPSE_AT_END', $ 5'ECLIPSE_DURING_FLARE', $
  ; 6'FLARE_AT_SOF', 7'FLARE_AT_EOF', 8'NON_SOLAR', $ 9'FAST_RATE_MODE', 10'FRONT_DECIMATION', 11'ATT_STATE_AT_PEAK', $
  ; 12'DATA_GAP_AT_START', 13'DATA_GAP_AT_END', $ 14'DATA_GAP_DURING_FLARE', $ 15'PARTICLE_EVENT', 16'DATA_QUALITY', $
  ; 17'POSITION_QUALITY', 18'ATTEN_0', 19'ATTEN_1', $ 20'ATTEN_2', 21'ATTEN_3', 22'REAR_DECIMATION', $
  ; 23'MAGNETIC_REGION', 24'IMAGE_STATUS', 25'SPECTRUM_STATUS', $ 26'SOLAR_UNCONFIRMED', 27'SOLAR'].

  ; Was this a shutter out flare (i.e. a RHESSI microflare?)
  att_in=total(fdata.flags[19:21],1)
  a0_id=where(att_in ne 1)
  ; How may shutter out flares
  print,n_elements(a0_id)
  ;  60,626
  ;How many overlap with microflare paper/list
  mfid=where(fdata[a0_id].peak_time lt anytim('01-Mar-2007'))
  print,n_elements(mfid)
  ; 26,936
  ; so a few more than the ~25,000 from the Christe/Hannah papers

  mfdata=fdata[a0_id]

  ; Maybe also get rid of those with sflag1 ne 1 and those that don't
  ; have a solar position (i.e. position[0] and position[1] eq 0.0)
  gdid=where(mfdata.sflag1 eq 1 and mfdata.position[0] ne 0.0 and mfdata.position[1] ne 0.0, ngd)
  print,ngd
  ; So now 58,305 out of 60,626 shutter out flares

  mfdata=mfdata[gdid]

  save,file='mfdata_a0gd.sav',mfdata
  ;  savegen,file='mfdata_a0gd.genx',mfdata

  ; Just check the time etc of a few events
  ; first event

  print,anytim(mfdata[0].peak_time,/yoh,/trunc)
  ;  12-Feb-02 02:19:22
  ;
  ; Hard MF from Hannah+ 2008 is 6111704 17-Nov-2006 05:13:38
  hid=where(mfdata.id_number eq 6111704)
  print,anytim(mfdata[hid].peak_time,/yoh,/trunc)
  ;  17-Nov-06 05:13:38
  print,mfdata[hid].energy_hi
  ;        25.0000      50.0000


  ;  IDL> help,mfdata,/str
  ;  ** Structure HSI_FLARELISTDATA, 32 tags, length=312, data length=293:
  ;  ID_NUMBER       LONG           2021229
  ;  START_TIME      DOUBLE       7.2948332e+08
  ;  END_TIME        DOUBLE       7.2948395e+08
  ;  PEAK_TIME       DOUBLE       7.2948356e+08
  ;  BCK_TIME        DOUBLE    Array[2]
  ;  IMAGE_TIME      DOUBLE    Array[2]
  ;  ENERGY_RANGE_FOUND
  ;  FLOAT     Array[2]
  ;  ENERGY_HI       FLOAT     Array[2]
  ;  PEAK_COUNTRATE  FLOAT           46.0000
  ;  BCK_COUNTRATE   FLOAT           3.75680
  ;  TOTAL_COUNTS    FLOAT           75270.0
  ;  PEAK_CORRECTION FLOAT           1.00000
  ;  TOTAL_CORRECTION
  ;  FLOAT           1.00000
  ;  POSITION        FLOAT     Array[2]
  ;  SPIN_AXIS       FLOAT     Array[2]
  ;  FSPOS           FLOAT     Array[2]
  ;  FILENAME        STRING    '                                                                                '
  ;  FLAGS           BYTE      Array[32]
  ;  SEG_INDEX_MASK  BYTE      Array[18]
  ;  EXTRA_BCK       FLOAT     Array[3, 3]
  ;  SFLAG1          BYTE         1
  ;  ACTIVE_REGION   INT           9809
  ;  GOES_CLASS      STRING    'C2.0                                                                            '
  ;  RADIAL_OFFSET   FLOAT          0.118995
  ;  PEAK_PHFLUX     FLOAT           3207.55
  ;  TOT_PHFLUENCE   FLOAT           662166.
  ;  E_PHFLUENCE     FLOAT           554205.
  ;  PEAK_PHFLUX_SIGMA
  ;  FLOAT       2.20495e+06
  ;  TOT_PHFLUENCE_SIGMA
  ;  FLOAT       8.29954e+07
  ;  E_PHFLUENCE_SIGMA
  ;  FLOAT       3.92791e+07
  ;  GOES_LEVEL_PK   FLOAT     Array[2]
  ;  ALT_ID          STRING    'SOL2002-02-12T02:19:22

  stop
end