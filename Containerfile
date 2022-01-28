FROM registry.redhat.io/ubi8/ubi-init:8.5

RUN dnf install -y --setopt install_weak_deps=false \
    --nodocs jq

ENV _BUILDAH_STARTED_IN_USERNS=""
ENV TERM="xterm"
ENV LANG="C.UTF-8"
ENV LC_ALL="C.UTF-8"
ENV BUILDAH_ISOLATION=rootless
ENV PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS=6
ENV PLEX_MEDIA_SERVER_HOME=/usr/lib/plexmediaserver
ENV PLEX_MEDIA_SERVER_MAX_STACK_SIZE=3000
ENV PLEX_MEDIA_SERVER_TMPDIR=/tmp
ENV PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR="/config/Library/Application Support"
ENV LD_LIBRARY_PATH="${PLEX_MEDIA_SERVER_HOME}"
ENV TMPDIR="${PLEX_MEDIA_SERVER_TMPDIR}"

EXPOSE 32400/tcp 8324/tcp 32469/tcp 1900/udp 32410/udp 32412/udp 32413/udp 32414/udp

ADD ./updatePlex.sh /updatePlex.sh
ADD updatePlex.service /etc/systemd/system/updatePlex.service
RUN mkdir -p $mnt/etc/systemd/system/ && \
    chmod +x /updatePlex.sh &&\
    ln -sf /etc/systemd/system/updatePlex.service /etc/systemd/system/multi-user.target.wants/updatePlex.service && \
    mkdir /config

#cp ./healthcheck.sh $mnt/healthcheck.sh
WORKDIR /config
#buildah config --healthcheck /healthcheck.sh $container
VOLUME /config
VOLUME /libraries
CMD ["/usr/sbin/init"]