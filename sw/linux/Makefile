

# This makefile is built upon the version of pavel-demin
# https://github.com/pavel-demin/red-pitaya-notes

# solves problem with awk while building linux kernel
# solution taken from http://www.googoolia.com/wp/2015/04/21/awk-symbol-lookup-error-awk-undefined-symbol-mpfr_z_sub/
LD_LIBRARY_PATH =

################################################################################
# Project name
NAME = bare

PART = xc7z020clg484-1

PROC = ps7_cortexa9_0

# Files from hlx
BIT   = ../../fpga/hlx/build/pitaya-min.bit
HWDEF = ../../fpga/hlx/build/pitaya-min.sdk/system_wrapper.hdf

# uEnv source
UENV_SRC = source/uEnv.txt

################################################################################
# Executables
HSI = hsi -nolog -nojournal -mode batch
RM = rm -rf

################################################################################
# Specify versions
UBOOT_TAG = xilinx-v2018.2
LINUX_TAG = 4.14
DTREE_TAG = xilinx-v2018.2
BUSYBOX_TAG = 1.30.1

################################################################################
# Target directories
UBOOT_DIR = build/u-boot-xlnx-$(UBOOT_TAG)
LINUX_DIR = build/linux-$(LINUX_TAG)
DTREE_DIR = build/device-tree-xlnx-$(DTREE_TAG)

################################################################################
# Target TAR files downloaded
UBOOT_TAR = build/u-boot-xlnx-$(UBOOT_TAG).tar.gz
LINUX_TAR = build/linux-$(LINUX_TAG).tar.xz
DTREE_TAR = build/device-tree-xlnx-$(DTREE_TAG).tar.gz

################################################################################
# Where to fetch uboot, linux and dtree
UBOOT_URL = https://github.com/Xilinx/u-boot-xlnx/archive/$(UBOOT_TAG).tar.gz
LINUX_URL = https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-$(LINUX_TAG).101.tar.xz
DTREE_URL = https://github.com/Xilinx/device-tree-xlnx/archive/$(DTREE_TAG).tar.gz

################################################################################
# Flags for compiling
LINUX_CFLAGS = "-O2 -march=armv7-a -mcpu=cortex-a9 -mtune=cortex-a9 -mfpu=neon -mfloat-abi=hard"
UBOOT_CFLAGS = "-O2 -march=armv7-a -mcpu=cortex-a9 -mtune=cortex-a9 -mfpu=neon -mfloat-abi=hard"
BUSYBOX_CFLAGS = "-O2 -march=armv7-a -mcpu=cortex-a9 -mtune=cortex-a9 -mfpu=neon -mfloat-abi=hard"

################################################################################
# RTL8188 driver source
RTL8188_TAR = build/rtl8188eu-v4.1.8_9499.tar.gz
RTL8188_URL = https://github.com/lwfinger/rtl8188eu/archive/v4.1.8_9499.tar.gz

################################################################################
# RTL8192 driver source
RTL8192_TAR = build/rtl8192cu-fixes-master.tar.gz
RTL8192_URL = https://github.com/pvaret/rtl8192cu-fixes/archive/master.tar.gz

################################################################################
# Busybox tar and source
BUSYBOX_DIR = build/busybox-$(BUSYBOX_TAG)
BUSYBOX_TAR = build/busybox-$(BUSYBOX_TAG).tar.bz2
BUSYBOX_URL = https://busybox.net/downloads/busybox-$(BUSYBOX_TAG).tar.bz2

################################################################################
# Output files
UBOOT  	= build/u-boot.elf
UIMAGE 	= build/uImage
FSBL   	= build/$(NAME).fsbl/executable.elf
DTB    	= build/devicetree.dtb
UENV   	= build/uEnv.txt
BUSYBOX = build/busybox-$(BUSYBOX_TAG)/busybox

################################################################################
# preciousand phony targets
.PRECIOUS: build/%.fsbl/executable.elf build/%.tree/system-top.dts
.PHONY: uimage uboot fsbl dtb dts bootbin

################################################################################
# Phony targets
all: build/boot.bin $(UIMAGE) build/devicetree.dtb busybox

uimage: $(UIMAGE)

uboot: $(UBOOT)

fsbl: $(FSBL)

dts: build/$(NAME).tree/system-top.dts
dtb: $(DTB)
uenv: $(UENV)

bootbin: build/boot.bin
busybox: $(BUSYBOX)

################################################################################
# Includes
include alpine/Makefile.mk

################################################################################
# Downloads
$(UBOOT_TAR):
	mkdir -p $(@D)
	curl -L $(UBOOT_URL) -o $@

$(LINUX_TAR):
	mkdir -p $(@D)
	curl -L $(LINUX_URL) -o $@

$(DTREE_TAR):
	mkdir -p $(@D)
	curl -L $(DTREE_URL) -o $@

$(RTL8188_TAR):
	mkdir -p $(@D)
	curl -L $(RTL8188_URL) -o $@

$(RTL8192_TAR):
	mkdir -p $(@D)
	curl -L $(RTL8192_URL) -o $@

$(BUSYBOX_TAR):
	mkdir -p $(@D)
	curl -L $(BUSYBOX_URL) -o $@

