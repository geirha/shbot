.PHONY: clean

shells = build/bin/bash+

bash1_version = 1.14.7
shells += build/bin/bash1

#bash25a_version = 2.05a.0
#shells += build/bin/bash25a
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
bash43_version = 4.3.33
shells += build/bin/bash43

#awks = build/bin/gawk3 build/bin/gawk4 build/bin/mawk \
#       build/bin/nawk build/bin/oawk

evalbot: hda
	 

initramfs.cpio.gz: initramfs
	{ cd initramfs && pax -x sv4cpio -w .; } | gzip -9 > initramfs.cpio.gz

#initramfs: $(shells) $(awks) build/bin/adu build/bin/ex $(manpages) scripts/generate-initramfs
initramfs: $(shells) $(awks) $(manpages) scripts/generate-initramfs
	scripts/generate-initramfs

hda: build/bzImage initramfs.cpio.gz 
	qemu-img create -f qcow2 hda.tmp 1M
	./savestate hda.tmp save
	mv hda.tmp hda

clean:
	rm -rf build/*/ initramfs/
	rm -f build/bzImage initramfs.cpio.gz hda hda.tmp fifo *~

## linux kernel

sources/linux:
	git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git "$@"

build/linux: sources/linux
	rm -rf "$@"
	mkdir -p "$@"
	@printf 'Building linux %s.\n' "$$($(MAKE) -sC "$<" kernelversion)"
	if [ "$$(uname -m)" = x86_64 ]; then \
	  cp kernel64.config "$@/.config"; \
	else \
	  cp kernel.config "$@/.config"; \
	fi
	$(MAKE) -C "$<" silentoldconfig O="../../$@"
	$(MAKE) -C "$@"

build/bzImage: build/linux
	cp "$</arch/x86/boot/bzImage" "$@"

## mksh

sources += sources/mksh
shells += build/bin/mksh
manpages += build/man/man1/mksh.1

sources/mksh:
	git clone https://github.com/MirBSD/mksh.git "$@"

build/mksh: sources/mksh
	rm -rf "$@"
	mkdir -p "$@"
	cd "$@" && sh "../../$</Build.sh"

build/bin/mksh: build/mksh
	mkdir -p "$(@D)"
	cp "$</mksh" "$@"
	scripts/add-trigger 'm#' "setsid mksh -l" "mksh $$("$@" -c 'echo "$${KSH_VERSION#* * }"')"

build/man/man1/mksh.1: sources/mksh
	mkdir -p "$(@D)"
	cp "$</mksh.1" "$@"

## bash

sources += sources/bash


sources/bash:
	git clone git://git.savannah.gnu.org/bash.git "$@"

build/bash-%: sources/bash
	rm -rf "$@"
	scripts/extract-from-git "$@"

build/bin/bash1: build/bash-$(bash1_version)
	scripts/build-shell bash $(bash1_version) bash1
	scripts/add-trigger '1#' "setsid bash1 -login" "bash-$$("$@" -c 'echo "$${BASH_VERSION%\(*}"')"

build/bin/bash25a: build/bash-$(bash25a_version)
	scripts/build-shell bash $(bash25a_version) bash25a
	scripts/add-trigger '25a#' "setsid bash25a --login" "bash-$$("$@" -c 'echo "$${BASH_VERSION%(*}"')"

build/bin/bash25b: build/bash-$(bash25b_version)
	scripts/build-shell bash $(bash25b_version) bash25b
	scripts/add-trigger '25b#' "setsid bash25b -l" "bash-$$("$@" -c 'echo "$${BASH_VERSION%(*}"')" \
	                    '2#'   "setsid bash2 -l"   "25b#"
build/bin/bash30: build/bash-$(bash30_version)
	scripts/build-shell bash $(bash30_version) bash30
	scripts/add-trigger '30#' "setsid bash30 -l" "bash-$$("$@" -c 'echo "$${BASH_VERSION%(*}"')"

build/bin/bash31: build/bash-$(bash31_version)
	scripts/build-shell bash $(bash31_version) bash31
	scripts/add-trigger '31#' "setsid bash31 -l" "bash-$$("$@" -c 'echo "$${BASH_VERSION%(*}"')"

build/bin/bash32: build/bash-$(bash32_version)
	scripts/build-shell bash $(bash32_version) bash32
	scripts/add-trigger '32#' "setsid bash32 -l" "bash-$$("$@" -c 'echo "$${BASH_VERSION%(*}"')" \
	                    '3#'  "setsid bash3 -l"  "32#"
build/bin/bash40: build/bash-$(bash40_version)
	scripts/build-shell bash $(bash40_version) bash40
	scripts/add-trigger '40#' "setsid bash40 -l" "bash-$$("$@" -c 'echo "$${BASH_VERSION%(*}"')"

build/bin/bash41: build/bash-$(bash41_version)
	scripts/build-shell bash $(bash41_version) bash41
	scripts/add-trigger '41#' "setsid bash41 -l" "bash-$$("$@" -c 'echo "$${BASH_VERSION%(*}"')"

build/bin/bash42: build/bash-$(bash42_version)
	scripts/build-shell bash $(bash42_version) bash42
	scripts/add-trigger '42#' "setsid bash42 -l" "bash-$$("$@" -c 'echo "$${BASH_VERSION%(*}"')"

build/bin/bash43: build/bash-$(bash43_version)
	scripts/build-shell bash $(bash43_version) bash43
	scripts/add-trigger '43#' "setsid bash43 -l" "bash-$$("$@" -c 'echo "$${BASH_VERSION%(*}"')" \
	                    '4#'  "setsid bash4 -l"  "43#" \
	                    '#'   "setsid bash -l"  "43#"

build/bin/bash+: build/bash-devel
	scripts/build-shell bash devel bash+
	scripts/add-trigger '+#' "setsid bash+ -l" "bash-devel"

## heirloom-sh
sources += sources/heirloom-project
shells += build/bin/bsh build/bin/jsh
manpages += build/man/man1/bsh.1 build/man/man1/jsh.1

sources/heirloom-project/%:
	git clone https://github.com/eunuchs/heirloom-project.git sources/heirloom-project

build/heirloom-sh: sources/heirloom-project/heirloom/heirloom-sh
	rm -rf "$@"
	mkdir -p "$@"
	cd "$@" && ln -s "../../$<"/* ./
	make -C "$@"

build/bin/bsh: build/heirloom-sh
	cp "$</sh" "$@"
	scripts/add-trigger 'b#' 'sh -c ". ~/.profile";read -r;PS1= exec bsh -ic "\x24REPLY;echo o>/proc/sysrq-trigger"      bourne

build/man/man1/bsh.1: build/heirloom-sh
	cp "$</sh.1" "$@"

build/bin/jsh: build/bin/bsh
	ln -s "$(<F)" "$@"
	scripts/add-trigger 'j#' 'sh -c ". ~/.profile";read -r;PS1= exec jsh -ic "\x24REPLY;echo o>/proc/sysrq-trigger"      bourne w/job

build/man/man1/jsh.1: build/man/man1/bsh.1
	ln -s "$(<F)" "$@"

#build/bin/bwk:
#	scripts/build-awk bwk
#build/bin/gawk3:
#	scripts/build-awk gawk 3.1.8 gawk3
#build/bin/gawk4:
#	scripts/build-awk gawk 4.1.1 gawk4
#build/bin/mawk:
#	scripts/build-awk mawk
#build/bin/nawk:
#	scripts/build-awk nawk
#
#
build/heirloom/%: build/heirloom
	mkdir -p "$@"
	$(MAKE) SHELL=/bin/sh -C "$(@D)" "$(@F)/Makefile"
	$(MAKE) SHELL=/bin/sh -C "$@"

build/heirloom: sources/heirloom-project/heirloom/heirloom
	rm -rf "$@"
	mkdir -p "$@"
	lndir "../../$<" "$@"

build/bin/oawk: build/heirloom/libcommon build/heirloom/libuxre build/heirloom/oawk build/heirloom/oawk/awk
	cp build/heirloom/oawk/awk "$@"

build/man/man1/oawk.1: build/heirloom/oawk/awk
	cp "$</awk.1" "$@"

#build/bin/adu:
#	scripts/build-adu
#build/bin/ex:
#	scripts/build-ex-vi
