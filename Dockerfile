# always pass those two arguments, or this will fail
ARG ARCH_BASE_IMAGE="super!duper!invalid!tag"
ARG DEBIAN_VERSION="super!duper!invalid!version"
FROM ${ARCH_BASE_IMAGE}:${DEBIAN_VERSION}
ARG DEBIAN_VERSION
ARG ARCH_BASE_IMAGE
ARG TARGET
ENV TARGET=${TARGET}
ENV DISTRO=${DEBIAN_VERSION}


COPY scripts/install-base-deps.sh /opt/scripts/
RUN /opt/scripts/install-base-deps.sh && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

COPY scripts/git-archive-all.sh /opt/scripts/
COPY scripts/build-package.sh /opt/scripts/

VOLUME "/out"
ENTRYPOINT [ "/bin/bash", "-c", "/opt/scripts/build-package.sh" ]
