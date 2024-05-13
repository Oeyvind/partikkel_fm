;***************************************************
; Granular FM feedback plugin (Csound/Cabbage)
;***************************************************
; Oeyvind Brandtsegg 2024
; obrandts@gmail.com

<Cabbage>
form size(450, 505), caption("Partikkel feedback FM"), pluginId("pfm4"), colour(23,38,45), guiMode("queue")

; debug button, remove for distribution
groupbox bounds(0,3,450,15),lineThickness("0"){
button channel("DisableGrainrate"), bounds(5, 0, 440, 15), text("Normal: Grainrate = icps", "Debug: Grainrate = 1"), colour:0(60, 80, 80, 255), colour:1(255, 60, 60, 255)
}

groupbox bounds(0,20,450,485),lineThickness("0"){
rslider channel("Octave"), bounds(5, 8, 70, 70), text("Octave"), range(-4, 4, 0, 1, 1)
rslider channel("Graindur"), bounds(75, 8, 70, 70), text("G.dur"), range(0.01, 2, 0.9, 1, 0.001)
rslider channel("Shape"), bounds(144, 8, 70, 70), text("Shape"), range(0.01, 0.99, 0.2, 1, 0.001)
rslider channel("Ratio"), bounds(217, 26, 50, 50), text("Ratio"), range(1, 12, 4, 1, 1)
button channel("Ratiomode"), bounds(220, 8, 42, 16), text("rate", "pitch"), colour:0(60, 80, 80, 255), colour:1(90, 60, 60, 255); grainrated ratio div, or pitchratio mult
rslider channel("Grainpitch"), bounds(266, 8, 70, 70), text("G.pitch"), range(0.25, 4, 1, 1, 0.001)
button channel("Pitch_mask"), bounds(342, 8, 100, 16), text("Pitch mask off", "Pitch mask on"), colour:0(60, 80, 80, 255), colour:1(90, 60, 60, 255)
button channel("Pitch_mask_sync"), bounds(375, 25, 35, 10), text("Alter", "Sync"), colour:0(60, 80, 80, 255), colour:1(90, 60, 60, 255)
rslider channel("Grainpitch2"), bounds(342, 31, 45, 45), text("G.pitch2"), range(0.25, 4, 1, 1, 0.001)
rslider channel("Grainmask_feedmix"), bounds(397, 31, 45, 45), text("Feedmix"), range(0, 1, 0, 1, 0.001)
image channel("Hide_pitchmask"), bounds(340,26,105,50), colour(0,0,0,130)

rslider channel("Lopass"), bounds(144, 168, 70, 70), text("Lopass_X"), range(1, 10, 6, 1, 0.001)
rslider channel("Hipass"), bounds(214, 168, 70, 70), text("Hipass_Hz"), range(0, 10, 6, 1, 0.001)
rslider channel("AMstabilizerdisplay"), bounds(284, 168, 70, 70), text("AM stabilizer"), range(0, 1, 0), markerThickness(0), trackerColour(20, 160, 0, 255), colour(0, 0, 0, 255)
rslider channel("AMstabilizer"), bounds(296, 174, 46, 46), range(0, 1, 0),trackerColour(30, 90, 255, 255), trackerInsideRadius(0.65), 

rslider channel("Fluxauto_modindex"), bounds(5, 88, 70, 70), text("FMndx"), range(0, 50, 0, 0.3, 0.001), markerThickness(0), trackerColour(20, 160, 0, 255), colour(0, 0, 0, 255)
rslider channel("Fm_index"), bounds(17, 94, 46, 46), range(0, 50, 4, 0.3, 0.001), trackerColour(30, 90, 255, 255), trackerInsideRadius(0.65), 
button channel("Fm_index_mode"), bounds(73, 127, 40, 16), text("Indx", "Flux"), colour:0(60, 80, 80, 255), colour:1(90, 60, 60, 255)
label text("ModCtrl"), bounds(73, 146, 45, 12), align("left") channel("label20")
rslider channel("Flux"), bounds(109, 88, 70, 70), text("Flux"), range(0, 5, 0, 1, 0.001), markerThickness(0), trackerColour(20, 160, 0, 255), colour(0, 0, 0, 255)
rslider channel("Flux_target"), bounds(121, 94, 46, 46), , range(0, 5, 2, 1, 0.001), trackerColour(30, 90, 255, 255), trackerInsideRadius(0.65)
nslider channel("Flux_target_kybdfollow"), bounds(177, 92, 60, 15), range(0, 2, 0.2, 1, 0.001),fontSize(14)
label bounds(179, 108, 60, 12), text("Flx_key") channel("label24")
nslider channel("Fluxfilt"), bounds(177, 128, 60, 15), range(0.001, 3, 0.2, 1, 0.001), fontSize(14)
label bounds(179, 146, 60, 12), text("Flx_filt") channel("label26")
image channel("Hide_flux"), bounds(115, 88, 125, 70), colour(0, 0, 0, 130)

rslider channel("Fm_shape"), bounds(244, 88, 70, 70), text("FM Shape"), range(0.01, 0.99, 0.2, 1, 0.001)
rslider channel("Fm_saturation"), bounds(314, 88, 70, 70), text("FM Saturation"), range(0.01, 0.99, 0.2, 1, 0.001)
button channel("Fm_global"), bounds(384, 102, 60, 15), text("Fm_local", "Fm_global"), colour:0(60, 80, 80, 255), colour:1(90, 60, 60, 255)
button channel("Fm_mask2nd"), bounds(384, 126, 60, 15), text("Fm nomask", "Fm_2nd"), colour:0(60, 80, 80, 255), colour:1(90, 60, 60, 255)

rslider channel("Feed_delay_display"), bounds(6, 167, 70, 70), text("F.delay"), range(0, 4, 0), popupText(0)
rslider channel("Feed_delay"), bounds(6, 167, 70, 70), text(" "), range(0, 4, 0), alpha(0), popupText(0)

button channel("Fdel_syncmode"), bounds(76, 172, 60, 18), text("Phasesync", "Grainsync"), colour:0(60, 80, 80, 255), colour:1(90, 60, 60, 255)
combobox channel("Fdel_quantize"), bounds(76, 192, 60, 16), text("off", "1/2", "1/3", "1/4", "1/5", "1/6", "1/7", "1/8", "1/9", "1/10"), value(1)
label bounds(78, 206, 60, 12), text("Quantize"), align("left") channel("label37")
nslider channel("Feed_delay_numdisplay"), bounds(76, 222, 50, 15), range(0, 4, 0, 0.35, 0.001), fontSize(14)

;rslider channel("Width"), bounds(306, 168, 70, 70), text("Width"), range(0, 1, 0.7, 1, 0.001)
rslider channel("Amp"), bounds(376, 168, 70, 70), text("Amp"), range(-96, 0, -5, 3, 0.1)

gentable bounds(5, 248, 160, 62), channel("envelope1"), outlineThickness(3), tableNumber(1.0), tableBackgroundColour(0, 0, 0, 0), , ampRange(0.0, 1.019999980926514, -1.0, 0.0100) tableColour:0(50, 100, 150, 255)
nslider channel("Attack"), bounds(6, 312, 50, 15), range(0.001, 2, 0.01, 1, 0.001), fontSize(14)
label bounds(56, 314, 15, 12), text("A"), align("left") channel("label44")
nslider channel("Decay"), bounds(76, 312, 50, 15), range(0.001, 2, 0.3, 1, 0.01), fontSize(14)
label bounds(126, 314, 15, 12), text("D"), align("left") channel("label46")
nslider channel("Sustain"), bounds(6, 328, 50, 15), range(0, 1, 0.6, 1, 0.01), fontSize(14)
label bounds(56, 330, 15, 12), text("S"), align("left") channel("label48")
nslider channel("Release"), bounds(76, 328, 50, 15), range(0.001, 2, 0.2, 1, 0.01), fontSize(14)
label bounds(126, 330, 15, 12), text("R"), align("left") channel("label50")
label bounds(30, 286, 50, 15), text("Amp"), align("left") channel("label51")

gentable bounds(170, 248, 275, 62), channel("envelope2"), outlineThickness(3), tableNumber(2.0), tableBackgroundColour(0, 0, 0, 0), , ampRange(0.0, 1.019999980926514, -1.0, 0.0100) tableColour:0(50, 150, 100, 255)
nslider channel("Val1"), bounds(171, 312, 45, 15), range(0, 1, 0, 1, 0.01), fontSize(14)
label bounds(217, 314, 15, 12), text("V1"), align("left") channel("label55")
nslider channel("Time1"), bounds(171, 328, 45, 15), range(0, 10, 1, 1, 0.01), fontSize(14)
label bounds(217, 330, 15, 12), text("T1"), align("left") channel("label57")
nslider channel("Val2"), bounds(237, 312, 45, 15), range(0, 1, 1, 1, 0.01), fontSize(14)
label bounds(283, 314, 15, 12), text("V2"), align("left") channel("label59")
nslider channel("Time2"), bounds(237, 328, 45, 15), range(0, 10, 1, 1, 0.01), fontSize(14)
label bounds(283, 330, 15, 12), text("T2"), align("left") channel("label61")
nslider channel("Val3"), bounds(303, 312, 45, 15), range(0, 1, 0, 1, 0.01), fontSize(14)
label bounds(349, 314, 15, 12), text("V3"), align("left") channel("label63")
nslider channel("Time3"), bounds(303, 328, 45, 15), range(0, 10, 1, 1, 0.01), fontSize(14)
label bounds(349, 330, 15, 12), text("T3"), align("left") channel("label65")
nslider channel("Val4"), bounds(369, 312, 45, 15), range(0, 1, 1, 1, 0.01), fontSize(14)
label bounds(415, 314, 15, 12), text("V4"), align("left") channel("label67")
combobox channel("Modenv_mode"), bounds(369, 330, 70, 15), text("off", "indx add", "indx mult"), value(1)
label bounds(205, 286, 50, 15), text("Mod"), align("left") channel("label68"), value(1)

csoundoutput bounds(5,350,440,130)
}
</Cabbage>

