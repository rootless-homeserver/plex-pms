#!/bin/bash
set -xe

container=$(buildah from registry.redhat.io/ubi8/ubi:8.5)

mnt=$(buildah mount ${container})
dnf install -y --releasever 8 \
    --setopt install_weak_deps=false \
    --nodocs --installroot=$mnt jq

buildah config --env _BUILDAH_STARTED_IN_USERNS="" --env BUILDAH_ISOLATION=chroot $container --env TERM="xterm" --env LANG="C.UTF-8" --env LC_ALL="C.UTF-8"
buildah config --port 32400/tcp $container
mkdir $mnt/config
mkdir $mnt/libraries
cp ./updatePlex.sh $mnt/updatePlex.sh
chmod +x $mnt/updatePlex.sh

mkdir -p $mnt/etc/systemd/system/
cp updatePlex.service $mnt/etc/systemd/system/updatePlex.service
ln -sf $mnt/etc/systemd/system/updatePlex.service $mnt/etc/systemd/system/multi-user.target.wants/updatePlex.service

#cp ./healthcheck.sh $mnt/healthcheck.sh
buildah config --workingdir /config $container
#buildah config --healthcheck /healthcheck.sh $container
buildah config --volume /config $container
buildah config --volume /libraries $container
buildah config --cmd /sbin/init $container

buildah unmount $container
buildah commit $container plexpms