# Usage

## Install requirements

```
yum install -y epel-release
yum install -y ansible python-netaddr git
```

_IMPORTANT: Make sure that you installed the epel version. The `extras` repository
has ansible 2.4, which is incompatible with this playbook!_


## Clone this repo


```
git clone --recursive https://bitbucket.versatushpc.com.br/scm/sv/deploy-2.0.git
cd deploy-2.0
git submodule init
git submodule update
```

## Runninng

* Before begin make sure to have, at last, the list of mac of the nodes.
* Edit `nodes.yaml`. The variable structures need stay the same. Here is a list of variables and their meanings

  |variable|required|desc|
  |---|---|---|
  |mac|yes|mac addess of the node|
  |ipmi_user|no|IPMI username, if ommited the default* one is used|
  |ipmi_password|no|IPMI password, if ommited the default* one is used|
  |slurm.Sockets|only for Slurm|Sockets slurm.conf entry|
  |slurm.CoresPerSocket|only for Slurm|CoresPerSocket slurm.conf entry|
  |slurm.ThreadsPerCore|only for Slurm|ThreadsPerCore slurm.conf entry|

  _* default here means the value present in `answers-<date>.yaml`._

* Run `ansible-playbook config.yaml` to create configuration file
  - Answer the questions to configure the environment.
  - A new file named answers-<date>.yaml will be created, where `<date>` is the date for today with the hour. This
    file contains all your answers to all previous questions, you will use this in the next steps.

* Run `ansible-playbook deploy.yaml -e @answer-<date>.yaml` to install the base system
* Add the image `ansible-playbook add-image.yaml -e @answers-<date>.yaml`
* To configure infiniband `ansible-playbook infiniband.yaml -e @answers-<date>.yaml`
* Install OpenHPC `ansible-playbook basic-openhpc.yaml -e @answers-<date>.yaml`
* If using Slurm, install Slurm `ansible-playbook slurm.yaml -e @answers-<date>.yaml`
* If using PBS, install PBS `ansible-playbook pbs.yaml -e @answers-<date>.yaml`
* To install ganglia `ansible-playbook ganglia.yaml -e @answers-<date>.yaml`
* To configure postfix `ansible-playbook postfix.yaml -e @answers-<date>.yaml`
* To configure spack `ansible-playbook spack.yaml -e @answers-<date>.yaml`
* To install TexLive  `ansible-playbook latex-support.yaml -e @answers-<date>.yaml`
* Finally to create nodes, run: `ansible-deploy define-nodes.yaml -e @answers-<date>.yaml`. The nodes will be
  defined in the order they appear in the file.

---

# Running single role

`ansible -m include_role -a 'name=<ROLE_NAME>' sms -e @answers-...yaml`

# Running single playbook

`ansible -m include_tasks -a 'roles/xcat/tasks/install.yaml' sms -e @answers-...yaml`

