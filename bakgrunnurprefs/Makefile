ARCHS = arm64 arm64e
THEOS_PACKAGE_SCHEME ?= rootless

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = BakgrunnurPrefs

BakgrunnurPrefs_FILES = $(wildcard *.m) ../BKGShared.mm
BakgrunnurPrefs_INSTALL_PATH = /Library/PreferenceBundles
BakgrunnurPrefs_FRAMEWORKS = UIKit
BakgrunnurPrefs_LDFLAGS += -Wl,-undefined,dynamic_lookup
BakgrunnurPrefs_LDFLAGS += -L/var/jb/usr/lib -lAltList
BakgrunnurPrefs_CFLAGS = -fobjc-arc -I$(THEOS_PROJECT_DIR)/bakgrunnurprefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/BakgrunnurPrefs.plist$(ECHO_END)
