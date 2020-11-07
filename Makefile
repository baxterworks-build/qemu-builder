#Unused, but kept as reference
SHELL=bash
.PHONY: debug container push all

debug:
	docker build -f Dockerfile-debug -t voltagex/fedora-mingw64-qemu:debug .
	docker run --cap-add SYS_PTRACE -it voltagex/fedora-mingw64-qemu:debug

container:
	docker build -t voltagex/fedora-mingw64-qemu .

push:
	docker push voltagex/fedora-mingw64-qemu
#	docker push voltagex/fedora-mingw64-qemu:debug

all: container push
