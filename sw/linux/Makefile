# 'make' builds everything
# 'make clean' deletes everything except source files and Makefile
#
# You need to set NAME, PART and PROC for your project.
# NAME is the base name for most of the generated files.

# solves problem with awk while building linux kernel
# solution taken from http://www.googoolia.com/wp/2015/04/21/awk-symbol-lookup-error-awk-undefined-symbol-mpfr_z_sub/
LD_LIBRARY_PATH =

# Project name
NAME = bare

PART = xc7z020clg484-1

PROC = ps7_cortexa9_0

# Files from hlx
BIT   = ../../fpga/hlx/build/pitaya-min.bit
HWDEF = ../../fpga/hlx/build/pitaya-min.sdk/system_wrapper.hdf

# For building linux kernel and other large stuff
MAKE_FLAGS = -j4

# CORES = axi_axis_reader_v1_0 axi_axis_writer_v1_0 axi_bram_reader_v1_0 \
#   axi_bram_writer_v1_0 axi_cfg_register_v1_0 axi_sts_register_v1_0 \
#   axis_accumulator_v1_0 axis_adder_v1_0 axis_alex_v1_0 axis_averager_v1_0 \
#   axis_bram_reader_v1_0 axis_bram_writer_v1_0 axis_constant_v1_0 \
#   axis_counter_v1_0 axis_decimator_v1_0 axis_fifo_v1_0 \
#   axis_gate_controller_v1_0 axis_gpio_reader_v1_0 axis_histogram_v1_0 \
#   axis_i2s_v1_0 axis_iir_filter_v1_0 axis_interpolator_v1_0 axis_keyer_v1_0 \
#   axis_lfsr_v1_0 axis_negator_v1_0 axis_oscilloscope_v1_0 axis_packetizer_v1_0 \
#   axis_phase_generator_v1_0 axis_pps_counter_v1_0 axis_pulse_generator_v1_0 \
#   axis_pulse_height_analyzer_v1_0 axis_ram_writer_v1_0 \
#   axis_red_pitaya_adc_v2_0 axis_red_pitaya_dac_v1_0 axis_stepper_v1_0 \
#   axis_tagger_v1_0 axis_timer_v1_0 axis_trigger_v1_0 axis_validator_v1_0 \
#   axis_variable_v1_0 axis_variant_v1_0 axis_zeroer_v1_0 dna_reader_v1_0 \
#   gpio_debouncer_v1_0 port_selector_v1_0 port_slicer_v1_0 pulse_generator_v1_0 \
#   shift_register_v1_0

# VIVADO = vivado -nolog -nojournal -mode batch
HSI = hsi -nolog -nojournal -mode batch
RM = rm -rf

# Specify versions
UBOOT_TAG = xilinx-v2018.2
LINUX_TAG = 4.14
DTREE_TAG = xilinx-v2018.2

# Target directories
UBOOT_DIR = build/u-boot-xlnx-$(UBOOT_TAG)
LINUX_DIR = build/linux-$(LINUX_TAG)
DTREE_DIR = build/device-tree-xlnx-$(DTREE_TAG)

# Target TAR files downloaded
UBOOT_TAR = build/u-boot-xlnx-$(UBOOT_TAG).tar.gz
LINUX_TAR = build/linux-$(LINUX_TAG).tar.xz
DTREE_TAR = build/device-tree-xlnx-$(DTREE_TAG).tar.gz

# Where to fetch uboot, linux and dtree
UBOOT_URL = https://github.com/Xilinx/u-boot-xlnx/archive/$(UBOOT_TAG).tar.gz
LINUX_URL = https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-$(LINUX_TAG).101.tar.xz
DTREE_URL = https://github.com/Xilinx/device-tree-xlnx/archive/$(DTREE_TAG).tar.gz

# Flags for compiling
LINUX_CFLAGS = "-O2 -march=armv7-a -mcpu=cortex-a9 -mtune=cortex-a9 -mfpu=neon -mfloat-abi=hard"
UBOOT_CFLAGS = "-O2 -march=armv7-a -mcpu=cortex-a9 -mtune=cortex-a9 -mfpu=neon -mfloat-abi=hard"
ARMHF_CFLAGS = "-O2 -march=armv7-a -mcpu=cortex-a9 -mtune=cortex-a9 -mfpu=neon -mfloat-abi=hard"

RTL8188_TAR = build/rtl8188eu-v4.1.8_9499.tar.gz
RTL8188_URL = https://github.com/lwfinger/rtl8188eu/archive/v4.1.8_9499.tar.gz

RTL8192_TAR = build/rtl8192cu-fixes-master.tar.gz
RTL8192_URL = https://github.com/pvaret/rtl8192cu-fixes/archive/master.tar.gz

