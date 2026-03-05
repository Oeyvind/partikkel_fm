<Cabbage>
form size(690, 645), caption("2 voice Partikkel feedback FM"), pluginId("pfm5"), colour(23,38,45), guiMode("queue")

label bounds(5,5,80,10), text("Osc1"), fontSize(13)
groupbox bounds(5,20,80,365),lineThickness("0"){
rslider channel("octave_1"), bounds(8, 8, 65, 65), text("Octave"), range(-4, 4, 0, 1, 1)

rslider channel("graindur_1_display"), bounds(8, 74, 65, 65),range(0.0, 2.5, 0.9, 1, 0.001), markerThickness(0), outlineColour(0,0,0,0), trackerInsideRadius(0.7), colour("black")
rslider channel("graindur_1"), bounds(9, 80, 63, 63), text("G.dur"), range(0.0, 2.5, 0.0, 1, 0.001), trackerColour(200,40,40), colour(90,80,35), markerColour(180,180,80)

rslider channel("grainpitch_1_display"), bounds(8, 144, 65, 65)range(0.5, 5, 1, 1, 0.001), markerThickness(0), outlineColour(0,0,0,0), trackerInsideRadius(0.7), colour("black")
rslider channel("grainpitch_1"), bounds(9, 150, 63, 63), text("G.pitch"), range(0.5, 5, 1, 1, 0.001), trackerColour(200,40,40), colour(90,80,35), markerColour(180,180,80)

rslider channel("modindex_1_display"), bounds(8, 214, 65, 65), range(0.0, 2.5, 0.3, 1, 0.001), markerThickness(0), outlineColour(0,0,0,0), trackerInsideRadius(0.7), colour("black")
rslider channel("modindex_1"), bounds(8, 220, 63, 63), text("Modindex"), range(0.0, 2.5, 0.0, 1, 0.001), trackerColour(200,40,40), colour(90,80,35), markerColour(180,180,80)

rslider channel("delaytime_1_display"), bounds(8, 284, 65, 65), range(0, 2.1, 0), markerThickness(0), outlineColour(0,0,0,0), trackerInsideRadius(0.7), colour("black")
rslider channel("delaytime_1"), bounds(8, 290, 63, 63), text("Delaytime"), range(0, 2.1, 0), trackerColour(200,40,40), colour(90,80,35), markerColour(180,180,80)
}

label bounds(165,5,80,10), text("Master"), fontSize(13)
groupbox bounds(165,20,80,365),lineThickness("0"), colour(70,20,20){
rslider channel("detune"), bounds(8, 8, 65, 65), text("Detune"), range(-50, 50, 0)
;rslider channel("grainpitch_0"), bounds(8, 148, 65, 65), text("G.pitch"), range(0.5, 5, 1, 1, 0.001)
;rslider channel("delaytime_0"), bounds(8, 288, 65, 65), text("Delaytime"), range(0.1, 2.1, 1, 1, 0.001)

rslider channel("xmod"), bounds(8, 78, 65, 65), text("Xmod"), range(0, 1, 0, 0.3, 0.0001)
rslider channel("portamento"), bounds(8, 148, 65, 65), text("Portamento"), range(0, 1, 0, 0.3, 0.0001)
rslider channel("width"), bounds(8, 218, 65, 65), text("Width"), range(0, 1, 1)
rslider channel("amp"), bounds(8, 288, 65, 65), text("Amp"), range(-96, 0, -5, 3, 0.1)
}