<CsoundSynthesizer>
<CsOptions>
-n -d -m0 -+rtmidi=null -M0
</CsOptions>
<CsInstruments>

; ******************
; globals

  ; sr = 48000 ; skip this when running as a plugin in a DAW
  ksmps = 10
  nchnls = 2
  0dbfs	= 1
  massign -1, 2
  gawavfm init 0
    
; ******************
;ftables

  giEnv1 ftgen 1, 0, 1024, 7, 0, 1024, 1 ; just for gui display of adsr envelope
  giEnv2 ftgen 2, 0, 1024, 7, 0, 1024, 1 ; just for gui display of fm mod envelope
  
  ; classic waveforms
  giSine		ftgen	0, 0, 65537, 10, 1					; sine wave
  giCosine	ftgen	0, 0, 8193, 9, 1, 1, 90					; cosine wave
	
  ; grain envelope tables
  giSigmoRise 	ftgen	0, 0, 8193, 19, 0.5, 1, 270, 1				; rising sigmoid
  giSigmoFall 	ftgen	0, 0, 8193, 19, 0.5, 1, 90, 1				; falling sigmoid
  giExpFall	ftgen	0, 0, 8193, 5, 1, 8193, 0.00001				; exponential decay
  giTriangleWin 	ftgen	0, 0, 8193, 7, 0, 4096, 1, 4096, 0			; triangular window 
  giSquareWin 	ftgen	0, 0, 8193, 7, 1, 8192, 1			; square window 

