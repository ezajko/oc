Centos Vault
=========

Install and configure Centos Vault 

Role Variables
--------------

`centos_vault_version`: The CentOS version to PIN


Example Playbook
----------------

Including an example of how to use your role (for instance, with variables
passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: roles/centos-vault, centos_vault_enabled: yes, centos_vault_version: 7.6.1810 }

