## DIY Guide for Contiv Networking

### Pre-requisites
1. You need Ubuntu 15.04 or higher on each of your servers used for the Contiv cluster.

2. If your servers are behind an http proxy (usually the case in many cisco labs...), you need
   to do "export http_proxy=<proxy url>" and "export https_proxy=<proxy_url>" in your shell

3. You will select and use on server to initate installation on all servers in the cluster.
   Please refrain from running install from multiple servers. Instead, stick to the same server to initiate
   installation.

4. It is recommended that you enable passwordless SSH access from the selected server to all
   the other servers in the cluster.
   An example of how to set this up is [here](http://www.linuxproblem.org/art_9.html)

5. It is recommended that you enable passwordless sudo on all servers as well.
   Example set up instructions can be found [here](http://askubuntu.com/questions/192050/how-to-run-sudo-command-with-no-password)

6. Get the IP addresses (dns names work as well) of all the servers and the network interface on which this IP address is configured

### Step1: Download the installer script
Log into one of the servers and download the installer script using the following command:
- `wget https://raw.githubusercontent.com/contiv/demo/master/net/net_demo_installer`

Note that if you are behind a proxy, you may need to set `https_proxy` environment variable
for it to work.

### Step2: Provide executable privileges and run installer script
- `chmod +x net_demo_installer`
- Run net_demo_installer script. NOTE: Provide the network interface information on which the IP is configured (as mentioned in Step 6 of pre-requisites). If no interface is specified, the script determines and uses the default network interface used by ansible:

         `./net_demo_installer <server1_ip_or_dns>[:<server1_nw_if>] <server2_ip_or_dns>[:<server2_nw_if>] . . .`
- The installer script will ask for username/password if passwordless ssh is not set during the installation

### Under the hoods
The installer script performs the following actions:
- performs preliminary checks to verify that the right version of OS is installed on the servers
- verifies that access to the servers can be established
- creates the ansible inventory file 
- establishes variables necessary for the servers to be provisioned in the appropriate mode
- runs the ansible playbook which installs necessary packages and brings up the services

### Troubleshooting
The current limitations of the script are as follows:
- The installer script is assumed to run from one of the server nodes in the cluster. This approach ensures that the required packages are installed only on the necessary nodes.
- Connections to the servers are assumed to be on the default ssh port and the default username used is the local hostname

The script generates many files for bookkeeping during the installation procedure. 
These files can be found under .gen folder in your installer directory. 
If you need to clear these files and start from a clean slate, use could use the following command:

            `./net_demo_installer -c`

This will list the files that will be cleared up and prompt you for confirmation to proceed.

If you find any other issues or have suggestions for improvement, please feel free to suggest/contribute.
