TAG_STUB			:= ghcr.io/corydodt/cronan
TAG_VERSION			:= latest

all:
	buildah build -t $(TAG_STUB):$(TAG_VERSION) .

build-deps:
	sudo dnf -y install buildah

iterate: CRONAN_TIME_EXPR:=53 19 * * *
iterate: CRONAN_SPLAY:=1800
iterate:
	$(MAKE)
	podman run -d \
		--env "CRONAN_TIME_EXPR=$(CRONAN_TIME_EXPR)" \
		--env "CRONAN_SPLAY=$(CRONAN_SPLAY)" \
		--name cronan \
		--rm --replace \
		$(TAG_STUB):$(TAG_VERSION)
	podman logs -f cronan
