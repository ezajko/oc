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
git clone --recursive https://bitbucket.versatushpc.com.br/scm/sv/deploy.git
cd deploy
git submodule init
git submodule update
```

## Runninng

* `ansible-playbook deploy.yml`
  * Answer the questions to configure the environment.
  * A new file named answers-<DATE>.yml will be created. This
    file contains all your answers to all previous questions, you
    will use this in the next steps.
* Add the image `ansible-playbook add-image.yml -e @answers-<date>.yml`
* Install OpenHPC `ansible-playbook basic-openhpc.yml -e @answers-<date>.yml`
* If using Slurm, install Slurm `ansible-playbook slurm.yml -e @answers-<date>.yml`
* Define nodes
  * Edit `nodes.yml`. Here is a list of variables
  
    |variable|required|desc|
    |---|---|---|
    |mac|yes|mac addess of the node|
    |ipmi_user|no|IPMI username, if ommited the default* one is used|
    |ipmi_password|no|IPMI password, if ommited the default* one is used|
    |slurm.Sockets|only for Slurm|Sockets slurm.conf entry|
    |slurm.CoresPerSocket|only for Slurm|CoresPerSocket slurm.conf entry|
    |slurm.ThreadsPerCore|only for Slurm|ThreadsPerCore slurm.conf entry|

    _* default here means the value present in `answers-<date>.yml`._
  * Run `ansible-deploy define-nodes.yml -e @answers-<date>.yml`. The nodes will be
    defined in the order they appear in the file.

---

# Running single role

`ansible -m include_role -a 'name=<ROLE_NAME>' sms -e @answers-...yml`

# Running single playbook

`ansible -m include_tasks -a 'roles/xcat/tasks/install.yml' sms -e @answers-...yml`

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
