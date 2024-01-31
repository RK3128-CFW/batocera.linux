#!/bin/sh

BOARD_DIR="$(dirname $0)"
GENIMAGE_CFG="${BOARD_DIR}/genimage.cfg"
GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"

rm -rf "${GENIMAGE_TMP}"

mkdir -p "${BINARIES_DIR}/boot"
cp "${BINARIES_DIR}/rootfs.ext2" "${BINARIES_DIR}/boot/batocera"
cp "${BOARD_DIR}/batocera.board" "${BINARIES_DIR}/boot/batocera.board"
touch "${BINARIES_DIR}/boot/autoresize"

genimage                           \
	--rootpath "${TARGET_DIR}"     \
	--tmppath "${GENIMAGE_TMP}"    \
	--inputpath "${BINARIES_DIR}"  \
	--outputpath "${BINARIES_DIR}" \
	--config "${GENIMAGE_CFG}"

exit $?
