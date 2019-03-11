IMAGE_NAME ?= s3-resource-iam
CONTAINER_NAME ?= s3-resource-container
ROOTFS ?= ./src/rootfs.tgz
RELEASE ?= ./release.tgz
VERSION ?= 0.0.1
BOSH_ENV ?= vbox


all: upload


upload: $(RELEASE)
	bosh -e $(BOSH_ENV) upload-release $<


release: $(ROOTFS)
	bosh create-release \
		--force \
		--tarball=$(RELEASE)


final-release: $(ROOTFS)
	bosh create-release \
		--name s3-iam-resource \
		--version $(VERSION) \
		--force \
		--final \
		--tarball=$(RELEASE)


image:
	cd ./src/s3-resource && \
		docker build -t $(IMAGE_NAME) .


$(ROOTFS):
	docker rm $(CONTAINER_NAME) || true
	docker create --name $(CONTAINER_NAME) $(IMAGE_NAME)
	docker export $(CONTAINER_NAME) | gzip > $@


clean:
	rm $(RELEASE) $(ROOTFS)
