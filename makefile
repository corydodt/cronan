SHELL				:= bash
TAG_ORG				:= corydodt
TAG_PKG				:= cronan
TAG_SLUG			:= $(TAG_ORG)/$(TAG_PKG)
TAG_STUB			:= ghcr.io/$(TAG_SLUG)
TAG_VERSION			:= latest
IMAGE_DESCRIPTION   := Cronan the schedularian: runs a job in a container as simply as possible
IMAGE_SOURCE        := https://github.com/corydodt/cronan


all: image

image:
	podman build \
		-t $(TAG_STUB):$(TAG_VERSION) \
		--annotation="org.opencontainers.image.description=$(IMAGE_DESCRIPTION)" \
		--annotation="org.opencontainers.image.source=$(IMAGE_SOURCE)" \
		--build-arg=ORG_OPENCONTAINERS_IMAGE_SOURCE="$(IMAGE_SOURCE)" \
		--build-arg=ORG_OPENCONTAINERS_IMAGE_DESCRIPTION="$(IMAGE_DESCRIPTION)" \
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

push:
	podman push $(TAG_STUB):$(TAG_VERSION)

login:
	podman login ghcr.io -u $(TAG_ORG) --password-stdin

login-local: op_ghcr_io_item := ghcr.io container registry/credential
login-local:
	# Note: secret-read is a local command I have installed. This will not work
	# for anyone but me.
	secret-read "$(op_ghcr_io_item)" | podman login ghcr.io -u $(TAG_ORG) --password-stdin
	podman push $(TAG_STUB):$(TAG_VERSION)

print-url: base_url := https://github.com/$(TAG_SLUG)/pkgs/container/$(TAG_PKG)/%s?tag=$(TAG_VERSION)
print-url: jq_expr := .[] | select(.metadata.container.tags[] == "'$(TAG_VERSION)'") .id
print-url:
	gh auth login --with-token --scopes read:packages
	pkg_version_id=$$(\
		gh api -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" /users/$(TAG_ORG)/packages/container/$(TAG_PKG)/versions | \
		jq '$(jq_expr)'); \
	printf "$(base_url)\n" $$pkg_version_id
