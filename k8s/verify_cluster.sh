#!/bin/bash
ansible-playbook -kK --inventory-file=.contiv_k8s_inventory verify.yml
