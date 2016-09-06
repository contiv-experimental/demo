#!/bin/bash
#Copyright 2016 Cisco Systems Inc. All rights reserved.
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#http://www.apache.org/licenses/LICENSE-2.0
#
#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.

DIR_PREFIX=.ansible_
ans_roles=( "Stouts.iptables:1.1.1:${DIR_PREFIX}iptables"       # iptables
            "ansible-etcd:v1.2:${DIR_PREFIX}etcd"                # etcd
            "ansible-ovs:v0.1.0:${DIR_PREFIX}ovs"               # ovs
            "ansible-contivnet:v0.1.1:${DIR_PREFIX}contivnet"   # contiv
            "ansible-zookeeper:v0.12.0:${DIR_PREFIX}zookeeper"  # zookeeper
            "ansible-java:0.1.4:${DIR_PREFIX}java"              # java
            "ansible-mesos:v0.5.0:${DIR_PREFIX}mesos"          # mesos
            "ansible-marathon:v0.3.5:${DIR_PREFIX}marathon"     # marathon
          )

die() {
  echo $@ && exit 1
}

# my version of ansible-galaxy
install_roles() {
  for RL1 in ${ans_roles[@]}
  do
    REPO=($(echo ${RL1} | sed 's/:/ /g'))
    URL=https://github.com/rchirakk/${REPO[0]}/archive/${REPO[1]}.tar.gz
    rm -rf ${REPO[2]}
    mkdir -p ${REPO[2]} && curl -sL ${URL} | tar -C ${REPO[2]} -xz --strip-components=1 || die "failed to get ${URL}"
  done
}

remove_roles() {
  for RL1 in ${ans_roles[@]}
  do
    REPO=($(echo ${RL1} | sed 's/:/ /g'))
    rm -rf ${REPO[2]}
  done
}

# main
install_roles 

# run playbook
ansible-playbook -i inventory $@ cluster.yml

# cleanup
remove_roles
