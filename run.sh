#!/bin/bash
python3 ./src/main.py --display ssd1322 --width 256 --height 64 --interface spi --mode 1 
# put rotate back into start line if your display is mounted upside down with the SPI
# interface on the left. The platform based station display doesn't need the rotation
# --rotate 2
