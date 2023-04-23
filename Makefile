SHELL=bash
.PHONY: debug container push all local-build


local-build:
	BUILDKIT_PROGRESS=plain DOCKER_BUILDKIT=1 docker build . -f Dockerfile.fedora-builder --output=built/
debug:
	docker build -f Dockerfile-debug -t voltagex/fedora-mingw64-qemu:debug .
	docker run --cap-add SYS_PTRACE -it voltagex/fedora-mingw64-qemu:debug

container:
	docker build -f Dockerfile.fedora-builder -t voltagex/fedora-mingw64-qemu .

push:
	docker push voltagex/fedora-mingw64-qemu
#	docker push voltagex/fedora-mingw64-qemu:debug

all: container push
