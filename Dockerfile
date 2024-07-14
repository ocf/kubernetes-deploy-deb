FROM docker.ocf.berkeley.edu/theocf/debian:bookworm

ARG KRANE_DEPLOY_TAG

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
RUN gem install bundler -v 2.0 --no-document


RUN mkdir /tmp/gems
WORKDIR /tmp/gems

# install krane
RUN echo "source \"https://rubygems.org\"" > Gemfile
RUN echo "gem \"krane\", \"${KRANE_DEPLOY_TAG}\"" >> Gemfile
RUN bundle install --binstubs --standalone

# copy over the debian files
COPY debian debian
COPY LICENSE debian/copyright

# add to the changelog
RUN dch --create --distribution unstable --package "krane" \
            --newversion "${KRANE_DEPLOY_TAG}" "Initial release"

# build the package
COPY Makefile.build Makefile
RUN dpkg-buildpackage -us -uc -sa

# copy over the .changes
CMD "bash" "-c" "cp ../*.deb ../*.buildinfo ../*.changes ../*.dsc ../*.tar.gz /mnt"
