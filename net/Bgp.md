This documents provides steps to bring up contiv infrastructure in a L3 native vlan mode. 

What does L3 capabilty facilitate in a contiv infrastructure ?

-  Enable communication between containers on different hosts natively using vlan encap 
-  Enables communication between containers and non containers 
-  Provides capability for uplink TOR's/Leaf switches to learn containers deployed in the fabric

What are the recommended topologies ?







Steps to bring up a demo cluster with routing capabilites:


What are the supported configurations

1) Ensure that BGP peering between the host server and the leaf switch is eBGP
2) Currently only one uplink from the server is supported. 


STEP 0 

Please follow the steps completetly in the link given below. This would enable installation of all the required packages , versions of the binary that would be needed to bring up the contiv infrastrure services. At the end of these steps netplugin , netmaster would be started in routing mode. please start the installer script provide in the link with -l option

./net_demo_installer -l 

STEP 1 

If you are using the sample topology provided above :
Ensure the following configurations on the switches

Switch1: 
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

vlan 1,50
route-map FH permit 20
  match ip address HOSTS


interface Vlan1
  no shutdown
  ip address 50.1.1.2/24
  ip router ospf 500 area 0.0.0.0

ip access-list HOSTS
  10 permit ip any any
  
  
  
  
Switch 2:

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
  


STEP 2:

Add the bgp neighbor on each of the contiv hosts 




STEP 3 :

Create a network with encap as vlan and start containers in the network



STEP 4:

Login to continer web and redis and verify the ip address has been allocated from the network. 








STEP 5:
Ping between the containers








STEP 6:
ping between container and a switch. 



















