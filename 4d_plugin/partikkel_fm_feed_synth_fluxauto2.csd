<Cabbage>
form size(710, 300), caption("Partikkel feedback FM"), pluginId("pfm3"), colour(25,35,35), guiMode("queue")

rslider channel("Octave"), bounds(5, 8, 70, 70), text("Octave"), range(-4, 4, 0, 1, 1)
rslider channel("Graindur"), bounds(75, 8, 70, 70), text("Graindur"), range(0.01, 2, 0.9, 1, 0.001)
rslider channel("Shape"), bounds(145, 8, 70, 70), text("Shape"), range(0.01, 0.99, 0.2, 1, 0.001)
rslider channel("FilterFq"), bounds(215, 8, 70, 70), text("FilterFq"), range(1, 10, 6)

rslider channel("Grainrate_ratio"), bounds(285, 8, 70, 70), text("RateRatio"), range(1, 12, 4, 1, 1)
rslider channel("Fm_index"), bounds(355, 8, 70, 70), text("FMndx"), range(0, 50, 6, 0.3)
checkbox channel("Fluxauto_enable"), bounds(417, 10, 15, 15)
label text("Fl_ndx"), bounds(415, 1, 30, 8), align("left")
rslider channel("Flux_target"), bounds(428, 8, 70, 70), text("Flux_target"), range(0, 5, 2)
rslider channel("Fluxauto_modindex"), bounds(495, 8, 70, 70), text("Fluxauto_indx"), range(0, 50, 0, 0.3)
rslider channel("Flux"), bounds(565, 8, 70, 70), text("Flux"), range(0, 5, 0)
rslider channel("Flux_target_kybdfollow"), bounds(635, 28, 70, 50), text("Flx_t_kybd"), range(0, 2, 0.2)

nslider channel("fluxfilt"), bounds(635, 8, 60, 20), range(0.001, 3, 0.2, 1, 0.001)

rslider channel("feed_delay"), bounds(565, 85, 70, 70), text("F.delay"), range(0.0, 10, 0.0, 0.35, 0.001)
checkbox channel("fdel_phasesync"), bounds(635, 95, 70, 13), text("Sync"), colour:0(60,80,80), colour:1("red"), value(1)
combobox channel("fdel_quantize"), bounds(635, 118, 70, 16), items("off", "1/2", "1/3", "1/4", "1/5", "1/6", "1/7")
label bounds(638, 132, 70, 11), text("Quantize"), align("left")

rslider channel("Detune"), bounds(5, 85, 70, 70), text("Detune"), range(0, 1, 0.02, 0.35, 0.0001)
rslider channel("Width"), bounds(80, 85, 70, 70), text("Width"), range(0, 1, 0.7, 1, 0.001)
rslider channel("Attack"), bounds(155, 85, 70, 70), text("A"), range(0.001, 2, 0.01, 0.35, 0.001)
rslider channel("Decay"), bounds(235, 85, 70, 70), text("D"), range(0.0001, 2, 0.3, 0.35, 0.001)
rslider channel("Sustain"), bounds(310, 85, 70, 70), text("S"), range(0, 1, 0.99, 0.35, 0.001)
rslider channel("Release"), bounds(385, 85, 70, 70), text("R"), range(0.0001, 2, 0.2, 0.35, 0.001)
rslider channel("Amp"), bounds(460, 85, 70, 70), text("Amp"), range(-96, 0, -5, 3, 0.1)

csoundoutput bounds(5,165,530,150)

</Cabbage>

<CsoundSynthesizer>
<CsOptions>
-n -d -m0 -+rtmidi=null -M0
</CsOptions>
<CsInstruments>

;***************************************************
; globals
;***************************************************

	sr = 48000
	ksmps = 10
	nchnls = 2
	0dbfs	= 1

;***************************************************
;ftables
;***************************************************

  ; classic waveforms
  giSine		ftgen	0, 0, 65537, 10, 1					; sine wave
  giCosine	ftgen	0, 0, 8193, 9, 1, 1, 90					; cosine wave
	
  ; grain envelope tables
  giSigmoRise 	ftgen	0, 0, 8193, 19, 0.5, 1, 270, 1				; rising sigmoid
  giSigmoFall 	ftgen	0, 0, 8193, 19, 0.5, 1, 90, 1				; falling sigmoid
  giExpFall	ftgen	0, 0, 8193, 5, 1, 8193, 0.00001				; exponential decay
  giTriangleWin 	ftgen	0, 0, 8193, 7, 0, 4096, 1, 4096, 0			; triangular window 
  giSquareWin 	ftgen	0, 0, 8193, 7, 1, 8192, 1			; square window 

