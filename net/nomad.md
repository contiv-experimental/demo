#Contiv + Nomad

The purpose of the document is to demostrate the simplicity of using Contiv as the networking and policy infrastructure for containers with Nomad for scheduling docker containers

The steps could be adapted to any vagrant or bare-metal setups running contiv components. For the simplicity of the document we assume that 2 nodes are brought with necessary contiv components (netplugin , netmaster)

[Clone] the contiv netplugin [workspace] and bringup vagrant nodes

##Step 0:
```
$vagrant ssh netplugin-node1
vagrant@netplugin-node1:/tmp$ ifconfig eth1
eth1      Link encap:Ethernet  HWaddr 08:00:27:d5:98:b7  
          inet addr:192.168.2.10  Bcast:0.0.0.0  Mask:255.255.255.0
          inet6 addr: fe80::a00:27ff:fed5:98b7/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:1066749 errors:0 dropped:0 overruns:0 frame:0
          TX packets:1364141 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:105016452 (105.0 MB)  TX bytes:141250926 (141.2 MB)
```

```
$vagrant ssh netplugin-node2
vagrant@netplugin-node2:~$ ifconfig eth1
eth1      Link encap:Ethernet  HWaddr 08:00:27:1f:1a:5b  
          inet addr:192.168.2.11  Bcast:0.0.0.0  Mask:255.255.255.0
          inet6 addr: fe80::a00:27ff:fe1f:1a5b/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:1360689 errors:0 dropped:0 overruns:0 frame:0
          TX packets:1064053 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:140892098 (140.8 MB)  TX bytes:104739491 (104.7 MB)
```

##Step 1: Install nomad on all the vagrant nodes

```
$ vagrant ssh netplugin-node1
vagrant@netplugin-node1:cd /tmp/
vagrant@netplugin-node1:curl -sSL https://releases.hashicorp.com/nomad/0.3.0/nomad_0.3.0_linux_amd64.zip -o nomad.zip
vagrant@netplugin-node1:echo Installing Nomad...
vagrant@netplugin-node1:unzip nomad.zip
vagrant@netplugin-node1:sudo chmod +x nomad
vagrant@netplugin-node1:sudo mv nomad /usr/bin/nomad
vagrant@netplugin-node1:sudo mkdir -p /etc/nomad.d
vagrant@netplugin-node1:sudo chmod a+w /etc/nomad.d
```

##Step 2: Create client and server Config file to run nomad agents

Fill client and server configuration file for nomad client and server agents. In this demo nomad server and client agent are running on netplugin node1 and a client agent is running on netplugin node2. 

**client1.hcl**
```
# Increase log verbosity
log_level = "DEBUG"         

# Setup data dir
data_dir = "/tmp/client1"

enable_debug = true
bind_addr = "192.168.2.10"

addresses {
    rpc = "192.168.2.10"
    http = "192.168.2.10"
    serf = "192.168.2.10"
}

advertise {
# We need to specify our host's IP because we can't
# advertise 0.0.0.0 to other nodes in our cluster.

    rpc = "192.168.2.10:5647"
    http = "192.168.2.10:5646"
    serf = "192.168.2.10:5648"
}


# Enable the client
client {
    enabled = true

    # For demo assume we are talking to server1. For production,
    # this should be like "nomad.service.consul:4647" and a system
    # like Consul used for service discovery.
    servers = ["192.168.2.10:4647"]
    node_class = "foo"
    options {
        "driver.raw_exec.enable" = "1"
    }

    reserved {
       cpu = 300
       memory = 301
       disk = 302
       iops = 303
       reserved_ports = "1-3,80,81-83"
    }
}

# Modify our port to avoid a collision with server1
ports {
    http = 5646
    rpc = 5647
    serf = 5648
}
```

**server.hcl**
```
# Increase log verbosity
log_level = "DEBUG"

bind_addr = "192.168.2.10"

addresses {
  rpc = "192.168.2.10"
  http = "192.168.2.10"
  serf = "192.168.2.10"
}

advertise {
  # We need to specify our host's IP because we can't
  # advertise 0.0.0.0 to other nodes in our cluster.
  rpc = "192.168.2.10:4647"
  http = "192.168.2.10:4646"
  serf = "192.168.2.10:4648"
}

# Setup data dir
data_dir = "/tmp/server1"

# Enable the server
server {
    enabled = true

    # Self-elect, should be 3 or 5 for production
    bootstrap_expect = 1
}

ports {
    http = 4646
    rpc = 4647
    serf = 4648
}

```

**client2.hcl**
```
# Increase log verbosity
log_level = "DEBUG"

# Setup data dir
data_dir = "/tmp/client1"

enable_debug = true
bind_addr = "192.168.2.11"

addresses {
    rpc = "192.168.2.11"
    http = "192.168.2.11"
    serf = "192.168.2.11"
}

advertise {
# We need to specify our host's IP because we can't
# advertise 0.0.0.0 to other nodes in our cluster.

    rpc = "192.168.2.11:4647"
    http = "192.168.2.11:4646"
    serf = "192.168.2.11:4648"
}


# Enable the client
client {
    enabled = true

    # For demo assume we are talking to server1. For production,
    # this should be like "nomad.service.consul:4647" and a system
    # like Consul used for service discovery.
    servers = ["192.168.2.10:4647"]
    node_class = "foo"
    options {
        "driver.raw_exec.enable" = "1"
    }

    reserved {
       cpu = 300
       memory = 301
       disk = 302
       iops = 303
       reserved_ports = "1-3,80,81-83"
    }
}

# Modify our port to avoid a collision with server1
ports {
    http = 4646
    rpc = 4647
    serf = 4648
}
```
```
$vagrant ssh netplugin-node1
vagrant@netplugin-node1:nomad agent -config server.hcl &
vagrant@netplugin-node1:nomad agent -config client1.hcl &
```
```
vagrant ssh netplugin-node2
vagrant@netplugin-node2:nomad agent -config client2.hcl &
```

