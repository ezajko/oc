mkdir -p /opt/versatushpc/{etc,xcat}
mkdir -p /opt/versatushpc/xcat/post{install,scripts}

copycds CentOS-7-x86_64-DVD-1810.iso

cat <<'EOF' > /opt/versatushpc/xcat/postinstall/add-cluster-key
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
chmod +x /opt/versatushpc/xcat/postinstall/add-cluster-key
chdef -t osimage -o centos7.6-x86_64-netboot-compute -p postinstall=/opt/versatushpc/xcat/postinstall/add-cluster-key

cat <<'EOF' > /opt/versatushpc/xcat/centos7.6-compute.pkglist
#NEW_INSTALL_LIST#
freeipa-client
EOF
chdef -t osimage -o centos7.6-x86_64-netboot-compute -p pkglist=/opt/versatushpc/xcat/centos7.6-compute.pkglist


chdef -t osimage -o centos7.6-x86_64-netboot-compute -p pkgdir=http://mirror.centos.org/centos/7/os/x86_64/
chdef -t osimage -o centos7.6-x86_64-netboot-compute -p pkgdir=http://mirror.centos.org/centos/7/updates/x86_64/
chdef -t osimage -o centos7.6-x86_64-netboot-compute -p pkgdir=http://mirror.centos.org/centos/7/extras/x86_64/
chdef -t osimage -o centos7.6-x86_64-netboot-compute -p pkgdir=http://mirror.centos.org/centos/7/centosplus/x86_64/
chdef -t osimage -o centos7.6-x86_64-netboot-compute -p pkgdir=http://download.fedoraproject.org/pub/epel/7/x86_64
chdef -t osimage -o centos7.6-x86_64-netboot-compute -p pkgdir=http://build.openhpc.community/OpenHPC:/1.3/CentOS_7
chdef -t osimage -o centos7.6-x86_64-netboot-compute -p pkgdir=http://build.openhpc.community/OpenHPC:/1.3/updates/CentOS_7

# Create keys
for t in dsa ecdsa ed25519 rsa; do ssh-keygen -t $t -f /opt/versatushpc/xcat/ssh_host_${t}_key -N '' <<< y; done

cat <<'eof' > /opt/versatushpc/xcat/postinstall/create-ssh-key
#!/bin/bash -x
\cp -vf /opt/versatushpc/xcat/ssh_host_* $img_rootimgdir/etc/ssh/
exit 0
eof
chmod +x /opt/versatushpc/xcat/postinstall/create-ssh-key
chdef -t osimage -o centos7.6-x86_64-netboot-compute -p postinstall=/opt/versatushpc/xcat/postinstall/create-ssh-key

