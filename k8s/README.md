####Pre-requisites
Machines running CentOS 7.2, connected to network, with at least two
interfaces (3 if possible).

Before starting, please be sure to set http/https proxies if your network requires it.
*(Note that https_proxy should be set to point to a http:// URL (not https://).
This is an ansible requirement.)*

Pick a machine that is on the management network and has ansible installed
to run the following steps.

###Step 1 Clone this repo
```
git clone https://github.com/contiv/demo
```

###Step 2 Clone the contrib repo
```
cd demo/k8s;

git clone https://github.com/jojimt/contrib -b contiv
```


###Step 3 Fill in cluster info
edit cluster_defs.json

See cluster_defs.json.README for instructions

###Step 4 Prepare machines
Create an rsa key and save in cwd as id_rsa.pub.

```
ssh-keygen -t rsa

./prepare.sh
```

###Step 5 Create cluster
```
./setup_k8s_cluster.sh
```

###Step 6 Verify cluster
```
./verify_cluster.sh
```