# Questions
|name|prompt|default|choices|help|
|---|---|---|---|---|
|cluster_name|Hostname?|headnode||
|domain_name|Domain name?|cluster.example.com||
|ipaadmin_password|FreeIPA admin password|||
|ipadm_password|FreeIPA Directory Manager password|||FreeIPA Directory Manager password<br/><br/>It uses the same password as admin password entered before. This is used<br/>for authenticating to LDAP.<br/>
|nodes_prefix|Node prefix?|node||
|nodes_separator|Node name separtor (optional)|||
|nodes_padding|Node name padding?|3||
|sms_eth_external|External interface?|eth0||
|sms_eth_internal|Internal interface?|eth1||
|sms_network|Management network?|172.26.0.0/16||Management network is the primary network. Is the one by<br/>which nodes boot and where services like DHCP, DNS, TFTP<br/>talk.<br/>
|sms_ip|Head node management network internal IP?|||
|sms_network_ip_start|Management network first node IP address|||This is the Management Network first node IP address. Remaning nodes<br/>will be addressed by subsequent address.<br/><br/>Expects an IP in the form 10.1.0.1<br/>
|xcat_dhcp_dynamicrange|xCAT DHCP Dynamic range?|||Dynamic range used for xCAT during node discovery.<br/><br/>Expects a IP range like 1.1.1.1-1.1.1.10<br/>
|service_network|Enter the service network|172.25.0.0/16||This is Service Network. Is the network used for BMC services and alike. It<br/>expects to receive a CIDR notation address like 10.1.0.0/16. The network address<br/>for the nodes are inferred from this network, starting from 10.1.0.2 up to<br/>as many as nodes are defined on cluster.csv<br/>
|service_network_ip_start|Service network first node IP address|||This is BMC address of the first node. The reimaing nodes<br/>will be named with subsequent IP address.<br/><br/>Expects an IP address like 10.2.0.1<br/>
|ipmi_user|What is the default IPMI username|ADMIN||
|ipmi_password|IPMI default password|||This can be overriden by node basis. The password<br/>is setup for IPMI connection together with IPMI username<br/>asked before<br/>
|name|prompt|default|choices|help|
|---|---|---|---|---|
|cluster_name|Hostname?|headnode||
|domain_name|Domain name?|cluster.example.com||
|ipaadmin_password|FreeIPA admin password|||
|ipadm_password|FreeIPA Directory Manager password|||FreeIPA Directory Manager password<br/><br/>It uses the same password as admin password entered before. This is used<br/>for authenticating to LDAP.<br/>
|nodes_prefix|Node prefix?|node||
|nodes_separator|Node name separtor (optional)|||
|nodes_padding|Node name padding?|3||
|sms_eth_external|External interface?|eth0||
|sms_eth_internal|Internal interface?|eth1||
|sms_network|Management network?|172.26.0.0/16||Management network is the primary network. Is the one by<br/>which nodes boot and where services like DHCP, DNS, TFTP<br/>talk.<br/>
|sms_ip|Head node management network internal IP?|||
|sms_network_ip_start|Management network first node IP address|||This is the Management Network first node IP address. Remaning nodes<br/>will be addressed by subsequent address.<br/><br/>Expects an IP in the form 10.1.0.1<br/>
|xcat_dhcp_dynamicrange|xCAT DHCP Dynamic range?|||Dynamic range used for xCAT during node discovery.<br/><br/>Expects a IP range like 1.1.1.1-1.1.1.10<br/>
|service_network_enabled|Configure service network?|yes|yes, no|Network used for BMC/IPMI services
|service_network|Enter the service network|172.25.0.0/16||This is Service Network. Is the network used for BMC services and alike. It<br/>expects to receive a CIDR notation address like 10.1.0.0/16. The network address<br/>for the nodes are inferred from this network, starting from 10.1.0.2 up to<br/>as many as nodes are defined on cluster.csv<br/>
|service_network_ip_start|Service network first node IP address|||This is BMC address of the first node. The reimaing nodes<br/>will be named with subsequent IP address.<br/><br/>Expects an IP address like 10.2.0.1<br/>
|ipmi_user|What is the default IPMI username|ADMIN||
|ipmi_password|IPMI default password|||This can be overriden by node basis. The password<br/>is setup for IPMI connection together with IPMI username<br/>asked before<br/>
|queue_system|Choose a queue system|none|none, slurm, pbs|
|pbs_default_place|PBS default place|shared|shared, scatter|PBS default.place option<br/>
|postfix_install|Install postfix?|yes|yes, no|Enable installation and configuration of postfix<br/>
|postfix_profile|Choose a profile for postfix installation?|local|relay, local, sasl|Select the profile. There are 3 options<br/>  local) All messages are delivered locally only<br/>  relay) Messages are relayed to another MTA<br/>  sasl)  Messages are relayed to another MTA, but it<br/>         uses user/password to connect to it<br/>
|postfix_relay_server|Type the MTA to relay to?|||The relay address, ex: relay-smtp.example.com<br/>
|postfix_mynetworks_more|Custom trusted networks? |||Comma separated list, localhost and cluster networks are already added by default<br/>Ex: 192.168.123.0/24, 10.0.0.0/8<br/>
|postfix_relay_server|Relay server?|||
|postfix_relay_port|Relay port?|25||
|postfix_sasl_user|SMTP user?|||
|postfix_sasl_password|SMTP password?|||
|postfix_sasl_server|SMTP server?|||
|postfix_sasl_port|SMTP port?|25||
|certificate_install|Create certificate|yes|yes, no|
|ib_stack|Infiniband stack|none|none, upstream, mellanox|none      => Do not install Infiniband at all<br/>upstream  => The main stream OFED stack, opensource and provided by default repos<br/>mellanox  => The Mellanox OFED stack<br/>
|ib_network|Application network|172.27.0.0/16||This is the network used by applications to talk, is a high speed network.<br/><br/>Expcets a network address like 172.27.0.0/16<br/>
|ib_network_ip_start|Infiniband network first node IP address|||