groupbox bounds(5,390,240,90),lineThickness("0"), colour(0,20,20){
label bounds(95, 0, 50, 15), text("Amp"), align("left") channel("label51")
gentable bounds(5, 5, 226, 62), channel("envelope1"), outlineThickness(3), tableNumber(1.0), tableBackgroundColour(0, 0, 0, 0),  tableGridColour(0,0,0,0), ampRange(0.0, 1.019999980926514, -1.0, 0.0100) tableColour:0(50, 100, 150, 255)
label bounds(5, 71, 15, 12), text("A:"), align("left") channel("label44")
nslider channel("Attack"), bounds(14, 70, 45, 15), range(0.001, 2, 0.01, 1, 0.001), fontSize(13)
label bounds(63, 71, 15, 12), text("D:"), align("left") channel("label46")
nslider channel("Decay"), bounds(74, 70, 43, 15), range(0.001, 2, 0.3, 1, 0.01), fontSize(13)
label bounds(121, 71, 15, 12), text("S:"), align("left") channel("label48")
nslider channel("Sustain"), bounds(132, 70, 43, 15), range(0, 1, 0.6, 1, 0.01), fontSize(13)
label bounds(179, 71, 15, 12), text("R:"), align("left") channel("label50")
nslider channel("Release"), bounds(189, 70, 43, 15), range(0.001, 2, 0.2, 1, 0.01), fontSize(13)
}

groupbox bounds(5,480,240,90),lineThickness("0"), colour(0,20,20){
rslider channel("drop_grainrate"), bounds(5, 5, 65, 65), text("Drop GR"), range(0.001, 1, 1, 0.3, 0.0001)
rslider channel("graindur_scaler"), bounds(75, 5, 65, 65), text("GR_scaler"), range(0.01, 1, 1)

}
; navigation
image bounds(265, 17, 200, 204), channel("navigator_dur_ndx"), colour(0,0,0,255), file("navigator_collage_dly_pitch.png"), crop(0,800,200,200)
xypad bounds(253, 5, 226, 265), channel("graindur_","modindex_"), colour(0,0,0,0), alpha(0.5)
; overview
image bounds(475, 20, 200, 200), channel("navigator_dur_ndx"), colour(0,0,0,255), file("navigator_collage_dly_pitch.png")
image bounds(475, 20, 10, 10), channel("dly_gp_navig"), colour(255,200,50,150)
;navigation
image bounds(265, 243, 200, 204), channel("navigator_dly_pitch"), colour(0,0,0,255), file("navigator_collage_dur_ndx.png"), crop(0,804,200,190)
xypad bounds(253, 229, 226, 265), channel("delaytime_","grainpitch_"), colour(0,0,0,0), alpha(0.5)
;overview
image bounds(475, 245, 200, 200), channel("navigator_dly_pitch"), colour(0,0,0,255), file("navigator_collage_dur_ndx.png")
image bounds(475, 245, 10, 10), channel("dur_ndx_navig"), colour(255,200,50,150)

; various labels and cosmetics
image bounds(255,5,450,15), colour(23,38,45)
label bounds(265,5,200,12), text("Navigation"), fontSize(13)
label bounds(475,5,200,12), text("Overview"), fontSize(13)

image bounds(255,222,220,21), colour(23,38,35)
label bounds(265,222,200,11), text("graindur"), fontSize(11)
image bounds(251,20,15,220), colour(23,38,35)
label bounds(254,222,200,11), text("modindex"), , fontSize(11), rotate(-1.57);), 265,222)

image bounds(255,447,220,36), colour(23,38,45)
label bounds(265,447,200,11), text("delay"), fontSize(11)
image bounds(251,245,15,220), colour(23,38,35)
label bounds(254,447,200,11), text("grainpitch"), fontSize(11), rotate(-1.57);), 265,222)

csoundoutput bounds(260,490,425,150)

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
  massign -1, 4
  chn_a "envamp", 2
  chn_k "envamp_", 2

;***************************************************
; Granular FM feedback instrument
;***************************************************
; Oeyvind Brandtsegg 2024
; obrandts@gmail.com

  giSine ftgen 0, 0, 65537, 10, 1 ; sine wave
  giCosine ftgen 0, 0, 8193, 9, 1, 1, 90 ; cosine wave	
  giSigmoRise ftgen 0, 0, 8193, 19, 0.5, 1, 270, 1 ; rising sigmoid
  giSigmoFall ftgen 0, 0, 8193, 19, 0.5, 1, 90, 1 ; falling sigmoid
  giSquareWin ftgen 0, 0, 8193, 7, 1, 8192, 1 ; square window 
  giEnv1 ftgen 1, 0, 1024, 7, 0, 1024, 1 ; just for gui display of adsr envelope

 
 
 ; ******************