;******************************************************
; partikkel instr
;******************************************************
  instr 1

  ivel veloc ; midi velocity
  iamp_dB ampmidid ivel, 20 ; convert to db range
 
; sync
  async 		= 0.0					; set the sync input to zero (disable external sync)

; grain pitch and rate
  inum notnum ; midi note number
  koctnum chnget "Octave"
  kcps = cpsmidinn(inum+(koctnum*12))
  kgrate_ratio chnget "Grainrate_ratio"
  kwavekey1	= kcps 
  kwavfreq = 1					; transposition factor (playback speed) of audio inside grains, 
  kgrainrate	divz kcps, kgrate_ratio, 1 ; number of grains per second relative to base freq
  agrainrate interp kgrainrate

; distribution 
  kdistribution	= 0.0						; grain random distribution in time
  idisttab	ftgentmp	0, 0, 16, 16, 1, 16, -10, 0	; probability distribution for random grain masking

; grain dur and  shape
  kgraindur chnget "Graindur"
  kduration	= (kgraindur*1000)/kgrainrate		; grain dur in milliseconds, relative to grain rate

  ienv_attack = giSigmoRise 				; grain attack shape (from table)
  ienv_decay = giSigmoFall 				; grain decay shape (from table)
  ka_d_ratio chnget "Shape"
  ksustain_amount	= 0.0					; balance between enveloped time(attack+decay) and sustain level time, 0.0 = no time at sustain level

; FM of grain pitch (playback speed)
  ifmamptab	ftgentmp	0, 0, 16, -2, 0, 0,   1			; FM index scalers, per grain
  ifmenv = giSquareWin ;giTriangleWin					; FM index envelope, over each grain (from table)
  awavfm init 0 ; feedback, the signal is written after the partikkel opcode

; init phase
  asamplepos1	= 0				; initial phase 

