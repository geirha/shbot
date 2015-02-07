.PHONY: clean

shells = build/bin/bash+ build/bin/mksh build/bin/bsh 

bash1_version = 1.14.7
shells += build/bin/bash1

bash25_version = 2.05.0
shells += build/bin/bash25
#bash25a_version = 2.05a.0
#shells += build/bin/bash25a
bash25b_version = 2.05b.13
shells += build/bin/bash25b

bash30_version = 3.0.22
shells += build/bin/bash30
bash31_version = 3.1.23
shells += build/bin/bash31
bash32_version = 3.2.57
shells += build/bin/bash32

bash40_version = 4.0.44
shells += build/bin/bash40
bash41_version = 4.1.17
shells += build/bin/bash41
bash42_version = 4.2.53
shells += build/bin/bash42
bash43_version = 4.3.30
shells += build/bin/bash43

dash_version = 0.5.8
shells += build/bin/dash

posh_version = 0.12.3
shells += build/bin/posh

awks = build/bin/gawk3 build/bin/gawk4 build/bin/mawk \
       build/bin/nawk build/bin/oawk

locales += build/locales/en_US.UTF-8
locales += build/locales/nb_NO.UTF-8
locales += build/locales/de_DE.UTF-8

evalbot: hda
	 

initramfs.cpio.gz: initramfs
	{ cd initramfs && pax -x sv4cpio -w .; } | gzip -9 > initramfs.cpio.gz

initramfs: $(shells) $(awks) build/bin/adu build/bin/ex scripts/generate-initramfs $(locales)
	scripts/generate-initramfs

build/bzImage: sources/linux
	scripts/build-linux2
	#scripts/build-linux http://www.kernel.org/pub/linux/kernel/v3.x/linux-3.14.2.tar.xz

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

build/dash-%:
	scripts/extract-from-git "$@"

build/posh-%: sources/posh
	scripts/extract-from-git "$@"

sources/posh:
	git clone git://anonscm.debian.org/users/clint/posh.git "$@"

sources/mksh:
	env CVS_RSH=ssh cvs -qd _anoncvs@anoncvs.mirbsd.org:/cvs co -PAd "$@" mksh

build/bin/posh: build/posh-$(posh_version)
	scripts/build-shell posh "$(posh_version)" posh
	scripts/add-trigger 'p#' 'setsid posh -l' "posh-0.12.3"

build/bin/dash: build/dash-$(dash_version)
	scripts/build-shell dash "$(dash_version)" dash
	scripts/add-trigger 'd#'  'setsid dash -l' "dash-0.5.8" \
						'sh#' 'setsid sh -l'   "d#"
sources/linux:
	git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git "$@"

build/bin/bash1: build/bash-$(bash1_version)
	scripts/build-shell bash $(bash1_version) bash1
	scripts/add-trigger '1#' "ln -sf bash1 /bin/bash;setsid bash -login" bash-1.14
build/bin/bash25: build/bash-$(bash25_version)
	scripts/build-shell bash $(bash25_version) bash25
	scripts/add-trigger '25#' "ln -sf bash25 /bin/bash;setsid bash --login" bash-2.05
build/bin/bash25a: build/bash-$(bash25a_version)
	scripts/build-shell bash $(bash25a_version) bash25a
	scripts/add-trigger '25a#' "ln -sf bash25a /bin/bash;setsid bash --login" bash-2.05a
build/bin/bash25b: build/bash-$(bash25b_version)
	scripts/build-shell bash $(bash25b_version) bash25b
	scripts/add-trigger '25b#' "ln -sf bash25b /bin/bash;setsid bash -l" bash-2.05b \
	                    '2#'   "ln -sf bash2 /bin/bash;setsid bash -l"   "25b#"
build/bin/bash30: build/bash-$(bash30_version)
	scripts/build-shell bash $(bash30_version) bash30
	scripts/add-trigger '30#' "ln -sf bash30 /bin/bash;setsid bash -l" bash-3.0
build/bin/bash31: build/bash-$(bash31_version)
	scripts/build-shell bash $(bash31_version) bash31
	scripts/add-trigger '31#' "ln -sf bash31 /bin/bash;setsid bash -l" bash-3.1
build/bin/bash32: build/bash-$(bash32_version)
	scripts/build-shell bash $(bash32_version) bash32
	scripts/add-trigger '32#' "ln -sf bash32 /bin/bash;setsid bash -l" bash-3.2 \
	                    '3#'  "ln -sf bash3 /bin/bash;setsid bash -l"  "32#"
build/bin/bash40: build/bash-$(bash40_version)
	scripts/build-shell bash $(bash40_version) bash40
	scripts/add-trigger '40#' "ln -sf bash40 /bin/bash;setsid bash -l" bash-4.0
build/bin/bash41: build/bash-$(bash41_version)
	scripts/build-shell bash $(bash41_version) bash41
	scripts/add-trigger '41#' "ln -sf bash41 /bin/bash;setsid bash -l" bash-4.1
build/bin/bash42: build/bash-$(bash42_version)
	scripts/build-shell bash $(bash42_version) bash42
	scripts/add-trigger '42#' "ln -sf bash42 /bin/bash;setsid bash -l" bash-4.2
build/bin/bash43: build/bash-$(bash43_version)
	scripts/build-shell bash $(bash43_version) bash43
	scripts/add-trigger '43#' "ln -sf bash43 /bin/bash;setsid bash -l" bash-4.3 \
	                    '4#'  "ln -sf bash4 /bin/bash;setsid bash -l"  "43#" \
	                    '#'   "setsid bash -l"  "4#"
build/bin/bash+: build/bash-devel
	scripts/build-shell bash devel bash+
	scripts/add-trigger '+#' "ln -sf bash+ /bin/bash;setsid bash -l" bash-devel
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

build/locales/%:
	set -x; \
	x="$@" locale=$${x##*/} lang=$${locale%.*} enc=$${locale#"$$lang."}; \
	localedef --no-archive -c -i "$$lang" -f "$$enc" "$@"
