## ACI Config high level instructions for inter-working with Contiv

This document lists the steps/pre-requisites required to setup the cluster in ACI mode.

#### VLANS

Contiv currently requires a static pool of vlans that needs to be reserved for use by Contiv. Contiv manages the allocation of these vlans. The vlan range configured in APIC for contive must be ALSO set up in contiv using the *netctl global set* command. See *sample_appcli.sh*.

#### APIC Configuration (*Fabric/Access Policies*)

```
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

    9. Edit aci.yml

   10. Use netctl global set to setup the vlan range from Step 1 in contiv.

```
