
evalbot: hda
	 

initramfs.cpio.gz: bash1.14.7 bash2.05b bash3.2 bash4.2
	./generate-initramfs
	{ cd initramfs && pax -x sv4cpio -w .; } | gzip -9 > initramfs.cpio.gz

bzImage:
	./build-linux http://www.kernel.org/pub/linux/kernel/v3.0/linux-3.5.4.tar.bz2

hda: initramfs.cpio.gz bzImage
	qemu-img create -f qcow2 hda.tmp 1M
	./savestate hda.tmp _sh
	./savestate hda.tmp _4
	./savestate hda.tmp _3
	./savestate hda.tmp _2
	./savestate hda.tmp _1
	./savestate hda.tmp _k93
	mv hda.tmp hda

clean: 
	rm -rf bash-*/ linux-*/
	rm -f initramfs.cpio.gz hda hda.tmp fifo *~ bash1.14.7 bash2.05b bash3.2 bash4.2 bzImage

bash1.14.7:  
	./build-bash 1.14.7
bash2.05b:
	./build-bash 2.05b
bash3.2:
	./build-bash 3.2
bash4.2:
	./build-bash 4.2