; ******************
; UDO
  opcode Fluxanalyzer, k, aii
  a1, ifftsize, ismoothing xin 
  ; *** flux analysis
  ; *** NOT comparing neighboring frames, but comparing between a smoothed and non-smoothed fsig
  ioverlap = 4
  iwtype = 1
  iwin ftgen 0, 0, ifftsize, 20, 7, 1, 1.5 ;  KAISER
  fsin pvsanal a1, ifftsize, ifftsize/ioverlap, ifftsize, -iwin  
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
  xout kfluxL2_norm 
endop

; *** UDO
  opcode SyncSingletrig, a, ai
  ; to be used with grain trigger pulses, to ensure we only create one extra grain at a time
  setksmps 1
  async, igatetime_samples xin 
  ksync_gate init 1
  ksync downsamp async
  kindex init 0
  if ksync_gate == 0 then
    ksync = 0
    kindex += 1
  endif
  if kindex > igatetime_samples then
    kindex = 0
    ksync_gate = 1
  endif
  ksync_out = ksync*ksync_gate
  if ksync == 1 then
    ksync_gate = 0
  endif
  async upsamp ksync_out
  xout async
  endop

; ******************
; GUI control
  instr 1

  kpitchmask_enable chnget "Pitch_mask"
  cabbageSet changed(kpitchmask_enable), "Hide_pitchmask", sprintfk("visible(%i)", 1-kpitchmask_enable)
  kfmindex_mode chnget "Fm_index_mode"
  cabbageSet changed(kfmindex_mode), "Hide_flux", sprintfk("visible(%i)", 1-kfmindex_mode)
  if kfmindex_mode == 0 then
    kfm_index chnget "Fm_index"
    cabbageSetValue "Fluxauto_modindex", kfm_index, changed(kfm_index)
  endif

  kfeed_delay chnget "Feed_delay"
  kdel_quantize chnget "Fdel_quantize"
  iQuantize[] fillarray 1,2,3,4,5,6,7,8,9,10
  kquantizeval = iQuantize[kdel_quantize-1]
  if kquantizeval > 1 then
    kfeed_delay = (floor(kfeed_delay*kquantizeval)/kquantizeval) ; quantize the delay time
    chnset kfeed_delay, "Feed_delay"
  endif
  cabbageSetValue "Feed_delay_display", kfeed_delay, changed(kfeed_delay)
  cabbageSetValue "Feed_delay_numdisplay", kfeed_delay, changed(kfeed_delay)

  ; envelope display
  ka chnget "Attack"
  kd chnget "Decay"
  ks chnget "Sustain"
  krel chnget "Release"
  ksumtime = ka+kd+krel
  katime = ka/ksumtime
  kdtime = kd/ksumtime
  krtime = krel/ksumtime
  if changed(ka,kd,ks,krel)> 0 then
    reinit tablupdate1
  endif
  tablupdate1:
  itablen1 = 1024
  iatime = itablen1*0.5*i(katime)
  idtime = itablen1*0.5*i(kdtime)
  irtime = itablen1*0.5*i(krtime)
  giEnv1 ftgen 1, 0, itablen1, 7, 0, iatime, 1, idtime, i(ks), itablen1*0.5, i(ks), irtime, 0
  cabbageSet  "envelope1", "tableNumber", 1   ; update table display
  rireturn

  kv1 chnget "Val1"
  kt1 chnget "Time1"
  kv2 chnget "Val2"
  kt2 chnget "Time2"
  kv3 chnget "Val3"
  kt3 chnget "Time3"
  kv4 chnget "Val4"
  ksumtime2 = kt1+kt2+kt3
  ktime1 = kt1/ksumtime2
  ktime2 = kt2/ksumtime2
  ktime3 = kt3/ksumtime2
  if changed(kv1,kv2,kv3,kv4,kt1,kt2,kt3)> 0 then
    reinit tablupdate2
  endif
  tablupdate2:
  itablen2 = 1024
  it1 =itablen2*i(ktime1)
  it2 =itablen2*i(ktime2)
  it3 =itablen2*i(ktime3)
  giEnv2 ftgen 2, 0, itablen1, -7, i(kv1), it1, i(kv2), it2, i(kv3), it3, i(kv4)
  cabbageSet  "envelope2", "tableNumber", 2   ; update table display
  rireturn

  endin



