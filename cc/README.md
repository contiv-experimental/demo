
#Contiv with Clear Containers Demo

This setup describes how to setup a simple environment to show Clear Containers running with Contiv Networking. This has been validated on Ubuntu 16.04, however it should work on any distribution that supports both Contiv and Clear Containers.

####Clear Container Documentation

Full clear container code and documentation is available at https://github.com/01org/cc-oci-runtime

cc-oci-runtime is an Open Containers Initiative (OCI) "runtime" that launches an Intel VT-x secured Clear Containers 2.0 hypervisor, rather than a standard Linux container. 

#### Step 1: Install the Clear container runtime

https://github.com/01org/cc-oci-runtime/wiki/Installing-Clear-Containers-on-Ubuntu-16.04

#####Note: Please stop at 5; do not setup systemd unit files or drop ins as step 6 and beyond will be done automatically by the setup script.

#### Step 2: Clone the demo project and switch to the clearcontainer branch

```
cd ~
git clone -b clearcontainer https://github.com/contiv/demo 
```

#### Step 3: Setup the demo configuration

Create a cfg.yaml file under ~/demo/cc with right information for your setup

```
## Connection Info
##
## Fill in the interface information for each of the servers
## For each of the servers mention the following details
## <server_ip_or_dns>:
##      control: <mandatory> Interface to use for control traffic
##      data: <mandatory> Interface to use for data traffic
##
## You may use the IP address or the hostname (if you have DNS).
## However, you need to be consistent as the installer tries match
## what you enter here against what you pass to net_demo_installer
## on the command line.
CONNECTION_INFO:
      192.168.2.20:
        control: enp0s8
        data: enp0s9
```

#### Step 4: Create the docker swarm 

```
cd ~/demo/cc
./net_demo_installer
```

#### Step 5: Launch Docker runc containers and verify regular container networking

```
$ netctl net create contiv-net --subnet=20.1.1.0/24
$ docker run -itd --name=web --net=contiv-net alpine /bin/sh
$ docker run -itd --name=db --net=contiv-net alpine /bin/sh
$ docker exec -it web /bin/sh
< inside the container >
root@f90e7fd409c4:/# ping db
PING db (20.1.1.3) 56(84) bytes of data.
64 bytes from db (20.1.1.3): icmp_seq=1 ttl=64 time=0.658 ms
64 bytes from db (20.1.1.3): icmp_seq=2 ttl=64 time=0.103 ms
```

#### Step 6: Launch additional Docker Clear Containers and verify container networking

```
$ docker run -itd --runtime=cor --name=ccweb --net=contiv-net alpine /bin/sh
$ docker run -itd --runtime=cor --name=ccdb --net=contiv-net alpine /bin/sh
$ docker exec -it web /bin/sh
< inside the container >
root@f90e7fd409c4:/# ping ccweb
PING ccweb (20.1.1.4) 56(84) bytes of data.
64 bytes from ccweb (20.1.1.4): icmp_seq=1 ttl=64 time=0.658 ms
64 bytes from ccweb (20.1.1.4): icmp_seq=2 ttl=64 time=0.103 ms
```
