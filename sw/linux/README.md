# Linux 

Disclaimer: This code is largely copied from [https://github.com/pavel-demin/red-pitaya-notes](https://github.com/pavel-demin/red-pitaya-notes), licensed under MIT license.

## Prerequirements
*DO NOT WORK ON A SHARED FOLDER INSIDE VIRTUALBOX*
It will get messy, because the Linux kernel build uses a case sensitive file system, which Mac does not provide.

Fix gmake:
```
sudo ln -s /usr/bin/make /usr/bin/gmake
```

Install some tools:
```
sudo apt install curl
```

On VirtualBox:
```bash
# On Host to fix shared folder symlinks
# Ubuntu=MACHINE_NAME noah=SHARE_NAME
VBoxManage setextradata Ubuntu VBoxInternal2/SharedFoldersEnableSymlinksCreate/noah 1
# On guets to fix folder permissions
# ON EACH REBOOT
sudo umount /mnt/noah
sudo mount -t vboxsf -o uid=1000,gid=1000 noah /mnt/noah
```

## Step-by-step build
For educational build purposes, the Makefile was extended to build each component seperately.
This guide will go through all components and briefly explain what they are needed for.

1. Create FSBL
Requires: 
- Hardware definition exported from Vivado HLx.
Generates: 
- `build/name.fsbl/executable.elf`

This generates the source code and binary for the first level bootloader that is executed after power on.
After project creation, the fsbl is compiled and the binary written.

```
rm -r build/*.fsbl
make fsbl
```

2. Devicetree source
Requires: 
- Hardware definition
- Devicetree sources download from Xilinx repository

Generates:
- Device tree sources `dts`

The devicetree files from Xilinx are downloaded and a device tree project created from the hardware definition files. 
From these two sources, a set of `dts` (device tree sources) files are generated.
Finally the makefile applies a patch to some output files.
The patch file is generates by this command:
```bash
diff -rupN pcw.dtsi pcw.dtsi.new > devicetree.patch
```

```
rm -r build/*.tree
make dts
```

3. Linux Kernel
Requires: 
- Nothing

Generates:
- uImage

Now it is time to pull a vanilla Linux kernel, uncompress the sources, apply some patches, copy some config and finally build the kernel. Issue the following command and go for a walk:

```
rm -r build/linux*
make uimage
```
