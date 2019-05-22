FROM docker.ocf.berkeley.edu/theocf/debian:buster

ARG KUBE_DEPLOY_TAG

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
            git \
            ruby \
            ruby-dev \
            rubygems \
            build-essential \
	    devscripts \
	    dpkg-dev \
	    debhelper

# install bundler
RUN gem update --system --no-document
RUN gem install bundler -v 2.0 --no-document


RUN mkdir /tmp/gems
WORKDIR /tmp/gems

# install kubernetes-deploy
RUN echo "source \"https://rubygems.org\"" > Gemfile
RUN echo "gem \"kubernetes-deploy\", \"${KUBE_DEPLOY_TAG}\"" >> Gemfile
RUN bundle install --binstubs --standalone

# copy over the debian files
COPY debian debian
COPY LICENSE debian/copyright

# add to the changelog
RUN dch --create --distribution unstable --package "kubernetes-deploy" \
            --newversion "${KUBE_DEPLOY_TAG}" "Initial release"

# build the package
COPY Makefile.build Makefile
RUN dpkg-buildpackage -us -uc -sa

# copy over the .changes
CMD "bash" "-c" "cp ../*.deb ../*.buildinfo ../*.changes ../*.dsc ../*.tar.gz /mnt"
