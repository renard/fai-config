# Generic FAI makefile

include Makefile.conf

all:

init: conf
	fai-setup -v
	fai-chboot -IFv default

update-mirror:
	rm -rf $(MY_MIRROR_PATH)/pool $(MY_MIRROR_PATH)/dists
	fai-mirror -m 2000 -B -v -x NVIDIA,WIFI,X $(MY_MIRROR_PATH)

cd:
	fai-cd -m $(MY_MIRROR_PATH) -f isos/debian-squeeze-cw.iso


conf: $(shell find -type f -name '*.FAI_IN' | sed 's/\.FAI_IN//g')
%: %.FAI_IN Makefile.conf Makefile
	sed -e 's#@@MY_FAI_SERVER@@#$(MY_FAI_SERVER)#g' \
		-e 's#@@MY_FAI_NFS_ROOT@@#$(MY_FAI_NFS_ROOT)#g' \
		< $< > $@

clean:
	find -type f -name '*.FAI_IN' -print0 | sed 's/\.FAI_IN//g' | xargs -0 rm -f
