## DIY Guide for Contiv Networking with Cisco ACI

### Pre-requisites
- ACI Configuration and connectivity must be done before
- Connect Leafs to the servers
- Servers (or VMs) must be installed with Ubuntu 15.04 (RHEL support coming soon)

### Step1: Download the installer script
Log into one of the servers and download the installer script using the following command:
- `wget https://cisco.box.com/shared/static/29i1k4mleor9k050g3jcjgta6dczvd8n.tgz`
Note that if you are behind a proxy, you may need to set `https_proxy` environment variable
for it to work.

### Step2: Untar the script
- `tar xvzf 29i1k4mleor9k050g3jcjgta6dczvd8n.tgz`
It will create acidemo directory, which has a README file, an installer script, and a sample aci_cfg.yml

### Step3: Provide ACI Configuration and run installer script
- `cd acidemo`
- Fill in aci_cfg.yml according to README file 
- Run aci_demo_installer script according to README file:
`./aci_demo_installer <server_1_ip_or_dns> <server_2_ip_or_dns> . . .`
- The installer script will ask for username/password if passwordless ssh is not set during the installation
