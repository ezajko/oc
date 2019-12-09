Infiniband
=========

Install infiniband stack. Is possible to choose between `mellanox`, `upstream`, and `none`.

`mellanox`: Install the Mellanox stack
`upstream`: Install the upstream stack
`none`: Do not install infiniband

Role Variables
--------------

`ib_stack`: It can be `ofed` or `vanilla`

Dependencies
------------

A list of other roles hosted on Galaxy should go here, plus any details in
regards to parameters that may need to be set for other roles, or variables that
are used from other roles.

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables
passed in as parameters) is always nice for users too:

    - hosts: sms
      roles:
         - { role: infiniband, ib_stack: ofed }
		 
Running from command line
-------------------------

To run this role alone use the following command

	ansible -m include_role -a name=infinband -e ib_stack=mellanox sms

License
-------

BSD
