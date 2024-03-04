;***************************************************
; FM feedback instrument, regular oscillator
;***************************************************
; Oeyvind Brandtsegg 2024
; obrandts@gmail.com

  sr = 48000
  ksmps = 1
  nchnls = 1
  0dbfs = 1

instr 1

  iamp = ampdbfs(p4)
  icps = p5
  imodindex_start = p6
  imodindex_end = p7
  print iamp, icps, imodindex_start, imodindex_end
  kmodindex line imodindex_start, p3, imodindex_end
  ifmfq = p8
 
  ; FM
  amod oscili kmodindex*ifmfq, ifmfq
  acar oscili 1, icps+amod

  ; audio out
  out acar*iamp
endin

