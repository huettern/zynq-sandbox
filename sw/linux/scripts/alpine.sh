alpine_url=http://dl-cdn.alpinelinux.org/alpine/v3.9

uboot_tar=alpine-uboot-3.9.0-armv7.tar.gz
uboot_url=$alpine_url/releases/armv7/$uboot_tar

tools_tar=apk-tools-static-2.10.3-r1.apk
tools_url=$alpine_url/main/armv7/$tools_tar

firmware_tar=linux-firmware-other-20181220-r0.apk
firmware_url=$alpine_url/main/armv7/$firmware_tar

linux_dir=../linux-4.14
linux_ver=4.14.101-xilinx

apline_root_src=../../alpine/root

apline_uenv=../../alpine/uEnv.txt

modules_dir=alpine-modloop/lib/modules/$linux_ver

zip_dir=alpine-zip

passwd=changeme

echo "######################################################################"
echo "# Download"
# Alpine uboot
test -f $uboot_tar || curl -L $uboot_url -o $uboot_tar
# Alpine tools
test -f $tools_tar || curl -L $tools_url -o $tools_tar
# alpine linux firmware
test -f $firmware_tar || curl -L $firmware_url -o $firmware_tar


echo "######################################################################"
echo "# Untar"
# Additional drivers
for tar in linux-firmware-ath9k_htc-20181220-r0.apk linux-firmware-brcm-20181220-r0.apk linux-firmware-rtlwifi-20181220-r0.apk
do
  url=$alpine_url/main/armv7/$tar
  test -f $tar || curl -L $url -o $tar
done

# untar alpine uboot
mkdir alpine-uboot
tar -zxf $uboot_tar --directory=alpine-uboot

# untar alpine tools
mkdir alpine-apk
tar -zxf $tools_tar --directory=alpine-apk --warning=no-unknown-keyword


echo "######################################################################"
echo "# Generate initramfs"

mkdir alpine-initramfs
cd alpine-initramfs

# decompress tha vanilla alpine initramfs
gzip -dc ../alpine-uboot/boot/initramfs-vanilla | cpio -id

# Cleanup unwanted stuff
rm -rf etc/modprobe.d
rm -rf lib/firmware
rm -rf lib/modules
rm -rf var

# repack
find . | sort | cpio --quiet -o -H newc | gzip -9 > ../initrd.gz

cd ..


echo "######################################################################"
echo "# Generate image for uboot"
mkimage -A arm -T ramdisk -C gzip -d initrd.gz uInitrd


echo "######################################################################"
echo "# copy kernel"

mkdir -p $modules_dir/kernel

# Copy kernel modules from previously build linux kernel
find $linux_dir -name \*.ko -printf '%P\0' | tar --directory=$linux_dir --owner=0 --group=0 --null --files-from=- -zcf - | tar -zxf - --directory=$modules_dir/kernel
cp $linux_dir/modules.order $linux_dir/modules.builtin $modules_dir/

# Generate dependencies
depmod -a -b alpine-modloop $linux_ver



echo "######################################################################"
echo "# Additional kernel modules"

# Copy seleced firmware binaries into modloop
tar -zxf $firmware_tar --directory=alpine-modloop/lib/modules --warning=no-unknown-keyword --strip-components=1 --wildcards lib/firmware/ar* lib/firmware/rt*

# Additional firmware
for tar in linux-firmware-ath9k_htc-20181220-r0.apk linux-firmware-brcm-20181220-r0.apk linux-firmware-rtlwifi-20181220-r0.apk
do
  tar -zxf $tar --directory=alpine-modloop/lib/modules --warning=no-unknown-keyword --strip-components=1
done

# Pack kernel modules and firmware
mksquashfs alpine-modloop/lib modloop -b 1048576 -comp xz -Xdict-size 100%

# cleanup
rm -rf alpine-uboot alpine-initramfs initrd.gz alpine-modloop

echo "######################################################################"
echo "# Create root directory"

root_dir=alpine-root

# directory structure
mkdir -p $root_dir/usr/bin
mkdir -p $root_dir/etc
mkdir -p $root_dir/etc/apk

# apk cache
mkdir -p $root_dir/media/mmcblk0p1/cache
ln -s /media/mmcblk0p1/cache $root_dir/etc/apk/cache

