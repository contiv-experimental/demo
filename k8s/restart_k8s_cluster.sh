#!/bin/bash

# kubernetes version to use -- defaults to v1.1.4
: ${k8sVer:=v1.1.4}

# contiv version
: ${contivVer:=v0.1-03-16-2016.13-43-59.UTC}

top_dir=$PWD

# run ansible
ansible-playbook -kK -i .contiv_k8s_inventory $top_dir/contrib/ansible/cluster.yml --tags "contiv_restart" -e "networking=contiv localBuildOutput=$top_dir/k8s-$k8sVer/kubernetes/server/bin contiv_bin_path=$top_dir/contiv_bin etcd_peers_group=masters"
