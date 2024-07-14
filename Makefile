KRANE_DEPLOY_TAG := 2.4.9

.PHONY: build-image
build-image:
	docker build --build-arg "KRANE_DEPLOY_TAG=${KRANE_DEPLOY_TAG}" \
	        -t krane-build .

.PHONY: package_%
package_%: build-image
	mkdir -p "dist_$*"
	docker run \
		-e "DIST_TAG=$*" \
		--user $(shell id -u ${USER}):$(shell id -g ${USER}) \
		-v $(CURDIR)/dist_$*:/mnt:rw \
		krane-build

.PHONY: clean
clean:
	rm -rf dist_*

.PHONY: test
test: ;
