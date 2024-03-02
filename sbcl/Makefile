.PHONY: image

SBCL_VERSION ?= 2.4.2
TARGET ?= runtime-source

image:
	docker buildx build \
		--tag elderica/sbcl:latest \
		--tag elderica/sbcl:"${SBCL_VERSION}" \
		--build-arg SBCL_VERSION="${SBCL_VERSION}" \
		--target="${TARGET}" \
		--file Dockerfile .
