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
  kfeed_delay = p8 ; feedback delay time (phase synced)
  klpfilterfq = p9; bypass filter if cutoff above 20k
  khpfilterfq = p10 ; bypass filter if cutoff lower than 0.1
  iam_stabilizer = p11 ; switch for AM in feedback
  ; extra parameters for the grain generator moved to the end of the p-fields, to keep the first p-fields the same in both orchestras
  kgrainpitch = p12
  kgraindur = p13
  ka_d_ratio = p14 ; attack time (relative) for each grain
  ksustain_amount = p15 ; sustain time (relative) in each grain
  kindex_mapping = p16 ; apply index adjustment formula 
  kinvphase2 = p17 ; invert phase of every 2nd grain
  kgrainrate = kinvphase2 > 0 ? p5*2 : kgrainrate; and double the grain rate when using phase inversion of every 2nd grain

  ; index adjustment for granular FM, to attempt to keep the same modulation amount as we get in regular FM feedback
  if kindex_mapping == 1 then
    kmodindex = ((kmodindex)^1.8)/(kgraindur^0.7) ; empirical adjust mod index for these partikkelsettings
  endif
  ; always adjust amp slightly according to grain duration, as grain overlaps increase output amp
  kamp = iamp*limit(1/(kgraindur^0.5), 0.1, 4) ; empirical adjust amp for these partikkelsettings

  ; grain dur and  shape
  kduration	= (kgraindur*1000)/kgrainrate ; grain dur in milliseconds, relative to grain rate
  ienv_attack = giSigmoRise ; grain attack shape (from table)
  ienv_decay = giSigmoFall  ; grain decay shape (from table)
  
  ; fm signal
  awavfm init 0 ; feedback, the signal is written after the partikkel opcode
  
  ; other
  asamplepos1 = 0				; initial phase of wave inside each grain
  async init 0 
  kdistribution	= 0.0 ; grain random distribution in time
  idisttab ftgentmp 0, 0, 16, 16, 1, 16, -10, 0	; probability distribution for random grain masking

  ; masking (not active)
  ifmamptab	ftgentmp 0, 0, 16, -2,  0, 0,   1, 0, 0, 0 ; FM index scalers, per grain
  ifmenv = giSquareWin
  igainmasks ftgentmp	0, 0, 16, -2, 0, 0,   1, -1
  tablew kinvphase2, 1, igainmasks ; invert phase of every 2nd grain
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

  ; feedback scaling, mod index
  awavfm = a1*kmodindex

  ; filtering of feedback signal
  klp_delay_compensate = 0
  khp_delay_compensate = 0
  if klpfilterfq < 20000 then
    awavfm butterlp awavfm, klpfilterfq
    klpfilterfq_ratio divz klpfilterfq, kgrainpitch, 1 ; calculate filter delay at fundamental (source wave frequency), so we use the ratio between filter fq and fundamental fq 
    klp_delay_compensate = -(1/kgrainpitch)*divz(1,klpfilterfq_ratio,1)*0.25
  endif
  if khpfilterfq > 0.1 then
    awavfm butterhp awavfm, khpfilterfq
    khpfilterfq_ratio divz kgrainpitch, khpfilterfq, 1 ; opposite from for the LP filter, since our filter fq now is lower than the fundamental
    khp_delay_compensate = (1/kgrainpitch)*divz(1,khpfilterfq_ratio,1)*0.25 ; so we use the ratio between filter fq and fundamental fq to get there
  endif
  
  ; AM on feedback to avoid DC components (ala V.Lazzarini 2023)
  if iam_stabilizer > 0 then
    awavfm = (awavfm*(1+awavfm))
  endif

  ; feedback delay adjustment 
  ; sync delay to to pitch cycle (phase sync)
  ; compensate for delay introduced by the filters and for the ksmps delay in the feedback
  kfeed_delay_ limit (kfeed_delay*(1/kgrainpitch))-(1/kr)+khp_delay_compensate+klp_delay_compensate, 0, 1 
  awavfm vdelayx awavfm, a(kfeed_delay_), 1, 4 
  
  ; amp and out
  a1 *= kamp
  out	a1
 
endin

