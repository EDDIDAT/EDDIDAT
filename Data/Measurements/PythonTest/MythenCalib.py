# -*- coding: utf-8 -*-
"""
Calibrate Mythen detector using twotheta scans thorugh the primary beam. 
The fitting gives estiamtes for zero channel n0, detector tilt beta and 
distance between source and detector. 
"""

import xrayutilities as xu

pwidth, cch, tilt = xu.analysis.linear_detector_calib(angles, spectra, usetilt=True)


ReturnList=[pwidth,cch,tilt]