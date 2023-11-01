################################################################################
#
# M17 Gamepad Controller Driver
#
################################################################################
# Version.: Commits on October 31, 2023
M17_GAMEPAD_VERSION = 1
M17_GAMEPAD_SOURCE =
M17_GAMEPAD_LICENSE = GPLv2

M17_GAMEPAD_FLAGS=

define M17_GAMEPAD_BUILD_CMDS
	$(TARGET_CC) $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/controllers/m17-gamepad/m17_gamepad.c -o $(@D)/m17_gamepad -I$(STAGING_DIR)/usr/include/libevdev-1.0/ -levdev
endef

define M17_GAMEPAD_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 -D $(@D)/m17_gamepad $(TARGET_DIR)/usr/bin/m17_gamepad
        $(INSTALL) -m 0644 -D $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/controllers/m17-gamepad/99-m17-gamepad.rules $(TARGET_DIR)/etc/udev/rules.d/99-m17-gamepad.rules
endef

$(eval $(generic-package))
