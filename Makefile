.PHONY: clean

shells = build/bin/bash+ build/bin/mksh build/bin/bsh

bash1_version = 1.14.7
shells += build/bin/bash1

bash25_version = 2.05.0
shells += build/bin/bash25
bash25a_version = 2.05a.0
shells += build/bin/bash25a
bash25b_version = 2.05b.12
shells += build/bin/bash25b

bash30_version = 3.0.21
shells += build/bin/bash30
bash31_version = 3.1.22
shells += build/bin/bash31
bash32_version = 3.2.56
shells += build/bin/bash32

bash40_version = 4.0.43
shells += build/bin/bash40
bash41_version = 4.1.16
shells += build/bin/bash41
bash42_version = 4.2.52
shells += build/bin/bash42
bash43_version = 4.3.29
shells += build/bin/bash43

awks = build/bin/gawk3 build/bin/gawk4 build/bin/mawk \
       build/bin/nawk build/bin/oawk

evalbot: hda
	 

initramfs.cpio.gz: initramfs
	{ cd initramfs && pax -x sv4cpio -w .; } | gzip -9 > initramfs.cpio.gz

initramfs: $(shells) $(awks) build/bin/adu build/bin/ex scripts/generate-initramfs
	scripts/generate-initramfs

build/bzImage:
	scripts/build-linux http://www.kernel.org/pub/linux/kernel/v3.x/linux-3.14.2.tar.xz

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
	scripts/add-trigger '1#' "setsid bash1 -login" "bash-$$("$@" -c 'echo "$${BASH_VERSION%.*}"')"
build/bin/bash25: build/bash-$(bash25_version)
	scripts/build-shell bash $(bash25_version) bash25
	scripts/add-trigger '25#' "setsid bash25 --login" "bash-$$("$@" -c 'echo "$${BASH_VERSION%.*}"')"
build/bin/bash25a: build/bash-$(bash25a_version)
	scripts/build-shell bash $(bash25a_version) bash25a
	scripts/add-trigger '25a#' "setsid bash25a --login" "bash-$$("$@" -c 'echo "$${BASH_VERSION%.*}"')"
build/bin/bash25b: build/bash-$(bash25b_version)
	scripts/build-shell bash $(bash25b_version) bash25b
	scripts/add-trigger '25b#' "setsid bash25b -l" "bash-$$("$@" -c 'echo "$${BASH_VERSION%.*}"')" \
	                    '2#'   "setsid bash2 -l"   "25b#"
build/bin/bash30: build/bash-$(bash30_version)
	scripts/build-shell bash $(bash30_version) bash30
	scripts/add-trigger '30#' "setsid bash30 -l" "bash-$$("$@" -c 'echo "$${BASH_VERSION%.*}"')"
build/bin/bash31: build/bash-$(bash31_version)
	scripts/build-shell bash $(bash31_version) bash31
	scripts/add-trigger '31#' "setsid bash31 -l" "bash-$$("$@" -c 'echo "$${BASH_VERSION%.*}"')"
build/bin/bash32: build/bash-$(bash32_version)
	scripts/build-shell bash $(bash32_version) bash32
	scripts/add-trigger '32#' "setsid bash32 -l" "bash-$$("$@" -c 'echo "$${BASH_VERSION%.*}"')" \
	                    '3#'  "setsid bash3 -l"  "32#"
build/bin/bash40: build/bash-$(bash40_version)
	scripts/build-shell bash $(bash40_version) bash40
	scripts/add-trigger '40#' "setsid bash40 -l" "bash-$$("$@" -c 'echo "$${BASH_VERSION%.*}"')"
build/bin/bash41: build/bash-$(bash41_version)
	scripts/build-shell bash $(bash41_version) bash41
	scripts/add-trigger '41#' "setsid bash41 -l" "bash-$$("$@" -c 'echo "$${BASH_VERSION%.*}"')"
build/bin/bash42: build/bash-$(bash42_version)
	scripts/build-shell bash $(bash42_version) bash42
	scripts/add-trigger '42#' "setsid bash42 -l" "bash-$$("$@" -c 'echo "$${BASH_VERSION%.*}"')"
build/bin/bash43: build/bash-$(bash43_version)
	scripts/build-shell bash $(bash43_version) bash43
	scripts/add-trigger '43#' "setsid bash43 -l" "bash-$$("$@" -c 'echo "$${BASH_VERSION%.*}"')" \
	                    '4#'  "setsid bash4 -l"  "43#" \
	                    '#'   "setsid bash -l"  "4#"
build/bin/bash+: build/bash-devel
	scripts/build-shell bash devel bash+
	scripts/add-trigger '+#' "setsid bash+ -l" "bash-devel"
build/bin/bsh:
	scripts/build-shell bourne 050706 bsh
	scripts/add-trigger 'b#' "PS1= TIMEOUT=1 exec -l bsh -i" "bourne" \
	                    'j#' "PS1= TIMEOUT=1 exec -l jsh -i" "bourne(w/job)"
build/bin/mksh: sources/mksh
	scripts/build-shell mksh
	scripts/add-trigger 'm#' "setsid mksh -l" "mksh $$("$@" -fc 'IFS=\ ;set -A x -- $$KSH_VERSION;echo "$${x[2]}"')"

build/bin/bwk:
	scripts/build-awk bwk
build/bin/gawk3:
	scripts/build-awk gawk 3.1.8 gawk3
build/bin/gawk4:
	scripts/build-awk gawk 4.1.1 gawk4
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