; GUI control
instr 1

  ; parameter ranges
  imin_gd = 0.3
  imax_gd = 2.5
  istep_gd = 0.1
  insteps_gd = ((imax_gd-imin_gd)/istep_gd)+1

  imin_md = 0.3
  imax_md = 2.5
  istep_md = 0.1
  insteps_md = ((imax_md-imin_md)/istep_md)+1

  imin_gp = 0.5
  imax_gp = 5
  istep_gp = 0.25 ; base cps for analysis is 400Hz, increment 100Hz
  insteps_gp = ((imax_gp-imin_gp)/istep_gp)+1

  imin_dly = 0.1
  imax_dly = 2.0
  istep_dly = 0.1
  insteps_dly = ((imax_dly-imin_dly)/istep_dly)+1

  ; xypad1
  kdur_, kdur_trig cabbageGetValue "graindur_"
  kgraindur_1 chnget "graindur_1"
  kgraindur_2 chnget "graindur_2"
  cabbageSetValue "graindur_1_display", kgraindur_1+(kdur_*(imax_gd-imin_gd))+imin_gd, kdur_trig+changed(kgraindur_1,kgraindur_2)
  cabbageSetValue "graindur_2_display", kgraindur_2+(kdur_*(imax_gd-imin_gd))+imin_gd, kdur_trig+changed(kgraindur_1,kgraindur_2)

  kmod_, kmod_trig cabbageGetValue "modindex_"
  kmodindex_1 chnget "modindex_1"
  kmodindex_2 chnget "modindex_2"
  cabbageSetValue "modindex_1_display", kmodindex_1+(kmod_*(imax_md-imin_md))+imin_md, kmod_trig+changed(kmodindex_1,kmodindex_2)
  cabbageSetValue "modindex_2_display", kmodindex_2+(kmod_*(imax_md-imin_md))+imin_md, kmod_trig+changed(kmodindex_1,kmodindex_2)

  ;cabbageSetValue "gp_navig", kmod_, kmod_trig
  cabbageSet kdur_trig+kmod_trig, "dur_ndx_navig", sprintfk({{bounds(%i,%i,10,10)}}, 475+(kdur_*190),245+((1-kmod_)*190))

  ; navigator1 map update
  kdelaypos chnget "delaytime_"
  kdelayindex = int((kdelaypos*insteps_dly)-0.01)

  kgrainpitchpos chnget "grainpitch_"
  kpitchindex = int(((1-kgrainpitchpos)*insteps_gp)-0.01) 

  kdelayprint chnget "delaytime_1_display"
  kpitchprint chnget "grainpitch_1_display"
  ktrig changed kpitchindex,kdelayindex, kdelayprint, kpitchprint
  Spos sprintfk "navigator_dur_ndx  position %i %i, dly:%.2f ptch: %.2f", kdelayindex, kpitchindex, kdelayprint, kpitchprint
  puts Spos, ktrig+1
  cabbageSet ktrig, "navigator_dur_ndx", sprintfk({{crop(%d,%d,200,200)}},kdelayindex*200,(kpitchindex*200)-3)

  ; xypad2
  kdelay_, kdelay_trig cabbageGetValue "delaytime_"
  kdelaytime_1 chnget "delaytime_1"
  kdelaytime_2 chnget "delaytime_2"
  cabbageSetValue "delaytime_1_display", kdelaytime_1+(kdelay_*(imax_dly-imin_dly))+imin_dly, kdelay_trig+changed(kdelaytime_1,kdelaytime_2)
  cabbageSetValue "delaytime_2_display", kdelaytime_2+(kdelay_*(imax_dly-imin_dly))+imin_dly, kdelay_trig+changed(kdelaytime_1,kdelaytime_2)
  cabbageSetValue "dly_navig", kdelay_, kdelay_trig

  kpitch_, kpitch_trig cabbageGetValue "grainpitch_"
  kgrainpitch_1 chnget "grainpitch_1"
  kgrainpitch_2 chnget "grainpitch_2"
  cabbageSetValue "grainpitch_1_display", kgrainpitch_1*(kpitch_*(imax_gp-imin_gp))+imin_gp, kpitch_trig+changed(kgrainpitch_1,kgrainpitch_2)
  cabbageSetValue "grainpitch_2_display", kgrainpitch_2*(kpitch_*(imax_gp-imin_gp))+imin_gp, kpitch_trig+changed(kgrainpitch_1,kgrainpitch_2)
  
  ;cabbageSetValue "gp_navig", kpitch_, kpitch_trig
  cabbageSet kdelay_trig+kpitch_trig, "dly_gp_navig", sprintfk({{bounds(%i,%i,10,10)}}, 475+(kdelay_*190),20+((1-kpitch_)*190))

  ; navigator2 map update
  kmodindxpos chnget "modindex_"
  kmodindex_ = int(((1-kmodindxpos)*insteps_gd)-0.01)

  kgraindurpos chnget "graindur_"
  kgdurindex = int((kgraindurpos*insteps_md)-0.01)

  kdurprint chnget "graindur_1_display"
  kmodprint chnget "modindex_1_display"
  ktrig2 changed kmodindex_,kgdurindex, kdurprint, kmodprint
  Spos2 sprintfk "navigator_dly_pitch  position %i %i dur:%.2f mod: %.2f", kgdurindex, kmodindex_, kdurprint, kmodprint
  puts Spos2, ktrig2+1
  cabbageSet ktrig2, "navigator_dly_pitch", sprintfk({{crop(%d,%d,200,190)}},kgdurindex*200,(kmodindex_*200)+5)

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

  khost_playing chnget "IS_PLAYING"
  if (khost_playing == 0) && (changed(khost_playing) > 0) then
    event "i", -3.1, 0, -1
  endif

  awavfm_global chnget "wavfm_global" ; feedback from the other voice
  chnset awavfm_global, "wavfm_other"
  chnclear "wavfm_global"

