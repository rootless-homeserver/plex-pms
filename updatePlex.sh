#!/bin/bash -xe

URL=$(curl https://plex.tv/api/downloads/5.json?channel=plexpass | jq -r '.computer.Linux.releases[] | select(.build == "linux-x86_64" and .distro == "redhat") | .url')
curl $URL -o /tmp/plex.rpm

rpm -i /tmp/plex.rpm

set +xe
if ! [ -e /dev/console ] ; then
    socat -u pty,link=/dev/console stdout &
fi

systemctl enable --now plexmediaserver
sed -i 's/^User=/#User=/' /etc/systemd/system/multi-user.target.wants/plexmediaserver.service
sed -i 's/^Group=/#Group=/' /etc/systemd/system/multi-user.target.wants/plexmediaserver.service
systemctl daemon-reload
systemctl start plexmediaserver