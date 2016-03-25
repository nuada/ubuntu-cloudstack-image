#!/bin/bash

apt-get update
apt-get install -fy xenstore-utils curl wget byobu

# TODO auto attach data drive

# setup cloud-init
echo 'datasource_list: [ ConfigDrive, CloudStack, None ]' > /etc/cloud/cloud.cfg.d/90_dpkg.cfg

# cleanup cloud-init
addgroup --system --quiet netdev
rm -f /etc/udev/rules.d/70*
ln -s /dev/null /etc/udev/rules.d/80-net-name-slot.rules

# set some stuff
echo 'vm.swappiness = 0' >> /etc/sysctl.conf

# fix fstab
cat > /etc/fstab <<'EOF'
# /etc/fstab: static file system information.
#
# Use 'blkid' to print the universally unique identifier for a
# device; this may be used with UUID= as a more robust way to name devices
# that works even if disks are added and removed. See fstab(5).
#
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
/dev/xvda1	/               ext3    errors=remount-ro,noatime,barrier=0 0       1
EOF

export DEBIAN_FRONTEND=noninteractive

# set ssh keys to regenerate at first boot if missing
# this is a fallback to catch when cloud-init fails doing the same
# it will do nothing if the keys already exist
cat > /etc/rc.local <<'EOF'
dpkg-reconfigure openssh-server
echo > /etc/rc.local
EOF

# console fix for PV Ubuntus
cat > /etc/init/hvc0.conf <<'EOF'

# hvc0 - getty
#
# This service maintains a getty on hvc0 from the point the system is
# started until it is shut down again.

start on stopped rc or RUNLEVEL=[2345]
stop on runlevel [!2345]

respawn
exec /sbin/getty -L 115200 hvc0 vt102
EOF

# clean up
apt-get -y clean
apt-get -y autoremove
sed -i '/.*cdrom.*/d' /etc/apt/sources.list
rm -f /etc/ssh/ssh_host_*
rm -f /var/cache/apt/archives/*.deb
rm -f /var/cache/apt/*cache.bin
rm -f /var/lib/apt/lists/*_Packages
rm -f /etc/resolv.conf
rm -f /root/.bash_history
rm -f /root/.nano_history
rm -f /root/.lesshst
rm -f /root/.ssh/known_hosts
rm -rf /tmp/tmp
for k in $(find /var/log -type f); do echo > $k; done
for k in $(find /tmp -type f); do rm -f $k; done
for k in $(find /root -type f \( ! -iname ".*" \)); do rm -f $k; done
