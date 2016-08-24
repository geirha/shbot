.PHONY: clean
	 
hda: shbot-kernel shbot.cpio.gz 
	qemu-img create -f qcow2 hda.tmp 1M
	./savestate hda.tmp save
	mv hda.tmp hda

clean:
	rm -f fifo hda hda.tmp
