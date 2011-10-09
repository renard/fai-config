# Generic FAI makefile



MIRROR_PATH:=/srv/fai/mirror

all:

init:
	fai-setup -v
	fai-chboot -IFv default

update-mirror:
	rm -rf $(MIRROR_PATH)/pool $(MIRROR_PATH)/dists
	fai-mirror -m 2000 -B -v -x NVIDIA,WIFI,X $(MIRROR_PATH)

cd:
	fai-cd -m $(MIRROR_PATH) -f isos/debian-squeeze-cw.iso

