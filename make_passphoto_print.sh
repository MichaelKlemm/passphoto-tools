#!/usr/bin/env zsh

# Groesse in cm des Zielformats
PHOTO_W=10
PHOTO_H=15

PASSPHOTO_SIZE_W=3.5
PASSPHOTO_SIZE_H=4.5

# Oft 'zoomen' Fotodrucker etwas heran um mögliche Rahmen auszuschliessen.
# Ein Wert von 0.9 meint dass das Foto 10% kleiner gedruckt werden soll da der Drucker 10% 'zoomt'
# Meine Erfahrung bei dm zeigte dass 0.97 ein guter Wert ist.
RATIO_TO_FIX_PRINTER_OFFSET=0.97

PASSPHOTO_SIZE_W=$(( ${PASSPHOTO_SIZE_W} * ${RATIO_TO_FIX_PRINTER_OFFSET} ))
PASSPHOTO_SIZE_H=$(( ${PASSPHOTO_SIZE_H} * ${RATIO_TO_FIX_PRINTER_OFFSET} ))
WORK_DIR=$(pwd)
SCRIPT_DIR=$(cd $(dirname $0) && pwd)

if [[ -z "$1" ]]; then
  echo "No input file given. Usage: $0 <IMG>"
  exit 1
fi

IMAGE_IN_PATH=$(cd $SCRIPT_DIR && cd $(dirname $1) && pwd)/$(basename $1)
IMAGE_OUT_PATH=$(cd $SCRIPT_DIR && cd $(dirname $1) && pwd)/out-${PHOTO_W}x${PHOTO_H}.jpg

if [[ ! -f "${IMAGE_IN_PATH}" ]]; then
  echo "File not found: ${IMAGE_IN_PATH}"
  exit 1
fi

# Auslesen des Formats der Quelldatei
eval $(identify -format 'IMG_WIDTH=%w\nIMG_HIGHT=%h\n' ${IMAGE_IN_PATH})
echo "Using file ${IMAGE_IN_PATH} with size ${IMG_WIDTH}x${IMG_HIGHT}"

# Berechnung der horizontalen und vertikalen Rahmen
BORDER_VERT="$(echo $(( (( ${IMG_WIDTH} / ${PASSPHOTO_SIZE_W} * ${PHOTO_W} ) - ( 2 * ${IMG_WIDTH} )) / 4 )) | awk '{ print int($1) }')"
BORDER_HORT="$(echo $(( (( ${IMG_HIGHT} / ${PASSPHOTO_SIZE_H} * ${PHOTO_H} ) - ( 2 * ${IMG_HIGHT} )) / 4 )) | awk '{ print int($1) }')"

# Anwendung des Tools montage
montage \
  ${IMAGE_IN_PATH} ${IMAGE_IN_PATH} ${IMAGE_IN_PATH} ${IMAGE_IN_PATH} \
  -geometry ${IMG_WIDTH}x${IMG_HIGHT}+${BORDER_VERT}+${BORDER_HORT} \
  -quality 100 \
  ${IMAGE_OUT_PATH}