################################################################################
# untar and patch uboot
$(UBOOT_DIR): $(UBOOT_TAR)
	mkdir -p $@
	tar -zxf $< --strip-components=1 --directory=$@
	patch -d build -p 0 < patches/uboot/u-boot-xlnx-$(UBOOT_TAG).patch
	cp patches/uboot/zynq_red_pitaya_defconfig $@/configs
	cp patches/uboot/zynq-red-pitaya.dts $@/arch/arm/dts
	cp patches/uboot/zynq_red_pitaya.h $@/include/configs
	cp patches/uboot/u-boot-lantiq.c $@/drivers/net/phy/lantiq.c

################################################################################
# Untar and patch Linux kernel
$(LINUX_DIR): $(LINUX_TAR) $(RTL8188_TAR) $(RTL8192_TAR)
	mkdir -p $@
	tar -Jxf $< --strip-components=1 --directory=$@
	mkdir -p $@/drivers/net/wireless/realtek/rtl8188eu
	mkdir -p $@/drivers/net/wireless/realtek/rtl8192cu
	tar -zxf $(RTL8188_TAR) --strip-components=1 --directory=$@/drivers/net/wireless/realtek/rtl8188eu
	tar -zxf $(RTL8192_TAR) --strip-components=1 --directory=$@/drivers/net/wireless/realtek/rtl8192cu
	patch -d build -p 0 < patches/linux/linux-$(LINUX_TAG).patch
	cp patches/linux/xilinx_devcfg.c $@/drivers/char
	cp patches/linux/xilinx_zynq_defconfig $@/arch/arm/configs

################################################################################
# Untar device tree sources from xilinx
$(DTREE_DIR): $(DTREE_TAR)
	mkdir -p $@
	tar -zxf $< --strip-components=1 --directory=$@

################################################################################
# Untar Busybox
$(BUSYBOX_DIR): $(BUSYBOX_TAR)
	mkdir -p $@
	tar -xjf $< --strip-components=1 --directory=$@
	cp patches/busybox/busybox_config $@/.config

################################################################################
# Compile Linux kernel
$(UIMAGE): $(LINUX_DIR)
# 	make -C $< mrproper
	make -C $< ARCH=arm xilinx_zynq_defconfig
	make -C $< ARCH=arm CFLAGS=$(LINUX_CFLAGS) \
		-j $(shell nproc 2> /dev/null || echo 1) \
		CROSS_COMPILE=arm-linux-gnueabihf- UIMAGE_LOADADDR=0x8000 uImage modules
	cp $</arch/arm/boot/uImage $@

################################################################################
# Compile u-boot bootloader
$(UBOOT): $(UBOOT_DIR)
	mkdir -p $(@D)
# 	make -C $< mrproper
	make -C $< ARCH=arm zynq_red_pitaya_defconfig
	make -C $< ARCH=arm CFLAGS=$(UBOOT_CFLAGS) \
		CROSS_COMPILE=arm-linux-gnueabihf- all
	cp $</u-boot $@

################################################################################
# Generate bootimage
build/boot.bin: $(FSBL) $(BIT) $(UBOOT)
	echo "img:{[bootloader] $^}" > build/boot.bif
	bootgen -image build/boot.bif -w -o i $@

################################################################################
# Compile devicetree
$(DTB): $(UIMAGE) build/$(NAME).tree/system-top.dts
	$(LINUX_DIR)/scripts/dtc/dtc -I dts -O dtb -o $(DTB) \
		-i build/$(NAME).tree build/$(NAME).tree/system-top.dts

################################################################################
# Errors if HLx design not completed
$(HWDEF):
	$(error Hardware definition not found. Go to fpga/hlx directory and export hardware definition)

$(BIT):
	$(error Bitstream not found. Go to fpga/hlx directory and build)

################################################################################
# Create first stage bootloader using Hardware Software Interface (HSI)
$(FSBL): $(HWDEF)
	mkdir -p $(@D)
	$(HSI) -source scripts/fsbl.tcl -tclargs $(NAME) $(PROC) $(HWDEF) build/$(NAME).fsbl
	patch -d $(@D) < patches/fsbl/fsbl.patch
	make -C $(@D)

################################################################################
# Generate devicetree and patch it
build/%.tree/system-top.dts: $(HWDEF) $(DTREE_DIR)
	mkdir -p $(@D)
	$(HSI) -source scripts/devicetree.tcl -tclargs $(NAME) $(PROC) $(DTREE_DIR) $(HWDEF) build/$(NAME).tree
# 	sed -i 's|#include|/include/|' $@
# 	patch -d $(@D) < patches/devicetree/devicetree.patch

################################################################################
# Generate uEnv.txt
$(UENV) : $(UENV_SRC)
	cp $(UENV_SRC) $@

################################################################################
# Build Busybox
# $(BUSYBOX) : $(BUSYBOX_DIR)
$(BUSYBOX) : $(BUSYBOX_DIR)
	echo "placeholder"
	make -C $< ARCH=arm CFLAGS=$(BUSYBOX_CFLAGS) \
		-j $(shell nproc 2> /dev/null || echo 1) \
		CROSS_COMPILE=arm-linux-gnueabihf- all
	make -C $< ARCH=arm INSTALL_PATH=build/  \
		-j $(shell nproc 2> /dev/null || echo 1) \
		install

################################################################################
# clean stuff
clean:
	$(RM) build/uImage build/boot.bin build/devicetree.dtb build
	$(RM) .Xil usage_statistics_webtalk.html usage_statistics_webtalk.xml
	$(RM) vivado*.jou vivado*.log
	$(RM) webtalk*.jou webtalk*.log
