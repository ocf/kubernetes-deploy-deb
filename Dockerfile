FROM docker.ocf.berkeley.edu/theocf/debian:stretch

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
            git \
            ruby \
            ruby-dev \
            rubygems \
            build-essential

RUN gem install --no-ri --no-rdoc fpm -v 1.11.0

# from https://github.com/jordansissel/fpm/wiki/ConvertingGems
RUN mkdir /tmp/gems
WORKDIR /tmp/gems
RUN gem install --no-ri --no-rdoc --install-dir . kubernetes-deploy
RUN find cache -name '*.gem' | \
    xargs -rn1 fpm -s gem -t deb \
                   --deb-generate-changes \
                   --deb-dist "${DIST_TAG}" \
		   --description "Automatically generated from rubygems as dependencies for Shopify's kubernetes-deploy script" \
		   --url "https://github.com/ocf/kubernetes-deploy-deb" \
		   --maintainer "root@ocf.berkeley.edu" \
		   -d ruby \
		   -d rubygems \
		   --prefix $(gem environment gemdir)

CMD "bash" "-c" "cp /tmp/gems/*.deb /tmp/gems/*.changes /mnt"
