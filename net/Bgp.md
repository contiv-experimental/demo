This documents provides steps to bring up contiv infrastructure in a L3 native vlan mode. 

#What does L3 capabilty facilitate in a Contiv container infrastructure ?

-  Enable communication between containers on different hosts natively using vlan encap 
-  Enables communication between containers and non containers 
-  Provides capability for uplink TOR's/Leaf switches to learn containers deployed in the fabric

#What are the recommended topologies ?

![topo](https://cloud.githubusercontent.com/assets/784144/12862973/26d1136c-cc25-11e5-9451-a266ea033b5e.png)


#Typical worklow:
- Configure Bgp on the Leaf switches Leaf 1 and Leaf 2 
- Bring up Contiv – netplugin and netmaster
- Create a Vlan network with subnet pool and gateway
- Add Bgp configuration on the host, to peer with the uplink leaf
- Bring up containers in the networks created on the host

#What are the supported configurations

- Ensure that BGP peering between the host server and the leaf switch is eBGP
- Currently only one uplink from the server is supported
- Currently supported on bare-metals (watch this space for support on VMs soon)

#Supported version

This document would be applicable starting from the following version:

```
Version: v0.1-02-06-2016.14-42-05.UTC
GitCommit: 392e0a7
BuildTime: 02-06-2016.14-42-05.UTC
```


#Steps to bring up a demo cluster with routing capabilites:

![bgp](https://cloud.githubusercontent.com/assets/784144/12862804/17546052-cc24-11e5-9a17-277999761344.png)


##STEP 0 : Provision the host nodes with required services

Please follow the [prequesite] and [download] steps in the [demo installer] page. This would enable installation of all the required packages , versions of the binary that would be needed to bring up the contiv infrastrure services. At the end of these steps netplugin , netmaster would be started in routing mode. Once the prerequiste is completed please start the installer script. 

```
$chmod +x net_demo_installer
$./net_demo_installer -l 
```
The net_demo_installer will create a cfg.yaml template file on the first run. 

The [cfg.yaml] for the demo topology is as shown below.

```
CONNECTION_INFO:
      172.29.205.224:
        control: eth1
        data: eth7
      172.29.205.255:
        control: eth1
        data: eth6
```
Note: As shown in the topo diagram data interface should be the uplink interface and not the management interface of the server.

Rerun the installer after filling up the cfg.yaml. 
```
./net_demo_installer -l 
```

##STEP 1 : Configure the Switches to run BGP

If you are using the sample topology provided above , the following sample configuration could be used.


###Switch1: 
```
router ospf 500
  router-id 80.1.1.1
router bgp 500
  router-id 50.1.1.2
  address-family ipv4 unicast
    redistribute direct route-map FH
    redistribute static route-map FH
    redistribute ospf 500 route-map FH
  neighbor 50.1.1.1 remote-as 65002
    remote-as 65002
    address-family ipv4 unicast
  neighbor 60.1.1.4 remote-as 500
    remote-as 500
    update-source Vlan1
    address-family ipv4 unicast
    
interface Ethernet1/44
  no switchport
  ip address 80.1.1.1/24
  ip router ospf 500 area 0.0.0.0

vlan 1
route-map FH permit 20
  match ip address HOSTS


interface Vlan1
  no shutdown
  ip address 50.1.1.2/24
  ip router ospf 500 area 0.0.0.0

ip access-list HOSTS
  10 permit ip any any
```
  
###Switch 2:

```
feature ospf
feature bgp
feature interface-vlan

router ospf 500
  router-id 80.1.1.2
router bgp 500
  router-id 60.1.1.4
  address-family ipv4 unicast
    redistribute direct route-map FH
    redistribute ospf 500 route-map FH
  neighbor 50.1.1.2 remote-as 500
    remote-as 500
    update-source Vlan1
    address-family ipv4 unicast
  neighbor 60.1.1.3 remote-as 65002
    remote-as 65002
    address-family ipv4 unicast
    
interface Ethernet1/44
  no switchport
  ip address 80.1.1.2/24
  ip router ospf 500 area 0.0.0.0
  
vlan 1
route-map FH permit 20
  match ip address HOSTS


interface Vlan1
  no shutdown
  ip address 60.1.1.4/24
  ip router ospf 500 area 0.0.0.0
  
ip access-list HOSTS
  10 permit ip any any
  
```

##STEP 2: Add the bgp neighbor on each of the contiv hosts 

On the host where netmaster is running :
```
$netctl bgp create Contiv1 -router-ip="50.1.1.1/24" --as="65002" --neighbor-as="500" --neighbor="50.1.1.2"
$netctl bgp create Contiv2 -router-ip="60.1.1.3/24" --as="65002" --neighbor-as="500" --neighbor="60.1.1.4"
```
where Contiv1 and Contiv2 are the hostnames of the servers shown in the topology.

##STEP 3: Create a network with encap as vlan and start containers in the network

On the host where netmaster is running :
```
$netctl network create public --encap="vlan" --subnet=192.168.1.0/24 --gateway=192.168.1.254
```
On Contiv1 :
```
$docker run -itd --name=web1 --net=public alpine sh
```
On Contiv2 :
```
docker run -itd --name=web2 --net=public alpine sh
```

##STEP 4: Login to continer and verify the ip address has been allocated from the network. 

```
$docker ps -a
CONTAINER ID        IMAGE                          COMMAND             CREATED              STATUS              PORTS               NAMES
084f47e72101        ubuntu                         "bash"              About a minute ago   Up About a minute                       web1
0cc23ada5578        skynetservices/skydns:latest   "/skydns"           6 minutes ago        Up 6 minutes        53/tcp, 53/udp      defaultdns


root@contiv1:~/src/github.com/contiv/netplugin# docker exec -it 084f47e72101 bash
root@084f47e72101:/# ifconfig
eth0      Link encap:Ethernet  HWaddr 02:02:c0:a8:01:03
          inet addr:192.168.1.3  Bcast:0.0.0.0  Mask:255.255.255.0
          inet6 addr: fe80::2:c0ff:fea8:103/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1450  Metric:1
          RX packets:23 errors:0 dropped:0 overruns:0 frame:0
          TX packets:23 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:2062 (2.0 KB)  TX bytes:2062 (2.0 KB)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
```

##STEP 6: Verify that the switches have the container routes

```
Switch-1# show ip route
IP Route Table for VRF "default"
'*' denotes best ucast next-hop
'**' denotes best mcast next-hop
'[x/y]' denotes [preference/metric]
'%<string>' in via output denotes VRF <string>

50.1.1.0/24, ubest/mbest: 1/0, attached
    *via 50.1.1.2, Vlan1, [0/0], 3d23h, direct
50.1.1.2/32, ubest/mbest: 1/0, attached
    *via 50.1.1.2, Vlan1, [0/0], 3d23h, local
60.1.1.0/24, ubest/mbest: 1/0
    *via 80.1.1.2, Eth1/44, [110/44], 3d23h, ospf-500, intra
60.1.1.4/32, ubest/mbest: 1/0
    *via 80.1.1.2, [1/0], 1w3d, static
80.1.1.0/24, ubest/mbest: 1/0, attached
    *via 80.1.1.1, Eth1/44, [0/0], 1w3d, direct
80.1.1.1/32, ubest/mbest: 1/0, attached
    *via 80.1.1.1, Eth1/44, [0/0], 1w3d, local
192.168.1.1/32, ubest/mbest: 1/0
    *via 50.1.1.1, [20/0], 03:49:24, bgp-500, external, tag 65002
192.168.1.2/32, ubest/mbest: 1/0
    *via 60.1.1.3, [200/0], 00:00:02, bgp-500, internal, tag 65002
192.168.1.3/32, ubest/mbest: 1/0
    *via 50.1.1.1, [20/0], 03:47:08, bgp-500, external, tag 65002
```

##STEP 5: Ping between the containers

```
$root@084f47e72101:/# ping 192.168.1.2
PING 192.168.1.2 (192.168.1.2) 56(84) bytes of data.
64 bytes from 192.168.1.2: icmp_seq=1 ttl=62 time=9.29 ms
64 bytes from 192.168.1.2: icmp_seq=2 ttl=62 time=0.156 ms
64 bytes from 192.168.1.2: icmp_seq=3 ttl=62 time=0.139 ms
64 bytes from 192.168.1.2: icmp_seq=4 ttl=62 time=0.130 ms
64 bytes from 192.168.1.2: icmp_seq=5 ttl=62 time=0.123 ms

```

##STEP 6: Ping between container and a switch
 
```
$root@084f47e72101:/# ping 80.1.1.2
PING 80.1.1.2 (80.1.1.2) 56(84) bytes of data.
64 bytes from 80.1.1.2: icmp_seq=1 ttl=254 time=0.541 ms
64 bytes from 80.1.1.2: icmp_seq=2 ttl=254 time=0.549 ms
64 bytes from 80.1.1.2: icmp_seq=3 ttl=254 time=0.551 ms
64 bytes from 80.1.1.2: icmp_seq=4 ttl=254 time=0.562 ms
64 bytes from 80.1.1.2: icmp_seq=5 ttl=254 time=0.484 ms
```


##Policy support

For steps to apply policies supported in contiv networking. Please follow the steps in [Contiv Policies]


[demo installer]: <https://github.com/contiv/demo/tree/master/net>
[prequesite]: <https://github.com/contiv/demo/tree/master/net#pre-requisites>
[download]: <https://github.com/contiv/demo/tree/master/net#step-1-download-the-installer-script>
[cfg.yaml]: <https://github.com/contiv/demo/blob/master/net/extras/sample_cfg.yml>
[Contiv Policies]: <http://contiv.github.io/docs/3_netplugin.html>
















