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
  kmodindex = p6
  kfeed_delay = p7 ; feedback delay time (phase synced)
  klpfilterfq = p8; bypass filter if cutoff above 20k
  khpfilterfq = p9 ; bypass filter if cutoff lower than 0.1
  iam_stabilizer = p10 ; switch for AM in feedback
  ; extra parameters for the grain generator moved to the end of the p-fields, to keep the first p-fields the same in both orchestras
  kgrainpitch = p11
  kgraindur = p12
  ka_d_ratio = p13 ; attack time (relative) for each grain
  ksustain_amount = p14 ; sustain time (relative) in each grain
  kindex_mapping = p15 ; apply index adjustment formula 
  kinvphase2 = p16 ; invert phase of every 2nd grain
  kgrainrate = kinvphase2 > 0 ? kgrainrate*2 : kgrainrate; and double the grain rate when using phase inversion of every 2nd grain

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
  chnset a1, "audio"
  out	a1
 
endin

instr 2
  icps = p4
  Sfilename strget p5
  a1  chnget "audio"
  ;a1 rnd31 1,1
  ;a1 oscil 0.9, 400
  ;a1 += 0.5
  ;a2 oscil 0.17, 800
  ;a1 = a1+a2
  /*
  a2 oscil 0.5, 400
  a1 rnd31 1,1
  a1 butterbp a1, 500, 100
  a1 = a1+a2
*/
  ifftsize = 8192
  ibins init ifftsize/2
  kIn[] init ifftsize
  ihz_per_bin = (sr/ifftsize)
  print ihz_per_bin
  ktime timeinsts
  kcentrig metro 100
  kcentroid_test centroid butterhp(a1,3), kcentrig, ifftsize ; might need to implement this "manually" on the fft where I can zero out the DC

  ; tunable parameters
  ioctaves = 2
  imax_sidebands = 10 ; check sideband amplitudes at subdivisions of the fundamental frequency for all subdivisions from 1 to N
  ; report if *all* ((more than 70%) of the frequency bands have an amplitude higher than a threshold
  isideband_threshold = 1.2 ; sideband amplitude threshold, relative to average bin amp in sideband 
  
  ; array holds 
  ; number of sidebands found, expected number of sidebands, and average crest values for each N-subdivision present 
  ; First line holds global analysis parameters:
  ; dc, crest, centroid, rolloff
  kAnalysis[] init imax_sidebands+1, 4

  ; wait for trig before doing analysis
  kdiv init 99 
  kwritefile init 0
  kBand[] init 1 ; just need it present at init, size will change for each subdiv 

  ; trigger analysis
  kmetro metro 1, 0.5 ; after 0.5 and 1.5 secs
  if kmetro > 0 then
   kdiv = 1
   kwritefile = 1
  endif

  if kdiv == 1 then
    kcnt init 0
    kIn shiftin a1
    kframe_ready = 0
    kcnt += ksmps
    if kcnt == ifftsize then
      kWin[] window kIn
      kFFT[] = rfft(kWin)
      kMags[] = mags(kFFT)
      kDC = abs(kMags[0]) ; DC component
      kcnt = 0
      kframe_ready = 1
    endif
  
    if kframe_ready > 0 then 
      kMags[0] = 0 ; workaround for DC offset in crest calculation
      kMags[1] = 0 ; also zero the seconde bin, since there will be a leak from the first one 
      ksum_amp = sumarray(kMags)
      kavg_amp_0 = ksum_amp/ibins
      kmax_amp_0,kdx maxarray kMags
      kDC_relative divz kDC, kavg_amp_0, -1 ; dc relative to overall amp
      
      kcrest divz kmax_amp_0, kavg_amp_0, -1 ; spectral crest

      kcentroid = 0
      kndx_moments = 0
      while kndx_moments < (ifftsize/2) do
        kcentroid += kMags[kndx_moments]*(ihz_per_bin*kndx_moments)
        kndx_moments += 1
      od
      kcentroid /= (kavg_amp_0*ibins)

      irolloff_thresh = 0.95
      krolloff_fq = 0
      krolloff_amp = 0
      kndx_moments = 0
      while kndx_moments < (ifftsize/2) do
        krolloff_amp += kMags[kndx_moments]
        if krolloff_amp < (ksum_amp*irolloff_thresh) then
          krolloff_fq = kndx_moments*ihz_per_bin
        endif
        kndx_moments += 1
      od
      ;printk2 krolloff_fq, 20

      /*
      ; Tried these before too, and I do not seem to get anything useful out of them
      kspread = 0
      kndx_moments = 0
      while kndx_moments < (ifftsize/2) do
        kspread += kMags[kndx_moments]*(((ihz_per_bin*kndx_moments)-kcentroid)^2)
        kndx_moments += 1
      od
      kspread = kspread^0.5

      kskewness = 0
      kndx_moments = 0
      while kndx_moments < (ifftsize/2) do
        kskewness += kMags[kndx_moments]*(((ihz_per_bin*kndx_moments)-kcentroid)^3)
        kndx_moments += 1
      od
      kskewness divz kskewness, kspread^3, 0

      ;kflatness = 1
      ;kndx_moments = 0
      ;while kndx_moments < (ifftsize/2) do
      ;  kflatness *= kMags[kndx_moments]*0.1
      ;  ;printk2 kflatness, 20
      ;  kndx_moments += 1
      ;od
      ;kflatness = (kflatness/kavg_amp_0)^(1/(ifftsize/2))
      
      kMags += 0.1 ; workaround for flatness calculation
      kflatness	divz exp(sumarray(log(kMags))/ibins),  kavg_amp_0, 0
      if qnan(kflatness) > 0 then
        kflatness = -1
      endif
      ;kflatness = kflatness^0.3
      printk2 kflatness, 10
      */

      kAnalysis[0][0] = kDC_relative
      kAnalysis[0][1] = kcrest
      kAnalysis[0][2] = kcentroid
      kAnalysis[0][3] = krolloff_fq

      while kdiv <= imax_sidebands do 
        ;Sbin sprintfk "*** *** subdiv: %i", kdiv
        ;puts Sbin, kdiv

        kexpected_num_sidebands = kdiv ; expected number of sidebands in the first octave
        koct_count = 1
        while koct_count < ioctaves do
          kexpected_num_sidebands += kdiv*(2^koct_count) ; expected number of sidebands in the next octaves
          koct_count += 1
        od

        kAnalysis[kdiv][1] = kexpected_num_sidebands ; record the expected number of sidebands (so we can take a percentage later)
        kcps = icps
        kbandwidth = kcps/kdiv
        kbins = round(kbandwidth/ihz_per_bin)
        ;printk2 kbandwidth, 10
        ;printk2 kbins, 20
        ksideband_counter = 0
        ksideband_crest = 0
        while kcps < (icps*(2^ioctaves)-(ihz_per_bin/2)) do ; look for sidebands within two octaves above the fundamental
          kcps += icps/kdiv
          kbin = round(kcps/ihz_per_bin)
          ;Sbininfo sprintfk "bin:%i, fq:%f, amp:%f", kbin, kbin*ihz_per_bin, kMags[kbin]
          ;puts Sbininfo, kbin
          reinit bandarray
          bandarray:
            ; bandwidth equals distance between sidebands
            ; get all bins within half the bandwidth above and below the center freq for the sideband
            kBand[] slicearray kMags, i(kbin)-int(i(kbins)/2), i(kbin)+round(i(kbins)/2)
            ;printarray kBand
          rireturn
          kavg_amp = sumarray(kBand)/(kbins)
          ;Sbininfo_avg sprintfk "    avg amp in band:%f,", kavg_amp
          ;puts Sbininfo_avg, kbin
          ksideband_crest += kMags[kbin]/kavg_amp
          ksideband_present = kMags[kbin]/kavg_amp > isideband_threshold ? 1 : 0
          ksideband_counter += ksideband_present
        od
        kAnalysis[kdiv][0] = ksideband_counter ; number of sidebands found
        kAnalysis[kdiv][2] = ksideband_crest ; spectral crest within this sideband
      kdiv +=1
      od

      if kwritefile > 0 then
        ;printarray kAnalysis
        kwritefile = 0
        gkAnalysis[] = kAnalysis
        Sscoreline sprintf {{i3 0 0.1 "%s"}}, Sfilename
        scoreline Sscoreline, 1
      endif
    endif ; frame ready
  endif ; metro trig

  endin

  instr 3
  ;print p1, p2, p3
  ; write analysis to file
  Sfilename strget p4
  Sfilename strcat Sfilename, "_analyze.txt"
  ilen = lenarray(gkAnalysis)
  Sinfo sprintfk "\ndc %.2f \ncrest %.2f\ncentroid %.2f\nrolloff %.2f\n", 
                gkAnalysis[0][0],
                gkAnalysis[0][1],
                gkAnalysis[0][2],
                gkAnalysis[0][3]
  kprint init 0
  kprint += 1
  puts Sinfo, kprint
  printarray gkAnalysis
  p3 = 1/kr
  kndx = 0
  while kndx < ilen do
    ksig1 = gkAnalysis[kndx][0]
    ksig2 = gkAnalysis[kndx][1]
    ksig3 = gkAnalysis[kndx][2]
    ksig4 = gkAnalysis[kndx][3]
    dumpk4 ksig1, ksig2, ksig3, ksig4, Sfilename, 8, 0
    kndx += 1
  od
  endin

