_This is a draft for Confluence documentation. It cover migration from chroot hacks to utilization of urls in pkgdir of the image_

# Steps 1 - 4

_no change, just run deploy.yml as usual_

# 5 - Image

```
copycds CentOS-7-x86_64-DVD-1810.iso

mkdir -p /install/custom/postinstall/centos7.6/
cat <<EOF > /install/custom/postinstall/centos7.6/add-cluster-key.sh
#!/bin/bash
pubkey=$(cat ~/.ssh/id_ed25519.pub)
authorized_keys="$IMG_ROOTIMGDIR/root/.ssh/authorized_keys"
if [ ! -f $authorized_keys ]; then
    mkdir -p $IMG_ROOTIMGDIR/root/.ssh || : # ignore error
    chmod 0700 $IMG_ROOTIMGDIR/root/.ssh
    echo "$pubkey" >> $authorized_keys
else
    grep "$pubkey" $authorized_keys || echo "$pubkey" >> $authorized_keys
fi
EOF
chmod +x /install/custom/postinstall/centos7.6/add-cluster-key.sh
chdef -t osimage -o centos7.6-x86_64-netboot-compute -p postinstall=/install/custom/postinstall/centos7.6/add-cluster-key.sh

mkdir -p /install/custom/netboot/centos7.6/
touch /install/custom/netboot/centos7.6/compute.pkglist
echo freeipa-client >> /install/custom/netboot/centos7.6/compute.pkglist
chdef -t osimage -o centos7.6-x86_64-netboot-compute -p pkglist=/install/custom/netboot/compute.synclist

# ★★★ New ★★★
chdef -t osimage -o centos7.6-x86_64-netboot-compute -p pkgdir=http://vault.centos.org/7.6.1810/os/x86_64/
chdef -t osimage -o centos7.6-x86_64-netboot-compute -p pkgdir=http://vault.centos.org/7.6.1810/updates/x86_64/
chdef -t osimage -o centos7.6-x86_64-netboot-compute -p pkgdir=http://vault.centos.org/7.6.1810/extras/x86_64/
chdef -t osimage -o centos7.6-x86_64-netboot-compute -p pkgdir=http://download.fedoraproject.org/pub/epel/7/x86_64
chdef -t osimage -o centos7.6-x86_64-netboot-compute -p pkgdir=http://build.openhpc.community/OpenHPC:/1.3/CentOS_7
chdef -t osimage -o centos7.6-x86_64-netboot-compute -p pkgdir=http://build.openhpc.community/OpenHPC:/1.3/updates/CentOS_7

# We run genimage here only for tracking errors before proceed
genimage centos7.6-x86_64-netboot-compute
```

# 6 - Basic OpenHPC

_Steps that doesn't change image root keep the same, for image tweaking the following is used_

```
mkdir -p /install/custom/netboot/centos7.6/
cat <<EOF >> /install/custom/netboot/centos7.6/compute.pkglist
ohpc-base-compute
lmod-ohpc
chrony
EOF
chdef -t osimage -o centos7.6-x86_64-netboot-compute -p pkglist=/install/custom/netboot/compute.synclist

mkdir -p /install/custom/postinstall/centos7.6/
cat <<EOF > /install/custom/postinstall/centos7.6/chrony-config.sh
sed -i s/0.centos.pool.ntp.org/headnode.cluster.example.com/ $IMG_ROOTIMGDIR/etc/chrony.conf
sed -i /centos.pool/d $IMG_ROOTIMGDIR/etc/chrony.conf
EOF
chmod +x /install/custom/postinstall/centos7.6/chrony-config.sh
chdef -t osimage -o centos7.6-x86_64-netboot-compute -p postinstall=/install/custom/postinstall/centos7.6/chrony-config.sh

# We run genimage here only for tracking errors before proceed
genimage centos7.6-x86_64-netboot-compute
```

# 7 - Slurm

```
yum install ohpc-slurm-server

perl -pi -e "s/ClusterName=\S+/ClusterName=ClusterExample/" /etc/slurm/slurm.conf
perl -pi -e "s/ControlMachine=\S+/ControlMachine=headnode.cluster.example.com/" /etc/slurm/slurm.conf
sed -i s/NodeName/\#NodeName/ /etc/slurm/slurm.conf
sed -i s/PartitionName/\#PartitionName/ /etc/slurm/slurm.conf
sed -i s/ReturnToService=1/\ReturnToService=2/ /etc/slurm/slurm.conf

mkdir -p /install/custom/netboot
cat >> /install/custom/netboot/compute.synclist << EOF
/etc/slurm/slurm.conf -> /etc/slurm/slurm.conf
/etc/munge/munge.key -> /etc/munge/munge.key
EOF
chdef -t osimage -o centos7.6-x86_64-netboot-compute synclists="/install/custom/netboot/compute.synclist"

systemctl enable munge
systemctl start munge
systemctl enable slurmctld
systemctl start slurmctld

echo ohpc-slurm-client >> /install/custom/netboot/centos7.6/compute.pkglist

mkdir -p /install/custom/postinstall/centos7.6/versatushpc/
cat <<EOF >/install/custom/postinstall/centos7.6/versatushpc/slurm.sh
if [ ! -f \$IMG_ROOTIMGDIR/etc/systemd/system/slurmd.service ]; then
    cp $IMG_ROOTIMGDIR/usr/lib/systemd/system/slurmd.service \$IMG_ROOTIMGDIR/etc/systemd/system/
    sed -e '/\[Unit\]/a\StartLimitBurst=5\nRestartLimitIntervalSec=33' \\
        -e '/\[Service\]/a\Restart=always\nRestartSec=5'               \\
        -i \$IMG_ROOTIMGDIR/etc/systemd/system/slurmd.service
    chroot \$IMG_ROOTIMGDIR systemctl enable munge
    chroot \$IMG_ROOTIMGDIR systemctl enable slurmd
fi
EOF
chmod +x /install/custom/postinstall/centos7.6/versatushpc/slurm.sh
chdef -t osimage -o centos7.6-x86_64-netboot-compute -p postinstall=/install/custom/postinstall/centos7.6/versatushpc/slurm.sh

genimage centos7.6-x86_64-netboot-compute
packimage centos7.6-x86_64-netboot-compute
```

# Other steps
Remaning steps keep the same
