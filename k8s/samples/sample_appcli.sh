#!/bin/bash
# Sample script to perform contiv cli configuration with ACI integration

# Function to get user confirmation to proceed
function ConfirmPrompt {
  set +v
  while true; do
  read -p "Ready to proceed(y/n)? " choice
  if [ "$choice" == "y" ]; then
      break
  fi

  if [ "$choice" == "n" ]; then
      echo "Try again when you are ready."
      exit 1
  else
      echo "Please answer y or n"
      continue
  fi
  done
  set -v
}

# Specify the correct vlan range here...
netctl global set --fabric-mode aci --vlan-range 100-500
netctl global info

ConfirmPrompt

# Create a tenant named bevco
netctl tenant create bevco
netctl tenant ls

# Choose the subnet you like...

netctl net create -t bevco -e vlan -s 66.1.1.1/24 -g 66.1.1.254 bevco-net1
netctl net ls -t bevco

ConfirmPrompt

netctl policy create -t bevco app2db
netctl group create -t bevco -p app2db bevco-net1 sugardb
netctl group create -t bevco bevco-net1 sodaapp
netctl policy rule-add -t bevco -d in --protocol tcp --port 6379 --from-group sodaapp -n bevco-net1 --action al
low app2db 1

ConfirmPrompt

netctl app-profile create -t bevco -g sodaapp,sugardb bevco-net1 store-profile
netctl app-profile ls -t bevco

# At this point, you will see the app profile created in ACI
# In order to use this policy, set the io.contiv labels in your kubernetes objects
# e.g. 
#        io.contiv.tenant: bevco
#        io.contiv.network: bevco-net1
#        io.contiv.net-group: sodaapp
# see samples/*.yaml for some examples
