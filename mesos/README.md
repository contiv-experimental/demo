
For vagrant demo, try
https://github.com/contiv/netplugin/tree/master/vagrant/mesos-cni

####Pre-requisites

```
CentOS 7.x machines with 2 network interfaces.
ansible setup to configure cluster.
Passwordless ssh to machines
```

###Step 1 Download files
```
mkdir -p some_dir && cd some_dir
wget https://raw.githubusercontent.com/contiv/demo/master/mesos/download.sh
./download.sh
```


###Step 2 Create inventory file
```
create ansible "inventory" file
follow example file inventory.example 
```

###Step 3 Execute playbook  
```
./setup.sh 

```

Example: bring-up vagrant cluster of 5 nodes & configure mesos/marathon with contiv
```
# bring up vagrant nodes
vagrant up

# update passwordless ssh to vagrant nodes
SSHKEY=$(vagrant ssh-config | grep IdentityFile | head -n1 | awk -F' ' '{ print $2 }')
ssh vagrant@192.168.33.10---14 -i ${SSHKEY}

# crate inventory
cp inventory.example inventory

# execute ansible playbook 
SSHKEY=$(vagrant ssh-config | grep IdentityFile | head -n1 | awk -F' ' '{ print $2 }')
./setup.sh -u vagrant  --private-key=${SSHKEY}
```

###Step 4 Launch containers

```
use "cni_task.sh" script to launch containers.
wget https://raw.githubusercontent.com/contiv/netplugin/master/vagrant/mesos-cni/cni_task.sh

This script creates contiv tenant/network.

usage: ./cni_task.sh [-m marathon-ipaddr] [-j jobname] [-t tenant-name] [-n network-name] [-g network-group] [-s subnet]
-m marathon-ipaddr : 192.168.2.10:5050 is by default
-j jobname         : "container.xxx" by default
-t tenant-name     : "default" by default
-n network-name    : "default-net" by default
-s subnet          : "10.36.28.0/24" by default

# create a python http server listening on port 9002 in contiv network 
'default-net'

./cni_task.sh 
```
to launch containers without using cni_task.sh, create network using netctl cli 

```
$ netctl net create default-net -subnet 10.1.1.0/24

create a json file & update the following fields with apropriate value
id : <unique id>
io.contiv.tenant :<name of contiv tenant name>
io.contiv.network : <name of contiv network name>
io.contiv.net-group : <name of contiv network group>

{
  "id": "container1",
  "cmd": "python -m SimpleHTTPServer 9002",
  "cpus": 1,
  "mem": 500,
  "disk": 0,
  "instances": 1,
  "container": {
    "type": "MESOS",
    "volumes": [],
    "mesos": {
      "image": "ubuntu:14.04",
      "privileged": false,
      "parameters": [],
      "forcePullImage": false
    }
  },
  "ipAddress": {
     "networkName": "netcontiv",
     "labels": {
         "io.contiv.tenant": <name of contiv tenant name>
         "io.contiv.network": <name of contiv network name>
         "io.contiv.net-group": <name of contiv network group> 
     }

 }
}
```


```
launch the containers by sending json configutaion to marathon
curl -X POST http://192.168.2.10:8080/v2/apps -d @${JSON_FILE} \
     -H "Content-type: application/json"
```
###Step 5 Check mesos/marathon
 mesos gui master:5050
 marathon gui  master:8080
 * mesos runs in HA mode,
 * marathon runs on the first master node