; ******************
; partikkel instr
  instr 2

  kdisableGrainrate chnget "DisableGrainrate" ; debug button, remove for distribution

  koctnum chnget "Octave"
  kgraindur chnget "Graindur"
  ka_d_ratio chnget "Shape"
  kratio chnget "Ratio"
  kratiomode chnget "Ratiomode"
  kgrainpitch1 chnget "Grainpitch"
  kpitchmask_enable chnget "Pitch_mask"
  kpitchmask_sync chnget "Pitch_mask_sync"
  kgrainpitch2 chnget "Grainpitch2"
  kgrainmask_feedmix chnget "Grainmask_feedmix"
  kgrainmask_feedmix *= kpitchmask_enable ; to make sure the mix is not set to use the 2nd grain in the mask (which is not generated when mask is off)
  kfmenv_ad_ratio chnget "Fm_shape"
  kfenv_sustain chnget "Fm_saturation"
  kfm_global chnget "Fm_global"
  kfm_mask2nd chnget "Fm_mask2nd"

  klpfilterfq chnget "Lopass"
  khpfilterfq chnget "Hipass"
  kam_stabilizer chnget "AMstabilizer"

  kfeed_delay chnget "Feed_delay"
  kdel_syncmode chnget "Fdel_syncmode"

  kfm_mod_control chnget "Fm_index"
  kfm_index_mode chnget "Fm_index_mode"
  kfluxfilt chnget "Fluxfilt"
  kflux_target chnget "Flux_target"
  kflux_target_kybd_follow chnget "Flux_target_kybdfollow"

  kmodenv_v1 chnget "Val1"
  kmodenv_v2 chnget "Val2"
  kmodenv_v3 chnget "Val3"
  kmodenv_v4 chnget "Val4"
  kmodenv_t1 chnget "Time1"
  kmodenv_t2 chnget "Time2"
  kmodenv_t3 chnget "Time3"
  kmodenv_mode chnget "Modenv_mode"
  kmodenv linseg i(kmodenv_v1), i(kmodenv_t1), i(kmodenv_v2), i(kmodenv_t2), i(kmodenv_v3), i(kmodenv_t3), i(kmodenv_v4)
  if kmodenv_mode == 2 then
    kfm_mod_control += kmodenv
  elseif kmodenv_mode == 3 then
    kfm_mod_control *= kmodenv
  endif

  kamp chnget "Amp"
  ;kwidth chnget "Width"
  kamp = ampdbfs(kamp)
  iA chnget "Attack"
  iD chnget "Decay"
  iS chnget "Sustain"
  iR chnget "Release"

