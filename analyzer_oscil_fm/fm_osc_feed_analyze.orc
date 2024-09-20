;***************************************************
; FM feedback instrument and timbre analysis
;***************************************************
; Oeyvind Brandtsegg 2024
; obrandts@gmail.com

   sr = 768000 
   ksmps = 1
   nchnls = 1
   0dbfs	= 1

instr 1

  iamp = ampdbfs(p4)
  icps = p5
  imodindex = p6
  kfeed_delay = p7 ; feedback delay time (phase synced)
  klpfilterfq = p8; bypass filter if cutoff above 20k
  khpfilterfq = p9 ; bypass filter if cutoff lower than 0.1
  iam_stabilizer = p10 ; switch for AM in feedback
   
  ; FM
  amod init 0 ; init feedback signal
  amod = icps+(amod*imodindex)
  acar oscili 1, amod
  amod_ = acar ; route output to feedback

  ; filtering of feedback signal
  klp_delay_compensate = 0
  khp_delay_compensate = 0
  if klpfilterfq < 20000 then
    amod_ butterlp amod_, klpfilterfq
    klpfilterfq_ratio divz klpfilterfq, icps, 1 ; calculate filter delay at fundamental (source wave frequency), so we use the ratio between filter fq and fundamental fq 
    klp_delay_compensate = -(1/icps)*divz(1,klpfilterfq_ratio,1)*0.25
  endif
  if khpfilterfq > 0.1 then
    amod_ butterhp amod_, khpfilterfq
    khpfilterfq_ratio divz icps, khpfilterfq, 1 ; opposite from for the LP filter, since our filter fq now is lower than the fundamental
    khp_delay_compensate = (1/icps)*divz(1,khpfilterfq_ratio,1)*0.25 ; so we use the ratio between filter fq and fundamental fq to get there
  endif
  
  ; AM on feedback to avoid DC components (ala V.Lazzarini 2023)
  if iam_stabilizer > 0 then
    amod = (amod_*amod)
  else
    amod = amod_*icps
  endif

  ; feedback delay adjustment 
  ; sync delay to to pitch cycle (phase sync)
  ; compensate for delay introduced by the filters and for the ksmps delay in the feedback
  kfeed_delay_ limit (kfeed_delay*(1/icps))-(1/kr)+khp_delay_compensate+klp_delay_compensate, 0, 1 
  amod vdelayx amod, a(kfeed_delay_), 1, 4 
  
  ; audio out
  a1 = acar*iamp 
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
  kpitch,knull ptrack a1, 2048

  ; Analysis for: dc, crest, centroid, rolloff, pitch
  ; Store values for each of these after 0.5 sec and after 1.5 sec
  kAnalysis[] init 2,5

  ; wait for trig before doing analysis
  kwritefile init 0 ; not needed
  
  ; trigger analysis
  kmetro metro 1, 0.5 ; after 0.5 and 1.5 secs
  kmeasure init -1
  if kmetro > 0 then
   kfft_trig = 1
   kmeasure += 1
   kwritefile = kmeasure == 1 ? 1 : 0
  endif

  if kfft_trig == 1 then
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
      kMags = abs(kMags)  ; ALL POSITIVE AMPS
      ksum_amp = sumarray(kMags)
      kavg_amp_0 = ksum_amp/ibins
      kmax_amp_0,kdx maxarray kMags
      kDC_relative divz abs(kDC), ksum_amp, -1 ; dc relative to sum of amplitudes
      kDC_relative = abs(kDC_relative)

      kcentroid = 0
      kndx_moments = 0
      while kndx_moments < (ifftsize/2) do
        kcentroid += kMags[kndx_moments]*(ihz_per_bin*kndx_moments)
        kndx_moments += 1
      od
      kcentroid /= (kavg_amp_0*ibins)

      ; custom spectral rolloff method
      ; measure how much of the energy resides in the high frequencies
      ; so... compare amp in the high frequency band with the overall amp for the sound
      irolloff_cutoff = icps*4 ;  energy in the band oabove 2 octaves above the fundamental
      irolloff_firstbin = round(irolloff_cutoff/ihz_per_bin)
      kHighband[] init ibins - irolloff_firstbin
      kHighband[] slicearray kMags, irolloff_firstbin, ibins
      khigh_amp sumarray kHighband
      krolloff_2khz = khigh_amp/ksum_amp ; relative to sum of amplitudes

      kMags[0] = 0 ; workaround for DC offset in crest calculation
      kMags[1] = 0 ; also zero the second bin, since there will be a leak from the first one 
      kcrest divz kmax_amp_0, kavg_amp_0, -1 ; spectral crest
 
      kAnalysis[kmeasure][0] = kDC_relative
      kAnalysis[kmeasure][1] = kcrest
      kAnalysis[kmeasure][2] = kcentroid
      kAnalysis[kmeasure][3] = krolloff_2khz
      kAnalysis[kmeasure][4] = kpitch

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
  Sinfo sprintfk "\ndc %.2f \ncrest %.2f\ncentroid %.2f\nrolloff %.2f\npitch %.2f\n", 
                gkAnalysis[0][0],
                gkAnalysis[0][1],
                gkAnalysis[0][2],
                gkAnalysis[0][3],
                gkAnalysis[0][4]
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
    ;ksig4 = gkAnalysis[kndx][3] ; skip rolloff for now
    ksig5 = gkAnalysis[kndx][4]
    dumpk4 ksig1, ksig2, ksig3, ksig5, Sfilename, 8, 0
    kndx += 1
  od
  endin

