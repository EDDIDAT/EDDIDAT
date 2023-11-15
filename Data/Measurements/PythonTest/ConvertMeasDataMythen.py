# -*- coding: utf-8 -*-
"""
Convert 2D meas data from Mythen detector using "FuzzyGridder1D" python script
Return is X and Y of binned data. Input is matrices with intensity and twotheta 
data of format n x 640 (n = number of twotheta positions)
"""

import xrayutilities as xu
# Load gridder
g = xu.gridder.FuzzyGridder1D(NumBins)
# Start gridding
g(angles, intensity, 0.00005)

X = g.xaxis
Y = g.data

ReturnList=[X,Y]