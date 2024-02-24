.PHONY: source binary

SBCL_VERSION ?= 2.4.1

source:
	docker buildx build \
		--tag elderica/sbcl:"${SBCL_VERSION}-source" \
		--build-arg SBCL_VERSION="${SBCL_VERSION}" \
		--file Dockerfile.source .

binary:
	docker buildx build \
		--tag elderica/sbcl:"${SBCL_VERSION}-binary" \
		--build-arg SBCL_VERSION="${SBCL_VERSION}" \
		--file Dockerfile.binary .
