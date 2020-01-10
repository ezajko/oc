Postfix
=======

Install and configure postfix, supports this profiles:

* local delivery (Delivery e-mails locally only)
* sasl (Authenticate to a SMTP server with user and password) _depends on server configuration_
* relay (Relay e-mails to another SMTP server) _depends on server configuration_


Role Variables
--------------

|variable|values|desc|
|---|---|---| 
|postfix_install|yes/no|When no, skip the role exection|
|postfix_profile|local/relay/sasl|The type of configuration you want|
|postfix_relay_server|domain|Server to where messages are relayed|
|postfix_relay_port|int|Server port to where messages are relayed|
|postfix_sasl__user|text|SMTP user|
|postfix_sasl_password|text|SMTP password
|postfix_sasl_server|domain|SMTP server name or IP|
|postfix_sasl_port|int|SMTP server port|

Variables not prompted

|variable|values|desc|
|---|---|---| 
|postfix_myhostname|string|main.cf/myhostname|
|postfix_mydomain|string|main.cf/mydomain|
|postfix_mydestination|list|main.cf/mydestination|
|fqdn|string|The FQDN of the server, is used as file name for looking certificates and keys, see Requirements


A description of the settable variables for this role should go here, including
any variables that are in defaults/main.yaml, vars/main.yaml, and any variables
that can/should be set via parameters to the role. Any variables that are read
from other roles and/or the global scope (ie. hostvars, group vars, etc.) should
be mentioned here as well.

Requirements
------------

This role may configure Postfix to use TLS, see the table bellow to find out where the certificates are expected to be found:

|file|expected path|
|---|---|
|Certificate|`/etc/pki/tls/certs/<FQDN>.cer`|
|Private key|`/etc/pki/tls/private/<FQDN>.key`|

Where `<FQDN>` is the full qualified name of the machine being set up. The creation of this files is not of this role business, for this see [certificate](../certificate/README.md) role.

Dependencies
------------

None

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables
passed in as parameters) is always nice for users too:

    - hosts: sms
      roles:
         - postfix
