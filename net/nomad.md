#Contiv + Nomad

The purpose of the document is to demostrate the simplicity of running Nomad for scheduling docker containers with Contiv as the networking and policy infrastructure for containers

The steps could be adapted to any vagrant or bare-metal setups running contiv components. For the simplicity of the document we assume that 2 nodes are brought with necessary contiv components (netplugin , netmaster)

This could be done using pulling the contiv netplugin workspace form here

make demo



##Step 1: Install nomad on all the vagrant nodes




##Step 2: Fill client and server configuration file for nomad agents. In this demo nomad server and client agent are running on netplugin node1 and a client agent is running on netplugin node2 



##Step 3: Verify the node status to ensure the nodes are discovered and peered.
```
vagrant@netplugin-node1:/tmp$ nomad node-status -address=http://192.168.2.10:4646
    2016/03/16 04:53:03 [DEBUG] http: Request /v1/nodes (117.577µs)
ID        Datacenter  Name             Class  Drain  Status
fcca53eb  dc1         netplugin-node2  foo    false  ready
1233ef56  dc1         netplugin-node1  foo    false  ready
```

##Step 4: Create a network and endpoint group . Attach policies and rules to the same. Skip creating endpoint group creation if the purpose of experimenting is only to verify networking functionality. More information regarding the usage of policy and network can be found at here.




Step 5: Now that infrastructure is setup . Create a job file and schedule tasks




Step 6: Verify endpoints for containers are allocated Ip's from the network created. 
