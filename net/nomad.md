```
vagrant@netplugin-node1:/tmp$ nomad node-status -address=http://192.168.2.10:4646
    2016/03/16 04:53:03 [DEBUG] http: Request /v1/nodes (117.577µs)
ID        Datacenter  Name             Class  Drain  Status
fcca53eb  dc1         netplugin-node2  foo    false  ready
1233ef56  dc1         netplugin-node1  foo    false  ready
```
