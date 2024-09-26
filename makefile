SHELL				:= bash
TAG_ORG				:= corydodt
TAG_STUB			:= ghcr.io/$(TAG_ORG)/cronan
TAG_VERSION			:= latest
IMAGE_DESCRIPTION   := Cronan the schedularian: runs a job in a container as simply as possible
IMAGE_SOURCE        := https://github.com/corydodt/cronan


all: image

image:
	podman build \
		-t $(TAG_STUB):$(TAG_VERSION) \
		--annotation="org.opencontainers.image.description=$(IMAGE_DESCRIPTION)" \
		--annotation="org.opencontainers.image.source=$(IMAGE_SOURCE)" \
		.

iterate: CRONAN_TIME_EXPR:=53 19 * * *
iterate: CRONAN_SPLAY:=1800
iterate:
	$(MAKE) image
	podman run -d \
		--env "CRONAN_TIME_EXPR=$(CRONAN_TIME_EXPR)" \
		--env "CRONAN_SPLAY=$(CRONAN_SPLAY)" \
		--name cronan \
		--rm --replace \
		$(TAG_STUB):$(TAG_VERSION)
	podman logs -f cronan

push-manual: op_ghcr_io_item := ghcr.io container registry/credential
push-manual: image
	# Note: secret-read is a local command I have installed. This will not work
	# for anyone but me.
	secret-read "$(op_ghcr_io_item)" | podman login ghcr.io -u $(TAG_ORG) --password-stdin
	podman push $(TAG_STUB):$(TAG_VERSION)
