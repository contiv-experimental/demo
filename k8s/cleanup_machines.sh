#!/bin/bash
# Use this script to cleanup a machine after partial or full install
# You need to edit cleanup_list to contain the management ip of hosts you want to clean up

USAGE="cleanup_machines.sh <ssh_username>"
if [ $# -lt 1 ]; then
    echo $USAGE
    exit 1
fi

username=$1
top_dir=$PWD

# run ansible
ansible-playbook -kK -i cleanup_list $top_dir/cleanup.yml -e "ssh_username=$username"
