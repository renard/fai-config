# Generic FAI makefile

include Makefile.conf
MAKEFILES := Makefile Makefile.conf

# Makefile.conf.local can override some configuration variables.
ifneq ($(wildcard Makefile.conf.local),)
include Makefile.conf.local
MAKEFILES += Makefile.conf.local
endif

all:
help:
	@echo "\n\
Help for FAI helper\n\
\n\
Run make(1) with following arguments:\n\
\n\
 - clean:         Clean all generated files.\n\
 - conf:          Create all configuration files from *.FAI_IN files.\n\
 - init:          Create FAI environment.\n\
 - update-mirror: Update debian mirror for CD generation.\n\
 - cd:            Create bootable CD.\n\
 - help:          This help screen,\n\
	"

init: conf
	fai-setup -v
	fai-chboot -IFv default

update-mirror:
	rm -rf $(MY_MIRROR_PATH)/pool $(MY_MIRROR_PATH)/dists
	fai-mirror -m 2000 -B -v $(MY_IGNORE_CLASSES) $(MY_MIRROR_PATH)

cd:
	mkdir -p isos
	fai-cd -m $(MY_MIRROR_PATH) -f isos/debian-squeeze-cw.iso


conf: $(shell find etc config -type f -name '*.FAI_IN' | sed 's/\.FAI_IN//g') grub
%: %.FAI_IN $(MAKEFILES)
	@echo "Generating $@"
	@sed -e 's#@@MY_FAI_SERVER@@#$(MY_FAI_SERVER)#g' \
		-e 's#@@MY_FAI_NFS_ROOT@@#$(MY_FAI_NFS_ROOT)#g' \
		< $< > $@

grub: etc/grub.cfg
	@for f in config/files/etc/network/interfaces/*; do \
		ip=`/sbin/ifup --force -n -v -i $$f  -a  2>&1 | grep -B 1 'route add default' | tr  '\n' ' ' | sed -n 's/ifconfig \([^ ]\+\) \([^ ]\+\) netmask \([^ ]\+\) \+.*default gw \([^ ]\+\) .*/ip=\2::\4:\1::\3:none/p'` ; \
		h=`basename $$f` ; \
		echo "\n\
menuentry \"Install server - $$h\" {\n\
	\tset gfxpayload=1024x768\n\
	\tlinux /boot/vmlinuz boot=live FAI_FLAGS=\"verbose,sshd,createvt\" FAI_ACTION=install hostname=$$h $$ip\n\
	\tinitrd /boot/initrd.img\n\
}\n\
	" >> $< ; \
	done





# 	echo "menuentry \"Install server - $$h\" {" ; \
# 	echo "\tset gfxpayload=1024x768" ; \
# 	echo "\tlinux   /boot/vmlinuz boot=live FAI_FLAGS=\"verbose,createvt\" FAI_ACTION=install hostname=$$h $$ip" ; \
# 	echo "\tinitrd  /boot/initrd.img" ; \
# 	echo "}" ; \
# done;



clean:
	@find etc config -type f -name '*.FAI_IN' -print0 | sed 's/\.FAI_IN//g' | xargs -0 rm -f
