.PHONY: clean

shells = build/bin/bash+ build/bin/mksh build/bin/bsh

bash1_version = 1.14.7
shells += build/bin/bash1

bash2_version = 2.05b
shells += build/bin/bash2

bash30_version = 3.0.16
shells += build/bin/bash30
bash31_version = 3.1.17
shells += build/bin/bash31
bash32_version = 3.2.48
shells += build/bin/bash32

bash40_version = 4.0.38
shells += build/bin/bash40
bash41_version = 4.1.11
shells += build/bin/bash41
bash42_version = 4.2.45
shells += build/bin/bash42
bash43_version = 4.3.11
shells += build/bin/bash43

awks = build/bin/bwk build/bin/gawk3 build/bin/gawk4 build/bin/mawk \
       build/bin/nawk build/bin/oawk

evalbot: hda
	 

initramfs.cpio.gz: initramfs
	{ cd initramfs && pax -x sv4cpio -w .; } | gzip -9 > initramfs.cpio.gz

initramfs: $(shells) $(awks) build/bin/adu build/bin/ex scripts/generate-initramfs
	scripts/generate-initramfs

build/bzImage:
	scripts/build-linux http://www.kernel.org/pub/linux/kernel/v3.x/linux-3.14.tar.xz

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
build/bin/bash30: build/bash-$(bash30_version)
	scripts/build-shell bash $(bash30_version) bash30
build/bin/bash31: build/bash-$(bash31_version)
	scripts/build-shell bash $(bash31_version) bash31
build/bin/bash32: build/bash-$(bash32_version)
	scripts/build-shell bash $(bash32_version) bash32
build/bin/bash40: build/bash-$(bash40_version)
	scripts/build-shell bash $(bash40_version) bash40
build/bin/bash41: build/bash-$(bash41_version)
	scripts/build-shell bash $(bash41_version) bash41
build/bin/bash42: build/bash-$(bash42_version)
	scripts/build-shell bash $(bash42_version) bash42
build/bin/bash43: build/bash-$(bash43_version)
	scripts/build-shell bash $(bash43_version) bash43
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