; keyboard input
  inum notnum ; midi note number
  ivel veloc ; midi velocity
  iamp_dB ampmidid ivel, 20 ; convert to db range
 
; sync
  async init 0 
  async *= kpitchmask_enable*kpitchmask_sync ; enable synchronizing pitch masked grains (both grains in mask are generated at the same time)
  async SyncSingletrig async, ksmps-1 ; to avoid feedback when triggering extra grains from partikkelsync

; grain pitch and rate
  if kratiomode == 0 then ; allow mod ratio to affect grain pitch or grain rate selectively
    kgrate_ratio = kratio
  else 
    kgrainpitch1 *= kratio
    kgrainpitch2 *= kratio
    kgrate_ratio = 1
  endif
  kcps = cpsmidinn(inum+(koctnum*12))
  kwavekey1	= kcps*kgrainpitch1
  kwavekey2	= kcps*kgrainpitch2
  kwavfreq = 1 ; transposition factor (playback speed) of audio inside grains, 
  kgrainrate divz kcps, kgrate_ratio, 1 ; number of grains per second relative to base freq
  if kdisableGrainrate > 0 then ; debug button, remove for distribution
    kgrainrate = 1 ; debug button, remove for distribution
  endif; debug button, remove for distribution
  kgrainrate *= ((kpitchmask_enable*(1-kpitchmask_sync))+1); twice the grain rate and duration when pitch masking and not synced
  kgrainrate_syncadjusted = kpitchmask_enable+kpitchmask_sync == 2 ? kgrainrate*((sr/kgrainrate)/((sr/kgrainrate)-ksmps)) : kgrainrate
  agrainrate interp kgrainrate_syncadjusted

