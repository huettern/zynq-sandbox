#!/bin/bash

# Get destination directory
if [ $# -eq 0 ]
  then
    echo "No arguments supplied, using default destination"
    DST=/media/$USER/root
else
	DST=$1
fi

# Ask if correct destination
read -r -p "Busybox will be copied to $DST Continue? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY]) 
        echo "Starting.."
        ;;
    *)
		echo "aborting."
        exit
esac

# copy busybox content
cp -rv build/busybox-1.30.1/_install/* $DST/

# Create some directories
mkdir -p $DST/proc 
mkdir -p $DST/sys
mkdir -p $DST/dev
mkdir -p $DST/etc
mkdir -p $DST/etc/init.d

# Copy init script
cp -v source/busybox/rcS $DST/etc/init.d/

# sync
sync

echo "Write busybox-sd done!"
