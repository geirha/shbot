bashes = build/bin/bash1 build/bin/bash2 build/bin/bash3 build/bin/bash4
awks = build/bin/bwk build/bin/gawk3 build/bin/gawk4 build/bin/mawk build/bin/nawk build/bin/oawk

evalbot: hda
	 

initramfs.cpio.gz: $(bashes) build/bin/mksh $(awks) initramfs
	{ cd initramfs && pax -x sv4cpio -w .; } | gzip -9 > initramfs.cpio.gz

initramfs: generate-initramfs
	./generate-initramfs

build/bzImage:
	./build-linux http://www.kernel.org/pub/linux/kernel/v3.0/linux-3.5.4.tar.bz2

hda: initramfs.cpio.gz build/bzImage
	qemu-img create -f qcow2 hda.tmp 1M
	./savestate hda.tmp save
	mv hda.tmp hda

clean: 
	rm -rf build/ initramfs/
	rm -f initramfs.cpio.gz hda hda.tmp fifo *~

build/bin/bash1:
	./build-bash 1.14.7 bash1
build/bin/bash2:
	./build-bash 2.05b bash2
build/bin/bash3:
	./build-bash 3.2 bash3
build/bin/bash4:
	./build-bash 4.2 bash4

build/bin/bwk:
	./build-awk bwk
build/bin/gawk3:
	./build-awk gawk 3.1.8 gawk3
build/bin/gawk4:
	./build-awk gawk 4.0.1 gawk4
build/bin/mawk:
	./build-awk mawk
build/bin/nawk:
	./build-awk nawk
build/bin/oawk:
	./build-awk oawk

build/bin/mksh:
	./build-mksh R40i20120901 mksh
