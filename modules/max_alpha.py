import cv2
import sys

im = cv2.imread(sys.argv[1], -1)

m = im[:, :, 3] > 10

hsv = cv2.cvtColor(im[:, :, :3], cv2.COLOR_BGR2HSV)
hsv[:, :, 1] = 255
hsv[hsv[:, :, 2] > 10, 2] = 255
im[:, :, :3] = cv2.cvtColor(hsv, cv2.COLOR_HSV2BGR)

im[m, 3] = 255

cv2.imwrite(sys.argv[2], im)