mkdef -f -t node -o node001 ip=172.26.0.1 bmc=172.25.0.1 mac=56:6f:90:d5:00:45 bmcusername=ADMIN bmcpassword=password mgt=ipmi groups=compute,all netboot=xnba arch=x86_64
ipa host-add  --ip-address=172.26.0.1 node001.cluster.example.com
ipa host-add-managedby --hosts=headnode.cluster.example.com node001.cluster.example.com
# Add all public keys, they are generated at genimage time, so this need to run after genimage
# we can get read of this by creating keys before genimage anc copying it to the image
kinit admin
ipa host-mod $(cat /opt/versatushpc/xcat/ssh_host_*.pub | awk '{ print $2 }' | xargs -n1 -I% echo --sshpubkey=\'%\' | paste -s) --updatedns node001.cluster.example.com
makehosts node001
makedhcp node001



# JOIN  MANUAL

# on server create the keytab for each node
ipa-getkeytab -s headnode.cluster.example.com -D "cn=Directory Manager" -w admin1234 -p host/node001.cluster.example.com -k /opt/versatushpc/etc/node001-krb5.keytab

echo '/opt/versatushpc/etc/node001-krb5.keytab -> (node001) /etc/krb5.keytab' >> /opt/versatushpc/xcat/compute.synclist
chdef -t osimage -o centos7.6-x86_64-netboot-compute synclists="/opt/versatushpc/xcat/compute.synclist"

# postinstall
mkdir -p /opt/versatushpc/xcat/postscripts
ln -sv /opt/versatushpc/xcat/postscripts /install/postscripts/versatushpc
cat <<'EOF2' > /opt/versatushpc/xcat/postscripts/ipa-join
domain_to_basedn() {
    for i in $(echo $1 | tr -s . ' '); do
        echo -n dc=$i,;
    done | sed -e 's/,$//';
}

exec 1> >(logger -s -t xCAT -p local4.info) 2>&1

mkdir -p /etc/{ipa,ssh,sssd,openldap}/

: ${DHCPINTERFACES:=headnode.cluster.example.com|eth1} # fallback for testing

domain="$(hostname -d)"
nodename="$(hostname --fqdn)"
basedn="$(domain_to_basedn $domain)"
headnode="${DHCPINTERFACES%|*}" # this came from xCAT site table
realm="${domain^^}"

On the image
cat > /etc/sssd/sssd.conf << EOF
[domain/$domain]

cache_credentials = True
krb5_store_password_if_offline = True
ipa_domain = cluster.example.com
id_provider = ipa
auth_provider = ipa
access_provider = ipa
ipa_hostname = $nodename
chpass_provider = ipa
ipa_server = _srv_, $headnode
ldap_tls_cacert = /etc/ipa/ca.crt
[sssd]
services = nss, sudo, pam, ssh

domains = $domain
[nss]
homedir_substring = /home

[pam]

[sudo]

[autofs]

[ssh]

[pac]

[ifp]

[secrets]

[session_recording]

EOF

chown root:root /etc/sssd/sssd.conf
chmod 600 /etc/sssd/sssd.conf

authconfig --update --enablesssd --enablesssdauth

cat > /etc/krb5.conf << EOF
includedir /etc/krb5.conf.d/
includedir /var/lib/sss/pubconf/krb5.include.d/

[libdefaults]
  default_realm = $realm
  dns_lookup_realm = true
  dns_lookup_kdc = true
  rdns = false
  dns_canonicalize_hostname = false
  ticket_lifetime = 24h
  forwardable = true
  udp_preference_limit = 0
  default_ccache_name = KEYRING:persistent:%{uid}


[realms]
  $realm = {
    pkinit_anchors = FILE:/var/lib/ipa-client/pki/kdc-ca-bundle.pem
    pkinit_pool = FILE:/var/lib/ipa-client/pki/ca-bundle.pem

  }


[domain_realm]
  .$domain                     = $realm
  $domain                      = $realm
  $nodename                    = $realm

EOF

curl -o /etc/ipa/ca.crt http://$headnode/ipa/config/ca.crt

certutil -A -d /etc/ipa/nssdb -n "IPA CA" -t CT,C,C -a -i /etc/ipa/ca.crt

systemctl start certmonger.service
systemctl enable certmonger.service

ipa-getcert request -d /etc/pki/nssdb -n Server-Cert -K HOST/$nodename -N "CN=$nodename,O=$realm"

# This is weird; the NIS domain should be the domain and not the hostname:
authconfig --nisdomain=$nodename --update

cat >> /etc/nsswitch.conf << EOF

sudoers: files sss

EOF

# My changes
cat > /etc/ipa/default.conf << EOF
[global]
basedn = $basedn
realm = $realm
domain = $domain
server = $headnode
host = $nodename
xmlrpc_uri = https://$headnode/ipa/xml
enable_ra = True
EOF

cat >> /etc/openldap/ldap.conf << EOF
URI ldaps://$headnode
BASE $basedn
TLS_CACERT /etc/ipa/ca.crt
EOF

cat >> /etc/ssh/ssh_config << EOF

GlobalKnownHostsFile /var/lib/sss/pubconf/known_hosts
PubkeyAuthentication yes
ProxyCommand /usr/bin/sss_ssh_knownhostsproxy -p %p %h

Host *
    GSSAPIAuthentication yes
# If this option is set to yes then remote X11 clients will have full access
# to the original X11 display. As virtually no X11 client supports the untrusted
# mode correctly we set this to yes.
    ForwardX11Trusted yes
# Send locale-related environment variables
    SendEnv LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES
    SendEnv LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT
    SendEnv LC_IDENTIFICATION LC_ALL LANGUAGE
    SendEnv XMODIFIERS
EOF

cat >> /etc/ssh/sshd_config << EOF
KerberosAuthentication no
PubkeyAuthentication yes
UsePAM yes
AuthorizedKeysCommand /usr/bin/sss_ssh_authorizedkeys
GSSAPIAuthentication yes
ChallengeResponseAuthentication yes
AuthorizedKeysCommandUser nobody
EOF

systemctl start sssd
systemctl enable sssd
systemctl restart sshd
EOF2
chmod +x /opt/versatushpc/xcat/postscripts/ipa-join
chdef -t osimage -o centos7.6-x86_64-netboot-compute -p postscripts=versatushpc/ipa-join


# HBA

ipa hostgroup-add --desc="Compute Nodes" compute
ipa hostgroup-add-member --hosts=node001.cluster.example.com compute

# on server
echo -e "\tHostbasedAuthentication yes" >> /etc/ssh/ssh_config
echo -e "\tEnableSSHKeysign yes" >> /etc/ssh/ssh_config

# on nodecat
cat <<'EOF' >/opt/versatushpc/xcat/postinstall/hostbased-auth
#!/bin/sh -x

# Configure Image Clientside
grep -E 'HostbasedAuthentication yes' $IMG_ROOTIMGDIR/etc/ssh/ssh_config || echo -e "\tHostbasedAuthentication yes" >> $IMG_ROOTIMGDIR/etc/ssh/ssh_config
grep -E 'EnableSSHKeysign yes'        $IMG_ROOTIMGDIR/etc/ssh/ssh_config || echo -e "\tEnableSSHKeysign yes"        >> $IMG_ROOTIMGDIR/etc/ssh/ssh_config

# Configure Image Serverside
test -f $IMG_ROOTIMGDIR/etc/ssh/shosts.equiv || cat <<EOF2 > $IMG_ROOTIMGDIR/etc/ssh/shosts.equiv
headnode.cluster.example.com
@compute
EOF2

cat $IMG_ROOTIMGDIR/etc/ssh/sshd_config
sed -e 's/^#HostbasedAuthentication no/HostbasedAuthentication yes/' -i~ $IMG_ROOTIMGDIR/etc/ssh/sshd_config
cat $IMG_ROOTIMGDIR/etc/ssh/sshd_config

# Create the known_hosts file with the keys:
export DSA_KEY=`cat $IMG_ROOTIMGDIR/etc/ssh/ssh_host_dsa_key.pub | cut -f 2 -d " "`
export RSA_KEY=`cat $IMG_ROOTIMGDIR/etc/ssh/ssh_host_rsa_key.pub | cut -f 2 -d " "`
export ECDSA_KEY=`cat $IMG_ROOTIMGDIR/etc/ssh/ssh_host_ecdsa_key.pub | cut -f 2 -d " "`
export ED25519_KEY=`cat $IMG_ROOTIMGDIR/etc/ssh/ssh_host_ed25519_key.pub | cut -f 2 -d " "`

ssh-keyscan headnode.cluster.example.com > $IMG_ROOTIMGDIR/etc/ssh/ssh_known_hosts
cat <<EOF2 >> $IMG_ROOTIMGDIR/etc/ssh/ssh_known_hosts
node* ssh-dsa $DSA_KEY
node* ssh-ed25519 $RSA_KEY
node* ecdsa-sha2-nistp256 $ECDSA_KEY
node* ssh-rsa $ED25519_KEY
EOF2
EOF
chmod +x /opt/versatushpc/xcat/postinstall/hostbased-auth

chdef -t osimage -o centos7.6-x86_64-netboot-compute -p postinstall=/opt/versatushpc/xcat/postinstall/hostbased-auth

rm -rf /install/netboot/centos7.6/x86_64/compute/rootimg
genimage centos7.6-x86_64-netboot-compute
yum install -y pigz # makes packimage faster
packimage centos7.6-x86_64-netboot-compute
nodeset node001 osimage=centos7.6-x86_64-netboot-compute