; distribution 
  kdistribution	= 0.0 ; grain random distribution in time
  idisttab ftgentmp 0, 0, 16, 16, 1, 16, -10, 0	; probability distribution for random grain masking

; grain dur and  shape
  kduration	= (kgraindur*1000)/kgrainrate ; grain dur in milliseconds, relative to grain rate
  kduration *= ((kpitchmask_enable*(1-kpitchmask_sync))+1) ; twice the grain rate and duration when pitch masking and not synced
  ienv_attack = giSigmoRise ; grain attack shape (from table)
  ienv_decay = giSigmoFall  ; grain decay shape (from table)
  ksustain_amount = 0.0 ; balance between enveloped time(attack+decay) and sustain level time, 0.0 = no time at sustain level

; FM of grain pitch (playback speed)
  ifmamptab	ftgentmp 0, 0, 16, -2,  0, 0,   1, 0, 0, 0 ; FM index scalers, per grain
  tablew kfm_mask2nd*((kpitchmask_enable*2)+1), 1, ifmamptab ; enable fm masking (every 2nd grain), but every 4th grain when also pitch masking
  ifmenv_tabsize = 4096
  if changed(kfmenv_ad_ratio, kfenv_sustain) > 0 then
    reinit fmenvtable
  endif
  fmenvtable:
  ifmenv_sustain = i(kfenv_sustain)*ifmenv_tabsize
  ifmenv_atck = i(kfmenv_ad_ratio)*(ifmenv_tabsize-ifmenv_sustain)
  ifmenv_dec = (1-i(kfmenv_ad_ratio))*(ifmenv_tabsize-ifmenv_sustain)
  ifmenv ftgen 0, 0, ifmenv_tabsize, 7, 0, ifmenv_atck, 1, ifmenv_sustain, 1, ifmenv_dec, 0 ; FM index envelope, over each grain
  rireturn
  awavfm init 0 ; feedback, the signal is written after the partikkel opcode
  if kfm_global > 0 then ; make fm feed signal global (simultaneous notes affecting each other)
    awavfm = gawavfm
  endif
  awavfm_test = awavfm ; just for debugging feedback delay adjustments

; init phase
  asamplepos1 = 0				; initial phase 

; masking
  igainmasks ftgentmp	0, 0, 16, -2, 0, 0,   1
  ichannelmasks	ftgentmp 0, 0, 16, -2,  0, 0,  0, 1
  tablew kpitchmask_enable, 1, ichannelmasks ; enable pitch masking (every 2nd grain)
  krandommask = 0
  iwaveamptab ftgentmp	0, 0, 32, -2, 0, 0,   1,0,0,0,0,   0,1,0,0,0
  tablew kpitchmask_enable, 1, iwaveamptab ; enable pitch masking (every 2nd grain)

  iopcode_id = 1

  a1,a2 partikkel agrainrate, kdistribution, idisttab, async, 0, -1, \
        ienv_attack, ienv_decay, ksustain_amount, ka_d_ratio, kduration, 1, igainmasks, \
        kwavfreq, 0.5, -1, -1, awavfm, \
        ifmamptab, ifmenv, giCosine, 1, 1, 1, \
        ichannelmasks, krandommask, giSine, giSine, giSine, giSine, \
        iwaveamptab, asamplepos1, asamplepos1, asamplepos1, asamplepos1, \
        kwavekey1, kwavekey2, 0, 0, 100, iopcode_id

  async partikkelsync iopcode_id

