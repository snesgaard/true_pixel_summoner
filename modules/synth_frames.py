import numpy as np
import cv2
import sys

if len(sys.argv) < 2:
    sys.exit(0)

def im_lead(p):
    return cv2.imread(p, -1)

im = np.hstack(map(im_lead, sys.argv[2:]))
cv2.imwrite(sys.argv[1], im)
