

# Which alpine tag to use
ALP_TAG = v3.9


################################################################################
# URLs to download

# Base URL
ALP_URL = http://dl-cdn.alpinelinux.org/alpine/$(ALP_TAG)
ALP_BUILD = build/alpine

# Uboot
ALP_UBOOT_TAR=$(ALP_BUILD)/alpine-uboot-3.9.0-armv7.tar.gz
ALP_UBOOT_URL=$(ALP_URL)/releases/armv7/alpine-uboot-3.9.0-armv7.tar.gz
ALP_UBOOT_DIR=$(ALP_BUILD)/uboot-3.9.0

# tools
ALP_TOOLS_TAR=$(ALP_BUILD)/apk-tools-static-2.10.3-r1.apk
ALP_TOOLS_URL=$(ALP_URL)/main/armv7/apk-tools-static-2.10.3-r1.apk
ALP_TOOLS_DIR=$(ALP_BUILD)/tools-2.10.3-r1

# Firmware
ALP_FIRMWARE_TAR=$(ALP_BUILD)/linux-firmware-20190322-r0.apk
ALP_FIRMWARE_URL=$(ALP_URL)/main/armv7/linux-firmware-20190322-r0.apk
ALP_FIRMWARE_DIR=$(ALP_BUILD)/firmware-20181220-r0

# Alpine initramfs
ALP_INITRAMFS = $(ALP_BUILD)/alpine-initramfs

################################################################################
# Download
$(ALP_UBOOT_TAR):
	mkdir -p $(@D)
	curl -L $(ALP_UBOOT_URL) -o $@

$(ALP_TOOLS_TAR):
	mkdir -p $(@D)
	curl -L $(ALP_TOOLS_URL) -o $@

$(ALP_FIRMWARE_TAR):
	mkdir -p $(@D)
	curl -L $(ALP_FIRMWARE_URL) -o $@

################################################################################
# untar
$(ALP_UBOOT_DIR): $(ALP_UBOOT_TAR)
	mkdir -p $@
	tar -zxf $< --strip-components=1 --directory=$@

$(ALP_TOOLS_DIR): $(ALP_TOOLS_TAR)
	mkdir -p $@
	tar -zxf $< --strip-components=1 --directory=$@ --warning=no-unknown-keyword

$(ALP_FIRMWARE_DIR): $(ALP_FIRMWARE_TAR)
	mkdir -p $@
	tar -zxf $< --strip-components=1 --directory=$@

################################################################################
# Phnoy targets
.PHONY: alpine

alpine: $(ALP_UBOOT_DIR) $(ALP_TOOLS_DIR) $(ALP_FIRMWARE_DIR)


################################################################################
# Init ram fs
.PHONY: ap-initramfs
ap-initramfs: $(ALP_INITRAMFS)
$(ALP_INITRAMFS): 
	mkdir -p $@
	cd $@

	# Unzip
	gzip -dc ../../$(ALP_UBOOT_DIR)/boot/initramfs-vanilla | cpio -id

	cd ..
