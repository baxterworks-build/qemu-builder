SHELL=bash
.PHONY: debug container push all local-build clean


local-build:
	BUILDKIT_PROGRESS=plain DOCKER_BUILDKIT=1 docker build . -f Dockerfile.fedora-builder --output=built/

#debug:
#	docker build -f Dockerfile-debug -t $USER/fedora-mingw64-qemu:debug .
#	docker run --cap-add SYS_PTRACE -it $USER/fedora-mingw64-qemu:debug

container:
	BUILDKIT_PROGRESS=plain DOCKER_BUILDKIT=1 docker build -f Dockerfile.fedora-builder -t $USER/fedora-mingw64-qemu .

push:
	docker push $USER/fedora-mingw64-qemu
#	docker push $USER/fedora-mingw64-qemu:debug

clean:
	rm -vr built/

all: container push

