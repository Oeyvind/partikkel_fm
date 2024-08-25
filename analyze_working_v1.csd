<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 2
0dbfs  = 1

instr 1

  a1  diskin2 "sideband_test4_partikl.wav", 1
  ifftsize = 8192
  ibins init ifftsize/2
  kIn[] init ifftsize
  kcnt init 0
  kIn shiftin a1
  kcnt += ksmps
  if kcnt == ifftsize then
    kWin[] window kIn
    kFFT[] = rfft(kWin)
    kMags[] = mags(kFFT)
    kcnt = 0
  endif
  icps = 400
  ihz_per_bin = (sr/ifftsize)
  ibin = round(icps/ihz_per_bin)
  kref_amp = kMags[ibin]
  ;printk2 kref_amp, 30
  kcps init icps

  ; tunable parameters
  ioctaves = 2
  imax_sidebands = 10 ; check sideband amplitudes at subdivisions of the fundamental frequency for all subdivisions from 1 to N
  ; report if *all* ((more than 70%) of the frequency bands have an amplitude higher than a threshold
  isideband_threshold = 1 ; sideband amplitude threshold, relative to average bin amp in sideband 
  isideband_percentage = 0.99 ; percentage of sidebands that must be present for the sibdivision to count as present
  
  ; array holds 
  ; number of sidebands found and
  kSidebands_present[] init imax_sidebands
  kdiv init 99 ; not to do the analysis at init, but wait for the first metro tick
  kBand[] init 1
  while kdiv <= imax_sidebands do 
    Sbin sprintfk "subdiv: %i", kdiv
    puts Sbin, kdiv
    kexpected_num_sidebands = kdiv
    koct_count = 1
    while koct_count < ioctaves do
      kexpected_num_sidebands += kdiv*(2^koct_count)
      koct_count += 1
    od
    Sexpected sprintfk "N Sidebands: %i for subdiv %i in %i octaves: threshold at %.1f sidebands", kexpected_num_sidebands, kdiv, ioctaves, kexpected_num_sidebands*isideband_percentage
    puts Sexpected, kdiv
    kcps = icps
    kbandwidth = kcps/kdiv
    kbins = round(kbandwidth/ihz_per_bin)
    ksideband_counter = 0
    while kcps < (icps*(2^ioctaves)-(ihz_per_bin/2)) do ; look for sidebands within two octaves above the fundamental
      kcps += icps/kdiv
      kbin = round(kcps/ihz_per_bin)
      Sbininfo sprintfk "bin:%i, fq:%f, amp:%f, rel_amp:%i", kbin, kbin*ihz_per_bin, kMags[kbin], dbfsamp(kMags[kbin]/kref_amp)
      puts Sbininfo, kbin
      reinit bandarray
      bandarray:
      kBand[] slicearray kMags, i(kbin)-round(i(kbins)/2), i(kbin)+round(i(kbins)/2)
      printarray kBand
      rireturn
      kavg_amp = sumarray(kBand)/kbins
      Sbininfo_avg sprintfk "    avg amp in band:%f,", kavg_amp
      puts Sbininfo_avg, kbin
      ksideband_present = kMags[kbin]/kavg_amp > isideband_threshold ? 1 : 0
      ksideband_counter += ksideband_present
      
      printk2 ksideband_counter
      if ksideband_counter > kexpected_num_sidebands*isideband_percentage then
        kSidebands_present[kdiv-1] = kdiv
        printarray kSidebands_present
      endif
    od
  kdiv +=1
  od

  ; reset for next test
  kmetro metro 1, 0.000001
  if kmetro > 0 then
   printarray kSidebands_present
   kdiv = 1
  endif
  

endin
</CsInstruments>
<CsScore>
f 1 0 4096 10 1

i 1 0 4
e
</CsScore>
</CsoundSynthesizer>