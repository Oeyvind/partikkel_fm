<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 2
0dbfs  = 1

instr 1

  a1  diskin2 "sideband_test3_partikl.wav", 1
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
  kcps init icps
  ioctaves = 2
  imax_sidebands = 4 ; check sideband amplitudes at subdivisions of the fundamental frequency for all subdivisions from 1 to N
  ; report if *all* ((more than 70%) of the frequency bands have an amplitude higher than a threshold
  isideband_threshold = -30 ; sideband amplitude threshold, relative to amp of fundamental
  isideband_percentage = 0.7 ; percentage of sidebands that must be present for the sibdivision to count as present
  kSidebands_present[] init imax_sidebands ; array holds zeroes for nonpresent sideband divisions, and N for each N-subdivision present 
  kdiv init 99 ; not to do the analysis at init, but wait for the first metro tick
  while kdiv <= imax_sidebands do 
    Sbin sprintfk "subdiv: %i", kdiv
    puts Sbin, kdiv
    kcps = icps
    ksideband_counter = 0
    while kcps < (icps*(2^ioctaves)-(ihz_per_bin/2)) do ; look for sidebands within two octaves above the fundamental
      kcps += icps/kdiv
      kbin = round(kcps/ihz_per_bin)
      Sbininfo sprintfk "bin:%i, fq:%f, amp:%i", kbin, kbin*ihz_per_bin, dbfsamp(kMags[kbin]/kref_amp)
      puts Sbininfo, kbin
      Sbininfo1 sprintfk "    bin:%i, fq:%f, amp:%i", kbin-1, (kbin-1)*ihz_per_bin, dbfsamp(kMags[kbin-1]/kref_amp)
      Sbininfo2 sprintfk "    bin:%i, fq:%f, amp:%i", kbin+1, (kbin+1)*ihz_per_bin, dbfsamp(kMags[kbin+1]/kref_amp)
      puts Sbininfo1, kbin
      puts Sbininfo2, kbin
      ksideband_present = dbfsamp(kMags[kbin]/kref_amp) > isideband_threshold ? 1 : 0
      ksideband_counter += ksideband_present
      kexpected_num_sidebands = kdiv
      koct_count = 1
      while koct_count < ioctaves do
        kexpected_num_sidebands += kdiv*(2^koct_count)
        koct_count += 1
      od
      Sexpected sprintfk "N Sidebands: %i for subdiv %i in %i octaves: threshold at %.1f sidebands", kexpected_num_sidebands, kdiv, ioctaves, kexpected_num_sidebands*isideband_percentage
      puts Sexpected, kdiv
      
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