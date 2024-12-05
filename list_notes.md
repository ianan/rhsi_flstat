## Some notes on the RHESSI flarelist

Full flare list online is dated 12-Sep-2022 and contains 104,036 events (previously was >120,000)?
[https://hesperia.gsfc.nasa.gov/hessidata/dbase/hessi\_flare\_list.txt](https://hesperia.gsfc.nasa.gov/hessidata/dbase/hessi_flare_list.txt)

Details of the original list are in: [https://hesperia.gsfc.nasa.gov/rhessi3/docs/qlook/hsi\_flare\_list.html]
(https://hesperia.gsfc.nasa.gov/rhessi3/docs/qlook/hsi_flare_list.html)

For the microflares, criteria to apply:

* Shutter out and no attenuator changes, i.e. `.flags[18:21]=0`
* No Eclipse during the flare, i.e. `.flags[3:5]=0`
* No SAA during the flare, i.e. `.flags[0:2]=0`
* No datagaps during the flare, i.e, `.flags[12:14]=0`
* Data quality is good, i.e. `.flags[16]<4`
* Is a solar event, i.e. `.flags[27]=1` or `sflag=1` or `.flags[8]=0`
* Has a non-zero positon, i.e. `position[0] ne 0.` and `position[1] ne 0.` 
	* though some of these just need this recalculated (as per LHH list?)
* Flare peak is $3\sigma$, i.e. `peak_countrate/bck_countrate >=3`
* XRS flux is `goes_level_pk>=1e-8` or some other level or non-zero, and certainly below something very high, like `goes_level_pk<1e-2`
	* 	In derived lists, do this to the background subtracted XRS flux 
* Could also be imaged in $12-25$ keV, i.e. `energy_hi[0] >= 12`
	* Only important if trying to catch higher energy/non-thermal/footpoint emission? 

Not as big of a deal??

* No SOF/EOF??, i.e. `.flags[6:7]=0` start or end of the file??
* Other microflares list had duration $>=60$s