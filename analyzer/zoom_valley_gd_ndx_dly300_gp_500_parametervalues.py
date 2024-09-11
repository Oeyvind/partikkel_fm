
import numpy as np
# test parameters
graindurs = np.around(np.arange(0.9,2.0,0.05),2).tolist()
#[0.8, 0.85, 0.9, 0.95, 1.0, 1.05, 1.1, 1.15, 1.2, 1.3, 1.4, 1.5, 1.6]
modindices = np.around(np.arange(0.7,2.0,0.05),2).tolist()
#[0.8, 0.9, 1, 1.1, 1.2, 1.3, 1.4, 1.5]
delays = np.around(np.arange(0.3,0.4,0.005),2).tolist()
#[0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8]
grainpitches = np.around(np.arange(490,620,5),2).tolist()

