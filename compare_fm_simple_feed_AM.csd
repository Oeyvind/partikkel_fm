<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

  sr = 48000
  ksmps = 1
  nchnls = 2
  0dbfs = 1

;***************************************************
; FM instrument, simple
;***************************************************
instr 1

  iamp = ampdbfs(p4)
  icps = p5
  kmodindex line 0, p3, p6
  kfeed_delay = 0.75 ; feedback delay time (phase synced)
  klpfilterfq = 21000; bypass filter if cutoff above 20k
  khpfilterfq = 0 ; bypass filter if cutoff lower than 0.1
  iam_stabilizer = 1 ; switch for AM in feedback
   
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
; compensate for delay introduced by the filters 
  kfeed_delay_ limit (kfeed_delay*(1/icps))-(1/kr)+khp_delay_compensate+klp_delay_compensate, 0, 1 
  amod vdelayx amod, a(kfeed_delay_), 1, 4 
  
; audio out
 outs acar*iamp, acar*iamp
endin

</CsInstruments>
<CsScore>

;         amp  cps  mod 
i1  0  3  -7   400  1.5
i1  ^+4  3  .  100 .
e

</CsScore>
</CsoundSynthesizer>