# Output files
UBOOT  = build/u-boot.elf
UIMAGE = build/uImage
FSBL   = build/$(NAME).fsbl/executable.elf
DTB    = build/devicetree.dtb

.PRECIOUS: build/%.fsbl/executable.elf build/%.tree/system-top.dts
.PHONY: uimage uboot fsbl dtb dts bootbin

all: build/boot.bin $(UIMAGE) build/devicetree.dtb

uimage: $(UIMAGE)

uboot: $(UBOOT)

fsbl: $(FSBL)

dts: build/$(NAME).tree/system-top.dts
dtb: $(DTB)

bootbin: build/boot.bin


# cores: $(addprefix build/cores/, $(CORES))

# xpr: build/$(NAME).xpr

# bit: build/$(NAME).bit

#
# Downloads
# 
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

#
# untar and patch uboot
# 
$(UBOOT_DIR): $(UBOOT_TAR)
	mkdir -p $@
	tar -zxf $< --strip-components=1 --directory=$@
	patch -d build -p 0 < patches/uboot/u-boot-xlnx-$(UBOOT_TAG).patch
	cp patches/uboot/zynq_red_pitaya_defconfig $@/configs
	cp patches/uboot/zynq-red-pitaya.dts $@/arch/arm/dts
	cp patches/uboot/zynq_red_pitaya.h $@/include/configs
	cp patches/uboot/u-boot-lantiq.c $@/drivers/net/phy/lantiq.c

#
# Untar and patch Linux
#
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

#
# Untar device tree
#
$(DTREE_DIR): $(DTREE_TAR)
	mkdir -p $@
	tar -zxf $< --strip-components=1 --directory=$@

#
# Compile Linux
#
$(UIMAGE): $(LINUX_DIR)
	make $(MAKE_FLAGS) -C $< mrproper
	make $(MAKE_FLAGS) -C $< ARCH=arm xilinx_zynq_defconfig
	make $(MAKE_FLAGS) -C $< ARCH=arm CFLAGS=$(LINUX_CFLAGS) \
		-j $(shell nproc 2> /dev/null || echo 1) \
		CROSS_COMPILE=arm-linux-gnueabihf- UIMAGE_LOADADDR=0x8000 uImage modules
	cp $</arch/arm/boot/uImage $@

#
# Compile u-boot
# 
$(UBOOT): $(UBOOT_DIR)
	mkdir -p $(@D)
	make $(MAKE_FLAGS) -C $< mrproper
	make $(MAKE_FLAGS) -C $< ARCH=arm zynq_red_pitaya_defconfig
	make $(MAKE_FLAGS) -C $< ARCH=arm CFLAGS=$(UBOOT_CFLAGS) \
		CROSS_COMPILE=arm-linux-gnueabihf- all
	cp $</u-boot $@

#
# Generate bootimage
# Requires fsbl, bit and uboot
#
build/boot.bin: $(FSBL) $(BIT) $(UBOOT)
	echo "img:{[bootloader] $^}" > build/boot.bif
	bootgen -image build/boot.bif -w -o i $@

#
# Compile devicetree
#
$(DTB): $(UIMAGE) build/$(NAME).tree/system-top.dts
	$(LINUX_DIR)/scripts/dtc/dtc -I dts -O dtb -o $(DTB) \
		-i build/$(NAME).tree build/$(NAME).tree/system-top.dts

$(HWDEF):
	@echo Hardware definition not found
	@echo Go to fpga/hlx directory and export hardware definition

$(BIT):
	@echo Bitstream not found
	@echo Go to fpga/hlx directory and build

#
# Create first stage bootloader using Hardware Software Interface (HSI)
#
$(FSBL): $(HWDEF)
	mkdir -p $(@D)
	$(HSI) -source scripts/fsbl.tcl -tclargs $(NAME) $(PROC) $(HWDEF) build/$(NAME).fsbl

#
# Generate devicetree and patch it
#
build/%.tree/system-top.dts: $(HWDEF) $(DTREE_DIR)
	mkdir -p $(@D)
	$(HSI) -source scripts/devicetree.tcl -tclargs $(NAME) $(PROC) $(DTREE_DIR) $(HWDEF) build/$(NAME).tree
	sed -i 's|#include|/include/|' $@
	patch -d $(@D) < patches/devicetree/devicetree.patch

clean:
	$(RM) build/uImage build/boot.bin build/devicetree.dtb build
	$(RM) .Xil usage_statistics_webtalk.html usage_statistics_webtalk.xml
	$(RM) vivado*.jou vivado*.log
	$(RM) webtalk*.jou webtalk*.log
