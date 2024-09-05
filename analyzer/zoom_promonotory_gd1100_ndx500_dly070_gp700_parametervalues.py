
import numpy as np
# test parameters

graindurs = np.around(np.arange(1.05,2.1,0.04),2).tolist()
#[0.8, 0.85, 0.9, 0.95, 1.0, 1.05, 1.1, 1.15, 1.2, 1.3, 1.4, 1.5, 1.6]
modindices = np.around(np.arange(0.55,1.35,0.03),2).tolist()
#[0.8, 0.9, 1, 1.1, 1.2, 1.3, 1.4, 1.5]
delays = np.around(np.arange(0.05,0.2,0.01),2).tolist()
#[0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8]
grainpitches = np.around(np.arange(600,1600,60),2).tolist()

