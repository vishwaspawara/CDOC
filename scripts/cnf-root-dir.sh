#!/bin/bash


CHROOT=$1
mkdir -p $CHROOT/{dev,sys,proc,lib,home,etc,bin,sbin,lib64,opt,usr/{bin,lib,lib64}}

ln -s $CHROOT/bin $CHROOT/usr/bin
ln -s $CHROOT/lib $CHROOT/usr/lib
ln -s $CHROOT/lib64 $CHROOT/usr/lib64
ln -s $CHROOT/sbin $CHROOT/usr/sbin

cp /lib64/ld-linux-x86-64.so.2 $CHROOT/lib64

while read -r line; do
	echo "attempting to install $line"
	cp /bin/$line $CHROOT/bin
	ldd /bin/$line |awk '{if($3 ~ /^\//)print $3}' |while read -r lib; do
		dest_dir="$CHROOT$(dirname "$lib")"
		mkdir -p "$dest_dir"
		cp "$lib" "$dest_dir"
	done
	echo done
done <utils.txt

sudo cp -r Env/opt/python2.7 $CHROOT/opt
echo 'ln -s opt/python2.7/bin/python2.7 bin/py2.7' > $CHROOT/create_ln.sh

