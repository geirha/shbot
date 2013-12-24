.PHONY: clean

shells = build/bin/bash+ build/bin/mksh build/bin/bsh

bash1_version = 1.14.7
shells += build/bin/bash1

bash2_version = 2.05b
shells += build/bin/bash2

bash3_version = 3.2.48
shells += build/bin/bash3

bash4_version = 4.2.45
shells += build/bin/bash4

awks = build/bin/bwk build/bin/gawk3 build/bin/gawk4 build/bin/mawk \
       build/bin/nawk build/bin/oawk

evalbot: hda
	 

initramfs.cpio.gz: initramfs
	{ cd initramfs && pax -x sv4cpio -w .; } | gzip -9 > initramfs.cpio.gz

initramfs: $(shells) $(awks) build/bin/adu build/bin/ex scripts/generate-initramfs
	scripts/generate-initramfs

build/bzImage:
	scripts/build-linux http://www.kernel.org/pub/linux/kernel/v3.x/linux-3.12.6.tar.bz2

hda: build/bzImage initramfs.cpio.gz 
	qemu-img create -f qcow2 hda.tmp 1M
	./savestate hda.tmp save
	mv hda.tmp hda

clean-bash:
	for dir in build/bash-*/; do \
		[ -d "$$dir" ] || continue; \
		$(MAKE) -C "$$dir" clean; \
	done

clean:
	rm -rf build/*/ initramfs/
	rm -f build/bzImage initramfs.cpio.gz hda hda.tmp fifo *~

build/bash-%:
	scripts/extract-from-git "$@"

sources/mksh:
	env CVS_RSH=ssh cvs -qd _anoncvs@anoncvs.mirbsd.org:/cvs co -PAd "$@" mksh

build/bin/bash1: build/bash-$(bash1_version)
	scripts/build-shell bash $(bash1_version) bash1
build/bin/bash2: build/bash-$(bash2_version)
	scripts/build-shell bash $(bash2_version) bash2
build/bin/bash3: build/bash-$(bash3_version)
	scripts/build-shell bash $(bash3_version) bash3
build/bin/bash4: build/bash-$(bash4_version)
	scripts/build-shell bash $(bash4_version) bash4
build/bin/bash+: build/bash-devel
	scripts/build-shell bash devel bash+
build/bin/bsh:
	scripts/build-shell bourne 050706 bsh
build/bin/mksh: sources/mksh
	scripts/build-shell mksh

build/bin/bwk:
	scripts/build-awk bwk
build/bin/gawk3:
	scripts/build-awk gawk 3.1.8 gawk3
build/bin/gawk4:
	scripts/build-awk gawk 4.1.0 gawk4
build/bin/mawk:
	scripts/build-awk mawk
build/bin/nawk:
	scripts/build-awk nawk
build/bin/oawk:
	scripts/build-awk oawk

build/bin/adu:
	scripts/build-adu
build/bin/ex:
	scripts/build-ex-vi
