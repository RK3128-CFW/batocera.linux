################################################################################
#
# toolchain-optional-linaro-arm
#
################################################################################

TOOLCHAIN_OPTIONAL_LINARO_ARM_VERSION = 6.3.1-2017.05
TOOLCHAIN_OPTIONAL_LINARO_ARM_SITE = https://releases.linaro.org/components/toolchain/binaries/7.5-2019.12/arm-linux-gnu
TOOLCHAIN_OPTIONAL_LINARO_ARM_SITE = https://releases.linaro.org/components/toolchain/binaries/6.3-2017.05/arm-linux-gnueabihf/

ifeq ($(HOSTARCH),x86)
	TOOLCHAIN_OPTIONAL_LINARO_ARM_SOURCE = gcc-linaro-6.3.1-2017.05-I686_arm-linux-gnueabihf.tar.xz
else
	TOOLCHAIN_OPTIONAL_LINARO_ARM_SOURCE = gcc-linaro-6.3.1-2017.05-x86_64_arm-linux-gnueabihf.tar.xz
endif

# wrap gcc and g++ with ccache like in gcc package.mk
PKG_GCC_PREFIX="$(HOST_DIR)/lib/gcc-linaro-arm-linux-gnueabihf/bin/arm-linux-gnueabihf-"

define HOST_TOOLCHAIN_OPTIONAL_LINARO_ARM_INSTALL_CMDS
	mkdir -p $(HOST_DIR)/lib/gcc-linaro-arm-linux-gnueabihf/
	cp -a $(@D)/* $(HOST_DIR)/lib/gcc-linaro-arm-linux-gnueabihf
endef

$(eval $(host-generic-package))
