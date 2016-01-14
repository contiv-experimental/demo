# Options in configuration file
Configuration file has all the information to setup the nodes in various modes. 
This document provides information on the various configuration options required for the setup.

### CONNECTION_INFO
This is a mandatory option that provides the access to all server-nodes in the setup. This information is required for both Standalone and ACI setups.

For every server in the setup, provide the IP/DNS and provide the control, data interface

          CONNECTION_INFO:
          <server1-ip-or-dns>:
            control: <interface on which control protocols can interact>
            data: <interface used to send data packets>
          <server2-ip-or-dns>:
            control: <interface on which control protocols can interact>
            data: <interface used to send data packets>
            

### ACI setup Info
All options listed below for ACI setup are mandatory.
##### General APIC reachability information

          APIC_URL: "https://<apic-server-url>:443"
          APIC_USERNAME: "admin"
          APIC_PASSWORD: "password"

##### Information related to leaf nodes
Full path of the leaf nodes connected to your servers.

        APIC_LEAF_NODES:
        - topology/pod-1/node-101
        - topology/pod-1/node-102
