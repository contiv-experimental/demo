Pre-Requisites for ACI setup
============================

VLANS 

Contiv currently uses vlans starting from 100. Please make sure that a block of vlans starting from 100 are 
reserved for use by Contiv. This will be made configurable in a subsequent release.

APIC Configuration (Fabric/Access Policies)
    
    1. Create a physical domain named "allvlans" (For now, this name is hard-coded. This will be made configurable/generic in
       a follow on release.).

    2. Create a vlan pool with a block of vlans starting with 100 as described above. Set allocation mode to "Static Allocation"
       and associate with the "allvlans" physical domain.

    3. Create an Attachable Access Entity Profile(AAEP) and associate with the "allvlans" physical domain.

    4. Create a Policy Group (under Interface Policies) and specify the AAEP created in the previous step.

    5. Create an Interface Profile and specify the physical interfaces connected from your ToR(s) to the bare metal servers.
       You can create separate Interface Profiles for individual ToRs if you like.

    6. Create a Switch Profile (Switch Policies/Profiles) and specify the appropriate interface profile created in step 4.

    7. Make a note of the full node name of the ToRs you have connected to your servers.

    8. Find the interface name of the NIC on the server that is connected to the ToR (e.g. eth5).
