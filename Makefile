SHELL=bash
OUTPUT=1

ifeq ($(OUTPUT),1)
	DOCKER_OUTPUT=--output=built/
else
	DOCKER_OUTPUT=
endif



.PHONY: debug container push all local-build clean


configure:
	BUILDKIT_PROGRESS=plain DOCKER_BUILDKIT=1 docker build . -f Dockerfile.fedora-builder --target=qemu-configure

build:
	BUILDKIT_PROGRESS=plain DOCKER_BUILDKIT=1 docker build . -f Dockerfile.fedora-builder $(DOCKER_OUTPUT)

build-android:
	BUILDKIT_PROGRESS=plain DOCKER_BUILDKIT=1 docker build . -f Dockerfile.android $(DOCKER_OUTPUT)