; masking
  igainmasks	ftgentmp	0, 0, 16, -2, 0, 0,   1
  ichannelmasks	ftgentmp	0, 0, 16, -2,  0, 0,  0
  krandommask	= 0
  iwaveamptab	ftgentmp	0, 0, 32, -2, 0, 0,   0.5,0.5,0,0,0

  kdetune = semitone(chnget:k("Detune"))-1
  
  a1 partikkel agrainrate*(1+kdetune), kdistribution, idisttab, async, 0, -1, \
        ienv_attack, ienv_decay, ksustain_amount, ka_d_ratio, kduration, 1, igainmasks, \
        kwavfreq*(1+kdetune), 0.5, -1, -1, awavfm, \
        ifmamptab, ifmenv, giCosine, 1, 1, 1, \
        ichannelmasks, krandommask, giSine, giSine, giSine, giSine, \
        iwaveamptab, asamplepos1, asamplepos1, asamplepos1, asamplepos1, \
        kwavekey1, 0, 0, 0, 100

  a2 partikkel agrainrate*(1-kdetune), kdistribution, idisttab, async, 0, -1, \
        ienv_attack, ienv_decay, ksustain_amount, ka_d_ratio, kduration, 1, igainmasks, \
        kwavfreq*(1-kdetune), 0.5, -1, -1, awavfm, \
        ifmamptab, ifmenv, giCosine, 1, 1, 1, \
        ichannelmasks, krandommask, giSine, giSine, giSine, giSine, \
        iwaveamptab, asamplepos1, asamplepos1, asamplepos1, asamplepos1, \
        kwavekey1, 0, 0, 0, 100
   
  iA chnget "Attack"
  iD chnget "Decay"
  iS chnget "Sustain"
  iR chnget "Release"
  aenv madsr iA, iD, iS, iR
  a1 *= aenv
  a2 *= aenv
  kfilter chnget "FilterFq"
  kfilterfq = kfilter*kcps
  a1 lpf18 a1, kfilterfq, 0.3, 0.3
  a2 lpf18 a1, kfilterfq, 0.3, 0.3
  kfm_mod_control chnget "Fm_index"
  kfm_mod_fluxadjusted init 0
  kfluxauto_enable chnget "Fluxauto_enable"
  if kfluxauto_enable > 0 then
    kfm_mod = kfm_mod_fluxadjusted
  else
    kfm_mod = kfm_mod_control
  endif
  awavfm = (a1+a2)*kfm_mod

  ; *** flux analysis
  ; ***************
  ; spectral analysis L2, low fft size, smoothing, custom window
  ifftsize = 8192
  ioverlap = 4
  iwtype = 1
  iwin ftgen 0, 0, ifftsize, 20, 7, 1, 1.5 ;  KAISER
  fsin pvsanal awavfm, ifftsize, ifftsize/ioverlap, ifftsize, -iwin  
  ismoothing = 0.002
  fsmooth pvsmooth fsin, ismoothing, ismoothing
  
  iarrsize = ifftsize/2 + 1
  kAmps[] init iarrsize
  kFreqs[] init iarrsize
  kAmpsmooth[] init iarrsize
  kFreqsmooth[] init iarrsize
  kflag pvs2array kAmps, kFreqs, fsin
  kflag pvs2array kAmpsmooth, kFreqsmooth, fsmooth
  if changed(kflag) > 0 then
    kmaxAmp maxarray kAmps
    kFluxL2[] = limit(kAmps^2-kAmpsmooth^2, 0, 9999) ; L2 distance (limit, includes only positive changes)
    kfluxL2 = sumarray(kFluxL2) ; sum of all distances
  endif
  kfluxL2_norm divz kfluxL2, kmaxAmp^2, 0 ; normalized flux, independent of amplitude
  kfluxL2_norm *= 0.15
  kfluxfilt chnget "fluxfilt"
  ifilter_skipreinit = 1
  kfluxL2_norm tonek kfluxL2_norm, kfluxfilt, ifilter_skipreinit
  cabbageSetValue "Flux", kfluxL2_norm, changed(kfluxL2_norm)
  kflux_target chnget "Flux_target"
  kflux_target_kybd_follow chnget "Flux_target_kybdfollow"
  ikybd_follow = (inum-60)/12 ; per octave adjustment, centered on note 60
  kflux_target = kflux_target-(kflux_target*kflux_target_kybd_follow*ikybd_follow)
  kfm_mod_fluxadjusted limit (kflux_target-kfluxL2_norm)*kfm_mod_control, 0, 100
  cabbageSetValue "Fluxauto_modindex", kfm_mod_fluxadjusted, changed(kfm_mod_fluxadjusted)

  ; *** 
  ;atest = awavfm
  kfeed_delay chnget "feed_delay"
  kfeed_phasesync chnget "fdel_phasesync"
  imaxdel = 0.1
  printk2 1/kcps, 10
  print inum, cpsmidinn(inum), 1/cpsmidinn(inum) 
  if kfeed_phasesync > 0 then
    kdel_quantize chnget "fdel_quantize"
    iQuantize[] fillarray 1,1,2,3,4,5,6,7
    kquantizeval = iQuantize[kdel_quantize]
    printk2 kquantizeval
    if kquantizeval > 1 then
      kfeed_delay = (floor(kfeed_delay*kquantizeval)/kquantizeval)
    endif
    printk2 kfeed_delay
    ;cabbageSetValue "feed_delay", kfeed_delay, changed(kfeed_delay)
    ;chnset kfeed_delay, "feed_delay"
    kfeed_delay_ limit (kfeed_delay*(1/kcps))-(1/kr), 0, imaxdel
  else
    kfeed_delay_ limit (kfeed_delay-(1/kr))*0.001, 0, imaxdel
  endif
  ;printk2 kfeed_delay
  awavfm vdelayx awavfm, a(kfeed_delay_), imaxdel, 4
  
  kamp chnget "Amp"
  kamp = ampdbfs(kamp)

  kwidth chnget "Width"
  aL = (a1*(1-kwidth)+a2*kwidth)*kamp*iamp_dB
  aR = (a2*(1-kwidth)+a1*kwidth)*kamp*iamp_dB
  outs	aL, aR
        
  endin

;******************************************************

</CsInstruments>
<CsScore>
</CsScore>

</CsoundSynthesizer>
