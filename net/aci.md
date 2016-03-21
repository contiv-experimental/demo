##DIY Guide to setup Contiv Networking in ACI setup

This document mentions the steps/pre-requisites required to setup the cluster in ACI mode. Note that the steps listed here are in addition to the steps mentioned in the [general README](https://github.com/contiv/demo/tree/master/net/README.md).

### Pre-requisites for ACI setup

#### VLANS

Contiv currently uses vlans starting from 100. Please make sure that a block of vlans starting from 100 are
 reserved for use by Contiv. This will be made configurable in a subsequent release.

#### APIC Configuration (Fabric/Access Policies)

    1. Create a VLAN Pool under "Fabric" -> "Access Policies" -> "Pools" -> "VLAN". Set allocation mode to
       "Static Allocation".

    2. Create a physical domain under "Fabric" -> "Access Policies" -> "Physical and External Domains" -> "Physical Domains"

    3. Create an Attachable Access Entity Profile(AAEP) and associate with the physical domain created in step #2.

    4. Create a Policy Group (under Interface Policies) and specify the AAEP created in step #3.

    5. Create an Interface Profile and specify the physical interfaces connected from your ToR(s) to the bare metal servers.
       You can create separate Interface Profiles for individual ToRs if you like.

    6. Create a Switch Profile (Switch Policies/Profiles) and specify the appropriate interface profile created in step 5.

    7. Make a note of the full node name of the ToRs you have connected to your servers.

    8. Find the interface name of the NIC on the server that is connected to the ToR (e.g. eth5).

### Additional information in the cfg.yml

Sample cfg.yml for ACI setup: [sample_aci_cfg.yml](https://github.com/contiv/demo/tree/master/net/extras/sample_aci_cfg.yml)

Apart from providing the usual information in the cfg.yml (as described [here](https://github.com/contiv/demo/tree/master/net/README.md#information-in-cfgyml)), the following additional details are required to provide access information to the APIC and the leaf(s) connected to the ACI topology.

##### ACI setup Info
All options listed below for ACI setup are mandatory.
###### General APIC reachability information 

          APIC_URL: "https://<apic-server-url>:443"
          APIC_USERNAME: "admin"
          APIC_PASSWORD: "password"

###### Physical domain information 
       This is the physical domain created in step 2 of the APIC Configuration steps. 
       NOTE: This is the just the physical domain name. Do NOT prefix this "uni/phys-"
          APIC_PHYS_DOMAIN: "<phys_domain>" 
       example:
          APIC_PHYS_DOMAIN: "allVlans-Test"

###### Bridge domain information 
       If the intention is not to create new bridge domains for the applications, and use one of the bridge domains already created under tenant common, this can be accomplished by specifying the bridge domain as an env parameter.
       example:
          APIC_EPG_BRIDGE_DOMAIN: "test"  
       NOTE: Please make sure that this bridge domain is already created. And, also, this override works only for bridge domains in Tenant common.
       Otherwise, specify the bridge domain as "not_specified"
          APIC_EPG_BRIDGE_DOMAIN: "not_specified"  

###### Unrestricted EPG<->EPG communication 
       EPs within an EPG can always communicate without restrictions. But, inter-EPG communications are always dictated by contracts. But, if the intent is to allow unrestricted communication between EPGs (under a particular tenant), the following knob can be used:

           APIC_CONTRACTS_UNRESTRICTED_MODE: "yes"
       This will make sure that the EPG consumes the default "allow-all" contract.
       Otherwise, specify this knob as "no"
           APIC_CONTRACTS_UNRESTRICTED_MODE: "no"

###### Information related to leaf nodes 
Full path of the leaf nodes connected to your servers. Use the informtion obtained in Step 8 of [APIC Configuration](aci.md#apic-configuration-fabricaccess-policies) here.

        APIC_LEAF_NODES:
        - topology/pod-1/node-101
        - topology/pod-1/node-102

### Running the installer in ACI mode
To run the installer in ACI mode use the -a option

          ./net_demo_isntaller -a

To restart the services once installed use the -r option. This ensures that the services are restarted in a clean state.

          ./net_demo_isntaller -ar

### NOTE
The installer script downloads some basic containers (web/redis) to get you going
