export GO_EASY_ON_ME = 1
THEOS_PACKAGE_SCHEME ?= rootless
export ARCHS = arm64 arm64e
export DEBUG = 0
export FINALPACKAGE = 1

TARGET := iphone:clang:latest:14.5

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Bakgrunnur

$(TWEAK_NAME)_FILES = $(wildcard *.xm) $(wildcard *.mm)
$(TWEAK_NAME)_CFLAGS = -fobjc-arc
$(TWEAK_NAME)_FRAMEWORKS = UIKit QuartzCore

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += bkg
SUBPROJECTS += bakgrunnurprefs
SUBPROJECTS += bakgrunnurcc
SUBPROJECTS += bkgd
include $(THEOS_MAKE_PATH)/aggregate.mk
