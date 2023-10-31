################################################################################
#
# uboot files for M17
#
################################################################################

UBOOT_M17_VERSION = 0fea506b631079240ca8bba42a7c15047e2dc2d6
#e20e9d85d326345fb2e80105a79263c95757414f
#634b85f106c0eb3d5167c989729b564253d60816
UBOOT_M17_SITE = $(call github,rk3128-cfw,caesar-u-boot,$(UBOOT_M17_VERSION))
UBOOT_M17_LICENSE = GPLv2

UBOOT_M17_DEPENDENCIES = rk3128-blobs

define UBOOT_M17_BUILD_CMDS
    # FIXME: there should be a better way to build
    # Build uboot for wx8-rk3128
    cd $(@D) && ARCH=arm CHIP=rk3126 CROSS_COMPILE=$(HOST_DIR)/bin/arm-buildroot-linux-gnueabihf- make m17-rk3126_defconfig
    cd $(@D) && ARCH=arm CHIP=rk3126 CROSS_COMPILE=$(HOST_DIR)/bin/arm-buildroot-linux-gnueabihf- make
    #cd $(@D) && $(@D)/make.sh wx8-rk3128

    # Generate idbloader.img
    $(@D)/tools/mkimage -n rk3128 -T rksd -d $(BINARIES_DIR)/rkbin/bin/rk31/rk3126_ddr_300MHz_v2.09.bin $(@D)/idbloader.img
    cat $(BINARIES_DIR)/rkbin/bin/rk31/rk_3126_miniloader_v2.56.bin >> $(@D)/idbloader.img

    # Generate uboot.img
    $(@D)/tools/loaderimage --pack --uboot $(@D)/u-boot-dtb.bin $(@D)/uboot.img --size 1024 4
  
    # Generate trust.img
    $(@D)/tools/loaderimage --pack --trustos $(BINARIES_DIR)/rkbin/bin/rk31/rk3126_tee_ta_v2.01.bin $(@D)/trust.img --size 1024 4
endef

define UBOOT_M17_INSTALL_TARGET_CMDS
	cp $(@D)/idbloader.img $(BINARIES_DIR)/idbloader.img
	cp $(@D)/uboot.img     $(BINARIES_DIR)/uboot-m17.img
	cp $(@D)/trust.img     $(BINARIES_DIR)/trust.img
endef

$(eval $(generic-package))
