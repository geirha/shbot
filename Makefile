.PHONY: clean

shells = build/bin/bash1 build/bin/bash2 build/bin/bash3 \
         build/bin/bash4 build/bin/bash+ build/bin/mksh build/bin/bsh
awks = build/bin/bwk build/bin/gawk3 build/bin/gawk4 build/bin/mawk \
       build/bin/nawk build/bin/oawk

evalbot: hda
	 

initramfs.cpio.gz: $(shells) $(awks) build/bin/adu build/bin/ex initramfs
	{ cd initramfs && pax -x sv4cpio -w .; } | gzip -9 > initramfs.cpio.gz

initramfs: generate-initramfs
	./scripts/generate-initramfs

build/bzImage:
	./scripts/build-linux http://www.kernel.org/pub/linux/kernel/v3.0/linux-3.5.4.tar.bz2

hda: initramfs.cpio.gz build/bzImage
	qemu-img create -f qcow2 hda.tmp 1M
	./savestate hda.tmp save
	mv hda.tmp hda

clean:
	rm -rf build/ initramfs/
	rm -f initramfs.cpio.gz hda hda.tmp fifo *~

build/bash-%:
	./scripts/extract-from-git "$@"

build/mksh:
	cd build && env CVS_RSH=ssh cvs -qd _anoncvs@anoncvs.mirbsd.org:/cvs co -PA mksh

build/bin/bash1: build/bash-1.14.7
	./scripts/build-shell bash 1.14.7 bash1
build/bin/bash2: build/bash-2.05b
	./scripts/build-shell bash 2.05b bash2
build/bin/bash3: build/bash-3.2.48
	./scripts/build-shell bash 3.2.48 bash3
build/bin/bash4: build/bash-4.2.45
	./scripts/build-shell bash 4.2.45 bash4
build/bin/bash+: build/bash-devel
	./scripts/build-shell bash devel bash+
build/bin/bsh:
	./scripts/build-shell bourne 050706 bsh
build/bin/mksh: build/mksh
	./scripts/build-shell mksh

build/bin/bwk:
	./scripts/build-awk bwk
build/bin/gawk3:
	./scripts/build-awk gawk 3.1.8 gawk3
build/bin/gawk4:
	./scripts/build-awk gawk 4.0.1 gawk4
build/bin/mawk:
	./scripts/build-awk mawk
build/bin/nawk:
	./scripts/build-awk nawk
build/bin/oawk:
	./scripts/build-awk oawk

build/bin/adu:
	./scripts/build-adu
build/bin/ex:
	./scripts/build-ex-vi
