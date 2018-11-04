# chef-openstack deployment
___

## Requirements:  

* Deploy 5 nodes: 2 controllerss and 3 computes
* Deploy using **CHEF**
* Deploy in Packet.net


## Assumptions:  

* The nodes have an installed Operating System
* The nodes have at least two HDD, one for the OS and the other for services such as Cinder and DB
* The nodes have network communication between themselves

## Procedure:  

By default the traditional **CHEF** deployment, is using a master server and bootstrapping the nodes from there, where the master provides cookbooks, roles, environments and configurations.  
One of the requests was to find a way to not use an extra server, so each node must be able to self-provision resources.

For this lab I use:

* Nodes deployed at Packet.net (*c1.small.x86*)  
* CentOS 7   
* OpenStack-Chef Github repo: https://github.com/openstack/openstack-chef  

Because this repo does not contain cookbooks:

* A **chef-server**: https://docs.chef.io/install_server.html#standalone.html  
* **berks**, to easy download cookbooks and their depends: https://downloads.chef.io/chefdk  

### Download cookbooks for distribution

In **chef-server**

* Download and install **Chef Development Kit** witch contains **berks**: https://downloads.chef.io/chefdk  

* Download openstack-chef repo for chef stuff as roles, environments, data bags, etc.

`git clone https://git.openstack.org/openstack/openstack-chef`

* Install cookbooks with dependencies and upload to local **chef-server**

`cd openstack-chef`  
`berks install`  
`berks upload`  

* The above download the cookbooks in the berks path, copy them to our openstack-chef directory.

`cp -a ~/.berkshelf/cookbooks/ openstack-chef/`

At this point, we already have the necessary files to do without **chef-server**, we need to make this directory accessible for the nodes, for example: upload them to GitHub to clone them in each repo, for this lab I use simply `scp`

### Prepare the nodes

In order to deploy OpenStack with this procedure, we need install first a **controller** and then the **computes**

_**CONTROLLER Node:**_

* We need a fresh and updated installation, in addition to NTP for OpenStack

`yum -y install ntpd git-core`  
`yum -y update`  

`reboot`

` systemctl start ntpd && systemctl enable ntpd && ntpq -np`

* Install **chef-client**

`curl -L https://omnitruck.chef.io/install.sh | sudo bash`

* Get the chef files, *in this case*:

`scp -r root@$CHEF-SERVER:/root/openstack-chef/ /root/`
 
*  Copy data bags
 
`cd openstack-chef`
`mkdir -p /etc/chef && cp .chef/encrypted_data_bag_secret /etc/chef/openstack_data_bag_secret`
 
* Assign the IP of the **controller** to the OpenStack endpoints and correct some annoying issues during deployment

`sed -i 's/192.168.101.60/$CONTROLLER-IP/g' environments/multinode.json`
`sed -i 's/localhost/$CONTROLLER-IP/g' environments/multinode.json`
`sed -i 's/192.168.101.60/$CONTROLLER-IP/g' cookbooks/openstack-identity/templates/default/wsgi-keystone.conf.erb`
 
`export LC_ALL=en_US.UTF-8 && export LANG=en_US.UTF-8`
`mkdir -p /etc/neutron/ && touch /etc/neutron/plugin.ini`

* Upload cookbooks locally

`knife cookbook upload -a -z --include-dependencies --cookbook-path cookbooks/`

* Deploy the node

`chef-client -z -E multinode -r 'role[multinode-controller]'`
 
_**COMPUTE Node**_ 

To deploy the compute node, follow exactly the same steps above (using the *$CONTROLLER-IP*) but the final command for the deploy should be:

`chef-client -z -E multinode -r 'role[multinode-compute]'`

### Verify and test

`ssh $CONTROLLER`  
`source /root/openrc`  
`nova --version`  
`openstack service list && openstack hypervisor list`  
`openstack image list`  
`openstack user list`  
`openstack server list`  

Example:

```bash
[root@ctr02 ~]# source /root/openrc
[root@ctr02 ~]# nova --version
10.1.0
[root@ctr02 ~]# openstack service list && openstack hypervisor list
+----------------------------------+----------------+----------------+
| ID                               | Name           | Type           |
+----------------------------------+----------------+----------------+
| 0858679a0c4b4d4c8e38d20ed783bc5a | nova           | compute        |
| 0a2b65bea6b44b69aa6890811235f413 | heat-cfn       | cloudformation |
| 356e531397374f0db450f6e8c339da54 | keystone       | identity       |
| 95eebeb0e80c4f3c8fcb75bd483f3375 | cinderv2       | volumev2       |
| aa9bd8653a1e4d9eb1087071d79590c6 | cinderv3       | volumev3       |
| acc3a6deca8f43ffad17130c4822f128 | glance         | image          |
| b1835b8dafff49baa28d0fb0eecf831e | heat           | orchestration  |
| bb743178bfeb4121bcfddd64048c7a14 | neutron        | network        |
| d06aa45aaf5b44089128b04c5346740f | nova-placement | placement      |
+----------------------------------+----------------+----------------+
+----+---------------------+-----------------+----------------+-------+
| ID | Hypervisor Hostname | Hypervisor Type | Host IP        | State |
+----+---------------------+-----------------+----------------+-------+
|  1 | ctr03.chef.lab      | QEMU            | 147.75.70.231  | up    |
|  2 | ctr05.chef.lab      | QEMU            | 147.75.109.159 | up    |
|  3 | ctr04.chef.lab      | QEMU            | 147.75.109.229 | up    |
|  4 | ctr06.chef.lab      | QEMU            | 147.75.109.231 | up    |
+----+---------------------+-----------------+----------------+-------+
[root@ctr02 ~]#
```

___

William Vera  
<wv@linux.com>  
Oct 24 2018

