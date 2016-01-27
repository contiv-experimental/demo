## Multicast application demo
The purpose of the document is to illustrate the experiment done to validate
multicast in a contiv network.

### Steps to run sender and receiver multicast application between containers
For this experiement we will run 2 containers , one on each VM. We will create a vlan network
and run a sender and receiver multicast application.

#### Step 1: Pull the contiv netplugin workspace from github
    ```
   $ git clone https://github.com/contiv/netplugin
   $ cd netplugin
   ```

#### Step 2: Run the demo script
   `$ make demo`

#### Step 3: Login to netplugin-node1
   `$ vagrant ssh netplugin-node1`

#### Step 4: Create a network
  `$ sudo netctl net create contiv-net --encap=vlan --subnet=20.1.1.0/24 --gateway=20.1.1.254 --pkt-tag=1010`

#### Step 5: Pull a docker multicast application box from dockerhub
   `$ docker pull qiwang/centos7-mcast`

#### Step 6: Run a docker container in the network created.
   `$ docker run -it --name=msender --net=contiv-net qiwang/centos7-mcast /bin/bash`

#### Step 7: On container msender go to /root directory and run the multicast sender application
```
   root@9f4e7fd418c5:/# cd /root
   root@9f4e7fd418c5:/# ./mcast.py -s -i eth0
```
#### Step 8: Login to netplugin-node2
   `vagrant ssh netplugin-node2`

#### Step 9: Pull a docker multicast application box from dockerhub
    `$ docker pull qiwang/centos7-mcast`

#### Step 10: Run a docker container in the network created.
    `$ docker run -it --name=mreceiver --net=contiv-net qiwang/centos7-mcast /bin/bash`

#### Step 11: Go to /root directory and run the multicast receiver application
     ```
    root@564f7f4424c1:/# cd /root
    root@564f7f4424c1:/# ./mcast.py -i eth0

    ('20.1.1.3', 35624)  '1453881422.973572'
    ('20.1.1.3', 35624)  '1453881423.977554'
    ('20.1.1.3', 35624)  '1453881424.978941'
    ```

    where 20.1.1.3 is the IP assigned to container msender.


### Steps to run sender and receiver multicast application between container and host VM

#### Step 1: Run the demo setup
   `$ make demo`

#### Step 2: Login to netplugin-node1
   `$vagrant ssh netplugin-node1`

#### Step 3: Create a network for eg:contiv-net
   `$ sudo netctl net create contiv-net --encap=vlan --subnet=20.1.1.0/24 --gateway=20.1.1.254 --pkt-tag=1010`

#### Step 4: Create a port on the OVS with the network tag used for contiv-net
  ```
   $ sudo ovs-vsctl add-port contivVlanBridge port1 -- set interface inb01 type=internal
   $ sudo ovs-vsctl set port port1 tag=1010
   $ ifconfig port1 30.1.1.8/24
  ```

#### Step 5: Launch a multicast application
   for eg https://github.com/leslie-wang/py-multicast-example
   `$ ./mcast.py -s -i inb01`

#### Step 6: Login to netplugin-node2
   `$ vagrant ssh netplugin-node2`

#### Step 7: Pull a docker multicast application box from dockerhub
   `$ docker pull qiwang/centos7-mcast`

#### Step 8: Run a docker container in the network created.
   `$ docker run -it --name=mreceiver --net=contiv-net qiwang/centos7-mcast /bin/bash`

#### Step 9: Go to /root directory and run the multicast receiver application
```
   root@426b8cdbf5f8:/# cd /root
   root@426b8cdbf5f8:/# ./mcast.py -i eth0

   Output on mreceiver:
   ('30.1.1.8', 35678)  '1453882966.102203'
   ('30.1.1.8', 35678)  '1453882967.120764'
   ('30.1.1.8', 35678)  '1453882968.12215'
```
