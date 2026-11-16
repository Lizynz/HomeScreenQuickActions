export ARCHS = arm64 arm64e
GO_EASY_ON_ME = 1
PACKAGE_VERSION = 2.0
TARGET = iphone:clang:17.2

#THEOS_PACKAGE_SCHEME=roothide
THEOS_PACKAGE_SCHEME = rootless

export SYSROOT = $(THEOS)/sdks/iPhoneOS17.2.sdk

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = HomeScreenQuickActions

$(TWEAK_NAME)_FILES = $(TWEAK_NAME).xm
$(TWEAK_NAME)_CFLAGS = -fobjc-arc
$(TWEAK_NAME)_FRAMEWORKS = UIKit Foundation SpringBoardServices

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += HomeScreenQuickActionsSettings
include $(THEOS_MAKE_PATH)/aggregate.mk
