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
  ;kref_amp = kMags[ibin]
  ;printk2 kref_amp, 30
  kcps init icps

  ; tunable parameters
  ioctaves = 2
  imax_sidebands = 10 ; check sideband amplitudes at subdivisions of the fundamental frequency for all subdivisions from 1 to N
  ; report if *all* ((more than 70%) of the frequency bands have an amplitude higher than a threshold
  isideband_threshold = 1 ; sideband amplitude threshold, relative to average bin amp in sideband 
  ;isideband_percentage = 0.7 ; percentage of sidebands that must be present for the subdivision to count as present
  
  ; array holds 
  ; number of sidebands found,
  ; expected nummber of sidebands, and
  ; sum of crest values for each N-subdivision present 
  kSidebands_present[] init imax_sidebands+1, 3
  kavg_amp_0 = sumarray(kMags)/ibins
  kmax_amp_0 maxarray kMags
  kcrest = kmax_amp_0/kavg_amp_0
  kSidebands_present[0][2] = kcrest

  kdiv init 99 ; not to do the analysis at init, but wait for the first metro tick
  kBand[] init 1 ; just need it present at init, size will change for each subdiv 
  while kdiv <= imax_sidebands do 
    Sbin sprintfk "*** *** subdiv: %i", kdiv
    puts Sbin, kdiv
    kexpected_num_sidebands = kdiv ; expected number of sidebands in the first octave
    koct_count = 1
    while koct_count < ioctaves do
      kexpected_num_sidebands += kdiv*(2^koct_count) ; expected number of sidebands in the next octaves
      koct_count += 1
    od
    kSidebands_present[kdiv][1] = kexpected_num_sidebands ; record the expected number of sidebands (so we can take a percentage later)
    kcps = icps
    kbandwidth = kcps/kdiv
    kbins = round(kbandwidth/ihz_per_bin)
    printk2 kbandwidth, 10
    printk2 kbins, 20
    ksideband_counter = 0
    ksideband_crest = 0
    while kcps < (icps*(2^ioctaves)-(ihz_per_bin/2)) do ; look for sidebands within two octaves above the fundamental
      kcps += icps/kdiv
      kbin = round(kcps/ihz_per_bin)
      Sbininfo sprintfk "bin:%i, fq:%f, amp:%f", kbin, kbin*ihz_per_bin, kMags[kbin]
      puts Sbininfo, kbin
      reinit bandarray
      bandarray:
      kBand[] slicearray kMags, i(kbin)-int(i(kbins)/2), i(kbin)+round(i(kbins)/2)
      printarray kBand
      rireturn
      kavg_amp = sumarray(kBand)/(kbins)
      Sbininfo_avg sprintfk "    avg amp in band:%f,", kavg_amp
      puts Sbininfo_avg, kbin
      ksideband_crest += kMags[kbin]/kavg_amp
      ksideband_present = kMags[kbin]/kavg_amp > isideband_threshold ? 1 : 0
      ksideband_counter += ksideband_present
      ;printk2 ksideband_counter
      if ksideband_present > 0 then
        kSidebands_present[kdiv][0] = ksideband_counter;/kdiv
        ;printarray kSidebands_present
      endif
      kSidebands_present[kdiv][2] = ksideband_crest
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