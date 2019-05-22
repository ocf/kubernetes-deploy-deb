KUBE_DEPLOY_TAG := 0.26.4

.PHONY: build-image
build-image:
	docker build --build-arg "KUBE_DEPLOY_TAG=${KUBE_DEPLOY_TAG}" \
	        -t kubernetes-deploy-build .

.PHONY: package_%
package_%: build-image
	mkdir -p "dist_$*"
	docker run \
		-e "DIST_TAG=$*" \
		--user $(shell id -u ${USER}):$(shell id -g ${USER}) \
		-v $(CURDIR)/dist_$*:/mnt:rw \
		kubernetes-deploy-build

.PHONY: clean
clean:
	rm -rf dist_*

.PHONY: test
test: ;