##Step 3: Verify the node status to ensure the nodes are discovered and peered.
```
vagrant@netplugin-node1:/tmp$ nomad node-status -address=http://192.168.2.10:4646
    2016/03/16 17:51:11 [DEBUG] http: Request /v1/nodes (101.494µs)
ID        Datacenter  Name             Class  Drain  Status
8cd0aaa1  dc1         netplugin-node2  foo    false  ready
4bac61f9  dc1         netplugin-node1  foo    false  ready
```

##Step 4: Create a network and attach it to an endpoint group.

If endpoint group has to be attached to a network - create policies and attach rules to the same. . Refer to the [contiv docs] on steps to create policies.  

```
 vagrant@netplugin-node1: netctl net create contiv-net -subnet="40.1.1.0/24"
vagrant@netplugin-node1: netctl policy create prod_web
vagrant@netplugin-node1: netctl policy rule-add prod_web 1 -direction=in -protocol=tcp -action=deny
vagrant@netplugin-node1: netctl policy rule-add prod_web 2 -direction=in -protocol=tcp -port=80 -action=allow -priority=10
vagrant@netplugin-node1: netctl policy rule-add prod_web 3 -direction=in -protocol=tcp -port=443 -action=allow -priority=10
vagrant@netplugin-node1: netctl group create contiv-net web -policy=prod_web

```

##Step 5: Now that infrastructure is setup . Create a job file and schedule tasks

```
nomad init
```

This would create an example.nomad file that we will use to deploy containers in a network. Change the docker driver config in the file to specify a network containers need to be attached to. If the network has a policy group attached to it then the format is epgname.network. If the container needs to be attached to a network without any policies set network_mode=network_name.

**example.nomad**
```
              # Use Docker to run the task.
                        driver = "docker"

                        # Configure Docker driver with the image
                        config {
                                image = "redis:latest"
                                port_map {
                                        db = 6379
                                }
                                network_mode="web.contiv-net"
                        }
```

```
vagrant@netplugin-node1:nomad run -address=http://192.168.2.10:4646 example.nomad
```

##Step 6: Verify endpoints for containers are allocated ip address from the network created. 

```
vagrant@netplugin-node2:~$ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                                                  NAMES
5d5522b9ae0a        redis:latest        "/entrypoint.sh redis"   28 seconds ago      Up 26 seconds       10.0.2.15:58847->6379/tcp, 10.0.2.15:58847->6379/udp   redis-5d46fa82-fcc4-53cc-cf08-059417217e59
```

```
vagrant@netplugin-node1:/tmp$ docker network ls
NETWORK ID          NAME                DRIVER
0c242226aa20        web.contiv-net      netplugin           
222c44a4380b        contiv-net          netplugin           
f28f834efacf        bridge              bridge              
fc1f63732ca8        none                null                
a4f246e21bb9        host                host
```

```
vagrant@netplugin-node2:~$ docker network inspect web.contiv-net
[
    {
        "Name": "web.contiv-net",
        "Id": "0c242226aa20bfb693d6fda89f7eb6ca3f68909b056d6178a4d9c7186c5942ed",
        "Scope": "global",
        "Driver": "netplugin",
        "IPAM": {
            "Driver": "netplugin",
            "Config": [
                {
                    "Subnet": "40.1.1.0/24"
                }
            ]
        },
        "Containers": {
            "5d5522b9ae0a257707eecf05ff5beb6ee939a9c34b85254134ea0a3197427c1f": {
                "EndpointID": "256aadcb73b1b96ce690d69d2fb044aef89f19b3dd8325242958fbb44b1ec4e8",
                "MacAddress": "",
                "IPv4Address": "40.1.1.4/24",
                "IPv6Address": ""
            }
        },
        "Options": {
            "encap": "vxlan",
            "pkt-tag": "1",
            "tenant": "default"
        }
    }
]
```
```
vagrant@netplugin-node2:/tmp$ docker inspect 5d5522b9ae0a

        "Networks": {
            "web.contiv-net": {
                "EndpointID": "256aadcb73b1b96ce690d69d2fb044aef89f19b3dd8325242958fbb44b1ec4e8",
                "Gateway": "",
                "IPAddress": "40.1.1.4",
                "IPPrefixLen": 24,
                "IPv6Gateway": "",
                "GlobalIPv6Address": "",
                "GlobalIPv6PrefixLen": 0,
                "MacAddress": ""
            }
        }
    }
}
]
```


[workspace]: <https://github.com/contiv/netplugin>
[Clone]: <https://github.com/contiv/netplugin#step-1-clone-the-project-and-bringup-the-vms>
[contiv docs]: <http://contiv.github.io/docs/3_netplugin.html>

