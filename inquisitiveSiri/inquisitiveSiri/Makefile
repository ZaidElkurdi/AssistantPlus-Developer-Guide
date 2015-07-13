include theos/makefiles/common.mk

export ARCHS = armv7 arm64
export TARGET = iphone:clang:latest:8.4
export SDKVERSION=8.4

BUNDLE_NAME = inquisitiveSiri
inquisitiveSiri_BUNDLE_EXTENSION = assistantPlugin
inquisitiveSiri_FILES = $(wildcard *.m)
inquisitiveSiri_INSTALL_PATH = /Library/AssistantPlusPlugins/
inquisitiveSiri_CFLAGS = -fobjc-arc
inquisitiveSiri_FRAMEWORKS = Foundation

include $(THEOS_MAKE_PATH)/bundle.mk

after-install::
	install.exec "killall -9 SpringBoard"