; filtering, also affects feedback
  klp_delay_compensate = 0
  khp_delay_compensate = 0
  if klpfilterfq < 9.9 then
    a1 butterlp a1, limit(klpfilterfq*kwavekey1, 20, 20000)
    a2 butterlp a2, limit(klpfilterfq*kwavekey1, 20, 20000)
    klpfilterfq_ratio = klpfilterfq ; the filterfq here is already a factor of the fundamental, so we do not divide
    klp_delay_compensate = -(1/kwavekey1)*(divz(1,klpfilterfq_ratio,1)) ; close to correct, but more than a few samples off when the ratio is low (we typically use ratio < 10)
  endif
  if khpfilterfq > 0.1 then
    a1 butterhp a1, khpfilterfq
    a2 butterhp a2, khpfilterfq
    khpfilterfq_ratio divz kwavekey1, khpfilterfq, 1
    khp_delay_compensate = (1/kwavekey1)*(1/khpfilterfq_ratio)*0.25 ; close to correct, might miss with a few samples
  endif
  
  ; combine grains from pitch masking into one feedback signal   
  ; and at the same time add AM to avoid DC components in feedback (ala V.Lazzarini 2023)
  ; the AM stabilizer leads to *instabilities* when the mod index is too high (just above 1.0),
  ; so we try to auto-adjust it
  kfm_mod init 0 ; need the variable before it has been adjusted (below)
  kam_stabilizer /= limit(kfm_mod,1,99)
  cabbageSetValue "AMstabilizerdisplay", kam_stabilizer, changed(kam_stabilizer)
  awavfm = (a1*(1-kgrainmask_feedmix)*(1+(awavfm*kam_stabilizer))) + \
           ((a2*kgrainmask_feedmix)*(1+(awavfm*kam_stabilizer)))

; enable fm index adjustment from target flux value
  kflux Fluxanalyzer awavfm, 8192, 0.002
  ifilter_skipreinit = 1
  kflux tonek kflux, kfluxfilt, ifilter_skipreinit
  cabbageSetValue "Flux", kflux, changed(kflux)
  ikybd_follow = (inum-60)/12 ; per octave adjustment, centered on note 60
  kflux_target = kflux_target-(kflux_target*kflux_target_kybd_follow*ikybd_follow)
  kfm_mod_fluxadjusted limit (kflux_target-kflux)*kfm_mod_control, 0, 100
  kfm_mod_fluxadjusted init 0
  if kfm_index_mode > 0 then
    kfm_mod = kfm_mod_fluxadjusted
  else
    kfm_mod = kfm_mod_control
  endif
  cabbageSetValue "Fluxauto_modindex", kfm_mod, changed(kfm_mod)
  awavfm *= kfm_mod

; feedback delay adjustment
  imaxdel = 1
  if kdel_syncmode == 0 then
    kfeed_delay_ limit (kfeed_delay*(1/kwavekey1))-(1/kr)+khp_delay_compensate+klp_delay_compensate, 0, imaxdel ; sync to pitch cycle
  else
    kfeed_delay_ limit (kfeed_delay*(1/kgrainrate))-(1/kr)+khp_delay_compensate+klp_delay_compensate, 0, imaxdel; sync to grain cycle
  endif
  awavfm vdelayx awavfm, a(kfeed_delay_), imaxdel, 4
  if kfm_global > 0 then ; make fm feed signal global (simultaneous notes affecting each other)
    gawavfm = awavfm
  endif
  
; amp and out
  aenv madsr iA, iD, iS, iR
  a1 *= aenv
  a2 *= aenv
  ; kwidth disabled for now
  ;aL = (a1*(1-kwidth)+a2*kwidth)*kamp*iamp_dB
  ;aR = (a2*(1-kwidth)+a1*kwidth)*kamp*iamp_dB
  aL = a1*kamp*iamp_dB
  aR = a1*kamp*iamp_dB
  outs	aL, aR
        
  endin

;******************************************************

</CsInstruments>
<CsScore>
i1 0 86400 ; gui handling
</CsScore>

</CsoundSynthesizer>