endin

; midi instrument scheduler (mono)
instr 2
  inum notnum
  icps = cpsmidinn(inum)
  kcps = icps
  chnset kcps, "cps"
  ivel veloc
  xtratim 1/kr
  krelease release
  iactive active 2 ; how many instances currently running of this instrument
  kactive active 2
  if iactive == 1 then  
    event_i "i", 3.1, 0, -1 
  endif
  if (kactive == 1) && (krelease > 0) then
    event "i", -3.1, 0, -1
  endif
endin

; monophonic amp envelope
instr 3
  iatck chnget "Attack"
  idec chnget "Decay"
  isus chnget "Sustain"
  irel chnget "Release"
  isus = pow(isus,2)
  istartamp chnget "envamp_"
  atck expsega istartamp+0.0001, iatck, 1, idec, isus, 1, isus
  arel init 1
  xtratim irel
  krelease release
  if krelease > 0 then
    arel expon, 1, irel, 0.0001
  endif
  aenv = atck*arel
  chnset downsamp(aenv), "envamp_"
  chnset aenv, "envamp"
endin

instr 4
  kamp chnget "amp"
  kamp_dB = ampdbfs(kamp)
  iamp = ampdbfs(-6)
  ;amp chnget "envamp"
  ;kcps chnget "cps"
  inum notnum
  icps = cpsmidinn(inum)
  kcps = icps
  ivoice = 1 ; separate ivoice not used in poly


  iatck chnget "Attack"
  idec chnget "Decay"
  isus chnget "Sustain"
  irel chnget "Release"
  isus = pow(isus,2)
  istartamp chnget "envamp_"
  atck expsega istartamp+0.0001, iatck, 1, idec, isus, 1, isus
  arel init 1
  xtratim irel
  krelease release
  if krelease > 0 then
    arel expon, 1, irel, 0.0001
  endif
  amp = atck*arel


  Soctave sprintf "octave_%i", ivoice
  koctave chnget Soctave
  kcps *= semitone(koctave*12)
  kdetune chnget "detune"
  kdetune = ivoice == 1 ? 0 : kdetune
  kgrainrate_ = kcps+(kcps*cent(kdetune))
  kgrainrate_drop chnget "drop_grainrate"
  kgrainrate = kgrainrate_*kgrainrate_drop
  Smodindex sprintf "modindex_%i_display", ivoice
  kmodindex chnget Smodindex
  Sdelaytime sprintf "delaytime_%i_display", ivoice
  kfeed_delay chnget Sdelaytime ; feedback delay time (phase synced)
  klpfilterfq = 21000; bypass filter if cutoff above 20k
  khpfilterfq = 0 ; bypass filter if cutoff lower than 0.1
  iam_stabilizer = 0 ; switch for AM in feedback
  ; extra parameters for the grain generator moved to the end of the p-fields, to keep the first p-fields the same in both orchestras
  Sgrainpitch sprintf "grainpitch_%i_display", ivoice
  kgrainpitch chnget Sgrainpitch
  kgrainpitch *= kgrainrate_ ; relative to grainrate 
  Sgraindur sprintf "graindur_%i_display", ivoice
  kgraindur chnget Sgraindur
  kgraindur_scaler chnget "graindur_scaler"
  kgraindur *= kgraindur_scaler
  ;Stest sprintfk "   modindex %.2f, graindur %.2f", kmodindex, kgraindur
  ;puts Stest, changed(kmodindex, kgraindur)+1

  ka_d_ratio = 0.5 ; attack time (relative) for each grain
  ka_d_ratio *= kgraindur_scaler^2
  ksustain_amount = 0.33 ; sustain time (relative) in each grain
  kindex_mapping = 0 ; apply index adjustment formula 
  kinvphase2 = 0 ; invert phase of every 2nd grain
  kgrainrate = kinvphase2 > 0 ? kgrainrate*2 : kgrainrate; and double the grain rate when using phase inversion of every 2nd grain
  kportamento chnget "portamento"
  if kportamento > 0 then
    kgrainrate portk kgrainrate, kportamento*0.3
  endif

  ; index adjustment for granular FM, to attempt to keep the same modulation amount as we get in regular FM feedback
  if kindex_mapping == 1 then
    kmodindex = ((kmodindex)^1.8)/(kgraindur^0.7) ; empirical adjust mod index for these partikkelsettings
  endif
  ; always adjust amp slightly according to grain duration, as grain overlaps increase output amp
  kamp_adjust = iamp*limit(1/(kgraindur^0.5), 0.1, 4) ; empirical adjust amp for these partikkelsettings

  ; grain dur and  shape
  kduration	= (kgraindur*1000)/kgrainrate ; grain dur in milliseconds, relative to grain rate
  ienv_attack = giSigmoRise ; grain attack shape (from table)
  ienv_decay = giSigmoFall  ; grain decay shape (from table)
  
  ; fm signal
  Swavfm sprintf "wafm_%i", inum
  awavfm chnget Swavfm ; feedback, the signal is written after the partikkel opcode
  ; ADD crossmodulation between the two oscillators here
  kcrossmod chnget "xmod"
  awavfm_other chnget "wavfm_other" ; feedback from the other voice
  awavfm = awavfm*(sqrt(1-kcrossmod))+awavfm_other*sqrt(kcrossmod)

  ; other
  asamplepos1 = 0				; initial phase of wave inside each grain
  async init 0 
  kdistribution	= 0.0 ; grain random distribution in time
  idisttab ftgentmp 0, 0, 16, 16, 1, 16, -10, 0	; probability distribution for random grain masking

  ; masking (not active)
  ifmamptab	ftgentmp 0, 0, 16, -2,  0, 0,   1, 0, 0, 0 ; FM index scalers, per grain
  ifmenv = giSquareWin
  igainmasks ftgentmp	0, 0, 16, -2, 0, 0,  1, -1
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
  ;printk2 kmodindex
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
  chnset awavfm, Swavfm
  chnmix awavfm, "wavfm_global"

  ; amp and out
  
  a1 *= kamp_dB*amp
  kwidth chnget "width"
  kpan = ((((inum%5)*0.25)-0.5)*kwidth)+0.5 
  aL = a1*sqrt(1-kpan)
  aR = a1*sqrt(kpan)
  outs	aL, aR
 
endin

</CsInstruments>
<CsScore>
i1  0  86400 ; gui control
;i4  0  86400 1 ; voice 1
;i4  0  86400 2 ; voice 2
</CsScore>
</CsoundSynthesizer>
