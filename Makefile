ROOTLESS ?= 0

ifeq ($(ROOTLESS),1)
	TARGET = iphone:clang:14.2
	THEOS_LAYOUT_DIR_NAME = layout-rootless
	THEOS_PACKAGE_SCHEME = rootless
else
	TARGET = iphone:clang:14.2
endif

GO_EASY_ON_ME = 1

PACKAGE_VERSION = 1.7

export SYSROOT = $(THEOS)/sdks/iPhoneOS14.2.sdk

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = HomeScreenQuickActions

$(TWEAK_NAME)_FILES = $(TWEAK_NAME).xm
$(TWEAK_NAME)_CFLAGS = -fobjc-arc
$(TWEAK_NAME)_FRAMEWORKS = UIKit Foundation SpringBoardServices

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += HomeScreenQuickActionsSettings
include $(THEOS_MAKE_PATH)/aggregate.mk
