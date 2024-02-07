;***************************************************
; FM feedback instrument, regular oscillator
;***************************************************
; Oeyvind Brandtsegg 2024
; obrandts@gmail.com

  sr = 48000
  ksmps = 10
  nchnls = 1
  0dbfs = 1

instr 1

  iamp = ampdbfs(p4)
  icps = p5
  imodindex_start = p6
  imodindex_end = p7
  print iamp, icps, imodindex_start, imodindex_end
  kmodindex line imodindex_start, p3, imodindex_end
  kfeed_delay = p8 ; feedback delay time (phase synced)
  klpfilterfq = p9; bypass filter if cutoff above 20k
  khpfilterfq = p10 ; bypass filter if cutoff lower than 0.1
  iam_stabilizer = p11 ; switch for AM in feedback
   
  ; FM
  amod init 0 ; init feedback signal
  amod = icps+(amod*kmodindex)
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
  out acar*iamp
endin

