KUBE_DEPLOY_TAG := 0.26.2

.PHONY: build-image
build-image:
	docker build -t kubernetes-deploy-build .

.PHONY: package_%
package_%: build-image
	mkdir -p "dist_$*"
	docker run -e "KUBE_DEPLOY_TAG=${KUBE_DEPLOY_TAG}" \
		-e "DIST_TAG=$*" \
		--user $(shell id -u ${USER}):$(shell id -g ${USER}) \
		-v $(CURDIR)/dist_$*:/mnt:rw \
		kubernetes-deploy-build

.PHONY: clean
clean:
	rm -rf dist_*

.PHONY: test
test: ;
