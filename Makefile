
evalbot: hda initramfs.cpio.gz bzImage
	 

initramfs.cpio.gz:
	( cd root; find . | cpio -o -H newc; ) | gzip -9 > initramfs.cpio.gz

hda: initramfs.cpio.gz bzImage
	qemu-img create -f qcow2 hda.tmp 1M
	./savestate hda.tmp _2
	./savestate hda.tmp _3
	./savestate hda.tmp _4
	./savestate hda.tmp _k93
	./savestate hda.tmp _sh
	mv hda.tmp hda

clean: 
	rm -f initramfs.cpio.gz hda hda.tmp fifo *~

