import os
from configparser import ConfigParser
from subprocess import check_output

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']
).get_hosts('all')


def test_hosts_file(host):
    basepath = '/etc/yum.repos.d/CentOS-Base.repo'
    vaultpath = '/etc/yum.repos.d/CentOS-Vault.repo'
    baserepos = host.file(basepath)
    vaultrepos = host.file(vaultpath)

    version = host.ansible.get_variables()['centos_vault_version']
    repos = 'base extras updates'.split()

    assert baserepos.exists
    assert vaultrepos.exists

    baseconfig = ConfigParser().read(basepath)
    vaultconfig = ConfigParser().read(vaultpath)
    repolist = check_output('yum repolist'.split(), universal_newlines=True)
    for repo in repos:
        assert baseconfig[repo]['enabled'] == '0'
        vault = 'C{}-{}'.format(version, repo)
        assert vaultconfig[vault]['enabled'] == '1'
        assert vault in repolist
