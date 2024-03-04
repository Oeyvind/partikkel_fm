;***************************************************
; Granular FM feedback instrument
;***************************************************
; Oeyvind Brandtsegg 2024
; obrandts@gmail.com

   sr = 48000 
   ksmps = 1
   nchnls = 1
   0dbfs	= 1
   
   giSine ftgen 0, 0, 65537, 10, 1					; sine wave
   giCosine ftgen 0, 0, 8193, 9, 1, 1, 90	; cosine wave	
   giSigmoRise	ftgen	0, 0, 8193, 19, 0.5, 1, 270, 1	; rising sigmoid
   giSigmoFall	ftgen	0, 0, 8193, 19, 0.5, 1, 90, 1		; falling sigmoid
   giSquareWin	ftgen	0, 0, 8193, 7, 1, 8192, 1			  ; square window 
 
instr 1

  iamp = ampdbfs(p4)
  kgrainrate = p5
  imodindex_start = p6
  imodindex_end = p7
  kmodindex line imodindex_start, p3, imodindex_end
  ifmfq = p8
  kgrainpitch = p9  
  kgraindur = p10
  ka_d_ratio = p11 ; attack time (relative) for each grain
  ksustain_amount = p12 ; sustain time (relative) in each grain
  kindex_mapping = p13 ; apply index adjustment formula 

  ; index adjustment for granular FM, to attempt to keep the same modulation amount as we get in regular FM feedback
  if kindex_mapping == 1 then
    kmodindex = ((kmodindex)^1.8)*1/(kgraindur^0.8) ; empirical adjust mod index for these partikkelsettings
  endif
  ; always adjust amp slightly according to grain duration, as grain overlaps increase output amp
  kamp = iamp*limit(1/(kgraindur^0.5), 0.1, 4) ; empirical adjust amp for these partikkelsettings

  ; grain dur and  shape
  kduration	= (kgraindur*1000)/kgrainrate ; grain dur in milliseconds, relative to grain rate
  ienv_attack = giSigmoRise ; grain attack shape (from table)
  ienv_decay = giSigmoFall  ; grain decay shape (from table)
  
  ; fm signal
  awavfm oscil kmodindex, ifmfq
  
  ; other
  asamplepos1 = 0				; initial phase of wave inside each grain
  async init 0 
  kdistribution	= 0.0 ; grain random distribution in time
  idisttab ftgentmp 0, 0, 16, 16, 1, 16, -10, 0	; probability distribution for random grain masking

  ; masking (not active)
  ifmamptab	ftgentmp 0, 0, 16, -2,  0, 0,   1, 0, 0, 0 ; FM index scalers, per grain
  ifmenv = giSquareWin
  igainmasks ftgentmp	0, 0, 16, -2, 0, 0,   1
  ichannelmasks	ftgentmp 0, 0, 16, -2,  0, 0,  0
  krandommask = 0
  iwaveamptab ftgentmp	0, 0, 32, -2, 0, 0,   1,0,0,0,0

  a1 partikkel a(kgrainrate), kdistribution, idisttab, async, 0, -1, \
        ienv_attack, ienv_decay, ksustain_amount, ka_d_ratio, kduration, 1, igainmasks, \
        1, 0.5, -1, -1, awavfm, \
        ifmamptab, ifmenv, giCosine, 1, 1, 1, \
        ichannelmasks, krandommask, giSine, giSine, giSine, giSine, \
        iwaveamptab, asamplepos1, asamplepos1, asamplepos1, asamplepos1, \
        kgrainpitch, 0, 0, 0, 100

  
  ; amp and out
  a1 *= kamp
  out	a1
 
endin

