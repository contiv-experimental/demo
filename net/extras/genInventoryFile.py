#!/usr/bin/python

import sys
import yaml

NW_MODE_STANDALONE = 'standalone'
NW_MODE_ACI = 'aci'

class SafeDict(dict):
    'Provide a default value for missing keys'
    def __missing__(self, key):
        return 'missing'

class Inventory:
    groupName = "netplugin-node"

    def __init__(self, args):
        self.cfgFile = args[0]
        self.inventoryFile = args[1]
        self.nodeInfoFile = args[2]
        self.networkMode = args[3].lower()
        self.fwdMode = args[4]
    def parseConfigFile(self):
        with open(self.cfgFile) as inFd:
            config = yaml.load(inFd)
        self.configInfo = SafeDict(config)

    def handleMissing(self, item, holder, fd):
        print "ERROR No entry for {} in {}".format(item, holder)
        fd.close()
        sys.exit(1)

    def writeInventoryEntry(self, outFd, config):
        if self.configInfo[config] is 'missing':
            self.handleMissing(config, self.cfgFile, outFd);
        else:
            cfg_entry = "{}={}\n".format(config.lower(), self.configInfo[config])
            outFd.write(cfg_entry)

    def writeInventory(self, outFd):
        outFd.write("[" + Inventory.groupName + "]\n")
        self.nodeCount = 1
        connInfo = SafeDict(self.configInfo['CONNECTION_INFO'])

        # Add host entries in the inventory file
        for node in connInfo:
            var_line = "node{} ".format(self.nodeCount)
            outFd.write(var_line)
            var_line = "ansible_ssh_host={} ".format(node)
            outFd.write(var_line)
            var_line = "contiv_network_mode={} ".format(self.networkMode)
            outFd.write(var_line)
            var_line = "control_interface={} ".format(connInfo[node]['control'])
            outFd.write(var_line)
            var_line = "netplugin_if={} ".format(connInfo[node]['data'])
            outFd.write(var_line)
            var_line = "fwd_mode={}\n".format(self.fwdMode)
            outFd.write(var_line)

            self.nodeCount += 1

        self.nodeCount -= 1

        # write group vars if network mode is ACI
        if self.networkMode == NW_MODE_ACI:
            outFd.write("[" + Inventory.groupName + ":vars]\n")
            self.writeInventoryEntry(outFd, 'APIC_URL')
            self.writeInventoryEntry(outFd, 'APIC_USERNAME')
            self.writeInventoryEntry(outFd, 'APIC_PASSWORD')
            self.writeInventoryEntry(outFd, 'APIC_PHYS_DOMAIN')
            self.writeInventoryEntry(outFd, 'APIC_EPG_BRIDGE_DOMAIN')
            self.writeInventoryEntry(outFd, 'APIC_CONTRACTS_UNRESTRICTED_MODE')

            if self.configInfo['APIC_LEAF_NODES'] is 'missing':
                self.handleMissing("APIC_LEAF_NODES", self.cfgFile, outFd);

            if self.configInfo['APIC_LEAF_NODES'] is None:
                self.handleMissing("APIC_LEAF_NODES", self.cfgFile, outFd);
            else:
                leafCount = 0
                leafStr = "apic_leaf_nodes="
                for leaf in self.configInfo['APIC_LEAF_NODES']:
                    if leafCount > 0:
                        leafStr += ","

                    leafStr += leaf
                    leafCount += 1

                # if no leaf was found, treat as error
                if leafCount == 0:
                    self.handleMissing("APIC_LEAF_NODES", self.cfgFile, outFd);
                
                leafStr += "\n"
                outFd.write(leafStr)

    def writeNodeInfo(self):
        with open(self.nodeInfoFile, "w+") as nodeInfoFd:
            node_info = "{}".format(self.nodeCount)
            nodeInfoFd.write(node_info)

    def writeInventoryFile(self):
        with open(self.inventoryFile, "w+") as outFd:
            self.writeInventory(outFd)

if __name__ == "__main__":
    inv = Inventory(sys.argv[1:])

    inv.parseConfigFile()

    inv.writeInventoryFile()

    inv.writeNodeInfo()
