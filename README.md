# Build instructions

Create and build Vivado project
```bash
cd fpga/hlx/
make NAME=pitaya-min bit
make NAME=pitaya-min hw-export
```

Compile Linux
```bash
cd sw/linux/
make
```

# Toolchain setup

## Linux

```bash
pip3 install cocotb
sudo apt install iverilog
```


## Mac OSX
### Install ghdl

```bash
wget https://github.com/ghdl/ghdl/releases/download/v0.35/ghdl-0.35-llvm-macosx.tgz
mkdir ghdl && cd ghdl
tar xvzf ../ghdl-0.35-llvm-macosx.tgz
cp -r include/* /usr/local/include/
cp -r bin/* /usr/local/bin/
cp -r lib/* /usr/local/lib/
ghdl --version
```

### Install gtkwave
Download from [here](https://sourceforge.net/projects/gtkwave/files/gtkwave-3.3.95-osx-app/gtkwave.zip/download)

### Install vivado docker
Follow instructions [here](https://github.com/noah95/vivado-docker)


# Some notes

## Diffs and patches
One day I had to apply a patch to a driver (the rtl8188 in particular). 
There was only a change in a single file. So I copied the old file structure to a temporary directory, applied the changes and created a diff.
```bash
cd sw/linux/build/
cp -r linux-4.14 linux-4.14-old
# Make changes in file under linux-4.14
diff -rupN linux-4.14-orig/file.c linux-4.14/file.c
```
Where `-r` is recursive, `-u` outputs 3 lines of unified context, `-p` shows the C-function in which the change is and `-N` treats absent files as empty.

The output looked something like this:
```diff
--- linux-4.14-orig/drivers/net/wireless/realtek/rtl8188eu/os_dep/ioctl_cfg80211.c  2019-10-07 11:00:13.336166963 +0200
+++ linux-4.14/drivers/net/wireless/realtek/rtl8188eu/os_dep/ioctl_cfg80211.c 2019-10-07 11:00:25.527976896 +0200
@@ -2948,7 +2948,6 @@ void rtw_cfg80211_indicate_sta_assoc(str
    sinfo.filled = 0;
    sinfo.assoc_req_ies = pmgmt_frame + WLAN_HDR_A3_LEN + ie_offset;
    sinfo.assoc_req_ies_len = frame_len - WLAN_HDR_A3_LEN - ie_offset;
-   cfg80211_sinfo_alloc_tid_stats(&sinfo, GFP_KERNEL);
    cfg80211_new_sta(ndev, GetAddr2Ptr(pmgmt_frame), &sinfo, GFP_ATOMIC);
  }
 }
```

This hunk is added to the `patches/linux/linux-4.14.path` file. When applying the path, all lines before `---` are ignored so it is practice to add the used diff command to the file.

Lets test the patch on the old directory.
```bash
# revert changes made to the file
cp linux-4.14-orig/file.c linux-4.14/file.c
patch --forward -d build -p 0 < patches/linux/linux-4.14.patch
```
Where `--forward` doesn't check if patch has already been applied, `-d` changed directory before anything else and `-p 0` use entire file name unmodified.

**Pay attention to tabs/spaces when using an editor. Best pipe the output of diff directly to the patch file.**