Ganglia
=========

Install Ganglia

Requirements
------------
- OHPC repository need to be enabled on the
  target. https://openhpc.community/
- Depends on [cluster-dimage role](../../roles/cluster-dimage/). View
  [prepare.yml](molecule/default/prepare.yml) for an example

Role Variables
--------------

`ganglia_enabled`: `yes/no`. If `no`, Ganglia is not installed at all

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables
passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: ganglia, ganglia_install: yes }
		 
Running this role alone

	 ansible -m include_role -a 'name=ganglia' -e ganglia_install=yes -e cluster_name=newcluster sms

License
-------

BSD
