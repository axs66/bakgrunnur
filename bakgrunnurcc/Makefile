ARCHS = arm64 arm64e
THEOS_PACKAGE_SCHEME ?= rootless

include $(THEOS)/makefiles/common.mk

TARGET = iphone:clang:latest:14.5

BUNDLE_NAME = Bakgrunnur
Bakgrunnur_BUNDLE_EXTENSION = bundle
Bakgrunnur_FILES = $(wildcard *.m) ../BKGShared.mm
Bakgrunnur_PRIVATE_FRAMEWORKS = ControlCenterUIKit Preferences
Bakgrunnur_FRAMEWORKS = UIKit QuartzCore
Bakgrunnur_INSTALL_PATH = /Library/ControlCenter/Bundles/
Bakgrunnur_CFLAGS = -fobjc-arc

after-install::
	install.exec "killall -9 SpringBoard"

include $(THEOS_MAKE_PATH)/bundle.mk
