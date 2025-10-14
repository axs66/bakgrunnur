ARCHS = arm64 arm64e
THEOS_PACKAGE_SCHEME ?= rootless

TARGET := iphone:clang:latest:14.5

include $(THEOS)/makefiles/common.mk

TOOL_NAME = bkgd

bkgd_FILES = $(wildcard *.mm)
bkgd_CFLAGS = -fobjc-arc -Wno-module-import-in-extern-c
bkgd_CODESIGN_FLAGS = -Sentitlements.plist
# Rootless-safe install path; packaging scripts will handle runtime prefix
bkgd_INSTALL_PATH = /usr/libexec
bkgd_PRIVATE_FRAMEWORKS = IOKit

include $(THEOS_MAKE_PATH)/tool.mk
