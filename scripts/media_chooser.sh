#!/bin/bash

DIR=${1#/home/joshi/digital_media_frame/}
DIR=${DIR//$'\n'}

cd /home/joshi/digital_media_frame
# ./media_chooser.pl "${NAUTILUS_SCRIPT_SELECTED_FILE_PATHS#/home/joshi/digital_media_frame/}" &> /tmp/tmp.sh
./scripts/media_chooser.pl "$DIR" &> /home/joshi/digital_media_frame/mc.err
# echo -n "${NAUTILUS_SCRIPT_SELECTED_FILE_PATHS#/home/joshi/digital_media_frame/}" &> /tmp/tmp.sh
