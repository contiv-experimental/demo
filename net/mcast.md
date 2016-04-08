## Multicast application demo
The purpose of the document is to illustrate the experiment done to validate
multicast in a contiv network.

### Steps to run sender and receiver multicast application between containers
For this experiement we will run 2 containers , one on each VM. We will create a vlan network
and run a sender and receiver multicast application. For the purpose of this demo we will be using
multicast application from https://github.com/leslie-wang/py-multicast-example

#### Step 1: Pull the contiv netplugin workspace from github
```
$ git clone https://github.com/contiv/netplugin
$ cd netplugin
```

#### Step 2: Create demo VMs
- Start vms
- Create multicast enabled network

```
$ make demo
$ vagrant ssh netplugin-node1
$ netctl net create contiv-net --encap=vlan --subnet=20.1.1.0/24 --gateway=20.1.1.254 --pkt-tag=1010
```

#### Step 3: Run a docker container in the network created and start multicast sender application.
```
$ docker pull qiwang/centos7-mcast
$ docker run -it --name=msender --net=contiv-net qiwang/centos7-mcast /bin/bash
root@9f4e7fd418c5:/# cd /root
root@9f4e7fd418c5:/# ./mcast.py -s -i eth0
```

#### Step 4: Login to netplugin-node2
`vagrant ssh netplugin-node2`


#### Step 5: Run a docker container in the network created and launch the multicast receiver
```
$ docker pull qiwang/centos7-mcast
$ docker run -it --name=mreceiver --net=contiv-net qiwang/centos7-mcast /bin/bash
root@564f7f4424c1:/# cd /root
root@564f7f4424c1:/# ./mcast.py -i eth0

('20.1.1.3', 35624)  '1453881422.973572'
('20.1.1.3', 35624)  '1453881423.977554'
('20.1.1.3', 35624)  '1453881424.978941'
```

where 20.1.1.3 is the IP assigned to container msender.


### Steps to run sender and receiver multicast application between container and host VM

#### Step 1: Create demo VMs
- Start vms
- Create multicast enabled network

```
$ make demo
$ vagrant ssh netplugin-node1
$ netctl net create contiv-net --encap=vlan --subnet=20.1.1.0/24 --gateway=20.1.1.254 --pkt-tag=1010
```

#### Step 2: Create a port on the OVS with the network tag used for contiv-net
```
$ sudo ovs-vsctl add-port contivVlanBridge inb01 -- set interface inb01 type=internal
$ sudo ovs-vsctl set port inb01 tag=1010
$ sudo ifconfig inb01 30.1.1.8/24
```

#### Step 3: Launch a multicast sender application
`$ ./mcast.py -s -i inb01`

#### Step 4: Login to netplugin-node2
`$ vagrant ssh netplugin-node2`

#### Step 5: Run a docker container in the network created and launch multicast receiver.
```
$ docker pull qiwang/centos7-mcast
$ docker run -it --name=mreceiver --net=contiv-net qiwang/centos7-mcast /bin/bash
root@426b8cdbf5f8:/# cd /root
root@426b8cdbf5f8:/# ./mcast.py -i eth0

('30.1.1.8', 35678)  '1453882966.102203'
('30.1.1.8', 35678)  '1453882967.120764'
('30.1.1.8', 35678)  '1453882968.12215'
```