# Copy contents from apline root dir into alpine-root.
cp -r $apline_root_src/* $root_dir/

# Copy alpine binary and qemu arm CPU emulator to install alpine. 
# Further, for the chroot environment to find the alpine servers, our hosts resolv config is copied.
cp -r alpine-apk/sbin $root_dir/
cp /usr/bin/qemu-arm-static $root_dir/usr/bin/
cp /etc/resolv.conf $root_dir/etc/



# DELETED
# cp -r alpine/etc $root_dir/
# cp -r alpine/apps $root_dir/media/mmcblk0p1/
# cp -r alpine-apk/sbin $root_dir/
# rc-update add avahi-daemon default
# rc-update add chronyd default
# rc-update add dhcpcd default
# mkdir -p etc/runlevels/wifi
# rc-update -s add default wifi

# rc-update add iptables wifi
# rc-update add dnsmasq wifi
# rc-update add hostapd wifi

# sed -i 's/^SAVE_ON_STOP=.*/SAVE_ON_STOP="no"/;s/^IPFORWARD=.*/IPFORWARD="yes"/' etc/conf.d/iptables

# DELETED

echo "######################################################################"
echo "# Install alpine base"

# Chroot into alpine and install alpine-base
sudo chroot $root_dir /sbin/apk.static \
  --repository $alpine_url/main \
  --update-cache --allow-untrusted --initdb \
  add alpine-base

# Create a repositories file for upstream repository path.
echo $alpine_url/main > $root_dir/etc/apk/repositories
echo $alpine_url/community >> $root_dir/etc/apk/repositories

echo "######################################################################"
echo "# chroot for more settings"

# Now we chroot into the alpine-base installation and complete further installations.
sudo chroot $root_dir /bin/sh <<- EOF_CHROOT

apk update
apk add haveged openssh ucspi-tcp6 iw wpa_supplicant dhcpcd dnsmasq hostapd iptables avahi dbus dcron chrony gpsd libgfortran musl-dev fftw-dev libconfig-dev alsa-lib-dev alsa-utils curl wget less nano bc dos2unix

ln -s /etc/init.d/bootmisc etc/runlevels/boot/bootmisc
ln -s /etc/init.d/hostname etc/runlevels/boot/hostname
ln -s /etc/init.d/hwdrivers etc/runlevels/boot/hwdrivers
ln -s /etc/init.d/modloop etc/runlevels/boot/modloop
ln -s /etc/init.d/swclock etc/runlevels/boot/swclock
ln -s /etc/init.d/sysctl etc/runlevels/boot/sysctl
ln -s /etc/init.d/syslog etc/runlevels/boot/syslog
ln -s /etc/init.d/urandom etc/runlevels/boot/urandom

ln -s /etc/init.d/killprocs etc/runlevels/shutdown/killprocs
ln -s /etc/init.d/mount-ro etc/runlevels/shutdown/mount-ro
ln -s /etc/init.d/savecache etc/runlevels/shutdown/savecache

ln -s /etc/init.d/devfs etc/runlevels/sysinit/devfs
ln -s /etc/init.d/dmesg etc/runlevels/sysinit/dmesg
ln -s /etc/init.d/mdev etc/runlevels/sysinit/mdev

rc-update add local default
rc-update add dcron default
rc-update add haveged default
rc-update add sshd default

sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' etc/ssh/sshd_config

echo root:$passwd | chpasswd

setup-hostname red-pitaya
hostname red-pitaya

cat <<- EOF_CAT > root/.profile
alias rw='mount -o rw,remount /media/mmcblk0p1'
alias ro='mount -o ro,remount /media/mmcblk0p1'
EOF_CAT

sed -i 's/^# LBU_MEDIA=.*/LBU_MEDIA=mmcblk0p1/' etc/lbu/lbu.conf

lbu add root
lbu delete etc/resolv.conf
lbu delete root/.ash_history
lbu commit -d

EOF_CHROOT

echo "######################################################################"
echo "# restore hostname"

sudo hostname -F /etc/hostname


echo "######################################################################"
echo "# zip stuff"

mkdir -p $zip_dir

cp ../boot.bin $zip_dir/
cp ../uImage $zip_dir/
cp ../devicetree.dtb $zip_dir/
cp ../uEnv.txt $zip_dir/

cp -r $root_dir/media/mmcblk0p1/cache $zip_dir/
cp $root_dir/media/mmcblk0p1/red-pitaya.apkovl.tar.gz $zip_dir/
cp modloop $zip_dir/
cp uInitrd $zip_dir/

cp $apline_uenv $zip_dir/

zip -r red-pitaya-alpine-3.9-armv7-`date +%Y%m%d`.zip $zip_dir/

echo "######################################################################"
echo "# DONE!"