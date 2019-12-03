import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']
).get_hosts('all')


def test_hosts_file(host):
    files = (
        '/etc/pki/tls/private/newcluster.clusterdomain.key',
        '/etc/pki/tls/certs/newcluster.clusterdomain.cer',
        '/etc/pki/tls/certs/newcluster.clusterdomain.csr',
    )
    assert all(host.file(f).exists for f in files)
